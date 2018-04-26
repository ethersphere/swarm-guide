******************************
Swarm Configuration
******************************

Examples
==========

Below are examples on ways to run swarm beyond just the default network.


Connecting swarm only (no blockchain)
-------------------------------------

..  note::  Even though you do not need the ethereum blockchain, you will need geth to generate a swarm account ($BZZKEY), since this account determines the base address that your swarm node is going to use.

To suppress any ENS name resolution, use the ``--ens-api ''`` option.

.. code-block:: none

  go-swarm --bzzaccount $BZZKEY \
         --datadir $DATADIR \
         --ens-api ''


The ``go-swarm`` daemon will seek out and connect to other swarm nodes. It manages its own peer connections independent of ``geth``.

Using Swarm together with the Ropsten testnet blockchain ENS
-------------------------------------------------------------

In case you don't yet have a testnet account, run

.. code-block:: none

  geth --testnet account new

Run a geth node connected to the Ropsten testnet

.. code-block:: none

  geth --testnet

Then launch the swarm; connecting it to the geth node (``--ens-api``).


.. code-block:: none

  go-swarm --bzzaccount $BZZKEY \
         --keystore $HOME/.ethereum/geth/testnet/keystore \
         --ens-api $HOME/.ethereum/geth/testnet/geth.ipc



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


.. note:: In this example, running geth is optional, it is not strictly needed. To run without geth, simply change the ens-api flag to ``--ens-api ''`` (an empty string).

.. note:: In this example, ``--nodiscover`` is superfluous, because ``--maxpeers 0`` is already enough to suppress all discovery and connection attempts.


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

You can extend your singleton node into a private swarm. First you fire up a number of ``go-swarm`` instances, following the instructions above. You can keep the same datadir, since all node-specific into will reside under ``$DATADIR/bzz-$BZZKEY/``
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




Configuration of go-swarm
===========================

Command line options for go-swarm
-----------------------------------

The ``go-swarm`` executable supports the following configuration options:

* Configuration file
* Environment variables
* Command line

Options provided via command line override options from the environment variables, which will override options in the config file. If an option is not explicitly provided, a default will be chosen.

In order to keep the set of flags and variables manageable, only a subset of all available configuration options are available via command line and environment variables. Some are only available through a TOML configuration file.

.. note:: Swarm reuses code from ethereum, specifically some p2p networking protocol and other common parts. To this end, it accepts a number of environment variables which are actually from the ``geth`` environment. Refer to the geth documentation for reference on these flags.

This is the list of flags inherited from ``geth``:

.. code-block:: none

  --identity
  --bootnodes
  --datadir
  --keystore
  --nodiscover
  --v5disc
  --netrestrict
  --nodekey
  --nodekeyhex
  --maxpeers
  --nat
  --ipcdisable
  --ipcpath
  --password

The following table illustrates the list of all configuration options and how they can be provided.

Configuration options
------------------------

.. note:: ``go-swarm`` can be executed with the ``dumpconfig`` command, which prints a default configuration to STDOUT, and thus can be redirected to a file as a template for the config file.


A TOML configuration file is organized in sections. The below list of available configuration options is organized according to these sections. The sections correspond to `Go` modules, so need to be respected in order for file configuration to work properly. See `<https://github.com/naoina/toml>`_ for the TOML parser and encoder library for Golang, and `<https://github.com/toml-lang/toml>`_ for further information on TOML.


General configuration parameters
--------------------------------

.. csv-table::
   :header: "Config file", "Command-line flag", "Environment variable", "Default value", "Description"
   :widths: 10, 5, 5, 15, 55

   "n/a","--config","n/a","n/a","Path to config file in TOML format"
   "Contract","--chequebook","SWARM_CHEQUEBOOK_ADDR","0x0","Swap chequebook contract address"
   "EnsRoot","--ens-addr","SWARM_ENS_ADDR", "ens.TestNetAddress","Ethereum Name Service contract address"
   "EnsApi","--ens-api","SWARM_ENS_API","<$GETH_DATADIR>/geth.ipc","Ethereum Name Service API address"
   "Path","--datadir","GETH_DATADIR","<$GETH_DATADIR>/swarm","Path to the geth configuration directory"
   "ListenAddr","--httpaddr","SWARM_LISTEN_ADDR", "127.0.0.1","Swarm listen address"
   "Port","--bzzport","SWARM_PORT", "8500","Port to run the http proxy server"
   "PublicKey","n/a","n/a", "n/a","Public key of swarm base account"
   "BzzKey","n/a","n/a", "n/a","Swarm node base address (:math:`hash(PublicKey)hash(PublicKey))`. This is used to decide storage based on radius and routing by kademlia."
   "NetworkId","--bzznetworkid","SWARM_NETWORK_ID","3","Network ID"
   "SwapEnabled","--swap","SWARM_SWAP_ENABLE","false","Enable SWAP"
   "SyncEnabled","--sync","SWARM_SYNC_ENABLE","true","Disable swarm node synchronization. This option will be deprecated. It is only for testing."
   "SwapApi","--swap-api","SWARM_SWAP_API","","URL of the Ethereum API provider to use to settle SWAP payments"
   "Cors","--corsdomain","SWARM_CORS", "","Domain on which to send Access-Control-Allow-Origin header (multiple domains can be supplied separated by a ',')"
   "BzzAccount","--bzzaccount","SWARM_ACCOUNT", "","Swarm account key"
   "BootNodes","--boot-nodes","SWARM_BOOTNODES","","Boot nodes"


