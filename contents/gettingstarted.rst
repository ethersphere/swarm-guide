******************************
Getting started
******************************

The first thing to do is to start up your Swarm node and connect it to the Swarm.

How do I connect to Swarm?
===========================

To start a basic Swarm node you must have both geth and go-swarm installed on your machine. You can find the relevant instructions in the `Installation and Updates <./installation.html>`_  section.

If you do not yet have an Ethereum account that you wish to act as your Swarm account, create a new account by running the following command:

.. code-block:: none

  geth account new

You will be prompted for a password:

.. code-block:: none

  Your new account is locked with a password. Please give a password. Do not forget this password.
  Passphrase:
  Repeat passphrase:

Once you have specified the password (for example MYPASSWORD) the output will be your Ethereum address. This is also the base address for your Swarm node.

.. code-block:: none

  Address: {2f1cd699b0bf461dcfbf0098ad8f5587b038f0f1}

Using this account, connect to Swarm with

.. code-block:: none

  go-swarm --bzzaccount 2f1cd699b0bf461dcfbf0098ad8f5587b038f0f1

(replacing 2f1cd699b0bf461dcfbf0098ad8f5587b038f0f1 with your address).


Verifying that your local Swarm node is up
-------------------------------------------

When running, ``go-swarm`` is accessible through an HTTP API on port 8500. Confirm that it is up and running by pointing your browser to http://localhost:8500

.. _connect-ens:

How do I enable ENS name resolution?
=====================================

The `Ethereum Name Service <http://ens.readthedocs.io/en/latest/introduction.html>`_ is based on a suite of smart contracts running on the Ethereum main network. Thus, in order to use the ENS to resolve names to swarm content hashes, ``go-swarm`` has to connect to a ``geth`` instance that is connected to the Ethereum main net. This is done using the ``--ens-api '/path/to/geth/datadir/geth.ipc'`` flag.

First you must start your geth node and establish connection with Ethereum main network with the following command:

.. code-block:: none

  geth

for a full geth node, or

.. code-block:: none

  geth --syncmode=light

for light client mode.

After the connection is established, open another terminal window and connect to Swarm:

.. code-block:: none

  go-swarm --ens-api '$HOME/.ethereum/geth.ipc'

Verify that this was successful by pointing your browser to http://localhost:8500/bzz:/theswarm.eth/

Using Swarm together with the testnet ENS
------------------------------------------

It is also possible to use the Ropsten ENS test registrar for name resolution instead of the Ethereum main .eth ENS on mainnet.

Run a geth node connected to the Ropsten testnet

.. code-block:: none

  geth --testnet

Then launch the swarm; connecting it to the geth node (``--ens-api``).

.. code-block:: none

  go-swarm --ens-api $HOME/.ethereum/geth/testnet/geth.ipc

Swarm will automatically use the ENS deployed on Ropsten.

For other ethereum blockchains and other deployments of the ENS contracts, you can specify the contract addresses manually. For example the following command:

.. code-block:: none

  go-swarm --ens-api eth:314159265dD8dbb310642f98f50C066173C1259b@/home/user/.ethereum/geth.ipc \
           --ens-api test:0x112234455C3a32FD11230C42E7Bccd4A84e02010@ws:1.2.3.4:5678 \
           --ens-api 0x230C42E7Bccd4A84e02010112234455C3a32FD11@ws:8.9.0.1:2345

Will use the ``geth.ipc`` to resolve ``.eth`` names using the contract at ``314159265dD8dbb310642f98f50C066173C1259b`` and it will use ``ws:1.2.3.4:5678`` to resolve ``.test`` names using the contract at ``0x112234455C3a32FD11230C42E7Bccd4A84e02010``. For all other names it will use the ENS contract at ``0x230C42E7Bccd4A84e02010112234455C3a32FD11`` on ``ws:8.9.0.1:2345``.



Alternative Networks
====================

Below are examples on ways to run swarm beyond just the default network.

Swarm in singleton mode (no peers)
------------------------------------

To launch in singleton mode, use the ``--maxpeers 0`` flag. This works on both ``geth`` and ``go-swarm``.

For example:

