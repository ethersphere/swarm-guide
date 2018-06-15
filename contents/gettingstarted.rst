******************************
Getting started
******************************

The first thing to do is to start up your Swarm node and connect it to the Swarm.

How do I connect to Swarm?
===========================

To start a basic Swarm node you must have both ``geth`` and ``swarm`` installed on your machine. You can find the relevant instructions in the `Installation and Updates <./installation.html>`_  section.

To start Swarm you need an Ethereum account. You can create a new account by running the following command:

.. code-block:: none

  geth account new

You will be prompted for a password:

.. code-block:: none

  Your new account is locked with a password. Please give a password. Do not forget this password.
  Passphrase:
  Repeat passphrase:

Once you have specified the password, the output will be the Ethereum address representing that account. For example:

.. code-block:: none

  Address: {2f1cd699b0bf461dcfbf0098ad8f5587b038f0f1}

Using this account, connect to Swarm with

.. code-block:: none

  swarm --bzzaccount 2f1cd699b0bf461dcfbf0098ad8f5587b038f0f1

(replacing 2f1cd699b0bf461dcfbf0098ad8f5587b038f0f1 with your address).

Verifying that your local Swarm node is running
-----------------------------------------------

When running, ``swarm`` is accessible through an HTTP API on port 8500. Confirm that it is up and running by pointing your browser to http://localhost:8500

.. _connect-ens:

How do I enable ENS name resolution?
=====================================

.. note:: **ENS** is based on a suite of smart contracts running on the *Ethereum mainnet*.

The `Ethereum Name Service <http://ens.readthedocs.io/en/latest/introduction.html>`_ is the Ethereum equivalent of DNS in the classic web. In order to use **ENS** to resolve names to swarm content hashes, ``swarm`` has to connect to a ``geth`` instance that is connected to the *Ethereum mainnet*. This is done using the ``--ens-api`` flag.

First you must start your geth node and establish connection with Ethereum main network with the following command:

.. code-block:: none

  geth

for a full geth node, or

.. code-block:: none

  geth --syncmode=light

for light client mode.

.. note::

When you use the light mode, you don't have to sync the node before it can be used to answer ENS queries. However, please note that light mode is still an experimental feature.

After the connection is established, open another terminal window and connect to Swarm:

.. code-block:: none

  swarm --ens-api '$HOME/.ethereum/geth.ipc' \
    --bzzaccount 2f1cd699b0bf461dcfbf0098ad8f5587b038f0f1

.. note::
  For Mac OS, replace "$HOME/.ethereum/" with "~/Library/Ethereum/"

Verify that this was successful by pointing your browser to http://localhost:8500/bzz:/theswarm.eth/

Using Swarm together with the testnet ENS
------------------------------------------

It is also possible to use the Ropsten ENS test registrar for name resolution instead of the Ethereum main .eth ENS on mainnet.

Run a geth node connected to the Ropsten testnet

.. code-block:: none

  geth --testnet

Then launch the swarm; connecting it to the geth node (``--ens-api``).

.. code-block:: none

  swarm --ens-api $HOME/.ethereum/geth/testnet/geth.ipc

Swarm will automatically use the ENS deployed on Ropsten.

For other ethereum blockchains and other deployments of the ENS contracts, you can specify the contract addresses manually. For example the following command:

.. code-block:: none

  swarm --ens-api eth:314159265dD8dbb310642f98f50C066173C1259b@/home/user/.ethereum/geth.ipc \
           --ens-api test:0x112234455C3a32FD11230C42E7Bccd4A84e02010@ws:1.2.3.4:5678 \
           --ens-api 0x230C42E7Bccd4A84e02010112234455C3a32FD11@ws:8.9.0.1:2345

Will use the ``geth.ipc`` to resolve ``.eth`` names using the contract at ``314159265dD8dbb310642f98f50C066173C1259b`` and it will use ``ws:1.2.3.4:5678`` to resolve ``.test`` names using the contract at ``0x112234455C3a32FD11230C42E7Bccd4A84e02010``. For all other names it will use the ENS contract at ``0x230C42E7Bccd4A84e02010112234455C3a32FD11`` on ``ws:8.9.0.1:2345``.

Using an external ENS source
----------------------------

.. important::

  Take care when using external sources of information. By doing so you are trusting someone else to be truthful. Using an external ENS source may make you vulnerable to man-in-the-middle attacks. It is only recommended for test and development environments.

Maintaining a fully synced Ethereum node comes with certain hardware and bandwidth constraints, and can be tricky to achieve. Also, light client mode, where syncing is not necessary, is still experimental.

An alternative solution for development purposes is to connect to an external node that you trust, and that offers the necessary functionality through http.

If the external node is running on IP 12.34.56.78 port 8545, the command would be:

.. code-block:: none

  swarm --ens-api http://12.34.45.78:8545

You can also use ``https``. But keep in mind that Swarm *does not validate the certificate*.


Alternative modes
=================

Below are examples on ways to run swarm beyond just the default network.

Swarm in singleton mode (no peers)
------------------------------------

To launch in singleton mode, use the ``--maxpeers 0`` flag.

.. code-block:: none

 swarm --bzzaccount $BZZKEY \
        --datadir $DATADIR \
        --ens-api $DATADIR/geth.ipc \
        --maxpeers 0

Adding enodes manually
------------------------

By default, swarm will automatically seek out peers in the network. This can be suppressed using the ``--nodiscover`` flag:

.. code-block:: none

 swarm --bzzaccount $BZZKEY \
        --datadir $DATADIR \
        --ens-api $DATADIR/geth.ipc \
        --nodiscover

Without discovery, it is possible to manually start off the connection process by adding one or more peers using the ``admin.addPeer`` console command.

.. code-block:: none

  geth --exec='admin.addPeer("ENODE")' attach ipc:/path/to/bzzd.ipc

.. note::

  When you stop a node, all peer connections will be saved. When you start again, the node will try to reconnect to those peers automatically.

Where ENODE is the enode record of a swarm node. Such a record looks like the following:

.. code-block:: none

  enode://01f7728a1ba53fc263bcfbc2acacc07f08358657070e17536b2845d98d1741ec2af00718c79827dfdbecf5cfcd77965824421508cc9095f378eb2b2156eb79fa@1.2.3.4:30399

The enode of your swarm node can be accessed using ``geth`` connected to ``bzzd.ipc``

.. code-block:: shell

    geth --exec "admin.nodeInfo.enode" attach /path/to/bzzd.ipc

.. note::
  Note how ``geth`` is used for two different purposes here: You use it to run an Ethereum Mainnet node for ENS lookups. But you also use it to "attach" to the Swarm node to send commands to it.
