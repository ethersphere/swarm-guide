.. _run_swarm_client:

******************************
Connecting to Swarm (Advanced)
******************************

These instructions will begin by laying out how to start a local, private, personal (singleton) swarm. Use this to familiarise yourself with the functioning of the client; upload and download and http proxy.

Preparation
===========================

To start a basic swarm node we must start geth with an empty data directory on a private network and then connect the swarm daemon to this instance of geth.

First set aside an empty temporary directory to be the data store

..  note:: If you followed the installation instructions from this guide, you will find your executables in the $GOPATH/bin directory. Make sure to move your files into an executable $PATH, or include $GOPATH/bin directory on it.

.. code-block:: none

    mkdir -p ~/.ethereum/swarm
    export DATADIR=~/.ethereum/swarm
    echo "export DATADIR=~/.ethereum/swarm" >> ~/.bashrc

then make a new account using this directory

.. code-block:: none

  geth --datadir $DATADIR account new

You will be prompted for a password:

.. code-block:: none

  Your new account is locked with a password. Please give a password. Do not forget this password.
  Passphrase:
  Repeat passphrase:

Once you have specified the password (for example MYPASSWORD) the output will be an address - the base address of the swarm node.

.. code-block:: none

  Address: {2f1cd699b0bf461dcfbf0098ad8f5587b038f0f1}


We save it under the name ``BZZKEY``

.. code-block:: none

  BZZKEY=2f1cd699b0bf461dcfbf0098ad8f5587b038f0f1


With these preparations complete, we can now launch our swarm client. In what follows we detail a few ways you might want to use swarm.


* Connecting to the swarm testnet without blockchain
* Connecting to the swarm testnet and connecting to the Ropsten blockchain
* Using swarm in singleton mode for local testing
* Launching a private swarm
* Testing SWAP accounting with a private Swarm

Connecting to the swarm testnet
=================================



.. note::
    IMPORTANT: Automatic connection to the testnet is currently not working properly for all users. This issue is being fixed right now. In the meantime, please add a few enodes manually to bootstrap your node. See "Adding enodes manually" below.

Swarm needs an ethereum blockchain for

* Domain name resolution using the Ethereum Name Service (ENS) contract.
* Incentivisation (for example: SWAP)

If you do not care about domain resolution and run your swarm without SWAP (the default), then connecting to the blockchain is unnecessary. ``swarm`` per default tries to connect to the blockchain via ``geth``'s IPC endpoint (usually $DATADIR/geth.ipc). Thus, to start ``swarm`` with no domain resolution, the ``--ens-api`` option should be set to ``""`` (empty string). The ``--swap-api`` flag should only be set if SWAP is enabled.


Connecting swarm only (no blockchain)
-------------------------------------


Set up your environment as seen above, ie., make sure you have a data directory.

..  note::  Even though you do not need the ethereum blockchain, you will need geth to generate a swarm account ($BZZKEY), since this account determines the base address that your swarm node is going to use.

In the following examples, swarm's output will be written to a log file.
Please save your password into a file and replace ``password.file`` with the correct name.

.. code-block:: none

  swarm --bzzaccount $BZZKEY \
         --datadir $DATADIR \
         --ens-api '' \
         --password ~/password.file

The ``swarm`` daemon will seek out and connect to other swarm nodes. It manages its own peer connections independent of ``geth``.

Using swarm together with the Ropsten testnet blockchain
--------------------------------------------------------

In case you don't yet have an account, run

.. code-block:: none

  geth --datadir $DATADIR --testnet account new

Run a geth node connected to the Ropsten testnet

.. code-block:: none

  nohup geth --datadir $DATADIR \
         --unlock 0 \
         --password ~/password.file
         --testnet \

Then launch the swarm; connecting it to the geth node (--ens-api).


.. code-block:: none

  swarm --bzzaccount $BZZKEY \
         --datadir $DATADIR \
         --keystore $DATADIR/testnet/keystore \
         --ens-api $DATADIR/testnet/geth.ipc \
         --password ~/password.file

Adding enodes manually
------------------------

Eventually automatic node discovery will be working for swarm nodes. Until then you can start off the connection process by adding a few peers manually using the ``admin.addPeer`` console command.

.. code-block:: none

  geth --exec='admin.addPeer("ENODE")' attach ipc:/path/to/bzzd.ipc

.. uncomment_this Where ENODE is one of the following:
.. uncomment_this
.. uncomment_this.. code-block:: none