.. code-block:: none

 geth --datadir $DATADIR \
        --nodiscover \
        --maxpeers 0

and launch the Swarm; connecting it to the geth node.

.. code-block:: none

 go-swarm --bzzaccount $BZZKEY \
        --datadir $DATADIR \
        --ens-api $DATADIR/geth.ipc \
        --maxpeers 0 \
        --nodiscover


.. note:: In this example, running geth is optional, it is not strictly needed. To run without geth, simply set ``--ens-api ''`` (an empty string), or remove the ``--ens-api`` flag altogether.

.. note:: Strictly speaking, the ``--nodiscover`` flag is superfluous here, because ``--maxpeers 0`` is already enough to suppress all discovery and connection attempts.


Adding enodes manually
------------------------

By default, go-swarm will automatically seek out peers in the network. This can be suppressed using the ``--nodiscover`` flag.

Without discovery, it is possible to manually start off the connection process by adding a few peers using the ``admin.addPeer`` console command.

.. code-block:: none

  geth --exec='admin.addPeer("ENODE")' attach ipc:/path/to/bzzd.ipc

Where ENODE is the enode record of a swarm node. Such a record looks like the following:

.. code-block:: none

  enode://01f7728a1ba53fc263bcfbc2acacc07f08358657070e17536b2845d98d1741ec2af00718c79827dfdbecf5cfcd77965824421508cc9095f378eb2b2156eb79fa@1.2.3.4:30399

The enode of your swarm node can be accessed using ``geth`` connected to ``bzzd.ipc``

.. code-block:: shell

    geth --exec "console.log(admin.nodeInfo.enode)" attach /path/to/bzzd.ipc

Running a private swarm
-------------------------

You can extend your singleton node into a private swarm. First you fire up a number of ``go-swarm`` instances, following the instructions above. You can keep the same datadir, since all node-specific info will reside under ``$DATADIR/bzz-$BZZKEY/``
Make sure that you create an account for each instance of go-swarm you want to run.
For simplicity we can assume you run one geth instance and each go-swarm daemon process connects to that via ipc if they are on the same computer (or local network), otherwise you can use http or websockets as transport for the eth network traffic.

Once your ``n`` nodes are up and running, you can list all there enodes using ``admin.nodeInfo.enode`` (or cleaner: ``console.log(admin.nodeInfo.enode)``) on the swarm console.

.. code-block:: shell

    geth --exec "console.log(admin.nodeInfo.enode)" attach /path/to/bzzd.ipc

Then you can for instance connect each node with one particular node (call it bootnode) by injecting ``admin.addPeer(enode)`` into the go-swarm console (this has the same effect as if you created a :file:`static-nodes.json` file for devp2p:

.. code-block:: shell

    geth --exec "admin.addPeer($BOOTNODE)" attach /path/to/bzzd.ipc

Fortunately there is also an easier short-cut for this, namely adding the ``--bootnodes $BOOTNODE`` flag when you start Swarm.

These relatively tedious steps of managing connections need to be performed only once. If you bring up the same nodes a second time, earlier peers are remembered and contacted.

.. note::
    Note that if you run several go-swarm daemons locally on the same machine, you can use the same data directory ($DATADIR), each swarm  will automatically use its own subdirectory corresponding to the bzzaccount. This means that you can store all your keys in one keystore directory: $DATADIR/keystore.

In case you want to run several nodes locally and you are behind a firewall, connection between nodes using your external IP will likely not work. In this case, you need to substitute ``[::]`` (indicating localhost) for the IP address in the enode.

To list all enodes of a local cluster:

.. code-block:: shell

    for i in `ls $DATADIR | grep -v keystore`; do geth --exec "console.log(admin.nodeInfo.enode)" attach $DATADIR/$i/bzzd.ipc; done > enodes.lst

To change IP to localhost:

.. code-block:: shell

    cat enodes.lst | perl -pe 's/@[\d\.]+/@[::]/' > local-enodes.lst

.. note::
    The steps in this section are not necessary if you simply want to connect to the public Swarm testnet.
    Since a bootnode to the testnet is set by default, your node will have a way to bootstrap its connections.
