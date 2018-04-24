*************************
API Reference
*************************



HTTP
=========================

GET http://localhost:8500/bzz:/domain/some/path
  retrieve document at domain/some/path allowing domain to resolve via the `Ethereum Name Service`_

GET http://localhost:8500/bzz-immutable:/HASH/some/path
  retrieve document at HASH/some/path where HASH is a valid swarm hash

GET http://localhost:8500/bzz-raw:/domain/some/path
  retrieve the raw content at domain/some/path allowing domain to resolve via the `Ethereum Name Service`_

POST http://localhost:8500/bzz:
  The post request is the simplest upload method. Direct upload of files - no manifest is created.
  It returns the hash of the uploaded file

POST http://localhost:8500/bzz:/encrypt
  The post request is the simplest upload method. Direct upload of files - no manifest is created.
  It returns the hash of the uploaded file

POST http://localhost:8500/bzz-raw:
  The post request is the simplest upload method. Direct upload of files - no manifest is created.
  It returns the hash of the uploaded file

POST http://localhost:8500/bzz-raw:/encrypt
  The post request is the simplest upload method. Direct upload of files - no manifest is created.
  It returns the hash of the uploaded file

PUT http://localhost:8500/bzz:/HASH|domain/some/path
  The PUT request publishes the uploaded asset to the manifest. 
  It looks for the manifest by domain or hash, makes a copy of it and updates its collection with the new asset.
  It returns the hash of the newly created manifest.

Javascript
========================
Swarm currently supports a Javascript API through the `swarm-js <https://github.com/MaiaVictor/swarm-js>`_ package which is available through `NPM <https://www.npmjs.com/package/swarm-js>`_ by issuing
the following command:

.. code-block:: none
  
  npm install swarm-js

Usage is as simple as:

.. code-block:: javascript

        const file = "test file"; // could also be an Uint8Array of binary data
        swarm.upload(file).then(hash => {
          console.log("Uploaded file. Address:", hash);
        })
        
.. code-block:: javascript

        const fileHash = "a5c10851ef054c268a2438f10a21f6efe3dc3dcdcc2ea0e6a1a7a38bf8c91e23";
        swarm.download(fileHash).then(array => {
          console.log("Downloaded file:", swarm.toString(array));
        });

.. note:: For the full documentation please refer to the `GitHub`_ page.

.. _GitHub: https://github.com/MaiaVictor/swarm-js

IPC
========================

Swarm exposes an IPC API under the ``bzz`` namespace.

.. note:: Note that this is not the recommended way for users or dapps to interact with swarm and is only meant for debugging ad testing purposes. Given that this module offers local filesystem access, allowing dapps to use this module or exposing it via remote connections creates a major security risk. For this reason ``swarm`` only exposes this api via local ipc (unlike geth not allowing websockets or http).


Chequebook IPC API
------------------------------

Swarm also exposes an IPC API for the chequebook offering the followng methods:

``chequebook.balance()``
  Returns the balance of your swap chequebook contract in wei.
  It errors if no chequebook is set.

``chequebook.issue(beneficiary, value)``
  Issues a cheque to beneficiary (an ethereum address) in the amount of value (given in wei). The json structure returned can be copied and sent to beneficiary who in turn can cash it using ``chequebook.cash(cheque)``.
  It errors if no chequebook is set.

``chequebook.cash(cheque)``
  Cashes the cheque issued. Note that anyone can cash a cheque. Its success only depends on the cheque's validity and the solvency of the issuers chequbook contract up to the amount specified in the cheque. The tranasction is paid from your bzz base account.
  Returns the transaction hash.
  It errors if no chequebook is set or if your account has insufficient funds to send the transaction.

``chequebook.deposit(amount)``
  Transfers funds of amount  wei from your bzz base account to your swap chequebook contract.
  It errors if no chequebook is set  or if your account has insufficient funds.


Example: use of the console
------------------------------

Uploading content
^^^^^^^^^^^^^^^^^^

It is possible to upload files from the swarm console (without the need for swarm command or an http proxy). The console command is

.. code-block:: none

    bzz.upload("/path/to/file/or/directory", "filename")

The command returns the root hash of a manifest. The second argument is optional; it specifies what the empty path should resolve to (often this would be :file:`index.html`). Proceeding as in the example above (`Example: Uploading a directory`_). Prepare some files:

.. code-block:: none

  mkdir upload-test
  echo "one" > upload-test/one.txt
  echo "two" > upload-test/two
  mkdir upload-test/three
  echo "four" > upload-test/three/four

Then execute the ``bzz.upload`` command on the swarm console: (note ``bzzd.ipc`` instead of ``geth.ipc``)

.. code-block:: none

    ./geth --exec 'bzz.upload("upload-test/", "one.txt")' attach ipc:$DATADIR/bzzd.ipc

We get the output:

.. code-block:: none

        dec805295032e7b712ce4d90ff3b31092a861ded5244e3debce7894c537bd440

If we open this HASH in a browser

.. code-block:: none

  http://localhost:8500/bzz:/dec805295032e7b712ce4d90ff3b31092a861ded5244e3debce7894c537bd440/

We see "one" because the empty path resolves to "one.txt". Other valid URLs are

.. code-block:: none

  http://localhost:8500/bzz:/dec805295032e7b712ce4d90ff3b31092a861ded5244e3debce7894c537bd440/one.txt
  http://localhost:8500/bzz:/dec805295032e7b712ce4d90ff3b31092a861ded5244e3debce7894c537bd440/two
  http://localhost:8500/bzz:/dec805295032e7b712ce4d90ff3b31092a861ded5244e3debce7894c537bd440/three/four

We only recommend using this API for testing purposes or command line scripts. Since they save on http file upload, their performance is somewhat better than using the http API.

Downloading content
^^^^^^^^^^^^^^^^^^^^

As an alternative to http to retrieve content, you can use ``bzz.get(HASH)`` or ``bzz.download(HASH, /path/to/download/to)`` on the swarm console (note ``bzzd.ipc`` instead of ``geth.ipc``)

.. code-block:: none

    ./geth --exec 'bzz.get(HASH)' attach ipc:$DATADIR/bzzd.ipc
    ./geth --exec 'bzz.download(HASH, "/path/to/download/to")' attach ipc:$DATADIR/bzzd.ipc
