
******************************
Running the swarm client
******************************

These instructions will begin by laying out how to start a local, private, personal (singleton) swarm. Use this to familiarise yourself with the functioning of the client; upload and download and http proxy.

Preparation
===========================

To start a basic swarm node we must start geth with an empty data directory on a private network and then connect the swarm daemon to this instance of geth.

First set aside an empty temporary directory to be the data store

..  note:: If you followed the installation instructions from this guide, you will find your executables in the $GOPATH/bin directory. Make sure to move your files into an executable $PATH, or include $GOPATH/bin directory on it.

.. code-block:: none

   DATADIR=/tmp/BZZ/`date +%s`

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


With the preparations complete, we can now launch our swarm client. In what follows we detail a few ways you might want to use swarm.


* connecting to the swarm testnet without blockchain
* connecting to the swarm testnet and connecting to the Ropsten blockchain
* using swarm in singleton mode for local testing
* launching a private swarm
* testing SWAP accounting with a private Swarm

Connecting to the swarm testnet
=================================



.. note::
    IMPORTANT: Automatic connection to the testnet is currently not working properly for all users. This issue is being fixed right now. In the meantime, please add a few enodes manually to bootstrap your node. See "Adding enodes manually" below.

Swarm needs an ethereum blockchain for

* domain name resolution using the Ethereum Name Service (ENS) contract.
* incentivisation (for example: SWAP)

If you do not care about domain resolution and run your swarm without SWAP (the default), then connecting to the blockchain is unnecessary. Hence ``swarm`` does not require the ``--ethapi`` flag.


Connecting swarm only (no blockchain)
-------------------------------------


Set up you environment as seen above, ie., make sure you have a data directory.

..  note::  Even though you do not need the ethereum blockchain, you will need geth to generate a swarm account ($BZZKEY), since this account determines the base address that your swarm node is going to use.

.. code-block:: none

  swarm --bzzaccount $BZZKEY \
         --datadir $DATADIR \
         2>> $DATADIR/swarm.log < <(echo -n "MYPASSWORD") &

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
         --password <(echo -n "MYPASSWORD") \
         --testnet \
          2>> $DATADIR/geth.log &

Then launch the swarm; connecting it to the geth node (--ethapi).


.. code-block:: none

  swarm --bzzaccount $BZZKEY \
         --datadir $DATADIR \
         --keystore $DATADIR/testnet/keystore \
         --ethapi $DATADIR/geth.ipc \
         2>> $DATADIR/swarm.log < <(echo -n "MYPASSWORD") &

Adding enodes manually
------------------------

Eventually automatic node discovery will be working for swarm nodes. Until then you can start off the connection process by adding a few peers manually using the ``admin.addPeer`` console command.

.. code-block:: none

  geth --exec='admin.addPeer("ENODE")' attach ipc:/path/to/bzzd.ipc

Where ENODE is one of the following:

