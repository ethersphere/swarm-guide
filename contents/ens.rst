Using ENS names
================

.. note:: In order to `resolve` ENS names, your swarm node has to be connected to en Ethereum blockchain. See `Getting Started <./gettingstarted.html#connect-ens>` for instructions. This section explains how you can register your content to your ENS name.

`ENS <http://ens.readthedocs.io/en/latest/introduction.html>`_ is the system that Swarm uses to permit content to be referred to by a human-readable name, such as "theswarm.eth". It operates analogously to the DNS system, translating human-readable names into machine identifiers - in this case, the swarm hash of the content you're referring to. By registering a name and setting it to resolve to the content hash of the root manifest of your site, users can access your site via a URL such as ``bzz://theswarm.eth/``.

Suppose we upload a directory to Swarm containing (among other things) the file ``example.pdf``.

.. code-block:: none

  go-swarm --recursive up /path/to/dir
  >2477cc8584cc61091b5cc084cdcdb45bf3c6210c263b0143f030cf7d750e894d

 If we then register the root hash as the content for ``theswarm.eth``, then we can access the pdf at

.. code-block:: none

  bzz://theswarm.eth/example.pdf
  #or
  http://localhost:8500/bzz:/theswarm.eth/example.pdf

and get served the same content as with:

.. code-block:: none

  GET http://localhost:8500/bzz:/2477cc8584cc61091b5cc084cdcdb45bf3c6210c263b0143f030cf7d750e894d/example.pdf

Please refer to the `official ENS documentation <http://ens.readthedocs.io/en/latest/introduction.html>`_ for details.

The steps you must take are:

1. Register an ENS name.
2. Associate a resolver with that name.
3. Register the Swarm hash with the resolver as the ``content``.

We recommend using https://manager.ens.domains/. This will make it easy for you to
- Associate the default resolver with your name
- Register a Swarm hash.

.. note:: When you register a Swarm hash with https://manager.ens.domains/ you MUST prefix the hash with 0x. For example 0x2477cc8584cc61091b5cc084cdcdb45bf3c6210c263b0143f030cf7d750e894d
