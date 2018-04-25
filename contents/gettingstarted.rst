******************************
Getting started
******************************

These instructions layout the simplest way to connect to the swarm.

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

.. _connect-ens

How do I enable ENS name resolution?
=====================================

The `Ethereum Name Service <http://ens.readthedocs.io/en/latest/introduction.html>`_ is based on a suite of smart contracts running on the Ethereum main network. Thus, in order to use the ENS to resolve names to swarm content hashes, ``go-swarm`` has to connect to a ``geth`` instance that is connected to the Ethereum main net. This is done using the ``--ens-api '/path/to/geth/datadir/geth.ipc'``` flag.

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
