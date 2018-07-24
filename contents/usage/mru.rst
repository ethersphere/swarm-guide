Mutable Resource Updates
========================

.. note::
Mutable Resource Updates is a highly experimental feature, available from Swarm POC3. It is under active development, so expect things to change.

We have previously learned in this guide that when we make changes in data in Swarm, the hash returned when we upload that data will change in totally unpredictable ways. With *Mutable Resource Updates*, Swarm provides a built-in way of keeping a persistent identifier to changing data.

The usual way of keeping the same pointer to changing data is using the Ethereum Name Service ``ENS``. However, ``ENS`` is an on-chain feature, which limits functionality in some areas:

1. Every update to an ``ENS`` resolver will cost you gas to execute.
2. It is not be possible to change the data faster than the rate that new blocks are mined.
3. Correct ``ENS`` resolution requires that you are always synced to the blockchain.

With *Mutable Resource Updates* we no longer require the ``ENS`` in order to have a non-variable identifier to changing data. The resource can be referenced like a regular Swarm object, using the key obtained when the resource was created ( ``MRU_MANIFEST_KEY`` ) .
When the resource's data is updated the ``MRU_MANIFEST_KEY`` will  point to the new data.

If using *Mutable Resource Updates* in conjunction with an ``ENS`` resolver contract, only one initial transaction to register the ``MRU_MANIFEST_KEY`` will be necessary. This key will resolve to the latest version of the resource (updating the resource will not change the key).

There  are 3 different ways of interacting with *Mutable Resource Updates* : HTTP API, Golang API and Swarm CLI.

We will now see how to create, retrieve and update a *Mutable Resource* 

Creating a Mutable Resource
----------------------------
.. important:: * Only the private key (address) that created the Resource can update it. 
               * When  creating a Mutable Resource, one of the parameters that you will have to provide is the expected update frequency. This indicates  how often (in seconds) your resource will be updated. Although you can update the resource at other rates, doing so will slow down the process of retrieving the resource. 

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

* ``name`` Resource name. This is a user field. You can use any name.
* ``frequency`` Expected time interval between updates, in seconds.
* ``startTime`` Time the resource is valid from, in Unix time (seconds). Set to the current epoch. 
  
  * You can also put a startTime in the past or in the future. Setting it in the future will prevent nodes from finding content until the clock hits startTime. Setting it in the past allows you to create a history for the resource retroactively.


Returns the ``MRU_MANIFEST_KEY`` as a quoted string.

This only creates the resource, which will not return any data until a first update is submitted. You will usualy create and initialize the resource at once. To do so: 

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


* ``rootAddr`` Key of the chunk that contains the Mutable Resource metadata. Calculated as the SHA3 hash of ``ownerAddr`` and ``metaHash``
* ``data`` Content the mutable resource will be initialized with. Contains hex-encoded raw data or a multihash
* ``multihash`` Is a flag indicating whether the data field should be interpreted as raw data or a multihash.
* ``period`` Indicates for what period we are signing. Set to 1 for creation.
* ``version`` Indicates what resource version of the period we are signing. Must be set to 1 for creation.
* ``signature`` Signature of the digest. Hex encoded. Prefixed with 0x. The signature is calculated as follows: digest = H(period, version, rootAddr, metaHash, multihash, data). Where: 

  * ``H()`` is the SHA3 algorithm.
  * ``period`` version are encoded as little-endian uint64
  * ``rootAddr`` is encoded as a 32 byte array
  * ``metaHash`` is encoded as a 32 byte array
  * ``multihash`` is encoded as the least significant bit of a flags byte
  * ``data`` is the plain data byte array.



Returns the ``MRU_MANIFEST_KEY`` as a quoted string. 

Go API
~~~~~~~~

Swarm client (package swarm/api/client) has the following method:

.. code-block:: go 
	
	CreateResource(request *mru.Request) (string, error)

Returns the resulting ``MRU_MANIFEST_KEY`` 

CreateResource creates a Mutable Resource according to the data included in the Request parameter. 
To create a mru.Request, use the mru.NewCreateRequest() function.



Swarm CLI
~~~~~~~~~~~~~

The swarm CLI allows to create Mutable Resources directly from the console:

.. code-block:: none

  swarm --bzzaccount="<account>" resource create <frequency> [--name <name>] [--data <0x hex data> [--multihash]]
	