.. uncomment_this enode://01f7728a1ba53fc263bcfbc2acacc07f08358657070e17536b2845d98d1741ec2af00718c79827dfdbecf5cfcd77965824421508cc9095f378eb2b2156eb79fa@40.68.194.101:30400
.. uncomment_this enode://6d9102dd1bebb823944480282c4ba4f066f8dcf15da513268f148890ddea42d7d8afa58c76b08c16b867a58223f2b567178ac87dcfefbd68f0c3cc1990f1e3cf@40.68.194.101:30427
.. uncomment_this enode://fca15e2e40788e422b6b5fc718d7041ce395ff65959f859f63b6e4a6fe5886459609e4c5084b1a036ceca43e3eec6a914e56d767b0491cd09f503e7ef5bb87a1@40.68.194.101:30428
.. uncomment_this enode://b795d0c872061336fea95a530333ee49ca22ce519f6b9bf1573c31ac0b62c99fe5c8a222dbc83d4ef5dc9e2dfb816fdc89401a36ecfeaeaa7dba1e5285a6e63b@40.68.194.101:30429
.. uncomment_this enode://756f582f597843e630b35371fc080d63b027757493f00df91dd799069cfc6cb52ac4d8b1a56b973baf015dd0e9182ea3a172dcbf87eb33189f23522335850e99@40.68.194.101:30430
.. uncomment_this enode://d9ccde9c5a90c15a91469b865ffd81f2882dd8731e8cbcd9a493d5cf42d875cc2709ccbc568cf90128896a165ac7a0b00395c4ae1e039f17056510f56a573ef9@40.68.194.101:30431
.. uncomment_this enode://65382e9cd2e6ffdf5a8fb2de02d24ac305f1cd014324b290d28a9fba859fcd2ed95b8152a99695a6f2780c342b9815d3c8c2385b6340e96981b10728d987c259@40.68.194.101:30433
.. uncomment_this enode://7e09d045cc1522e86f70443861dceb21723fad5e2eda3370a5e14747e7a8a61809fa6c11b37b2ecf1d5aab44976375b6d695fe39d3376ff3a15057296e570d86@40.68.194.101:30434
.. uncomment_this enode://bd8c3421167f418ecbb796f843fe340550d2c5e8a3646210c9c9d747bbd34d29398b3e3716ee76aa3f2fc46d325eb685ece0375a858f20b759b40429fbf0d050@40.68.194.101:30435
.. uncomment_this enode://8bb7fb70b80f60962c8979b20905898f8f6172ae4f6a715b89712cb7e965bfaab9aa0abd74c7966ad688928604815078c5e9c978d6e57507f45173a03f95b5e0@40.68.194.101:30436




Swarm in singleton mode
===========================

To launch in singleton mode, start geth using ``--maxpeers 0``

.. code-block:: none

  nohup geth --datadir $DATADIR \
         --unlock 0 \
         --password ~/password.file
         --verbosity 4 \
         --networkid 3 \
         --nodiscover \
         --maxpeers 0 

and launch the swarm; connecting it to the geth node. For consistency, let's use the same network id 322 as geth.

.. code-block:: none

  swarm --bzzaccount $BZZKEY \
         --datadir $DATADIR \
         --ens-api $DATADIR/geth.ipc \
         --verbosity 4 \
         --maxpeers 0 \
         --bzznetworkid 3 \
         --password ~/password.file


.. note:: In this example, running geth is optional, it is not strictly needed. To run without geth, simply change the ens-api flag to ``--ens-api ''`` (an empty string).

At this verbosity level you should see plenty(!) of output accumulating in the logfiles. You can keep an eye on the output by using the command ``tail -f $DATADIR/swarm.log`` and ``tail -f $DATADIR/geth.log``. Note: if doing this from another terminal you will have to specify the path manually because $DATADIR will not be set.

You can change the verbosity level without restarting geth and swarm via the console:

.. code-block:: none

  geth --exec "web3.debug.verbosity(3)" attach ipc:$DATADIR/geth.ipc
  geth --exec "web3.debug.verbosity(3)" attach ipc:$DATADIR/bzzd.ipc


.. note:: Following these instructions you are now running a single local swarm node, not connected to any other.

If you want to run all these instructions in a single script, you can wrap them in something like

