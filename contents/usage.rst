*****************
Usage
*****************

Using a local Swarm Instance
================================

Uploading a file or directory to your local swarm instance
---------------------------------------------------------------

Make sure you have compiled bzzup 

.. code-block:: none
  
  cd $GOPATH/src/github.com/ethereum/go-ethereum
  go build ./cmd/bzzup

The bzzup program makes it easy to upload files and directories to your local swarm instance. Usage:

.. code-block:: none

  ./bzzup /path/to/file/or/directory

Example: uploading a file
^^^^^^^^^^^^^^^^^^^^^^^^^^
Issue the following command to upload the go-ethereum README file to your swarm

.. code-block:: none

  ./bzzup  $GOPATH/src/github.com/ethereum/go-ethereum/README.md 

It produces the following output

.. code-block:: none

  uploading file /home/swarm/go/src/github.com/ethereum/go-ethereum/README.md (16340 bytes)
  uploading manifest
  {
    "hash": "1ff07d819f3c35674c4effc1072de7c8efcb9fb27cc77781f53b990d6b28eb0f",
    "entries": [
      {
        "hash": "14355f4c0e81fb29395d129d338533bddca38129eec7b502242125fa711a4b46",
        "contentType": "text/markdown; charset=utf-8"
      }
    ]
  }

The hash beginning with "14355" is the swarm hash of the README.md file itself and the hash beginning with "1ff07" is the hash of a manifest that contains README.md as its only entry.  

You could then download this file from swarm by pointing your browser to

.. code-block:: none

  http://localhost:8500/bzz:/1ff07d819f3c35674c4effc1072de7c8efcb9fb27cc77781f53b990d6b28eb0f

Example: Uploading a directory
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Uploading directories is achieved with ``bzzup --recursive``.

Let us create some test files

.. code-block:: none

  mkdir upload-test
  echo "one" > upload-test/one.txt
  echo "two" > upload-test/two
  mkdir upload-test/three
  echo "four" > upload-test/three/four

We can upload this directory with

.. code-block:: none

  ./bzzup --recursive upload-test/

The output should look something like 

.. code-block:: none

  uploading file upload-test/one.txt (4 bytes)
  uploading file upload-test/three/four (5 bytes)
  uploading file upload-test/two (4 bytes)
  uploading manifest
  {
    "hash": "6c64ae708609be4cc34027b38b1104f0ea8dafd5164343117ce421f7714b5e98",
    "entries": [
      {
        "hash": "e57619a0be1101b948afc89dcfb9ce430f38fba9be19fd0a3ed7424d500340a4",
        "contentType": "text/plain; charset=utf-8",
        "path": "one.txt"
      },
      {
        "hash": "8cc6a12255e553fc8d8b25b309186981b1fd458d2be41bcc099f148c167839ec",
        "path": "three/four"
      },
      {
        "hash": "2940c27ab5409f9ffa0074c4c81c01ab6f165ac0ae973cd03212068013b3b6f3",
        "path": "two"
      }
    ]
  }

You could then retrieve the files relative to the root manifest like so:

.. code-block:: none

  http://localhost:8500/bzz:/6c64ae708609be4cc34027b38b1104f0ea8dafd5164343117ce421f7714b5e98/three/four

Uploading from the console
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

It is possible to upload files from the bzzd console (without the need for bzzup). The console command is

.. code-block:: none

    bzz.upload("/some/path/fileOrDirectory", "filename")

The command returns the root hash of a manifest. The second argument is optional; it specifies what the empty path shall resolve to (often this would be index.html). Continuing form above (note bzzd.ipc instead of geth.ipc)

.. code-block:: none

    ./geth --exec 'bzz.upload("upload-test/", "one.txt")' attach ipc:$DATADIR/bzzd.ipc

gives the output

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

Downloading a file from your local swarm instance
---------------------------------------------------------

As indicated above, your local swarm instance has an http interface running on port 8500 (by default). Downloading a file is thus a simple matter of pointing your browser to

.. code-block:: none

    http://localhost:8500/bzz:/HASH

where HASH is the id of a swarm manifest.

Alternatively, you can use ``bzz.get(HASH)`` on the bzzd console (note bzzd.ipc instead of geth.ipc)

.. code-block:: none

    ./geth --exec 'bzz.get(HASH)' attach ipc:$DATADIR/bzzd.ipc



Manifests
================

In general Manifests declare a list of strings associated with swarm entries. Before we get into generalities however, let us begin with an introductory example.

A Manifest example - directory trees
---------------------------------------

Suppose we had used ``bzzup`` (as described above) to upload a directory to swarm:

.. code-block:: none

    ./bzzup --recursive /path/to/directory