.. code-block:: none

    enode://9ce417169fe509edd1bec381dacdae65ef16f395135c4ad79f8286a263ad58226be3ae0b1dc619edaa2c5420c2aed4bb22571fdac0453a37e2bfee5efe51c67c@13.74.157.139:30399
    enode://d6f8fce0d91e4fc22debc8d00543408d2a200eef7ff9484a73402e5baa3d5a563ce83e7c57b77931d768ff129519471fb96c7562df1869081c186dca4550dd8b@13.74.157.139:30400
    enode://2b22c2d26d8ecc8e43a1fdb4e5768222e6ae136bd98259c4b2d630fafad33baf331e97c4a0edb886ae61dcdc2652a8af780d158b0b3460f3719ec040df3c0cf0@13.74.157.139:30401
    enode://72d1453047a0ec58b35b3994fcfb77c5e86b555075d629493986302c764e382b4e6aae679405122af2108184dae65da3fac0110855c50bd014941e6dccbe8c64@13.74.157.139:30402
    enode://0a93bd6a8ce52be02a688a1a3126fd39b8e51572dec403b68073575fc97f635cd44ea4183767ed19cd4c4e68d49a156a847acec27fd590bedc62947e098b8a0f@13.74.157.139:30403
    enode://855be7c00e5c05b46eb813ef877062704e5ad8165fe2a8efe703cdd73a81144cf524b6e12dcc1d5b10a8a49fa17ed45042a6407a9b0a3184b4c1f0e11fa1d0ce@13.74.157.139:30404
    enode://0029fc11219b90e4ed4d7b8805f5bc4b9b53c9ebf69f21230630ed6d5ec3d672617a8ef34059f9d6857ab89046eae65c93aa2157c46cf4a261a88a2885669d1a@13.74.157.139:30405
    enode://375955c1321129e7309a838f77649be59a52b33bfa20ca7ac41c7252022d2ca434daee9ba85e6af7698debe1319f34941916eacf65921831c4f7b93eadba3d2b@13.74.157.139:30406
    enode://bca3ceca443935f9db1cd80df473527d7d0e1fb762a6b345b52e6a4e6d63bd0e040adbb8bb173ea0b72d30f35cc57e5472c6f6e823c8ef5006d20a085e2dbcc1@13.74.157.139:30407
    enode://c141ed8bb6431a6cde7ece23b8d530ccec6c0d8c8e1869f6da95476f2461962f976a102cc0cd37a873d6fbe80770529a668437f8179383fdc3d739f6fb6c26d9@13.74.157.139:30408
    enode://fc1b81b8e829754ede5ee1150412610099c59820489f83348ac1dac8e1e9b13a7e92b7567be5774d2aebbfc7894d097c1141a13f5dd8b2e91083fb354a74fc47@13.74.157.139:30409
    enode://bde8075c7ae49c6ccd42546ca69149d5094e0ced0ed927229539d596e5434685f557af0887df3bff1c6e1a978474e126374050899ed4734571d22fd4f289af10@13.74.157.139:30410
    enode://90941f0c45d037b0e0e1f33bc317f9ca8c5e1edff232736a68b30b6fa2537db8084d3e08e143f98fece1bae47732737e7cc3f1f6b4567febc39361d0e03d41d0@13.74.157.139:30411
    enode://55ff0e8c46010a00371ce5729c5cc8456891d88c3ac2aba15692536d8fcc0d34e8c701405d395500704bf9c581032dd2d20194ce10dc4cff5395e6e0b963c025@13.74.157.139:30412
    enode://113bc8b69f8591ca58d0d35a125e79a711d85a873af94238cd7655d39304ee559a77c05662f17c7f4dc68391e8f94895711d46330ef1df11ccf386e9a7524518@13.74.157.139:30413
    enode://21ac7f7c10cb7960eb3cec1fb3f831bb8438a2f70bfb267c22c3784d2c66eda2d8a554509970cd11798a3105302ed5c640edccc97907080a3b918fa464788c27@13.74.157.139:30414
    enode://83e8dd68f491f79af1b70893272035bd10bae2d9393c13d9aee7b7162b2b093e5f3cf7626a6aeb15d16f93226321cc9a1bc472d6b3cf4f9a19d1908925bed81d@13.74.157.139:30415
    enode://5019af94ceff118323d5199c18723e70ecdabc7e58fdf111c77f156bddab1c9d016dbf7cb078de70a4f031593f0a16c12213a7412e1fc45ac812a53780d940fb@13.74.157.139:30416
    enode://ae22702c20ae8a4ae0c6b1d9935d2a82a7d11325d3ed5fe2105d80ebbdc66e504d334a74fe24e363b11c11355a22989c105849b31d2beae884f17f8946db11ce@13.74.157.139:30417
    enode://1a0fbb90305ddb31948721d61b76fe007cf82add44881aa7a22425d98dac42d2778fbe0f8d137d4e8c9cc04b6b7d39180a08caf52e281bc352d52798058c3cf3@13.74.157.139:30418
    enode://002c8b55f15700e4c8d41a7c23cf1d6f7125b71e477b82d8de68cda3cbe37a83a8d7fb6fb6df7eddde2e270730a0e41358326fc1e3c27786c7b683cbfb1644e1@13.74.157.139:30419
    enode://d6863a7fb35a61f1714835134b882f2678a52bdef073b4705184124fc09cc7aa652e8a27bccc7893edf1ef206cb628ad2fa561bf9ce390689cef1d0642708451@13.74.157.139:30420
    enode://2728a506f7f39eb72a00eca9361268ee87629d9e411e2717fe4cac40a62e57ee4f3d715666a63934b21ae702d90faa48ec87225580db72c89f5295e6f77b490c@13.74.157.139:30421
    enode://0e85a9e075034fdad1905303f70df5bfef79ae58979413db46935d8947c38af2fd2a3b4d07cbfe55a7fbacb7db04d35e625c6fd77eef1be9b1814261a92eb40f@13.74.157.139:30422
    enode://6e63ebe988e88fd467f3b275ad60a73c82f0d83cf455b4aa41f7bb886a3c105aad16b11228cd24df17890ddb1b2d99284ea7e5fa0959b610e3351c948dc97da8@13.74.157.139:30423
    enode://017d05134ba69abefbef61e98a68eddb5de97902b0ae28ab2c134be2660ef7a8b5823aed068f2ba9f939dbc21ef887e3ca48d53d19964105a9efb1ade0ca93cd@13.74.157.139:30424
    enode://31405dbd685cc5d64bfef3dd3d8cd370e2c026641b582b06083097e79f5ceb6555601e2986f7cd7ad9b29ac31d242ba824e3c9c969444466e4513a992257ee99@13.74.157.139:30425
    enode://3695d242e5fcc366e4172d808d13bff431f6eda9285c3eb0c89879c94a40c9efee97a3f1fb7899880ba4afcacd04eabafec800fc4b97a447c7844e034b948973@13.74.157.139:30426
    enode://6a64360359bbac28a6876953d04faa34d24d658491e2ce72028622719781ddc093843a543c85a93e6a77d1096f07108f49177f68eac0d428c4ede5507714d26a@13.74.157.139:30427
    enode://fda5af0108be321faf36909a5584dbaea9072d66432781f309dd6eec17b4d47fcad5170e8d8e93fecb1a263fc53146b513c2dc11c8fc66e79e3f0824b66e7a3c@13.74.157.139:30428
    enode://8926f7a89d25b8ef889bbcfdcb9f3172a35bde7b6f410ac1e41e01fea665a91272dfdfa31699f9262b4a73b81fa9fad494ce03b58bebf4a5588cd4370708131c@13.74.157.139:30429
    enode://f2d10c82f1f21842ca6c0c7db0c600d2b78c3dfc9cef558095eb93d01952cc1ae3d73971caf112b55cd82c97f6b552d42844798dfa78ebf5dc5d803487b6e3d2@13.74.157.139:30430
    enode://1e5521a0abd3816a7df9d519286f228fbf66e0eab65fd687b71e3ca7e591308f3d861d40bb09222d3db584fc6e64e42814005c17c8b220971c15fc7cfc34007b@13.74.157.139:30431
    enode://21652a2773916870108700353eec4cf5eb1c68e343bc18a511e2b47c8251b49130e92e50310993e0cf816647edc0af28e46906590babbff0d76a719ece529951@13.74.157.139:30432
    enode://cd816aac2ba313f4c1a8426dea6fcc47f3a4893f1f653da0f5692f6716e5f84ed52f682f01cac79a9ff39cfc03d6abb27b049d570106abbf5867d950f4553e46@13.74.157.139:30433




