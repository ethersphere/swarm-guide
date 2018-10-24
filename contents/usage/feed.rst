Feeds 
========================

.. note::
  Feeds, previously known as *Mutable Resource Updates*, is an experimental feature, available since Swarm POC3. It is under active development, so expect things to change.

Since Swarm hashes are content addressed, changes to data will constantly result in changing hashes. Swarm Feeds provide a way to easily overcome this problem and provide a single, persistent, identifier to follow sequential data.

The usual way of keeping the same pointer to changing data is using the Ethereum Name Service (ENS). However, since ENS is an on-chain feature, it might not be suitable for each use case since:

1. Every update to an ENS resolver will cost gas to execute
2. It is not be possible to change the data faster than the rate that new blocks are mined
3. ENS resolution requires your node to be synced to the blockchain


Swarm Feeds provide a way to have a persistent identifier for changing data without having to use ENS. It is named Feeds for its similarity with a news feed.

If you are using *Feeds* in conjunction with an ENS resolver contract, only one initial transaction to register the "Feed manifest address" will be necessary. This key will resolve to the latest version of the Feed (updating the Feed will not change the key).

You can think of a Feed as a user's Twitter account, where he/she posts updates about a particular Topic. In fact, the Feed object is simply defined as:

.. code-block:: go

  type Feed struct {
    Topic Topic
    User  common.Address
  }

That is, a specific user posting updates about a specific Topic.

Users can post to any topic. If you know the user's address and agree on a particular Topic, you can then effectively "follow" that user's Feed.

.. important::
  How you build the Topic is entirely up to your application. You could calculate a hash of something and use that, the recommendation
  is that it should be easy to derive out of information that is accesible to other users.
  
  For convenience, ``feed.NewTopic()`` provides a way to "merge" a byte array with a string in order to build a Feed Topic out of both.
  This is used at the API level to create the illusion of subtopics. This way of building topics allows to use a random byte array (for example the hash of a photo)
  and merge it with a human-readable string such as "comments" in order to create a Topic that could represent the comments about that particular photo.
  This way, when you see a picture in a website you could immediately build a Topic out of it and see if some user posted comments about that photo.

Feeds are not created, only updated. If a particular Feed (user, topic combination) has never posted to, trying to fetch updates will yield nothing.

Feed Manifests
--------------


A Feed Manifest is simply a JSON object that contains the ``Topic`` and ``User`` of a particular Feed (i.e., a serialized ``Feed`` object). Uploading this JSON object to Swarm in the regular way will return the immutable hash of this object. We can then store this immutable hash in an ENS Resolver so that we can have a ENS domain that "follows" the Feed described in the manifest.

Feeds API
---------

There  are 3 different ways of interacting with *Feeds* : HTTP API, Golang API and Swarm CLI.

HTTP API
~~~~~~~~

Posting to a Feed
.................

Since Feed updates need to be signed, and an update has some correlation with a previous update, it is necessary to retrieve first the Feed's current status. Thus, the first step to post an update will be to retrieve this current status in a ready-to-sign template:

1. Get Feed template

``GET /bzz-feed:/?topic=<TOPIC>&user=<USER>&meta=1``

``GET /bzz-feed:/<MANIFEST OR ENS NAME>/?meta=1``


Where:
 + ``user``: Ethereum address of the user who publishes the Feed
 + ``topic``: Feed topic, encoded as a hex string. Topic is an arbitrary 32-byte string (64 hex chars)

.. note::
  + If ``topic`` is omitted, it is assumed to be zero, 0x000...
  + if ``name=<name>`` (optional) is provided, a subtopic is composed with that name
  + A common use is to omit topic and just use ``name``, allowing for human-readable topics

You will receive a JSON like the below:

.. code-block:: js
 
  {
    "view": {
      "topic": "0x6a61766900000000000000000000000000000000000000000000000000000000",
      "user": "0xdfa2db618eacbfe84e94a71dda2492240993c45b"
    },
    "epoch": {
      "level": 16,
      "time": 1534237239
    }
    "protocolVersion" : 0,
  }

2. Post the update

Extract the fields out of the JSON and build a query string as below:

``POST /bzz-feed:/?topic=<TOPIC>&user=<USER>&level=<LEVEL>&time=<TIME>&signature=<SIGNATURE>``

Where:
 + ``topic``: Feed topic, as specified above
 + ``user``: your Ethereum address
 + ``level``: Suggested frequency level retrieved in the JSON above
 + ``time``: Suggested timestamp retrieved in the JSON above
 + ``protocolVersion``: Feeds protocol version. Currently ``0``
 + ``signature``: Signature, hex encoded. See below on how to calclulate the signature
 + Request posted data: binary stream with the update data


Reading a Feed
..............

To retrieve a Feed's last update:

``GET /bzz-feed:/?topic=<TOPIC>&user=<USER>``

``GET /bzz-feed:/<MANIFEST OR ENS NAME>``

.. note::

  + Again, if ``topic`` is omitted, it is assumed to be zero, 0x000...
  + If ``name=<name>`` is provided, a subtopic is composed with that name
  + A common use is to omit ``topic`` and just use ``name``, allowing for human-readable topics, for example:      
    ``GET /bzz-feed:/?name=profile-picture&user=<USER>``