.. code-block:: bash

  #!/bin/bash

  # Working directory
  cd /tmp

  # Preparation
  DATADIR=~/.ethereum/swarm
  mkdir -p $DATADIR
  read -s -p "Enter Password. It will be stored in $DATADIR/my-password: " MYPASSWORD && echo $MYPASSWORD > $DATADIR/my-password
  echo
  BZZKEY=$($GOPATH/bin/geth --datadir $DATADIR --password $DATADIR/my-password account new | awk -F"{|}" '{print $2}')

  echo "Your account is ready: "$BZZKEY

  # Run geth in the background
  nohup $GOPATH/bin/geth --datadir $DATADIR \
      --unlock 0 \
      --password ~/password.file
      --networkid 3 \
      --nodiscover \
      --maxpeers 0 

  echo "geth is running in the background, you can check its logs at "$DATADIR"/geth.log"

  # Now run swarm in the background
  $GOPATH/bin/swarm \
      --bzzaccount $BZZKEY \
      --datadir $DATADIR \
      --ens-api $DATADIR/geth.ipc \
      --maxpeers 0 \
      --bzznetworkid 3 \
      --password ~/password.file


  echo "swarm is running in the background, you can check its logs at "$DATADIR"/swarm.log"

  # Cleaning up
  # You need to perform this feature manually
  # USE THESE COMMANDS AT YOUR OWN RISK!
  ##
  # kill -9 $(ps aux | grep swarm | grep bzzaccount | awk '{print $2}')
  # kill -9 $(ps aux | grep geth | grep datadir | awk '{print $2}')
  # rm -rf ~/.ethereum/swarm

Running a private swarm
=============================

You can extend your singleton node into a private swarm. First you fire up a number of ``swarm`` instances, following the instructions above. You can keep the same datadir, since all node-specific into will reside under ``$DATADIR/bzz-$BZZKEY/``
Make sure that you create an account for each instance of swarm you want to run.
For simplicity we can assume you run one geth instance and each swarm daemon process connects to that via ipc if they are on the same computer (or local network), otherwise you can use http or websockets as transport for the eth network traffic.

Once your ``n`` nodes are up and running, you can list all there enodes using ``admin.nodeInfo.enode`` (or cleaner: ``console.log(admin.nodeInfo.enode)``) on the swarm console. With a shell one-liner:

.. code-block:: shell

    geth --exec "console.log(admin.nodeInfo.enode)" attach /path/to/bzzd.ipc

