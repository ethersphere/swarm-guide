Mutable Resource Updates
========================

.. note::
Mutable Resource Updates is a highly experimental feature, available from Swarm POC3. It is under active development, so expect things to change.

We have previously learned in this guide that when we make changes in data in Swarm, the hash returned when we upload that data will change in totally unpredictable ways. With *Mutable Resource Updates*, Swarm provides a built-in way of keeping a persistent identifier to changing data.

The usual way of keeping the same pointer to changing data is using the Ethereum Name Service ``ENS``. However, ``ENS`` is an on-chain feature, which limits functionality in some areas:

1. Every update to an ``ENS`` resolver will cost you gas to execute.
2. It is not be possible to change the data faster than the rate that new blocks are mined.
3. Correct ``ENS`` resolution requires that you are always synced to the blockchain.

With *Mutable Resource Updates* we no longer require the ``ENS`` in order to have a non-variable identifier to changing data. The resource can be accessed like a regular Swarm object using the key obtained when the resource was created ( ``MRU_MANIFEST_KEY`` ) .
When the data changes the ``MRU_MANIFEST_KEY`` will  point to the new data.

If using *Mutable Resource Updates* in conjunction with an ``ENS`` resolver contract, only one initial transaction to register the ``MRU_MANIFEST_KEY`` will be necessary. This key will resolve to the latest version of the resource (updating the resource will not change the key).

There  are 3 different ways of interacting with *Mutable Resource Updates* : HTTP API, Golang API and Swarm client.
We will now see how to create, retrieve and update a *Mutable Resource* 

Creating a Mutable Resource
----------------------------
.. important:: + Only the private key (address) that created the Resource can update it. 
               + When  creating a Mutable Resource, one of the parameters that you will have to provide is the expected update frequency. This indicates  how often (in seconds) your resource will be updated. Although you can update the resource at other rates, doing so will slow down the process of retrieving the resource. 

HTTP API
~~~~~~~~

To create a mutable resource using the HTTP API:
``POST /bzz-resource:/`` with the following JSON as payload:

.. code-block:: js

  "name": string,
  "frequency": number,
  "startTime": number,
  "ownerAddr": address
	
Where:

+ ``name`` Resource name. This is a user field. You can use any name.
+ ``frequency`` Time interval the resource is expected to update at, in seconds.
+ ``startTime`` Time the resource is valid from, in Unix time (seconds). Set to the current epoch. 
  
  + You can also put a startTime in the past or in the future. Setting it in the future will prevent nodes from finding content until the clock hits startTime. Setting it in the past allows you to create a history for the resource retroactively.


Returns the ``MRU_MANIFEST_KEY`` as a quoted string.

This only creates the resource. The resource will not return any data until a first update is submitted. You will usually create resources and initialize them. To do that, use the following:

``POST /bzz-resource:/`` with the following JSON as payload:

.. code-block:: js

  "name": string,
  "frequency": number,
  "startTime": number,
  "rootAddr" : hex string,
  "data": hex string,
  "multihash": bool,
  "period": number,
  "version": number,
  "signature": hex string 
	
Where:


+ ``rootAddr`` Key of the chunk that contains the Mutable Resource metadata. Calculated as the SHA3 hash of ``ownerAddr`` and ``metaHash``
+ ``multihash`` Is a flag indicating whether the data field should be interpreted as raw data or a multihash.
+ ``data`` Contains hex-encoded raw data or a multihash of the content the mutable resource will be initialized with.
+ ``period`` Indicates for what period we are signing. Set to 1 for creation.
+ ``version`` Indicates what resource version of the period we are signing. Must be set to 1 for creation.
+ ``signature`` Signature of the digest. Hex encoded. Prefixed with 0x. The signature is calculated as follows: digest = H(period, version, rootAddr, metaHash, multihash, data). Where: 

  + ``H()`` is the SHA3 algorithm.
  + ``period`` version are encoded as little-endian uint64
  + ``rootAddr`` is encoded as a 32 byte array
  + ``metaHash`` is encoded as a 32 byte array
  + ``multihash`` is encoded as the least significant bit of a flags byte
  + ``data`` is the plain data byte array.