To get a previous update:

Add an addtional ``time`` parameter. The last update before that ``time`` (unix time) will be looked up.

``GET /bzz-feed:/?topic=<TOPIC>&user=<USER>&time=<T>``

``GET /bzz-feed:/<MANIFEST OR ENS NAME>?time=<T>``

Creating a Feed Manifest
........................

To create a ``Feed manifest`` using the HTTP API:

``POST /bzz-Feed:/?topic=<TOPIC>&user=<USER>&manifest=1.`` With an empty body. 

This will create a manifest referencing the provided Feed.

.. note::
  This API call will be deprecated in the near future.

Go API
~~~~~~~~

Query object
.................

The ``Query`` object allows you to build a query to browse a particular ``Feed``.

The default ``Query``, obtained with ``feed.NewQueryLatest()`` will build a ``Query`` that retrieves the latest update of the given ``Feed``.

You can also use ``feed.NewQuery()`` instead, if you want to build a ``Query`` to look up an update before a certain date.

Advanced usage of ``Query`` includes hinting the lookup algorithm for faster lookups. The default hint ``lookup.NoClue`` will have your node track Feeds you query frequently and handle hints automatically.

Request object
.................

The ``Request`` object makes it easy to construct and sign a request to Swarm to update a particular Feed. It contains methods to sign and add data. We can  manually build the ``Request`` object, or fetch a valid "template" to use for the update.

A ``Request`` can also be serialized to JSON in case you need your application to delegate signatures, such as having a browser sign a Feed update request.

Posting to a Feed
.................

1. Retrieve a ``Request`` object or build one from scratch. To retrieve a ready-to-sign one: 

.. code-block:: go
  
  func (c *Client) GetFeedRequest(query *feed.Query, manifestAddressOrDomain string) (*feed.Request, error)

2. Use ``Request.SetData()`` and ``Request.Sign()`` to load the payload data into the request and sign it

3. Call ``UpdateFeed()`` with the filled ``Request``:

.. code-block:: go
  
  func (c *Client) UpdateFeed(request *feed.Request, createManifest bool) (io.ReadCloser, error) 




Reading a Feed
..............

To retrieve a Feed update, use `client.QueryFeed()`. ``QueryFeed`` returns a byte stream with the raw content of the Feed update.  

.. code-block:: go

  func (c *Client) QueryFeed(query *feed.Query, manifestAddressOrDomain string) (io.ReadCloser, error)


``manifestAddressOrDomain`` is the address you obtained in ``CreateFeedWithManifest`` or an ``ENS`` domain whose Resolver
points to that address.
``query`` is a Query object, as defined above.

You only need to provide either ``manifestAddressOrDomain`` or ``Query`` to ``QueryFeed()``. Set to ``""`` or ``nil`` respectively.


Creating a Feed Manifest
........................

Swarm client (package swarm/api/client) has the following method:

.. code-block:: go 
  
  func (c *Client) CreateFeedWithManifest(request *feed.Request) (string, error) 

``CreateFeedWithManifest`` uses the ``request`` parameter to set and create a  ``Feed manifest``.

Returns the resulting ``Feed manifest address`` that you can set in an ENS Resolver (setContent) or reference future updates using ``Client.UpdateFeed()``

Example Go code
...............

.. code-block:: go

  // Build a `Feed` object to track a particular user's updates
  f := new(feed.Feed)
  f.User = signer.Address()
  f.Topic, _ = feed.NewTopic("weather",nil)

  // Build a `Query` to retrieve a current Request for this feed
  query := feeds.NewQueryLatest(&f, lookup.NoClue)

  // Retrieve a ready-to-sign request using our query
  // (queries can be reused)
  request, err := client.GetFeedRequest(query, "")
  if err != nil {
      utils.Fatalf("Error retrieving feed status: %s", err.Error())
  }

  // set the new data
  request.SetData([]byte("Weather looks bright and sunny today, we should merge this PR and go out enjoy"))

  // sign update
  if err = request.Sign(signer); err != nil {
      utils.Fatalf("Error signing feed update: %s", err.Error())
  }

  // post update
  err = client.UpdateFeed(request)
  if err != nil {
      utils.Fatalf("Error updating feed: %s", err.Error())
  }

Command-Line
~~~~~~~~~~~~~~~~

Posting to a Feed
.................

To update a Feed with the cli:

.. code-block:: none

 swarm feed update [command options] <0x Hex data>

 creates a new update on the specified topic
            The topic can be specified directly with the --topic flag as an hex string
            If no topic is specified, the default topic (zero) will be used
            The --name flag can be used to specify subtopics with a specific name.
            If you have a manifest, you can specify it with --manifest instead of --topic / --name
            to refer to the feed
   OPTIONS:
  --manifest value  Refers to the feed through a manifest
  --name value      User-defined name for the new feed, limited to 32 characters. If combined with topic, the feed will be a       subtopic with this name
  --topic value     User-defined topic this feed is tracking, hex encoded. Limited to 64 hexadecimal characters