Swarm in singleton mode
===========================

To launch in singleton mode, start geth using ``--maxpeers 0``

.. code-block:: none

  nohup geth --datadir $DATADIR \
         --unlock 0 \
         --password <(echo -n "MYPASSWORD") \
         --verbosity 6 \
         --networkid 322 \
         --nodiscover \
         --maxpeers 0 \
          2>> $DATADIR/geth.log &

and launch the swarm; connecting it to the geth node. For consistency, let's use the same network id 322  as geth.

.. code-block:: none

  swarm --bzzaccount $BZZKEY \
         --datadir $DATADIR \
         --ethapi $DATADIR/geth.ipc \
         --verbosity 6 \
         --maxpeers 0 \
         --networkid 322 \
         2>> $DATADIR/swarm.log < <(echo -n "MYPASSWORD") &

.. note:: In this example, running geth is optional, it is not strictly needed. To run without geth, simply remove the --ethapi flag from swarm.

At this verbosity level you should see plenty(!) of output accumulating in the logfiles. You can keep an eye on the output by using the command ``tail -f $DATADIR/swarm.log`` and ``tail -f $DATADIR/geth.log``. Note: if doing this from another terminal you will have to specify the path manually because $DATADIR will not be set.

You can change the verbosity level without restarting geth and swarm via the console:

