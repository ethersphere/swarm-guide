*************************
Installation and Updates
*************************

Installation
=======================
Swarm is part of the Ethereum stack, the reference implementation is currently at POC (proof of concept) version 0.2.

The source code is found on github: https://github.com/ethereum/go-ethereum/tree/swarm/

Supported Platforms
=========================

Geth runs on all major platforms (linux, MacOSX, Windows, also raspberry pi, android OS, iOS).

..  note::
  This package has not been tested on platforms other than linux and OSX.

Prerequisites
================

building the swarm daemon :command:`bzzd` requires the following packages:

* go: https://golang.org
* git: http://git.org


Grab the relevant prerequisites and build from source.

On linux (ubuntu/debian variants) use ``apt`` to install go and git

.. code-block:: none

  sudo apt install golang git

while on Mac OSX you'd use :command:`brew`

.. code-block:: none

    brew install go git

Then you must prepare your go environment as follows

.. code-block:: none

  mkdir ~/go
  export GOPATH="$HOME/go"
  echo 'export GOPATH="$HOME/go"' >> ~/.profile

Installing from source
=======================

Once all prerequisites are met, download the go-ethereum source code

.. code-block:: none

  mkdir -p $GOPATH/src/github.com/ethereum
  cd $GOPATH/src/github.com/ethereum
  git clone https://github.com/ethereum/go-ethereum
  cd go-ethereum
  git checkout master
  go get github.com/ethereum/go-ethereum

and finally compile the swarm daemon ``bzzd`` and the main go-ethereum client ``geth`` and (optionally) the bzz uploader ``bzzup`` and bzzhash calculator ``bzzhash``

.. code-block:: none

  go build ./cmd/bzzd
  go build ./cmd/geth
  go build ./cmd/bzzup
  go build ./cmd/bzzhash


You can now run :command:`./bzzd` to start your swarm node.


Updating your client
=====================

To update your client simply download the newest source code and recompile.

.. code-block:: none

  cd $GOPATH/src/github.com/ethereum/go-ethereum
  git checkout master
  git pull
  go build ./cmd/geth ./cmd/bzzd ./cmd/bzzup

******************************
Running you own private swarm
******************************

Running your swarm client
===========================

To start a basic swarm node we must start geth with an empty data directory on a private network and then connect the swarm daemon to this instance of geth.

First set aside an empty temporary directory to be the data store

.. code-block:: none

   DATADIR=/tmp/BZZ/`date +%s`

then make a new account using this directory

.. code-block:: none

  ./geth --datadir $DATADIR account new

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

and finally, launch geth on a private network (id 322)

.. code-block:: none

  nohup ./geth --datadir $DATADIR \
         --unlock 0 \
         --password <(echo -n "MYPASSWORD") \
         --verbosity 6 \
         --networkid 322 \
         --nodiscover \
         --maxpeers 0 \
          2>> $DATADIR/geth.log &

and launch the bzzd; connecting it to the geth node

.. code-block:: none

  ./bzzd --bzzaccount $BZZKEY \
         --datadir $DATADIR \
         --ethapi $DATADIR/geth.ipc \
         --bzznoswap \
         --maxpeers 0 \
         2>> $DATADIR/bzz.log < <(echo -n "MYPASSWORD") &

At this verbosity level you should see plenty of output accumulating in the logfiles. You can keep an eye on the output by using the command ``tail -f $DATADIR/bzz.log`` and ``tail -f $DATADIR/geth.log``. Note: if doing this from another terminal you will have to specify the path manually because $DATADIR will be empty.

.. note:: Following these instructions you are now running a single local swarm node, not connected to any other. 

Testing SWAP on your private Swarm.
---------------------------------------
.. note:: Please: only test SWAP on a private network.

The SWarm Accounting Protocol (SWAP) is disabled above by use of the ``--bzznoswap`` flag. If it is set to false, then SWAP will be enabled. However, activating SWAP requires more than just removing the bzznoswap flag. This is because it requires a chequebook contract to be deployed and for that we need to have ether in the main account. We can get some ether either through mining or by simply issuing ourselves some ether in a custom genesis block.

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

If you already have bzzd and geth running, kill the processes

.. code-block:: none
  
  killall -s SIGKILL geth
  killall -s SIGKILL bzzd

and remove the old data from the $DATADIR and then reinitialise with the custom genesis block

.. code-block:: none

  rm -rf $DATADIR/geth $DATADIR/bzzd
  ./geth --datadir $DATADIR init $DATADIR/genesis.json

We are now ready to restart geth and bzzd using our custom genesis block

.. code-block:: none

  nohup ./geth --datadir $DATADIR \
         --mine \
         --unlock 0 \
         --password <(echo -n "MYPASSWORD") \
         --verbosity 6 \
         --networkid 322 \
         --nodiscover \
         --maxpeers 0 \
          2>> $DATADIR/geth.log &

and launch the bzzd (with SWAP); connecting it to the geth node

.. code-block:: none

  ./bzzd --bzzaccount $BZZKEY \
         --datadir $DATADIR \
         --ethapi $DATADIR/geth.ipc \
         --maxpeers 0 \
         2>> $DATADIR/bzz.log < <(echo -n "MYPASSWORD") &