Reading Feed status
...................

.. code-block:: none

  swarm feed info [command options] [arguments...]

  obtains information about an existing Swarm feed
            The topic can be specified directly with the --topic flag as an hex string
            If no topic is specified, the default topic (zero) will be used
            The --name flag can be used to specify subtopics with a specific name.
            The --user flag allows to refer to a user other than yourself. If not specified,
            it will then default to your local account (--bzzaccount)
            If you have a manifest, you can specify it with --manifest instead of --topic / --name / ---user
            to refer to the feed

  OPTIONS:
  --manifest value  Refers to the feed through a manifest
  --name value      User-defined name for the new feed, limited to 32 characters. If combined with topic, it will refer to a subtopic with this name
  --topic value     User-defined topic this feed is tracking, hex encoded. Limited to 64 hexadecimal characters
  --user value      Indicates the user who updates the feed



Creating a Feed Manifest
........................

The Swarm CLI allows to create Feed Manifests directly from the console:

``swarm feed create`` is defined as a command to create and publish a ``Feed manifest``.

.. code-block:: none

  swarm feed create [command options]

  creates and publishes a new feed manifest pointing to a specified user's updates about a particular topic.
            The feed topic can be built in the following ways:
            * use --topic to set the topic to an arbitrary binary hex string.
            * use --name to set the topic to a human-readable name.
                For example --name could be set to "profile-picture", meaning this feed allows to get this user's current profile picture.
            * use both --topic and --name to create named subtopics. 
              For example, --topic could be set to an Ethereum contract address and --name could be set to "comments", meaning
              this feed tracks a discussion about that contract.
            The --user flag allows to have this manifest refer to a user other than yourself. If not specified,
            it will then default to your local account (--bzzaccount)

  OPTIONS:
  --name value   User-defined name for the new feed, limited to 32 characters. If combined with topic, it will refer to a subtopic with this name
  --topic value  User-defined topic this feed is tracking, hex encoded. Limited to 64 hexadecimal characters
  --user value   Indicates the user who updates the feed


Computing Feed Signatures
-------------------------

1. computing the digest:

The digest is computed concatenating the following:
 +  1-byte protocol version (currently 0)
 +  7-bytes padding, set to 0
 +  32-bytes topic
 +  20-bytes user address
 +  7-bytes time, little endian
 +  1-byte level
 +  payload data (variable length)

2. Take the SHA3 hash of the above digest

3. Compute the ECDSA signature of the hash

4. Convert to hex string and put in the ``signature`` field above

JavaScript example
~~~~~~~~~~~~~~~~~~

.. code-block:: javascript

  var web3 = require("web3");

  if (module !== undefined) {
    module.exports = {
      digest: feedUpdateDigest
    }
  }

  var topicLength = 32;
  var userLength = 20;
  var timeLength = 7;
  var levelLength = 1;
  var headerLength = 8;
  var updateMinLength = topicLength + userLength + timeLength + levelLength + headerLength;




  function feedUpdateDigest(request /*request*/, data /*UInt8Array*/) {
    var topicBytes = undefined;
      var userBytes = undefined;
      var protocolVersion = 0;
    
      protocolVersion = request.protocolVersion

    try {
      topicBytes = web3.utils.hexToBytes(request.feed.topic);
    } catch(err) {
      console.error("topicBytes: " + err);
      return undefined;
    }

    try {
      userBytes = web3.utils.hexToBytes(request.feed.user);
    } catch(err) {
      console.error("topicBytes: " + err);
      return undefined;
    }

    var buf = new ArrayBuffer(updateMinLength + data.length);
    var view = new DataView(buf);
      var cursor = 0;
      
      view.setUint8(cursor, protocolVersion) // first byte is protocol version.
      cursor+=headerLength; // leave the next 7 bytes (padding) set to zero

    topicBytes.forEach(function(v) {
      view.setUint8(cursor, v);
      cursor++;
    });

    userBytes.forEach(function(v) {
      view.setUint8(cursor, v);
      cursor++;
    });
    
    // time is little-endian
    view.setUint32(cursor, request.epoch.time, true);
    cursor += 7;

    view.setUint8(cursor, request.epoch.level);
    cursor++;

    data.forEach(function(v) {
      view.setUint8(cursor, v);
      cursor++;
      });
      console.log(web3.utils.bytesToHex(new Uint8Array(buf)))

    return web3.utils.sha3(web3.utils.bytesToHex(new Uint8Array(buf)));
  }

  // data payload
  data = new Uint8Array([5,154,15,165,62])

  // request template, obtained calling http://localhost:8500/bzz-feed:/?user=<0xUSER>&topic=<0xTOPIC>&meta=1
  request = {"feed":{"topic":"0x1234123412341234123412341234123412341234123412341234123412341234","user":"0xabcdefabcdefabcdefabcdefabcdefabcdefabcd"},"epoch":{"time":1538650124,"level":25},"protocolVersion":0}

  // obtain digest
  digest = feedUpdateDigest(request, data)

  console.log(digest)