then the resulting hash points to a "manifest" - in this case a list of files within the directory along with their swarm hashes. Let us take a closer look.

The raw Manifest
-----------------------

We can see the retrieve the Manifest directly (instead of the files they refer to) by using the bzz-raw protocol ``bzzr``:

.. code-block:: none

    wget -O - "http://localhost:8500/bzzr:/HASH"

In our example it contains a list of all files contained in /path/to/directory together with their swarm ids (hashes) as well as their content-types. It may look like this: (whitespace added here to make it legible)

.. code-block:: js

  {"entries":[{"hash":"HASH-for-fileA1",
  "path":"directoryA/fileA1",
  "contentType":"text/plain"},
  {"hash":"HASH-for-fileB2",
  "path":"directoryA/directoryB/fileB2",
  "contentType":"text/plain"},
  {"hash":"HASH-for-fileB1",
  "path":"directoryA/directoryB/fileB1",
  "contentType":"text/plain"},
  {"hash":"HASH-for-fileC1",
  "path":"directoryA/directoryC/fileC1",
  "contentType":"text/plain"}]}


A note on content type
----------------------------

Manifests contain content-type information for the hashes they reference. In other contexts, where content-type is not supplied or, when you suspect the information is wrong, it is possible in a raw query to specify the content-type manually in the search query.

.. code-block:: js

   GET http://localhost:8500/bzzr:/HASH?content_type=\"text/plain\"")

Path Matching on Manifests
---------------------------------

A useful feature of manifests is that Urls can be matched on the paths. In some sense this makes the manifest a routing table and so the manifest swarm entry acts as if it were a host.

More concretely, continuing in our example, we can access the file

.. code-block:: none

    /path/to/directory/subdirectory/filename

by pointing the browser to

.. code-block:: none

    http://localhost:8500/bzz:/HASH/subdirectory/filename

.. note:: if the filename is index.html then it can be omitted.

Manifests in general
--------------------------

bzz url schemes
========================

To make it easier to access swarm content, we can use the bzz URL scheme. One of its primary merits is that it allows us to use human readable addresses instead of hashes. This is achieved by a name registration contract on the blockchain.

bzz
  the bzz scheme assumes a manifest and follows the path (the empty path if the url ends in the hash) and serves that content with content type specified in the manifest.

  This generic scheme supports name resolution for domains registered on the Ethereum Name Service (ENS, see :ref:`Ethereum Name Service`)

bzzi (immutable)
  The same as the generic scheme but there is no ENS domain resolution, the domain part of the path
  needs to be valid hash

bzzr (raw)

 entry whereas the bzz raw scheme simply serves the asset pointed to by the url. For the latter a content_type query parameter can be supplied if you know the mime you want otherwise it is a default octet stream.

For instance if you have an image (not the manifest wrapping it) at hash ``abc123...ef`` then  ``bzzr://abc123...ef?content_type=text/json`` will properly serve it.



Swarm RPC API
========================


Swarm exposes an RPC API under the ``bzz`` namespace. It offers the following methods:

``bzz.upload(localfspath, indexfile)``
  returns content hash

``bzz.download(bzzpath, localdirpath)``

``bzz.put(content, contentType)``
  returns content hash

``bzz.get(bzzpath)``
  returns object with content, mime type, status code and content size

``bzz.swapEnabled``

``bzz.syncEnabled``

``bzz.resolve(domain)``
  returns content hash
  resolves the domain name to a content hash using ENS.

``bzz.info()``
  information about the swarm node

``bzz.hive()``
  outputs the kademlia table in a human-friendly table format

Chequebook RPC API
------------------------------

Swarm also exposes an RPC API for the chequebook offering the followng methods:

``chequebook.``
``chequebook.``
``chequebook.``
``chequebook.``
``chequebook.``


Ethereum Name Service
========================


It is the swarm hash of a piece of data that dictates routing. Therefore its role is somehwhat analogous to an IP address in the TCP/IP internet. Domain names can be registered on the blockchain and set to resolve to any swarm hash. The Ethereum Name Service is thus analogous to DNS (and no ICANN nor any name servers are needed).

Currently the domain name is any arbitrary string in that the contract does not impose any restrictions. Since this is used in the host part of the url in the bzz scheme, we recommend using wellformed domain names so that there is interoperability with restrictive url handler libs.

ENS documentation is coming. In the meanwhile, docs are:

* ENS source code: https://github.com/ethereum/ens
* ENS EIPs 137: https://github.com/ethereum/EIPs/issues/137
* ENS EIPs 162: https://github.com/ethereum/EIPs/issues/162
* ENS Ethereum Domain Name System, talk at devcon2: https://www.youtube.com/watch?v=pLDDbCZXvTE