Then you can for instance connect each node with one particular node (call it bootnode) by injecting ``admin.addPeer(enode)`` into the swarm console (this has the same effect as if you created a :file:`static-nodes.json` file for devp2p:

.. code-block:: shell

    geth --exec "admin.addPeer($BOOTNODE)" attach /path/to/bzzd.ipc

Fortunately there is also an easier short-cut for this, namely adding the ``--bootnodes $BOOTNODE`` flag when you start swarm.

These relatively tedious steps of managing connections need to be performed only once. If you bring up the same nodes a second time, earlier peers are remembered and contacted.

.. note::
    Note that if you run several swarm daemons locally on the same instance, you can use the same data directory ($DATADIR), each swarm  will automatically use its own subdirectory corresponding to the bzzaccount. This means that you can store all your keys in one keystore directory: $DATADIR/keystore.

In case you want to run several nodes locally and you are behind a firewall, connection between nodes using your external IP will likely not work. In this case, you need to substitute ``[::]`` (indicating localhost) for the IP address in the enode.

To list all enodes of a local cluster:

.. code-block:: shell

    for i in `ls $DATADIR | grep -v keystore`; do geth --exec "console.log(admin.nodeInfo.enode)" attach $DATADIR/$i/bzzd.ipc; done > enodes.lst

To change IP to localhost:

.. code-block:: shell

    cat enodes.lst | perl -pe 's/@[\d\.]+/@[::]/' > local-enodes.lst

.. note::
    Steps in this section are not necessary if you simply want to connect to the swarm testnet.
    Since a bootnode to the testnet is set by default, your node will have a way to bootstrap its connections.



.. uncommentthis Testing SWAP
.. uncommentthis ===============

.. uncommentthis note:: Important! Please only test SWAP on a private network.

.. uncommentthisTesting SWAP on your private blockchain.
.. uncommentthis-----------------------------------------

.. uncommentthisThe SWarm Accounting Protocol (SWAP) is disabled by default. Set the ``--swap`` flag to enable it. If it is set to true, then SWAP will be enabled.
.. uncommentthisHowever, activating SWAP requires more than just adding the --swap flag. This is because it requires a chequebook contract to be deployed and for that we need to have ether in the main account. We can get some ether either through mining or by simply issuing ourselves some ether in a custom genesis block.

.. uncommentthisCustom genesis block
.. uncommentthis^^^^^^^^^^^^^^^^^^^^^^

.. uncommentthisOpen a text editor and write the following (be sure to include the correct BZZKEY)

.. uncommentthis.. code-block:: none

.. uncommentthis  {
.. uncommentthis  "nonce": "0x0000000000000042",
.. uncommentthis    "mixhash": "0x0000000000000000000000000000000000000000000000000000000000000000",
.. uncommentthis    "difficulty": "0x4000",
.. uncommentthis    "alloc": {
.. uncommentthis      "THE BZZKEY address starting with 0x eg. 0x2f1cd699b0bf461dcfbf0098ad8f5587b038f0f1": {
.. uncommentthis      "balance": "10000000000000000000"
.. uncommentthis      }
.. uncommentthis    },
.. uncommentthis    "coinbase": "0x0000000000000000000000000000000000000000",
.. uncommentthis    "timestamp": "0x00",
.. uncommentthis    "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
.. uncommentthis    "extraData": "Custom Ethereum Genesis Block to test Swarm with SWAP",
.. uncommentthis    "gasLimit": "0xffffffff"
.. uncommentthis  }

.. uncommentthisSave the file as ``$DATADIR/genesis.json``.

.. uncommentthisIf you already have swarm and geth running, kill the processes

.. uncommentthis.. code-block:: none

.. uncommentthis  killall -s SIGKILL geth
.. uncommentthis  killall -s SIGKILL swarm

.. uncommentthisand remove the old data from the $DATADIR and then reinitialise with the custom genesis block

.. uncommentthis.. code-block:: none

.. uncommentthis  rm -rf $DATADIR/geth $DATADIR/swarm
.. uncommentthis  geth --datadir $DATADIR init $DATADIR/genesis.json

.. uncommentthisWe are now ready to restart geth and swarm using our custom genesis block

.. uncommentthis.. code-block:: none

.. uncommentthis  nohup geth --datadir $DATADIR \
.. uncommentthis         --mine \
.. uncommentthis         --unlock 0 \
.. uncommentthis         --password <(echo -n "MYPASSWORD") \
.. uncommentthis         --networkid 3 \
.. uncommentthis         --nodiscover \
.. uncommentthis         --maxpeers 0 \
.. uncommentthis          

.. uncommentthisand launch the swarm (with SWAP); connecting it to the geth node. For consistency let's use the same network id  322 for the swarm private network.

.. uncommentthis.. code-block:: none

.. uncommentthis  swarm --bzzaccount $BZZKEY \
.. uncommentthis         --swap \
.. uncommentthis         --swap-api $DATADIR/geth.ipc \
.. uncommentthis         --datadir $DATADIR \
.. uncommentthis         --ens-api $DATADIR/geth.ipc \
.. uncommentthis         --maxpeers 0 \
.. uncommentthis         --bzznetworkid 3 \
.. uncommentthis         --password ~/password.file


.. uncommentthis If all is successful you will see the message "Deploying new chequebook" on the swarm.log. Once the transaction is mined, SWAP is ready.

.. uncommentthis .. note:: Astute readers will notice that enabling SWAP while setting maxpeers to 0 seems futile. These instructions will be updated soon to allow you to run a private swap testnet with several peers.

.. uncommentthis Mining on your private chain
.. uncommentthis ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. uncommentthis The alternative to creating a custom genesis block is to earn all your ether by mining on your private chain.
.. uncommentthis You can start your geth node in mining mode using the ``--mine`` flag, or (in our case) we can start mining on an already running geth node by issuing the ``miner.start()`` command:

.. uncommentthis .. code-block:: none

.. uncommentthis   geth --exec 'miner.start()' attach ipc:$DATADIR/geth.ipc

.. uncommentthisThere will be an initial delay while the necessary DAG is generated. You can see the progress in the geth.log file.
.. uncommentthisAfter mining has started, you can see your balance increasing via ``eth.getBalance()``:

.. uncommentthis.. code-block:: none

.. uncommentthis  geth --exec 'eth.getBalance(eth.coinbase)' attach ipc:$DATADIR/geth.ipc
.. uncommentthis   # or
.. uncommentthis   geth --exec 'eth.getBalance(eth.accounts[0])' attach ipc:$DATADIR/geth.ipc


.. uncommentthis Once the balance is greater than 0 we can restart ``swarm`` with swap enabled.

.. uncommentthis .. code-block:: none

.. uncommentthis     killall swarm
.. uncommentthis     swarm --bzzaccount $BZZKEY \
.. uncommentthis          --swap \
.. uncommentthis          --swap-api $DATADIR/geth.ipc \
.. uncommentthis          --datadir $DATADIR \
.. uncommentthis          --ens-api $DATADIR/geth.ipc \
.. uncommentthis          --maxpeers 0 \
.. uncommentthis          --password ~/password.file


.. uncommentthis Note: without a custom genesis block the mining difficulty may be too high to be practical (depending on your system). You can see the current difficulty with ``admin.nodeInfo``

.. uncommentthis .. code-block:: none

.. uncommentthis  geth --exec 'admin.nodeInfo' attach ipc:$DATADIR/geth.ipc | grep difficulty


Configuration
=====================

Command line options for swarm
==============================

The Swarm executable supports the following configuration options:

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
============================

.. note:: `swarm` can be executed with the *dumpconfig* command, which prints a default configuration to STDOUT, and thus can be redirected to a file as a template for the config file.

A TOML configuration file is organized in sections. The below list of available configuration options is organized according to these sections. The sections correspond to `Go` modules, so need to be respected in order for file configuration to work properly. See `<https://github.com/naoina/toml>`_ for the TOML parser and encoder library for Golang, and `<https://github.com/toml-lang/toml>`_ for further information on TOML.


General configuration parameters 
--------------------------------

.. csv-table:: 
   :header: "Config file", "Command-line flag", "Environment variable", "Default value", "Description"
   :widths: 10, 5, 5, 15, 55

   "n/a","--config","n/a","n/a","Path to config file in TOML format"
   "Contract","--chequebook","SWARM_CHEQUEBOOK_ADDR","0x0000000000000000000000000000000000000000","Swap chequebook contract address"
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


Storage parameters 
------------------

.. csv-table:: 
   :header: "Config file", "Command-line flag", "Environment variable", "Default value", "Description"
   :widths: 10, 5, 5, 15, 55

   "ChunkDbPath","n/a","n/a","<$GETH_ENV_DIR>/swarm/bzz-<$BZZ_KEY>/chunks","Path to leveldb chunk DB"
   "DbCapacity","n/a","n/a","5000000","DB capacity, number of chunks (5M is roughly 20-25GB)"
   "CacheCapacity","n/a","n/a","5000","Cache capacity, number of recent chunks cached in memory"
   "Radius","n/a","n/a","0","Storage Radius: minimum proximity order (number of identical prefix bits of address key) for chunks to warrant storage. Given a storage radius :math:`r` and total number of chunks in the network :math:`n`, the node stores :math:`n*2^{-r}` chunks minimum. If you allow :math:`b` bytes for guaranteed storage and the chunk storage size is :math:`c`, your radius should be set to :math:`int(log_2(nc/b))`"


Chunker parameters 
------------------

.. csv-table:: 
   :header: "Config file", "Command-line flag", "Environment variable", "Default value", "Description"
   :widths: 10, 5, 5, 15, 55

   "Branches","n/a","n/a","128","Number of branches in bzzhash merkle tree. :math:`Branches*ByteSize(Hash)` gives the datasize of chunks"
   "Hash","n/a","n/a","SHA3","Hash: The hash function used by the chunker (base hash algo of bzzhash): SHA3 or SHA256.This option will be removed in a later release."
   
   
Hive parameters 
---------------

.. csv-table::
   :header: "Config file", "Command-line flag", "Environment variable", "Default value", "Description"
   :widths: 10, 5, 5, 15, 55

   "CallInterval","n/a","n/a","3000000000","Time elapsed before attempting to connect to the most needed peer"
   "KadDbPath","n/a","n/a","<$GETH_ENV_DIR>/swarm/bzz-<$BZZ_KEY>/","Kademblia DB path, json file path storing the known bzz peers used to bootstrap kademlia table."


Kademlia parameters 
-------------------

.. csv-table:: 
   :header: "Config file", "Command-line flag", "Environment variable", "Default value", "Description"
   :widths: 10, 5, 5, 15, 55

   "MaxProx","n/a","n/a","8","highest Proximity order (i.e., Maximum number of identical prefix bits of address key) considered distinct. Given the total number of nodes in the network :math:`N`, MaxProx should be larger than :math:`log_2(N/ProxBinSize)`), safely :math:`log_2(N)`."
   "ProxBinSize","n/a","n/a","2","Number of most proximate nodes lumped together in the most proximate kademlia bin"
   "BuckerSize","n/a","n/a","4","maximum number of active peers in a kademlia proximity bin. If new peer is added, the worst peer in the bin is dropped."
   "PurgeInterval","n/a","n/a","151200000000000"
   "InitialRetryInterval","n/a","n/a","42000000"
   "MaxIdleInterval","n/a","n/a","42000000000"
   "ConnRetryExp","n/a","n/a","2"

.. _swap_params:

SWAP profile parameters 
-----------------------
These parameters are likely to change in POC 0.3

.. csv-table::
   :header: "Config file", "Command-line flag", "Environment variable", "Default value", "Description"
   :widths: 10, 5, 5, 15, 55

   "BuyAt","n/a","n/a","20000000000","(:math:`2*10^{10}` wei), highest accepted price per chunk in wei"
   "SellAt","n/a","n/a","20000000000","(:math:`2*10^{10}` wei) offered price per chunk in wei"
   "PayAt","n/a","n/a","100","Maximum number of chunks served without receiving a cheque. Debt tolerance."
   "DropAtMaximum","n/a","n/a","10000","Number of chunks served without receiving a cheque. Debt tolerance."

SWAP strategy parameters 
------------------------
These parameters are likely to change in POC 0.3

.. csv-table::
   :header: "Config file", "Command-line flag", "Environment variable", "Default value", "Description"
   :widths: 10, 5, 5, 15, 55

   "AutoCashInterval","n/a","n/a","300000000000","(:math:`3*10^{11}`, 5 minutes) Maximum Time before any outstanding cheques are cashed"
   "AutoCashThreshold","n/a","n/a","50000000000000","(:math:`5*10^{13}`) Maximum total amount of uncashed cheques in Wei"
   "AutoDepositInterval","n/a","n/a","300000000000","(:math:`3*10^{11}`, 5 minutes) Maximum time before cheque book is replenished if necessary by sending funds from the baseaccount"
   "AutoDepositThreshold","n/a","n/a","50000000000000","(:math:`5*10^{13}`) Minimum balance in Wei required before replenishing the cheque book"
   "AutoDepositBuffer","n/a","n/a","100000000000000","(:math:`10^{14}`) Maximum amount of Wei expected as a safety credit buffer on the cheque book"

SWAP pay profile parameters 
---------------------------
These parameters are likely to change in POC 0.3

.. csv-table::
   :header: "Config file", "Command-line flag", "Environment variable", "Default value", "Description"
   :widths: 10, 5, 5, 15, 55

   "PublicKey","n/a","n/a","","Public key of your swarm base account use"
   "Contract","n/a","n/a","0x0000000000000000000000000000000000000000","Address of the cheque book contract deployed on the Ethereum blockchain. If blank, a new chequebook contract will be deployed."
   "Beneficiary","n/a","n/a","0x0000000000000000000000000000000000000000","Ethereum account address serving as beneficiary of incoming cheques"


Synchronisation parameters 
--------------------------

.. csv-table:: Synchronisation parameters 
   :header: "Config file", "Command-line flag", "Environment variable", "Default value", "Description"
   :widths: 10, 5, 5, 15, 55

   "RequestDbPath","n/a","n/a","<$GETH_ENV_DIR>/swarm/bzz-<$BZZ_KEY>/requests","Path to request DB"
   "RequestDbBatchSize","n/a","n/a","512","Request DB Batch size"
   "KeyBufferSize","n/a","n/a","1024","In-memory cache for unsynced keys"
   "SyncBatchSize","n/a","n/a","128","In-memory cache for unsynced keys"
   "SyncBufferSize","n/a","n/a","128","In-memory cache for outgoing deliveries"
   "SyncCacheSize","n/a","n/a","1024","Maximum number of unsynced keys sent in one batch"
   "Sync priorities","n/a","n/a","[2, 1, 1, 0, 0]","Array of 5 priorities corresponding to 5 delivery types:<delivery, propagation, deletion, history, backlog>.Specifying a monotonically decreasing list of priorities is highly recommended."
   "SyncModes","n/a","n/a","[true, true, true, true, false]","A boolean array specifying confirmation mode ON corresponding to 5 delivery types:<delivery, propagation, deletion, history, backlog>. Specifying true for a type means all deliveries will be preceeded by a confirmation roundtrip: the hash key is sent first in an unsyncedKeysMsg and delivered only if confirmed in a deliveryRequestMsg."


.. note:: The status of this project warrants that there will be potentially a lot
   of changes to these options.

If ``config.Contract`` is blank (zero address), a new chequebook contract is deployed. Until the contract is confirmed on the blockchain, no outgoing retrieve requests will be allowed.

Setting up SWAP
-------------------------


..  index::
   chequebook
   autodeploy (chequebook contract)


SWAP (Swarm accounting protocol) is the  system that allows fair utilisation of bandwidth (see :ref:`incentivisation`, esp. :ref:`swap`).
In order for SWAP to be used, a chequebook contract has to have been deployed. If the chequebook contract does not exist when the client is launched or if the contract specified in the config file is invalid, then the client attempts to autodeploy a chequebook:

    [BZZ] SWAP Deploying new chequebook (owner: 0xe10536..  .5e491)

If you already have a valid chequebook on the blockchain you can just enter it in the config file ``Contract`` field.

..  index::
   chequebook contract address
   Contract, chequebook contract address

You can set a separate account as beneficiary to which the cashed cheque payment for your services are to be credited. Set it on the ``Beneficiary`` field in the config file.

..  index::
   maximum accepted chunk price (``BuyAt``)
   offered chunk price (``BuyAt``)
   SellAt, offered chunk price
   BuyAt, maximum accepted chunk price
   benefieciary (``Beneficiary`` configuration parameter)
   Beneficiary, recipient address for service payments

Autodeployment of the chequebook can fail if the baseaccount has no funds and cannot pay for the transaction. Note that this can also happen if your blockchain is not synchronised. In this case you will see the log message:

.. code-block:: shell

   [BZZ] SWAP unable to deploy new chequebook: unable to send chequebook     creation transaction: Account
    does not exist or account     balance too low..  .retrying in 10s

   [BZZ] SWAP arrangement with <enode://23ae0e62..  ..  ..  8a4c6bc93b7d2aa4fb@195.228.155.76:30301>: purchase from peer disabled; selling to peer disabled)

Since no business is possible here, the connection is idle until at least one party has a contract. In fact, this is only enabled for a test phase.
If we are not allowed to purchase chunks, then no outgoing requests are allowed. If we still try to download content that we dont have locally, the request will fail (unless we have credit with other peers).

.. code-block:: shell

    [BZZ] netStore.startSearch: unable to send retrieveRequest to peer [<addr>]: [SWAP] <enode://23ae0e62..  ..  ..  8a4c6bc93b7d2aa4fb@195.228.155.76:30301> we cannot have debt (unable to buy)

Once one of the nodes has funds (say after mining a bit), and also someone on the network is mining, then the autodeployment will eventually succeed:

.. code-block:: shell

    [CHEQUEBOOK] chequebook deployed at 0x77de9813e52e3a..  .c8835ea7 (owner: 0xe10536ae628f7d6e319435ef9b429dcdc085e491)
    [CHEQUEBOOK] new chequebook initialised from 0x77de9813e52e3a..  .c8835ea7 (owner: 0xe10536ae628f7d6e319435ef9b429dcdc085e491)
    [BZZ] SWAP auto deposit ON for 0xe10536 -> 0x77de98: interval = 5m0s, threshold = 50000000000000, buffer = 100000000000000)
    [BZZ] Swarm: new chequebook set: saving config file, resetting all connections in the hive
    [KΛÐ]: remove node enode://23ae0e6..  .aa4fb@195.228.155.76:30301 from table