.. code-block:: none

  geth --exec "web3.debug.verbosity(3)" attach ipc:$DATADIR/geth.ipc
  geth --exec "web3.debug.verbosity(3)" attach ipc:$DATADIR/bzzd.ipc


.. note:: Following these instructions you are now running a single local swarm node, not connected to any other.


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

These relatively tedious steps of managing connections needs to be performed only once. If you bring up the same nodes a second time, earlier peers are remembered and contacted.

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

If you want to run all these instructions in a single script, you can wrap them in something like

.. code-block:: bash

  #!/bin/bash

  # Working directory
  cd /tmp

  # Preparation
  DATADIR=/tmp/BZZ/`date +%s`
  mkdir -p $DATADIR
  read -s -p "Enter Password. It will be stored in $DATADIR/my-password: " MYPASSWORD && echo $MYPASSWORD > $DATADIR/my-password
  echo
  BZZKEY=$($GOPATH/bin/geth --datadir $DATADIR --password $DATADIR/my-password account new | awk -F"{|}" '{print $2}')

  echo "Your account is ready: "$BZZKEY

  # Run geth in the background
  nohup $GOPATH/bin/geth --datadir $DATADIR \
      --unlock 0 \
      --password <(cat $DATADIR/my-password) \
      --verbosity 6 \
      --networkid 322 \
      --nodiscover \
      --maxpeers 0 \
      2>> $DATADIR/geth.log &

  echo "geth is running in the background, you can check its logs at "$DATADIR"/geth.log"

  # Now run swarm in the background
  $GOPATH/bin/swarm \
      --bzzaccount $BZZKEY \
      --datadir $DATADIR \
      --ethapi $DATADIR/geth.ipc \
      --verbosity 6 \
      --maxpeers 0 \
      --bzznetworkid 322 \
      &> $DATADIR/swarm.log < <(cat $DATADIR/my-password) &


  echo "swarm is running in the background, you can check its logs at "$DATADIR"/swarm.log"

  # Cleaning up
  # You need to perform this feature manually
  # USE THESE COMMANDS AT YOUR OWN RISK!
  ##
  # kill -9 $(ps aux | grep swarm | grep bzzaccount | awk '{print $2}')
  # kill -9 $(ps aux | grep geth | grep datadir | awk '{print $2}')
  # rm -rf /tmp/BZZ


Testing SWAP
===============

.. note:: Important! Please only test SWAP on a private network.

Testing SWAP on your private blockchain.
-----------------------------------------

