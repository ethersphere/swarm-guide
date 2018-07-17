Mutable Resource Updates
========================

.. note::
Mutable Resource Updates is a highly experimental feature, available from Swarm POC3. It is under active development, so expect things to change.

We have previously learned in this guide that when we make changes in data in Swarm, the hash returned when we upload that data will change in totally unpredictable ways. With *Mutable Resource Updates*, Swarm provides a built-in way of keeping a persistent identifier to changing data.

The usual way of keeping the same pointer to changing data is using the Ethereum Name Service ``ENS``. However, ``ENS`` is an on-chain feature, which limits functionality in some areas:

1. Every update to an ``ENS`` resolver will cost you gas to execute.
2. It is not be possible to change the data faster than the rate that new blocks are mined.
3. Correct ``ENS`` resolution requires that you are always synced to the blockchain.

With *Mutable Resource Updates* we no longer require the ``ENS`` in order to have a non-variable identifier to changing data. The  resource  can be accessed like a regular Swarm object using the key obtained when the resource was created ( ``MRU_MANIFEST_KEY`` ) . When the data changes
the ``MRU_MANIFEST_KEY`` will  point to the new data.

If using *Mutable Resource Updates* in conjunction with an ``ENS`` resolver contract, only one initial transaction to register the ``MRU_MANIFEST_KEY`` will be necessary. This key will resolve to the latest version of the resource (mutating the resource will not change the key).

There  are 3 different ways of interacting with *Mutable Resource Updates* : HTTP API, Golang API and Swarm console

Creating a mutable resource
----------------------------
.. important:: Only the private key (address) that created the Resource can update it. 
 
When  creating a mutable resource one of the parameters that you will have to provide is the expected update frequency. This is an indication of how often (in seconds) your resource will change. Although you can update the resource at other rates, doing so will slow down the process of retrieving the resource. 



HTTP API
~~~~~~~~

To create a resource using the HTTP API:
``POST /bzz-resource:/`` with the following JSON as payload:

.. code-block:: js

  "name": string,
  "frequency": number,
  "startTime": number,
  "rootAddr" : hex string,
  "data": hex string,
  "multihash": boolean,none
  "period": number,
  "version": number,
  "signature": hex string 
	
Where:

+ ``name`` Resource name. This is a user field. You can use any name
+ ``frequency`` Time interval the resource is expected to update at, in **seconds**.
+ ``startTime`` Time the resource is valid from, in Unix time (seconds).
+ ``ownerAddr`` Is the address derived from your public key. Hex encoded.
+ ``multihash`` Is a flag indicating whether the data field should be interpreted as raw data or a multihash
+ ``data`` Contains hex-encoded raw data or a multihash of the content the mutable resource will be initialized with
+ ``period`` Indicates for what period we are signing. Set to 1 for creation.
+ ``version`` Indicates what resource version of the period we are signing. Must be set to 1 for creation.
+ ``signature`` Signature of the digest calculated as follows digest = H(H(period, version, rootAddr), metaHash, data). Hex encoded.
Returns the ``MRU_MANIFEST_KEY`` as a quoted string.

Go API
~~~~~~~~

Swarm client (package swarm/api/client) has the following method

.. code-block:: go 

  CreateResource(name string, frequency, startTime uint64, data []byte, multihash bool, signer mru.Signer)
    
CreateResource creates a Mutable Resource with the given name and frequency, initializing it with the provided data. Data is interpreted as multihash or not                
depending on the value of ``multihash``

+ ``name`` Human-readable name for your resource.
+ ``startTime`` When the resource starts to be valid. 0 means "now". Unix time in seconds.
+ ``data`` Initial data the resource will contain.
+ ``multihash`` Whether to interpret data as multihash
+ ``signer`` Signer object containing the Sign callback function
Returns the resulting Mutable Resource manifest address that you can use to include in an ``ENS`` resolver (setContent) or reference future updates (Client.UpdateResource)

Swarm console
~~~~~~~~~~~~~

The swarm CLI allows to create resources directly from the console:

.. code-block:: bash

  swarm --bzzaccount="<account>" resource create <frequency> [--name <name>] [--data <0x hex data> [--multihash=true/false]]
	
Where:

+ ``account`` Ethereum account needed to sign 
+ ``frequency`` Time interval the resource is expected to update at, in **seconds**.
+ ``multihash`` Is a flag indicating whether the data field should be interpreted as raw data or a multihash
+ ``data`` Contains hex-encoded raw data or a multihash of the content the mutable resource will be initialized with. Must be prefixed with 0x, and if is a swarm keccak256 hash, with 0x1b20


Retrieving a mutable resource
------------------------------

HTTP API
~~~~~~~~

Go API
~~~~~~~~

Swarm console
~~~~~~~~~~~~~


Updating a mutable resource
------------------------------

HTTP API
~~~~~~~~

Go API
~~~~~~~~

Swarm console
~~~~~~~~~~~~~

Mutable resource versioning
----------------------------
TODO: Change block height for time in seconds


As explained above, we need to specify a frequency parameter when we create a resource, which indicates the number of blocks that are expected to pass between each update. In Mutable Resourceswe call this the *period*. When you make an update, it will always belong to the *upcoming period*.

Let's make this less obscure with some concrete examples:

* Mutable Resource is created at block height ``4200000`` with frequency ``13``.
* Update made at block height ``4200010``. Update will belong to block height ``4200013``.
* Update made at block height ``4200014``. Update will belong to block height ``4200026``.
* Update made at block height ``4200021``. Update will *also* belong to block height ``4200026``.
* Update made at block height ``4200026``. Update will belong to block height ``4200039``.

.. important::
  Notice that if you make an update on the block height of an actual period, the update will belong to the *next* period.

This behavior is analogous to versioning. And indeed, Mutable Resources allow for retrieval of particular versions aswell. However, instead of using block heights for the versioning scheme, we instead use incremental serial numbers, where the starting block is update ``1``, the starting block plus frequency is update ``2`` and so forth.

If more updates are made within one period, they will be sequentially numbered aswell. So returning to our above example, the updates can be referenced by the following version numbers:

* Update creation = version ``1.1``
* Block height ``4200010`` = version ``2.1``
* Block height ``4200014`` = version ``3.1``
* Block height ``4200021`` = version ``3.2``
* Block height ``4200026`` = version ``4.1``