Returns the ``MRU_MANIFEST_KEY`` as a quoted string. 

Go API
~~~~~~~~

Swarm client (package swarm/api/client) has the following method:

.. code-block:: go 
	
	CreateResource(request *mru.Request) (string, error)

CreateResource creates a Mutable Resource according to the data included in the Request parameter. 
To create a Request, use the mru.NewCreateRequest() function.

Returns the resulting ``MRU_MANIFEST_KEY`` that you can use to include in an ``ENS`` resolver (setContent) or reference future updates (Client.UpdateResource).

Swarm client
~~~~~~~~~~~~~

The swarm CLI allows to create Mutable Resources directly from the console:

.. code-block:: bash

  swarm --bzzaccount="<account>" resource create <frequency> [--name <name>] [--data <0x hex data> [--multihash=true/false]]
	
Where:

+ ``account`` Ethereum account needed to sign.
+ ``frequency`` Time interval the resource is expected to update at, in **seconds**.
+ ``multihash`` Is a flag indicating whether the data field should be interpreted as raw data or a multihash.
+ ``data`` Contains hex-encoded raw data or a multihash of the content the mutable resource will be initialized with. Must be prefixed with 0x, and if is a swarm keccak256 hash, with 0x1b20.

Returns the ``MRU_MANIFEST_KEY`` of the Mutable Resource

Retrieving a mutable resource
------------------------------
.. important::
  
  In order to retrieve a resource, it must have been initialized with data, and ``startTime < currentTime``.

HTTP API
~~~~~~~~
To retrieve a resource:

+ ``GET /bzz-resource://<MRU_MANIFEST_KEY>`` Get latest update
+ ``GET /bzz-resource://<MRU_MANIFEST_KEY>/<n>`` Get latest update on period n
+ ``GET /bzz-resource://<MRU_MANIFEST_KEY>/<n>/<m>`` Get update version m of period n 
+ ``GET /bzz-resource://<MRU_MANIFEST_KEY>/meta`` Returns the resource metadata

By using ``bzz-resource://`` you get the raw data that was put in the resource. If the resource data is a multihash, using ``bzz://`` will return the content pointed by the multihash,
whereas ``bzz-resource://``  returns the actual multihash.

.. note::

	This behaviour is expected to change 

Go API
~~~~~~~~
To retrieve a resource we use the following method

.. code-block:: go 

	GetResource(manifestAddressOrDomain string) (io.ReadCloser, error)

+ ``manifestAddressOrDomain`` Either the ``ENS`` domain or ``MRU_MANIFEST_KEY`` associated to the *Mutable Resource* 

Returns the latest data currently contained in the resource as an octect stream. 

Swarm console
~~~~~~~~~~~~~

The swarm console doesn't allow to retrieve a resource per se, however we can retrieve the metainfo:

.. code-block:: bash

  swarm resource info <MRU_MANIFEST_KEY>

This will output the resource's metainfo

Updating a mutable resource
----------------------------

HTTP API
~~~~~~~~

~~~~~~~~

Swarm client
~~~~~~~~~~~~~

Mutable resource versioning
----------------------------
As explained above, we need to specify a frequency parameter when we create a resource, which indicates the time in seconds that are expected to pass between each update. In Mutable Resources we call this the *period*. When you make an update, it will belong to the  *current period*.

Let's make this less obscure with some concrete examples:

* Mutable Resource is created at timestamp ``4200000`` with frequency ``100``.
* Update made at timestamp ``4200050``. Update will belong to period ``1``.
* Update made at timestamp ``4200110``. Update will belong to period ``2``.
* Update made at timestamp ``4200190``. Update will *also* belong to period ``2``.
* Update made at timestamp ``4200200``. Update will belong to period ``3``.

A resource can be updated more than once every period. Every update within the same period is a ``version``.

* Resource creation = period ``1`` version ``1`` = ``1.1``
* Timestamp ``4200050`` = period ``1`` version ``2`` = ``1.2``
* Timestamp ``4200110`` = period ``2`` version ``1`` = ``2.1``
* Timestamp ``4200190`` = period ``2`` version ``2`` = ``2.2``
* Timestamp ``4200200`` = period ``3`` version ``1`` = ``3.1``