The SWarm Accounting Protocol (SWAP) is disabled by default. Use of the ``--swap`` flag to enable it. If it is set to true, then SWAP will be enabled.
However, activating SWAP requires more than just adding the --swap flag. This is because it requires a chequebook contract to be deployed and for that we need to have ether in the main account. We can get some ether either through mining or by simply issuing ourselves some ether in a custom genesis block.

Custom genesis block
^^^^^^^^^^^^^^^^^^^^^^

Open a text editor and write the following (be sure to include the correct BZZKEY)

.. code-block:: none

  {
  "nonce": "0x0000000000000042",
    "mixhash": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "difficulty": "0x4000",
    "alloc": {
      "THE BZZKEY address starting with 0x eg. 0x2f1cd699b0bf461dcfbf0098ad8f5587b038f0f1": {
      "balance": "10000000000000000000"
      }
    },
    "coinbase": "0x0000000000000000000000000000000000000000",
    "timestamp": "0x00",
    "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "extraData": "Custom Ethereum Genesis Block to test Swarm with SWAP",
    "gasLimit": "0xffffffff"
  }

Save the file as ``$DATADIR/genesis.json``.

If you already have swarm and geth running, kill the processes

.. code-block:: none

  killall -s SIGKILL geth
  killall -s SIGKILL swarm

and remove the old data from the $DATADIR and then reinitialise with the custom genesis block

.. code-block:: none

  rm -rf $DATADIR/geth $DATADIR/swarm
  geth --datadir $DATADIR init $DATADIR/genesis.json

We are now ready to restart geth and swarm using our custom genesis block

.. code-block:: none

  nohup geth --datadir $DATADIR \
         --mine \
         --unlock 0 \
         --password <(echo -n "MYPASSWORD") \
         --verbosity 6 \
         --networkid 322 \
         --nodiscover \
         --maxpeers 0 \
          2>> $DATADIR/geth.log &

and launch the swarm (with SWAP); connecting it to the geth node. For consistency let's use the same network id  322 for the swarm private network.

.. code-block:: none

  swarm --bzzaccount $BZZKEY \
         --swap \
         --datadir $DATADIR \
         --verbosity 6 \
         --ethapi $DATADIR/geth.ipc \
         --maxpeers 0 \
         --networkid 322 \
         2>> $DATADIR/swarm.log < <(echo -n "MYPASSWORD") &

If all is successful you will see the message "Deploying new chequebook" on the swarm.log. Once the transaction is mined, SWAP is ready.

.. note:: Astute readers will notice that enabling SWAP while setting maxpeers to 0 seems futile. These instructions will be updated soon to allow you to run a private swap testnet with several peers.

Mining on your private chain
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The alternative to creating a custom genesis block is to earn your all your ether by mining on your private chain.
You can start you geth node in mining mode using the ``--mine`` flag, or (in our case) we can start mining on an already running geth node by issuing the ``miner.start()`` command:

.. code-block:: none

   geth --exec 'miner.start()' attach ipc:$DATADIR/geth.ipc

There will be an initial delay while the necessary DAG is generated. You can see the progress in the geth.log file.
After mining has started, you can see your balance increasing via ``eth.getBalance()``:

.. code-block:: none

  geth --exec 'eth.getBalance(eth.coinbase)' attach ipc:$DATADIR/geth.ipc
  # or
  geth --exec 'eth.getBalance(eth.accounts[0])' attach ipc:$DATADIR/geth.ipc


Once the balance is greater than 0 we can restart ``swarm`` with swap enabled.

.. code-block:: none

    killall swarm
    swarm --bzzaccount $BZZKEY \
         --swap \
         --datadir $DATADIR \
         --verbosity 6 \
         --ethapi $DATADIR/geth.ipc \
         --maxpeers 0 \
         2>> $DATADIR/swarm.log < <(echo -n "MYPASSWORD") &

Note: without a custom genesis block the mining difficulty may be too high to be practical (depending on your system). You can see the current difficulty with ``admin.nodeInfo``

