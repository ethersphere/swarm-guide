******************************
Configuration
******************************


Command line options for swarm
====================================

The ``swarm`` executable supports the following configuration options:

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


Config File
=============

.. note:: ``swarm`` can be executed with the ``dumpconfig`` command, which prints a default configuration to STDOUT, and thus can be redirected to a file as a template for the config file.


A TOML configuration file is organized in sections. The below list of available configuration options is organized according to these sections. The sections correspond to `Go` modules, so need to be respected in order for file configuration to work properly. See `<https://github.com/naoina/toml>`_ for the TOML parser and encoder library for Golang, and `<https://github.com/toml-lang/toml>`_ for further information on TOML.


General configuration parameters
================================

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
   "SyncEnabled","--sync","SWARM_SYNC_ENABLE","true","Disable Swarm node synchronization. This option will be deprecated. It is only for testing."
   "SwapApi","--swap-api","SWARM_SWAP_API","","URL of the Ethereum API provider to use to settle SWAP payments"
   "Cors","--corsdomain","SWARM_CORS", "","Domain on which to send Access-Control-Allow-Origin header (multiple domains can be supplied separated by a ',')"
   "BzzAccount","--bzzaccount","SWARM_ACCOUNT", "","Swarm account key"
   "BootNodes","--boot-nodes","SWARM_BOOTNODES","","Boot nodes"