Once the node deployed a new chequebook, its address is set in the config file and all connections are reset with the new conditions. Purchase in one direction should be enabled. The logs from the point of view of the peer with no valid chequebook:


.. code-block:: shell

    [CHEQUEBOOK] initialised inbox (0x9585..  .3bceee6c -> 0xa5df94be..  .bbef1e5) expected signer: 041e18592..  ..  ..  702cf5e73cf8d618
    [SWAP] <enode://23ae0e62..  ..  ..  8a4c6bc93b7d2aa4fb@195.228.155.76:30301>    set autocash to every 5m0s, max uncashed limit: 50000000000000
    [SWAP] <enode://23ae0e62..  ..  ..  8a4c6bc93b7d2aa4fb@195.228.155.76:30301>    autodeposit off (not buying)
    [SWAP] <enode://23ae0e62..  ..  ..  8a4c6bc93b7d2aa4fb@195.228.155.76:30301>    remote profile set: pay at: 100, drop at: 10000,    buy at: 20000000000, sell at: 20000000000
    [BZZ] SWAP arrangement with <enode://23ae0e62..  ..  ..  8a4c6bc93b7d2aa4fb@195.228.155.76:30301>: purchase from peer disabled;   selling to peer enabled at 20000000000 wei/chunk)


..  index:: autodeposit