.. code-block:: none

  geth --exec 'admin.nodeInfo' attach ipc:$DATADIR/geth.ipc | grep difficulty


Configuration
=====================

Command line options for swarm
==============================

The swarm swarm daemon has the following swarm specific command line options:


``--bzzconfig value``
    Swarm config file path (datadir/bzz)
    The swarm config file is a json encoded format, the setting in there are documented in the following section

``--swap``
    Swarm SWAP enabled (default false).
    The SWAP (Swarm accounting protocol) is switched on by default in the current release.

``--bzznosync``
    Swarm Syncing disabled (default false)
    This option will be deprecated. It is only for testing.

``--bzzport value``
    Swarm local http api port (default 8500)
    Useful if you run multiple swarm instances and want to expose their own http proxy.

``--bzzaccount value``
    Swarm account key
    The base account that determines the node's swarm base address.
    This address determines which chunks are stored and retrieved at the node and therefore
    must not to be changed across sessions.

``--chequebook value``
    chequebook contract address
    the chequebook contract is automatically deployed on the connected blockchain if it doesn't exist.
    it is recorded in the config file, hence specifying it is rarely needed.

The rest of the flags are not swarm specific.


Configuration options
============================

This section lists all the options you can set in the swarm configuration file.

The default location for the swarm configuration file is ``<datadir>/swarm/bzz-<baseaccount>/config.json``. Thus continuing from the previous section, the configuration file would be

.. code-block:: none

  $DATADIR/swarm/bzz-$BZZKEY/config.json

It is possible to specify a different config file when launching swarm by using the `--bzzconfig` flag.

.. note:: The status of this project warrants that there will be potentially a lot
   of changes to these options.


Main parameters
-----------------------

Path  (:file:`<datadir>/bzz-<$BZZKEY>/`)
  swarm data directory

Port (8500)
  port to run the http proxy server

PublicKey
   Public key of your swarm base account


BzzKey
  Swarm node base address (:math:`hash(PublicKey)`). This is used to decide storage based on radius and routing by kademlia.

EnsRoot (0xd344889e0be3e9ef6c26b0f60ef66a32e83c1b69)
    Ethereum Name Service contract address

Storage parameters
-----------------------------

ChunkDbPath (:file:`<datadir>/bzz-<$BZZKEY>/chunks`)
  leveldb directory for persistent storage of chunks


DbCapacity (5000000)
  chunk storage capacity, number of chunks (5M is roughly 20-25GB)


CacheCapacity (5000)
  Number of recent chunks cached in memory


Radius (0)
  Storage Radius: minimum proximity order (number of identical prefix bits of address key) for chunks to warrant storage. Given a storage radius :math:`r` and total number of chunks in the network :math:`n`, the node stores :math:`n*2^{-r}` chunks minimum. If you allow :math:`b` bytes for guaranteed storage and the chunk storage size is :math:`c`, your radius should be set to :math:`int(log_2(nc/b))`


Chunker/bzzhash parameters
-------------------------------


..  index::
   chunker
   bzzhash

Branches (128)
   Number of branches in bzzhash merkle tree. :math:`Branches*ByteSize(Hash)` gives the datasize of chunks.
   This option will be removed in a later release

Hash (SHA3)
   The hash function used by the chunker (base hash algo of bzzhash): SHA3 or SHA256
   This option will be removed in a later release.

Synchronisation parameters
-------------------------------
..  index::
   syncronisation
   smart sync

These parameters are likely to change in POC 0.3

KeyBufferSize (1024)
   In-memory cache for unsynced keys


SyncBufferSize (128)
   In-memory cache for unsynced keys


SyncCacheSize (1024)
   In-memory cache for outgoing deliveries


SyncBatchSize (128)
   Maximum number of unsynced keys sent in one batch


