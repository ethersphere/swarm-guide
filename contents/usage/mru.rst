Feeds 
========================

.. note::
  Feeds, previously known as *Mutable resource Updates*, is a experimental feature, available from Swarm POC3. It is under active development, so expect things to change.

We have previously learned in this guide that when we make changes in data in Swarm, the hash returned when we upload that data will change in totally unpredictable ways. With *Feeds*, Swarm provides a built-in way of keeping a persistent identifier to changing data.

The usual way of keeping the same pointer to changing data is using the Ethereum Name Service ``ENS``. However, ``ENS`` is an on-chain feature, which limits functionality in some areas:

1. Every update to an ``ENS`` resolver will cost you gas to execute.
2. It is not be possible to change the data faster than the rate that new blocks are mined.
3. Correct ``ENS`` resolution requires that you are always synced to the blockchain.

Feeds allows us to have a non-variable identifier to changing data without having to use the ``ENS``. 

If using *Feeds* in conjunction with an ``ENS`` resolver contract, only one initial transaction to register the ``Feed manifest address`` will be necessary. This key will resolve to the latest version of the Feed (updating the Feed will not change the key).


You can think of a Feed as a user's Twitter account, where he/she posts updates about a particular Topic. In fact, the Feed object is simply defined as:

.. code-block:: go

  type Feed struct {
    Topic Topic
    User  common.Address
  }

Users can post to any topic. If you know the user's address and agree on a particular topic, you can then effectively "follow" that user's Feed.

There  are 3 different ways of interacting with *Feeds* : HTTP API, Golang API and Swarm CLI. We will now see how to create, retrieve and update Feeds.

Creating a Feed (Manifest)
----------------------------

Feeds are not created, only updated. If a particular Feed has never been updated, trying to fetch it will yield nothing.

What we can create is a ``Feed manifest``. A ``Feed manifest`` contains the ``topic`` and ``user`` of a particular Feed.
One use of this ``manifest``, is to include its ``address`` in a ``ENS`` Resolver, which allows to have a ENS domain
that "follows" the Feed described in the manifest.

HTTP API
~~~~~~~~

To create a ``Feed manifest`` using the HTTP API:

``POST /bzz-Feed:/?topic=<TOPIC>&user=<USER>&manifest=1.`` With an empty body. 

This will create a manifest referencing the provided Feed

Go API
~~~~~~~~

Swarm client (package swarm/api/client) has the following method:

.. code-block:: go 
  
  func (c *Client) CreateFeedWithManifest(request *feed.Request) (string, error) 

``CreateFeedWithManifest`` uses the ``request`` parameter to set and create a  ``Feed manifest``.

Returns the resulting ``Feed manifest address`` that you can set in an ENS Resolver (setContent) or reference future updates using ``Client.UpdateFeed``

The ``feed.Request`` type is defined as:



Swarm CLI
~~~~~~~~~~~~~

The swarm CLI allows to create Feed Manifests directly from the console:

``swarm feed create`` is redefined as a command line to create and publish a ``Feed manifest``.

.. code-block:: bash

  swarm feed create [command options]

  creates and publishes a new Feed manifest pointing to a specified user's updates about a particular topic.
          The topic can be specified directly with the --topic flag as an hex string
          If no topic is specified, the default topic (zero) will be used
          The --name flag can be used to specify subtopics with a specific name
          The --user flag allows to have this manifest refer to a user other than yourself. If not specified,
          it will then default to your local account (--bzzaccount)

  OPTIONS:
    --name value   User-defined name for the new resource, limited to 32 characters. If combined with topic, the resource will be a subtopic with this name
    --topic value  User-defined topic this resource is tracking, hex encoded. Limited to 64 hexadecimal characters
    --user value   Indicates the user who updates the resource	


Retrieving a Feed
------------------------------
HTTP API
~~~~~~~~
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


Go API
~~~~~~~~


The ``Query`` object allows you to build a query to browse a particular ``Feed``.

The default ``Query``, obtained with ``feed.NewQueryLatest()`` will build a ``Query`` that retrieves the latest update of the given ``Feed``.

You can also use ``feed.NewQuery()`` instead, if you want to build a ``Query`` to look up an update before a certain date.

Advanced usage of ``Query`` includes hinting the lookup algorithm for faster lookups. The default hint ``lookup.NoClue`` will have your node track feeds you query frequently and handle hints automatically.

We can then use the ``Query`` with: 

.. code-block:: go

  func (c *Client) QueryFeed(query *feed.Query, manifestAddressOrDomain string) (io.ReadCloser, error)

``QueryFeed`` returns a byte stream with the raw content of the feed update.  

``manifestAddressOrDomain`` is the address you obtained in ``CreateFeedWithManifest`` or an ``ENS`` domain whose Resolver
points to that address.


Updating a Feed
----------------------------

HTTP API
~~~~~~~~
To publish an update we first need to get some metainfromation about the Feed:

1.- Get resource metainformation

``GET /bzz-feed:/?topic=<TOPIC>&user=<USER>&meta=1``

``GET /bzz-feed:/<MANIFEST OR ENS NAME>/?meta=1``


Where:
 + ``user``: Ethereum address of the user who publishes the resource
 + ``topic``: Resource topic, encoded as a hex string.

.. note::
  + If topic is omitted, it is assumed to be zero, 0x000...
  + if name=<name> is provided, a subtopic is composed with that name
  + A common use is to omit topic and just use name, allowing for human-readable topics.

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
  }

2.- Post the update

Extract the fields out of the JSON and build a query string as below:

``POST /bzz-resource:/?topic=<TOPIC>&user=<USER>&level=<LEVEL>&time=<TIME>&signature=<SIGNATURE>``

Where:
 + ``body``: binary stream with the update data.



Go API
~~~~~~~~

With the go library we can update a Feed using:

.. code-block:: go
  
  func (c *Client) updateFeed(request *feed.Request, createManifest bool) (io.ReadCloser, error) 

We can  manually build the request parameter, or fetch a valid "template" to use for the update:

.. code-block:: go
  
  func (c *Client) GetFeedRequest(query *feed.Query, manifestAddressOrDomain string) (*feed.Request, error)



Swarm CLI
~~~~~~~~~~~~~

To update a Feed with the cli:

.. code-block:: none

  swarm resource update [command options] <0x Hex data>

  creates a new update on the specified topic
            The topic can be specified directly with the --topic flag as an hex string
            If no topic is specified, the default topic (zero) will be used
            The --name flag can be used to specify subtopics with a specific name.
            If you have a manifest, you can specify it with --manifest instead of --topic / --name
            to refer to the resource

  OPTIONS:
  --manifest value  Refers to the resource through a manifest
  --name value      User-defined name for the new resource, limited to 32 characters. If combined with topic, the resource will be a subtopic with this name
  --topic value     User-defined topic this resource is tracking, hex encoded. Limited to 64 hexadecimal characters




You can find more information about Feeds in  : https://github.com/ethereum/go-ethereum/pull/17559

