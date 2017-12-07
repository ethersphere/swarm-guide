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

Swarm runs an HTTP API. Thus, a simple way to upload and download files to/from Swarm is through this API.
We can use the ``curl`` tool to exemplify how to interact with this API.

.. note:: Files can be uploaded in a single HTTP request, where the body is either a single file to store, a tar stream (application/x-tar) or a multipart form (multipart/form-data).

To upload a single file, run this:

.. code-block:: none

  curl -H "Content-Type: text/plain" --data-binary "some-data" http://localhost:8500/bzz:/

Once the file is uploaded, you will receive a hex string which will look similar to.

.. code-block:: none

  027e57bcbae76c4b6a1c5ce589be41232498f1af86e1b1a2fc2bdffd740e9b39

This is the address string of your content inside Swarm.

To download a file from swarm, you just need the file's address string. Once you have it the process is simple. Run:

.. code-block:: none

  curl http://localhost:8500/bzz:/027e57bcbae76c4b6a1c5ce589be41232498f1af86e1b1a2fc2bdffd740e9b39

The result should be your file:

.. code-block:: none

  some-data

And that's it.

Tar stream upload
-----------------

.. code-block:: none

  ( mkdir dir1 dir2; echo "some-data" | tee dir1/file.txt | tee dir2/file.txt; )

  tar c dir1/file.txt dir2/file.txt | curl -H "Content-Type: application/x-tar" --data-binary @- http://localhost:8500/bzz:/
  > 1e0e21894d731271e50ea2cecf60801fdc8d0b23ae33b9e808e5789346e3355e

  curl http://localhost:8500/bzz:/1e0e21894d731271e50ea2cecf60801fdc8d0b23ae33b9e808e5789346e3355e/dir1/file.txt
  > some-data

  curl http://localhost:8500/bzz:/1e0e21894d731271e50ea2cecf60801fdc8d0b23ae33b9e808e5789346e3355e/dir2/file.txt
  > some-data

GET requests work the same as before with the added ability to download multiple files by setting `Accept: application/x-tar`:

.. code-block:: none

  curl -s -H "Accept: application/x-tar" http://localhost:8500/bzz:/ccef599d1a13bed9989e424011aed2c023fce25917864cd7de38a761567410b8/ | tar t
  > dir1/file.txt
    dir2/file.txt
    dir3/file.txt

 
Multipart form upload
---------------------

.. code-block:: none

  curl -F 'dir1/file.txt=some-data;type=text/plain' -F 'dir2/file.txt=some-data;type=text/plain' http://localhost:8500/bzz:/
  > 9557bc9bb38d60368f5f07aae289337fcc23b4a03b12bb40a0e3e0689f76c177

  curl http://localhost:8500/bzz:/9557bc9bb38d60368f5f07aae289337fcc23b4a03b12bb40a0e3e0689f76c177/dir1/file.txt 
  > some-data

  curl http://localhost:8500/bzz:/9557bc9bb38d60368f5f07aae289337fcc23b4a03b12bb40a0e3e0689f76c177/dir2/file.txt
  > some-data


Files can also be added to an existing manifest:
------------------------------------------------

.. code-block:: none

  curl -F 'dir3/file.txt=some-other-data;type=text/plain' http://localhost:8500/bzz:/9557bc9bb38d60368f5f07aae289337fcc23b4a03b12bb40a0e3e0689f76c177 
  > ccef599d1a13bed9989e424011aed2c023fce25917864cd7de38a761567410b8

  curl http://localhost:8500/bzz:/ccef599d1a13bed9989e424011aed2c023fce25917864cd7de38a761567410b8/dir1/file.txt
  > some-data

  curl http://localhost:8500/bzz:/ccef599d1a13bed9989e424011aed2c023fce25917864cd7de38a761567410b8/dir3/file.txt
  > some-other-data


Files can also be uploaded using a simple HTML form:
----------------------------------------------------

.. code-block:: html 

  <form method="POST" action="/bzz:/" enctype="multipart/form-data">
    <input type="file" name="dir1/file.txt">
    <input type="file" name="dir2/file.txt">
    <input type="submit" value="upload">
  </form>


Listing files
-------------

Setting `list=true` in the query of a `GET` request returns a list of files contained under the path, grouped into common prefixes which represent directories:

.. code-block:: none

   curl -s http://localhost:8500/bzz:/ccef599d1a13bed9989e424011aed2c023fce25917864cd7de38a761567410b8/?list=true | jq .
   > {
      "common_prefixes": [
        "dir1/",
        "dir2/",
        "dir3/"
      ]
    }

.. code-block:: none

    curl -s http://localhost:8500/bzz:/ccef599d1a13bed9989e424011aed2c023fce25917864cd7de38a761567410b8/dir1/?list=true | jq .
    > {
      "entries": [
        {
          "path": "dir1/file.txt",
          "contentType": "text/plain",
          "size": 9,
          "mod_time": "2017-03-12T15:19:55.112597383Z",
          "hash": "94f78a45c7897957809544aa6d68aa7ad35df695713895953b885aca274bd955"
        }
      ]
    }

Setting Accept: text/html returns the list as a browsable HTML document



Good luck, we hope you will enjoy using Swarm!