SyncPriorities ([3, 3, 2, 1, 1])
   Array of 5 priorities corresponding to 5 delivery types
   <delivery, propagation, deletion, history, backlog>.
   Specifying a monotonically decreasing list of priorities is highly recommended.

..  index::
   delivery types

SyncModes ([true, true, true, true, false])
   A boolean array specifying confirmation mode ON corresponding to 5 delivery types:
   <delivery, propagation, deletion, history, backlog>.
   Specifying true for a type means all deliveries will be preceeded by a confirmation roundtrip: the hash key is sent first in an unsyncedKeysMsg and delivered only if confirmed in a deliveryRequestMsg.

..  index::
   delivery types
   delivery request message
   unsynced keys message


Hive/Kademlia parameters
---------------------------------
..  index::
   Kademlia

These parameters are likely to change in POC 0.3


CallInterval (1s)
   Time elapsed before attempting to connect to the most needed peer


BucketSize (3)
   Maximum number of active peers in a kademlia proximity bin. If new peer is added, the worst peer in the bin is dropped.


MaxProx (10)
   Highest Proximity order (i.e., Maximum number of identical prefix bits of address key) considered distinct. Given the total number of nodes in the network :math:`N`, MaxProx should be larger than :math:`log_2(N/ProxBinSize)`), safely :math:`log_2(N)`.


ProxBinSize (8)
   Number of most proximate nodes lumped together in the most proximate kademlia bin


KadDbPath (:file:`<datadir>/bzz/bzz-<BZZKEY>/bzz-peers.json`)
   json file path storing the known bzz peers used to bootstrap kademlia table.


SWAP parameters
--------------------

BuyAt (:math:`2*10^{10}` wei)
   highest accepted price per chunk in wei


SellAt (:math:`2*10^{10}` wei)
   offered price per chunk in wei


PayAt (100 chunks)
   Maximum number of chunks served without receiving a cheque. Debt tolerance.


DropAt (10000)
   Maximum number of chunks served without receiving a cheque. Debt tolerance.


AutoCashInterval (:math:`3*10^{11}`, 5 minutes)
   Maximum Time before any outstanding cheques are cashed


AutoCashThreshold (:math:`5*10^{13}`)
   Maximum total amount of uncashed cheques in Wei


AutoDepositInterval (:math:`3*10^{11}`, 5 minutes)
   Maximum time before cheque book is replenished if necessary by sending funds from the baseaccount


AutoDepositThreshold (:math:`5*10^{13}`)
   Minimum balance in Wei required before replenishing the cheque book


AutoDepositBuffer (:math:`10^{14}`)
   Maximum amount of Wei expected as a safety credit buffer on the cheque book


PublicKey (PublicKey(bzzaccount))
   Public key of your swarm base account use


Contract
   Address of the cheque book contract deployed on the Ethereum blockchain. If blank, a new chequebook contract will be deployed.


Beneficiary (Address(PublicKey))
   Ethereum account address serving as beneficiary of incoming cheques


By default, the config file is sought under :file:`<datadir>/bzz/bzz-<$BZZKEY>/config.json`. If this file does not exist at startup, the default config file is created which you can then edit (the directories on the path will be created if necessary). In this case or if ``config.Contract`` is blank (zero address), a new chequebook contract is deployed. Until the contract is confirmed on the blockchain, no outgoing retrieve requests will be allowed.

Setting up SWAP
-------------------------


..  index::
   chequebook
   autodeploy (chequebook contract)


SWAP (Swarm accounting protocol) is the  system that allows fair utilisation of bandwidth (see :ref:`Incentivisation`, esp. :ref:`SWAP -- Swarm Accounting Protocol`).
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

For further fine tuning of SWAP, see :ref:`SWAP parameters`.

..  index::
   AutoDepositBuffer, credit buffer
   AutoCashThreshold, autocash threshold
   AutoDepositThreshold: autodeposit threshold
   AutoCashInterval, autocash interval
   AutoCashBuffer, autocash target credit buffer