If all is successful you will see the message "Deploying new chequebook" on the bzz.log. Once the transaction is mined, SWAP is ready.

.. note:: Astute readers will notice that enabling SWAP while setting maxpeers to 0 seems futile. These instructions will be updated soon to allow you to run a private swap testnet with several peers.

Mining on your private chain
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The alternative to creating a custom genesis block is to earn your all your ether by mining on your private chain.
You can start you geth node in mining mode using the ``--mine`` flag, or (in our case) we can start mining on an already running geth node by issuing the ``miner.start()`` command:

.. code-block:: none
  
  ./geth --exec 'miner.start()' attach ipc:$DATADIR/geth.ipc 

There will be an initial delay while the necessary DAG is generated. You can see the progress in the geth.log file. 
After mining has started, you can see your balance increasing via ``eth.getBalance()``:

.. code-block:: none

  ./geth --exec 'eth.getBalance(eth.coinbase)' attach ipc:$DATADIR/geth.ipc
  # or 
  ./geth --exec 'eth.getBalance(eth.accounts[0])' attach ipc:$DATADIR/geth.ipc


Once the balance is greater than 0 we can restart ``bzzd`` with swap enabled.

.. code-block:: none
  
    killall bzzd
    ./bzzd --bzzaccount $BZZKEY \
         --datadir $DATADIR \
         --ethapi $DATADIR/geth.ipc \
         --maxpeers 0 \
         2>> $DATADIR/bzz.log < <(echo -n "MYPASSWORD") &

Note: without a custom genesis block the mining difficulty may be too high to be practical (depending on your system). You can see the current difficulty with ``admin.nodeInfo``

.. code-block:: none

  ./geth --exec 'admin.nodeInfo' attach ipc:$DATADIR/geth.ipc | grep difficulty

********************************
Connecting to the swarm testnet
********************************

Coming soon.


Command line options
========================

The bzzd swarm daemon has the following swarm specific command line options:


``--bzzconfig value``
    Swarm config file path (datadir/bzz)
    The swarm config file is a json encoded format, the setting in there are documented in the following section

``--bzznoswap``
    Swarm SWAP disabled (default false).
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


Configuration options
============================

This section lists all the options you can set in the swarm configuration file.

The default location for the swarm configuration file is ``<datadir>/bzzd/bzz-<baseaccount>/config.json``. Thus continuing from the previous section, the configuration file would be

.. code-block:: none

  $DATADIR/bzzd/bzz-$BZZKEY/config.json

It is possible to specify a different config file when launching bzzd by using the `--bzzconfig` flag.

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

Syncronisation parameters
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

..  code-block::
   [BZZ] SWAP unable to deploy new chequebook: unable to send chequebook     creation transaction: Account
    does not exist or account     balance too low..  .retrying in 10s

   [BZZ] SWAP arrangement with <enode://23ae0e62..  ..  ..  8a4c6bc93b7d2aa4fb@195.228.155.76:30301>: purchase from peer disabled; selling to peer disabled)

Since no business is possible here, the connection is idle until at least one party has a contract. In fact, this is only enabled for a test phase.
If we are not allowed to purchase chunks, then no outgoing requests are allowed. If we still try to download content that we dont have locally, the request will fail (unless we have credit with other peers).

..  code-block::
    [BZZ] netStore.startSearch: unable to send retrieveRequest to peer [<addr>]: [SWAP] <enode://23ae0e62..  ..  ..  8a4c6bc93b7d2aa4fb@195.228.155.76:30301> we cannot have debt (unable to buy)

Once one of the nodes has funds (say after mining a bit), and also someone on the network is mining, then the autodeployment will eventually succeed:

..  code-block::
    [CHEQUEBOOK] chequebook deployed at 0x77de9813e52e3a..  .c8835ea7 (owner: 0xe10536ae628f7d6e319435ef9b429dcdc085e491)
    [CHEQUEBOOK] new chequebook initialised from 0x77de9813e52e3a..  .c8835ea7 (owner: 0xe10536ae628f7d6e319435ef9b429dcdc085e491)
    [BZZ] SWAP auto deposit ON for 0xe10536 -> 0x77de98: interval = 5m0s, threshold = 50000000000000, buffer = 100000000000000)
    [BZZ] Swarm: new chequebook set: saving config file, resetting all connections in the hive
    [KΛÐ]: remove node enode://23ae0e6..  .aa4fb@195.228.155.76:30301 from table

Once the node deployed a new chequebook, its address is set in the config file and all connections are reset with the new conditions. Purchase in one direction should be enabled. The logs from the point of view of the peer with no valid chequebook:


..  code-block::
    [CHEQUEBOOK] initialised inbox (0x9585..  .3bceee6c -> 0xa5df94be..  .bbef1e5) expected signer: 041e18592..  ..  ..  702cf5e73cf8d618
    [SWAP] <enode://23ae0e62..  ..  ..  8a4c6bc93b7d2aa4fb@195.228.155.76:30301>    set autocash to every 5m0s, max uncashed limit: 50000000000000
    [SWAP] <enode://23ae0e62..  ..  ..  8a4c6bc93b7d2aa4fb@195.228.155.76:30301>    autodeposit off (not buying)
    [SWAP] <enode://23ae0e62..  ..  ..  8a4c6bc93b7d2aa4fb@195.228.155.76:30301>    remote profile set: pay at: 100, drop at: 10000,    buy at: 20000000000, sell at: 20000000000
    [BZZ] SWAP arrangement with <enode://23ae0e62..  ..  ..  8a4c6bc93b7d2aa4fb@195.228.155.76:30301>: purchase from peer disabled;   selling to peer enabled at 20000000000 wei/chunk)


..  index:: autodeposit

Depending on autodeposit settings, the chequebook will be regularly replenished:

..  code-block::
  [BZZ] SWAP auto deposit ON for 0x6d2c5b -> 0xefbb0c:
   interval = 5m0s, threshold = 50000000000000,
   buffer = 100000000000000)
   deposited 100000000000000 wei to chequebook (0xefbb0c0..  .16dea,  balance: 100000000000000, target: 100000000000000)


The peer with no chequebook (yet) should not be allowed to download and thus retrieve requests will not go out.
The other peer however is able to pay, therefore this other peer can retrieve chunks from the first peer and pay for them. This in turn puts the first peer in positive, which they can then use both to (auto)deploy their own chequebook and to pay for retrieving data as well. If they do not deploy a chequebook for whatever reason, they can use their balance to pay for retrieving data, but only down to 0 balance; after that no more requests are allowed to go out. Again you will see:


..  code-block::
   [BZZ] netStore.startSearch: unable to send retrieveRequest to peer [aff89da0c6...623e5671c01]: [SWAP]  <enode://23ae0e62...8a4c6bc93b7d2aa4fb@195.228.155.76:30301> we cannot have debt (unable to buy)

If a peer without a chequebook tries to send requests without paying, then the remote peer (who can see that they have no chequebook contract) interprets this as adverserial behaviour resulting in the peer being dropped.

Following on in this example, we start mining and then restart the node. The second chequebook autodeploys, the peers sync their chains and reconnect and then if all goes smoothly the logs will show something like:

..  code-block::
    initialised inbox (0x95850c6..  .bceee6c -> 0xa5df94b..  .bef1e5) expected signer: 041e185925bb..  ..  ..  702cf5e73cf8d618
    [SWAP] <enode://23ae0e62..  ..  ..  8a4c6bc93b7d2aa4fb@195.228.155.76:30301> set autocash to every 5m0s, max uncashed limit: 50000000000000
    [SWAP] <enode://23ae0e62..  ..  ..  8a4c6bc93b7d2aa4fb@195.228.155.76:30301> set autodeposit to every 5m0s, pay at: 50000000000000, buffer: 100000000000000
    [SWAP] <enode://23ae0e62..  ..  ..  8a4c6bc93b7d2aa4fb@195.228.155.76:30301> remote profile set: pay at: 100, drop at: 10000, buy at: 20000000000, sell at: 20000000000
    [SWAP] <enode://23ae0e62..  ..  ..  8a4c6bc93b7d2aa4fb@195.228.155.76:30301> remote profile set: pay at: 100, drop at: 10000, buy at: 20000000000, sell at: 20000000000
    [BZZ] SWAP arrangement with <node://23ae0e62...8a4c6bc93b7d2aa4fb@195.228.155.76:30301>: purchase from peer enabled at 20000000000 wei/chunk; selling to peer enabled at 20000000000 wei/chunk)

As part of normal operation, after a peer reaches a balance of ``PayAt`` (number of chunks), a cheque payment is sent via the protocol. Logs on the receiving end:

..  code-block::
    [CHEQUEBOOK] verify cheque: contract: 0x95850..  .eee6c, beneficiary: 0xe10536ae628..  .cdc085e491, amount: 868020000000000,signature: a7d52dc744b8..  ..  ..  f1fe2001 - sum: 866020000000000
    [CHEQUEBOOK] received cheque of 2000000000000 wei in inbox (0x95850..  .eee6c, uncashed: 42000000000000)


..  index:: autocash, cheque

The cheque is verified. If uncashed cheques have an outstanding balance of more than ``AutoCashThreshold``, the last cheque (with a cumulative amount) is cashed. This is done by sending a transaction containing the cheque to the remote peer's cheuebook contract. Therefore in order to cash a payment, your sender account (baseaddress) needs to have funds and the network should be mining.

..  code-block::
   [CHEQUEBOOK] cashing cheque (total: 104000000000000) on chequebook (0x95850c6..  .eee6c) sending to 0xa5df94be..  .e5aaz

For further fine tuning of SWAP, see :ref:`SWAP parameters1.

..  index::
   AutoDepositBuffer, credit buffer
   AutoCashThreshold, autocash threshold
   AutoDepositThreshold: autodeposit threshold
   AutoCashInterval, autocash interval
   AutoCashBuffer, autocash target credit buffer


