Feeds 
========================

.. note::
Feeds, previously known as *Mutable resource Updates*, is a experimental feature, available from Swarm POC3. It is under active development, so expect things to change.

We have previously learned in this guide that when we make changes in data in Swarm, the hash returned when we upload that data will change in totally unpredictable ways. With *Feeds*, Swarm provides a built-in way of keeping a persistent identifier to changing data.

The usual way of keeping the same pointer to changing data is using the Ethereum Name Service ``ENS``. However, ``ENS`` is an on-chain feature, which limits functionality in some areas:

1. Every update to an ``ENS`` resolver will cost you gas to execute.
2. It is not be possible to change the data faster than the rate that new blocks are mined.
3. Correct ``ENS`` resolution requires that you are always synced to the blockchain.

*Feeds* allows us to have a non-variable identifier to changing data without having to use the ``ENS``. 

If using *Feeds* in conjunction with an ``ENS`` resolver contract, only one initial transaction to register the ``Feed manifest address`` will be necessary. This key will resolve to the latest version of the feed (updating the feed will not change the key).


You can think of a Feed as a user's Twitter account, where he/she posts updates about a particular Topic. In fact, the Feed object is simply defined as:

.. code-block:: go

  type Feed struct {
    Topic Topic
    User  common.Address
  }

Users can post Feeds with any topic. If you know the user's address and agree on a particular topic, you can then effectively "follow" that user's feed.

There  are 3 different ways of interacting with *Feeds* : HTTP API, Golang API and Swarm CLI. We will now see how to create, retrieve and update Feeds.

Creating a Feed
----------------------------
.. important:: * Only the private key (address) that created the Feed can update it. 
              

HTTP API
~~~~~~~~

To create a Feed using the HTTP API:

``POST /bzz-feed:/?topic=<TOPIC>&user=<USER>&manifest=1.`` With an empty body. 

This will create an empty Feed ready to be updated


Go API
~~~~~~~~

Swarm client (package swarm/api/client) has the following method:

.. code-block:: go 
  
  func (c *Client) CreateFeedWithManifest(request *feed.Request) (string, error) 

``CreateFeedWithManifest`` uses the ``request`` parameter to set and create a ``feed manifest``.

Returns the resulting feed manifest address that you can set in an ENS Resolver (setContent) or reference future updates using ``Client.UpdateFeed``

The ``feed.Request`` type is defined as:

.. code-block:: go 
  
  type Request struct {
	Update     // actual content that will be put on the chunk, less signature
	Signature  *Signature
	idAddr     storage.Address // cached chunk address for the update (not serialized, for internal use)
	binaryData []byte          // cached serialized data (does not get serialized again!, for efficiency/internal use)
  }

Swarm CLI
~~~~~~~~~~~~~

The swarm CLI allows to create Feeds directly from the console:

``swarm feed create`` is redefined as a command line to create and publish a Feed manifest only, an "empty Feed".

``swarm feed create [command options]``

.. code-block:: bash

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

Add an addtional ``time`` parameter. The last update before that ``time`` will be looked up.

``GET /bzz-feed:/?topic=<TOPIC>&user=<USER>&time=<T>``

``GET /bzz-feed:/<MANIFEST OR ENS NAME>?time=<T>``


Go API
~~~~~~~~


The ``Query`` object allows you to build a query to browse a particular ``Feed``.

.. code-block:: go

  // Query is used to specify constraints when performing an update lookup
  type Query struct {
    Feed
    Hint      lookup.Epoch
    TimeLimit uint64    // TimeLimit indicates an upper bound for the search. Set to 0 for "now"

  }
  


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

To update the resource, create a new flat JSON with the following fields:

.. code-block:: js

  "data": hex string,
  "multihash": bool,
  "period": number,
  "version": number,
  "signature": hex string 
	
Where:

* ``data`` New data you want to set
* ``multihash`` Whether the new data should be considered a multihash
* ``period`` **See note below**
* ``version`` **See note below**
* ``signature`` Calculated in the same way as explained above for simultaneous resource creation and update

Then, POST the resulting JSON to: ``POST /bzz-resource:/``

.. note::

  To avoid any unexpected behaviour the ``period`` and ``version`` values of the update must be set to the recommended values obtained when doing ``GET /bzz-resource://<MRU_MANIFEST_KEY>/meta``.

Go API
~~~~~~~~
As with the HTTP API, we have to know the version and period that are valid for the update. To get this information we use :

.. code-block:: go

  GetResourceMetadata(manifestAddressOrDomain string) (*mru.Request, error)

Returns a ``mru.Request`` object that describes the resource and can be used to construct an update. To finish constructing the request for the update we need to: 

* Call ``Request.SetData()`` to put the new data in
* Call ``Request.Sign()`` to sign the update

Once we have our request fully constructed, we can update our resource by calling: 

.. code-block:: go

  UpdateResource(request *mru.Request)

Where ``request`` is the previously constructed request.

Swarm CLI
~~~~~~~~~~~~~
.. code-block:: none

  swarm --bzzaccount="<account>" resource update <Manifest Address or ENS domain> <0x Hexdata> [--multihash]

The ``--multihash`` flag sets multihash to true. By default the data is not considered to be a multihash.
As mentioned earlier, if you want to use the output of ``swarm up``, prefix it with ``0x1b20`` to indicate a keccak256 hash.

Mutable Resource versioning
----------------------------