Depending on autodeposit settings, the chequebook will be regularly replenished:

.. code-block:: shell

  [BZZ] SWAP auto deposit ON for 0x6d2c5b -> 0xefbb0c:
   interval = 5m0s, threshold = 50000000000000,
   buffer = 100000000000000)
   deposited 100000000000000 wei to chequebook (0xefbb0c0..  .16dea,  balance: 100000000000000, target: 100000000000000)


The peer with no chequebook (yet) should not be allowed to download and thus retrieve requests will not go out.
The other peer however is able to pay, therefore this other peer can retrieve chunks from the first peer and pay for them. This in turn puts the first peer in positive, which they can then use both to (auto)deploy their own chequebook and to pay for retrieving data as well. If they do not deploy a chequebook for whatever reason, they can use their balance to pay for retrieving data, but only down to 0 balance; after that no more requests are allowed to go out. Again you will see:


.. code-block:: shell

   [BZZ] netStore.startSearch: unable to send retrieveRequest to peer [aff89da0c6...623e5671c01]: [SWAP]  <enode://23ae0e62...8a4c6bc93b7d2aa4fb@195.228.155.76:30301> we cannot have debt (unable to buy)

If a peer without a chequebook tries to send requests without paying, then the remote peer (who can see that they have no chequebook contract) interprets this as adverserial behaviour resulting in the peer being dropped.