Where:

* ``account`` Ethereum account needed to sign.
* ``frequency`` Time interval the resource is expected to update at, in **seconds**.
* ``multihash`` Is a flag indicating that the data should be interpreted as a multihash. By default data isn't interpreted as a multihash.
* ``data`` Contains hex-encoded raw data or a multihash of the content the mutable resource will be initialized with. Must be prefixed with 0x, and if is a swarm keccak256 hash, with 0x1b20.

Returns the ``MRU_MANIFEST_KEY`` of the Mutable Resource

Retrieving a mutable resource
------------------------------
.. important::
  
  In order to retrieve a resource's content, it must have been initialized with data (either at resource creation or through a later update) and ``startTime < currentTime``.

HTTP API
~~~~~~~~
To retrieve a resource:

* ``GET /bzz-resource://<MRU_MANIFEST_KEY>`` Get latest update
* ``GET /bzz-resource://<MRU_MANIFEST_KEY>/<n>`` Get latest update on period n
* ``GET /bzz-resource://<MRU_MANIFEST_KEY>/<n>/<m>`` Get update version m of period n 
* ``GET /bzz-resource://<MRU_MANIFEST_KEY>/meta`` Returns the resource metadata

By using ``bzz-resource://`` you get the raw data that was put in the resource. If the resource data is a multihash, using ``bzz://`` will return the content pointed by the multihash,
whereas ``bzz-resource://``  returns the actual multihash.

.. note::

  + ``MRU_MANIFEST_KEY`` can be substituted by an ``ENS`` domain that has it content set to a ``MRU_MANIFEST_KEY``
  +	The ``bzz-resource`` and ``bzz`` scheme behaviour is expected to change 

Go API
~~~~~~~~
To retrieve a resource we use the following method

.. code-block:: go 

	GetResource(manifestAddressOrDomain string) (io.ReadCloser, error)

* ``manifestAddressOrDomain`` Either the ``ENS`` domain or ``MRU_MANIFEST_KEY`` associated to the *Mutable Resource* 

Returns the latest data currently contained in the resource as an octect stream. 

Swarm CLI
~~~~~~~~~~~~~

The swarm client doesn't allow to retrieve a resource per se, however we can use it to retrieve the metainfo:

.. code-block:: none

  swarm resource info <MRU_MANIFEST_KEY>

This will output the resource's metainfo

Updating a mutable resource
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
* ``period`` **See note**.
* ``version`` **See note**.
* ``signature`` Calculated in the same way as explained above for simultaneous resource creation and update.

Then, POST the resulting JSON to: ``POST /bzz-resource:/``

.. note::

  To avoid any malfunction the ``period`` and ``version`` values of the update must be set to the recommended values obtained when doing ``GET /bzz-resource://<MRU_MANIFEST_KEY>/meta``.

Go API
~~~~~~~~
As with the HTTP API, we have to know the version and period that are valid for the update. To get this information we use :

.. code-block:: go

  GetResourceMetadata(manifestAddressOrDomain string) (*mru.Request, error)

Returns a ``mru.Request`` object that describes the resource and can be used to construct an update. To finish constructing the request for the update we need to : 

* Call ``Request.SetData()`` to put the new data in
* Call ``Request.Sign()`` to sign the update

Once we have our request fully constructed, we can update our resource by calling: 

.. code-block:: go

  UpdateResource(request *mru.Request)

Where ``request`` is the previously constructed request

Swarm CLI
~~~~~~~~~~~~~
.. code-block:: none

  swarm --bzzaccount="<account>" resource update <Manifest Address or ENS domain> <0x Hexdata> [--multihash]

The ``--multihash`` flag sets multihash to true. By default the data is not considered to be a multihash.
As mentioned earlier, if you want to use the output of swarm up, prefix it with 0x1b20 to indicate a keccak256 hash.

Mutable resource versioning
----------------------------
As explained above, we need to specify a frequency parameter when we create a resource. This indicates the time in seconds that are expected to pass between each update.
In Mutable Resources we call this the *period*. When you make an update, it will belong to the  *current period*.

Let's make this less obscure with some concrete examples:

* Mutable Resource is created and initialized with data at timestamp ``4200000`` with frequency ``100``.
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
