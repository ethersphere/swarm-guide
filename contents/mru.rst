MRU
====

Mutable Resource Updates
---------------------------

As of POC 0.3 Swarm offers mutable resources updates. This does not imply that the underlying chunks are actually modified, but rather provides a deterministic blockchain-time-based (e.g. relies on the blockchain's generation time) hashing system that enables the Swarm node to look for the most recent version of a resource (or, in turn, a specific requested version).

``bzz-resource`` resources are meant to serve as a mechanism to push updates to an ``ENS`` identifier.
Thus, a typical way to access them would be to simply point at the ``bzz-resource`` URL:

.. code-block:: none

  bzz-resource:/theswarm.eth

This will make sure that you always get the most current version of ``theswarm.eth``.
You can also point to a specific version by specifying an Ethereum block height and a version specifier. If the
requested version cannot be found, the Swarm node will try to fetch the latest version in relative to that requested version (but not a newer one).

.. note::
  To simplify things, think of immutable resources as a layer between your Dapp and ENS, facilitating faster and cheaper
  resource updates. Architecture wise, this means your ENS record will point to a versionless ``bzz-resource``. This will allow
  a browser pointing to the ENS record to retrieve the newest version of your resource. A resource update does not infer that the ENS
  record gets updated.

.. important::
  Creating or updating a mutable resource involves, under the hood, a proper configuration that ensures that the actor that is trying to make a mutable
  resource update is indeed the owner of the ENS record. This means your node has to be configured accordingly. If your Swarm node isn't configured with the
  ``--ens-api`` switch, ``bzz-resource`` updates will be disabled entirely.


Creating a mutable resource
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Given the correct configuration, creating a new mutable resource is as simple as:

.. code-block:: none

  curl -X POST --header "Content-Type:application/octet-stream" --data-binary <BINARY_DATA> http://localhost:8500/bzz-resource:/yourdomainname.eth/<period>


  curl -X POST --header "Content-Type:application/octet-stream" --data-binary <BINARY_DATA> http://localhost:8500/bzz-resource:/yourdomainname.eth/

The Swarm node will ensure that you are indeed the owner of the ENS record, and if so, will commit the resource change.


Retrieving a mutable resource
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Retrieval of a mutable resource is as easy as:

.. code-block:: none

  curl http://localhost:8500/bzz-resource:/yourdomainname.eth

This will retrieve the newest version of the resource you've requested, regardless of ownership


Retrieving a specific version
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You can also retrieve a specific version of the resource, specifying a block height and a (incremental) version identifier:

.. code-block:: none

  curl http://localhost:8500/bzz-resource:/yourdomainname.eth/3/1
