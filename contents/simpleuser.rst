******************************
Connecting to Swarm (Simple)
******************************

These instructions layout the simplest way to use swarm.

How do I connect?
===========================

To start a basic swarm node you must have both geth and swarm installed on your manchine. You can find the relevant instructions in the Installation section of the Swarm manual.

..  note:: You can find the relevant instructions in the Installation and Updates section of the Swarm manual.

If you do have not yet made your Ethereum account, start by running the following command:

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

Since we need to use it later, save it into your ENV variables under the name ``BZZKEY``

.. code-block:: none

  BZZKEY=2f1cd699b0bf461dcfbf0098ad8f5587b038f0f1

Next, start your geth node and establish connection with Ethereum main network with the following command

.. code-block:: none

  geth

After the connection is established, open another terminal window and connect to Swarm with

.. code-block:: none

  swarm --bzzaccount $BZZKEY


How do I upload and download?
==============================

The best way to upload and download files to/from Swarm has to do with using curl.

To upload a single file, run this:

.. code-block:: none

  curl -H "Content-Type: text/plain" --data-binary "some-data" http://localhost:8500/bzz:/

Once the file is uploaded, you will receive a hex string which will look similar to.

.. code-block:: none

  027e57bcbae76c4b6a1c5ce589be41232498f1af86e1b1a2fc2bdffd740e9b39

This is the address string of your file inside Swarm.

To download a file from swarm, you just need the file's address string. Once, you have it the process is simple. Run:

.. code-block:: none

  curl -s http://localhost:8500/bzz:/027e57bcbae76c4b6a1c5ce589be41232498f1af86e1b1a2fc2bdffd740e9b39

And that's it.

Good luck, we hope you enjoyed using Swarm!