Following on in this example, we start mining and then restart the node. The second chequebook autodeploys, the peers sync their chains and reconnect and then if all goes smoothly the logs will show something like:

.. code-block:: shell

    initialised inbox (0x95850c6..  .bceee6c -> 0xa5df94b..  .bef1e5) expected signer: 041e185925bb..  ..  ..  702cf5e73cf8d618
    [SWAP] <enode://23ae0e62..  ..  ..  8a4c6bc93b7d2aa4fb@195.228.155.76:30301> set autocash to every 5m0s, max uncashed limit: 50000000000000
    [SWAP] <enode://23ae0e62..  ..  ..  8a4c6bc93b7d2aa4fb@195.228.155.76:30301> set autodeposit to every 5m0s, pay at: 50000000000000, buffer: 100000000000000
    [SWAP] <enode://23ae0e62..  ..  ..  8a4c6bc93b7d2aa4fb@195.228.155.76:30301> remote profile set: pay at: 100, drop at: 10000, buy at: 20000000000, sell at: 20000000000
    [SWAP] <enode://23ae0e62..  ..  ..  8a4c6bc93b7d2aa4fb@195.228.155.76:30301> remote profile set: pay at: 100, drop at: 10000, buy at: 20000000000, sell at: 20000000000
    [BZZ] SWAP arrangement with <node://23ae0e62...8a4c6bc93b7d2aa4fb@195.228.155.76:30301>: purchase from peer enabled at 20000000000 wei/chunk; selling to peer enabled at 20000000000 wei/chunk)

