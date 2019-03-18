.. _Ethereum Name Service:

Using ENS names
================

.. note:: In order to `resolve` ENS names, your Swarm node has to be connected to an Ethereum blockchain (mainnet, or testnet). See `Getting Started <./gettingstarted.html#connect-ens>`_ for instructions. This section explains how you can register your content to your ENS name.

`ENS <http://ens.readthedocs.io/en/latest/introduction.html>`_ is the system that Swarm uses to permit content to be referred to by a human-readable name, such as "theswarm.eth". It operates analogously to the DNS system, translating human-readable names into machine identifiers - in this case, the Swarm hash of the content you're referring to. By registering a name and setting it to resolve to the content hash of the root manifest of your site, users can access your site via a URL such as ``bzz://theswarm.eth/``.

.. note:: Currently The `bzz` scheme is not supported in major browsers such as Chrome, Firefox or Safari. If you want to access the `bzz` scheme through these browsers, currently you have to either use an HTTP gateway, such as https://swarm-gateways.net/bzz:/theswarm.eth/ or use a browser which supports the `bzz` scheme, such as Mist <https://github.com/ethereum/mist>.

Suppose we upload a directory to Swarm containing (among other things) the file ``example.pdf``.

.. code-block:: none

  $ swarm --recursive up /path/to/dir
  >2477cc8584cc61091b5cc084cdcdb45bf3c6210c263b0143f030cf7d750e894d

If we register the root hash as the ``content`` for ``theswarm.eth``, then we can access the pdf at

.. code-block:: none

  bzz://theswarm.eth/example.pdf

if we are using a Swarm-enabled browser, or at

.. code-block:: none

  http://localhost:8500/bzz:/theswarm.eth/example.pdf

via a local gateway. We will get served the same content as with:

.. code-block:: none

  http://localhost:8500/bzz:/2477cc8584cc61091b5cc084cdcdb45bf3c6210c263b0143f030cf7d750e894d/example.pdf

Please refer to the `official ENS documentation <http://ens.readthedocs.io/en/latest/introduction.html>`_ for the full details on how to register content hashes to ENS.

In short, the steps you must take are:

1. Register an ENS name.
2. Associate a resolver with that name.
3. Register the Swarm hash with the resolver as the ``content``.

We recommend using https://manager.ens.domains/. This will make it easy for you to:

- Associate the default resolver with your name
- Register a Swarm hash.

.. note:: When you register a Swarm hash with https://manager.ens.domains/ you MUST prefix the hash with 0x. For example 0x2477cc8584cc61091b5cc084cdcdb45bf3c6210c263b0143f030cf7d750e894d

Overview of ENS (video)
-----------------------

Nick Johnson on the Ethereum Name System

.. raw:: html

  <iframe width="560" height="315" src="https://www.youtube.com/embed/pLDDbCZXvTE" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>


Migrating to the new ENS public resolver
----------------------------------------

Since EIP-1577 has been merged, the new public resolver content hash format has changed.
In order to migrate your ENS name to the new contract version, follow the following steps:

1. Update the ENS registry to point to the newly deployed public resolver (contract address is: ``0xD3ddcCDD3b25A8a7423B5bEe360a42146eb4Baf3``). You can do so through the `ENS Manager <https://manager.ens.domains>`_ interface.

2. Send a transaction to the Public resolver contract and call the `setContentHash` function. You'll need the following information to make the call:

Contract ABI:

.. code-block:: javascript

   [{"constant":true,"inputs":[{"name":"interfaceID","type":"bytes4"}],"name":"supportsInterface","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"pure","type":"function"},{"constant":false,"inputs":[{"name":"node","type":"bytes32"},{"name":"key","type":"string"},{"name":"value","type":"string"}],"name":"setText","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"node","type":"bytes32"},{"name":"contentTypes","type":"uint256"}],"name":"ABI","outputs":[{"name":"","type":"uint256"},{"name":"","type":"bytes"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"node","type":"bytes32"},{"name":"x","type":"bytes32"},{"name":"y","type":"bytes32"}],"name":"setPubkey","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"node","type":"bytes32"},{"name":"hash","type":"bytes"}],"name":"setContenthash","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"node","type":"bytes32"}],"name":"addr","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"node","type":"bytes32"},{"name":"key","type":"string"}],"name":"text","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"node","type":"bytes32"},{"name":"contentType","type":"uint256"},{"name":"data","type":"bytes"}],"name":"setABI","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"node","type":"bytes32"}],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"node","type":"bytes32"},{"name":"name","type":"string"}],"name":"setName","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"node","type":"bytes32"}],"name":"contenthash","outputs":[{"name":"","type":"bytes"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"node","type":"bytes32"}],"name":"pubkey","outputs":[{"name":"x","type":"bytes32"},{"name":"y","type":"bytes32"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"node","type":"bytes32"},{"name":"addr","type":"address"}],"name":"setAddr","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"inputs":[{"name":"ensAddr","type":"address"}],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"name":"node","type":"bytes32"},{"indexed":false,"name":"a","type":"address"}],"name":"AddrChanged","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"node","type":"bytes32"},{"indexed":false,"name":"name","type":"string"}],"name":"NameChanged","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"node","type":"bytes32"},{"indexed":true,"name":"contentType","type":"uint256"}],"name":"ABIChanged","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"node","type":"bytes32"},{"indexed":false,"name":"x","type":"bytes32"},{"indexed":false,"name":"y","type":"bytes32"}],"name":"PubkeyChanged","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"node","type":"bytes32"},{"indexed":false,"name":"indexedKey","type":"string"},{"indexed":false,"name":"key","type":"string"}],"name":"TextChanged","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"node","type":"bytes32"},{"indexed":false,"name":"hash","type":"bytes"}],"name":"ContenthashChanged","type":"event"}]


Your ENS Node hash, which is retrievable using the Swarm binary: ``swarm hash ens node <your-ens-name.eth>``.

The ENS content hash, encoded as a string in accordance with the `EIP-1577 spec <https://eips.ethereum.org/EIPS/eip-1577>`_, which is retrievable using the Swarm binary: ``swarm hash ens contenthash <swarm-hash-of-uploaded-content>``.

Once the transaction is mined, the content you point to should be retrievable using your ENS name.


