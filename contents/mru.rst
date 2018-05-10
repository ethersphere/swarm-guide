Mutable Resource Updates
========================

.. note::
  Mutable Resource Updates is a highly experimental feature, available from swarm POC3. It is under active development, so expect things to change.

We have previously learned in this guide that when we make changes in data in swarm, the hash returned when we upload that data will change in totally unpredictable ways. With *Mutable Resource Updates*, swarm provides a built-in way of keeping a persistent identifier to changing data.

The usual way of keeping the same pointer to changing data is using the Ethereum Name Service ``ENS``. However, ``ENS`` is an on-chain feature, which limits functionality in some areas:

1. Every update to an ``ENS`` resolver will cost you gas to execute
2. It is not be possible to change the data faster than the rate that new blocks are mined.
3. Correct ``ENS`` resolution requires that you are always synced to the blockchain.

Using *Mutable Resource Updates* you only need to register the data resource *once* with ``ENS``. After this, your lookup calls to that ``ENS`` name will automatically resolve to the latest update existing in swarm.

Creating a mutable resource
^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. important::
  If you run your node with the ``--ens-api`` flag, the node will make an ``ENS`` lookup on create and update operations to ensure that the node account is the owner of the ``ENS`` name before allowing the updates to go through. If you run the node *without* this flag, updates will *not* be checked, but will still be checked by other nodes in the network. Updates from illegitimate owners will be discarded by other nodes, and will not propagate in the network.

When you create a mutable resource, you will have to supply an expected update frequency. This is an indication of how often (in number of blocks) your resource will change. Don't worry; as we will see later you can always update the resource inbetween these intervals if you want.

Let's say we will want to update some data every 42 blocks (roughly every 10 minutes). The resulting resource constructor will be as follows:

.. code-block:: none

  SWARMHASH=`swarm up foo.html` && curl -X POST http://localhost:8500/bzz-resource:/yourdomainname.eth/42 --data $SWARMPAGE

This will result in json output along the lines of:

.. code-block:: none

  {"manifest":"94f373bb8df041687d5cc9a6cbf72ccd8886e816c7b25aa1e7776a21c55a540c","resource":"yourdomainname.eth","update":"fed6fe4ee69a45181535f11f22f2592b6d21a9de0dfd77dda358612d0cb34067"}

To use ``ENS`` lookups for this resource, you use the ``setContent`` method of your ``ENS`` resolver to point to the hash in the ``manifest`` entry above. Once this is mined, you will be able to view the contents of ``foo.html`` in a browser by visiting ``http://localhost:8500/bzz:/yourdomainname.eth``

Now for the magic; to change this resource, you issue:

.. code-block:: none

  SWARMHASH=`swarm up bar.html` && curl -X POST http://localhost:8500/bzz-resource:/yourdomainname.eth --data $SWARMPAGE

After this, when you enter ``http://localhost:8500/bzz:/yourdomainname.eth`` in the browser, you will see the contents of ``bar.html`` instead. Note that no update to ``ENS`` has been made in the meantime. You've saved a bit of money, and the update happens at the speed of storing a swarm chunk.

Retrieving a mutable resource
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The above example is limited to updating swarm web content. But Mutable Resource Updates can just as well be used to store and retrieve "raw" data aswell. This is done using the ``/raw`` subpath in the url upon update. An example:

.. code-block:: none

  curl -X POST http://localhost:8500/bzz-resource:/yourdomainname.eth/raw --data foo
  curl -X GET http://localhost:8500/bzz-resource:/yourdomainname.eth

  curl -X POST http://localhost:8500/bzz-resource:/yourdomainname.eth/raw --data bar
  curl -X GET http://localhost:8500/bzz-resource:/yourdomainname.eth

The above two commands pairs will return "foo" and "bar" repectively.

.. important:: 
  Updates made using the *raw* subpath are served with the ``applcation/octet-stream`` mime type. This means that the receiving application needs to know itself how to interpret the underlying data.

Mutable resource versioning
^^^^^^^^^^^^^^^^^^^^^^^^^^^

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

Retrieving a specific mutable resource version
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

We can retrieve specific Mutable Resource Update versions by adding the version numbers to the url.

Either we can choose to only name the period, in which case we will get the latest version of that period. Thus, again referring to the above examples:

.. code-block:: none

  curl -X GET http://localhost:8500/bzz-resource:/yourdomainname.eth/1

Will return the content of version ``1.1`` 

.. code-block:: none

  curl -X GET http://localhost:8500/bzz-resource:/yourdomainname.eth/3

Will return the content of version ``3.2``

.. code-block:: none

  curl -X GET http://localhost:8500/bzz-resource:/yourdomainname.eth/3/1

Will return the content of version ``3.1``

.. code-block:: none

  curl -X GET http://localhost:8500/bzz-resource:/yourdomainname.eth

Will of course return the version ``4.1``