As part of normal operation, after a peer reaches a balance of ``PayAt`` (number of chunks), a cheque payment is sent via the protocol. Logs on the receiving end:

.. code-block:: shell

    [CHEQUEBOOK] verify cheque: contract: 0x95850..  .eee6c, beneficiary: 0xe10536ae628..  .cdc085e491, amount: 868020000000000,signature: a7d52dc744b8..  ..  ..  f1fe2001 - sum: 866020000000000
    [CHEQUEBOOK] received cheque of 2000000000000 wei in inbox (0x95850..  .eee6c, uncashed: 42000000000000)


..  index:: autocash, cheque

The cheque is verified. If uncashed cheques have an outstanding balance of more than ``AutoCashThreshold``, the last cheque (with a cumulative amount) is cashed. This is done by sending a transaction containing the cheque to the remote peer's cheuebook contract. Therefore in order to cash a payment, your sender account (baseaddress) needs to have funds and the network should be mining.

.. code-block:: shell

   [CHEQUEBOOK] cashing cheque (total: 104000000000000) on chequebook (0x95850c6..  .eee6c) sending to 0xa5df94be..  .e5aaz

For further fine tuning of SWAP, see :ref:`swap_params`.

..  index::
   AutoDepositBuffer, credit buffer
   AutoCashThreshold, autocash threshold
   AutoDepositThreshold: autodeposit threshold
   AutoCashInterval, autocash interval
   AutoCashBuffer, autocash target credit buffer
