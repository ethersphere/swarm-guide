.. _updownload:

***************************
Uploading and Downloading
***************************

..  contents::

Introduction
==================================
.. note:: This guide assumes you've installed the swarm client and have a running node that listens by default on port 8500. See `Getting Started <./gettingstarted.html>`_ for details.

Arguably, uploading and downloading content is the raison d'être of Swarm. Uploading content consists of "uploading" content to your local Swarm node, followed by your local Swarm node "syncing" the resulting chunks of data with its peers in the network. Meanwhile, downloading content consists of your local Swarm node querying its peers in the network for the relevant chunks of data and then reassembling the content locally.

Uploading and downloading data can be done through the ``swarm`` command line interface (CLI) on the terminal or via the HTTP interface on ``http://localhost:8500``.


Using CLI
=====================

Uploading a file to your local Swarm node
------------------------------------------
.. note:: Once a file is uploaded to your local Swarm node, your node will `sync` the chunks of data with other nodes on the network. Thus, the file will eventually be available on the network even when your original node goes offline.

The basic command for uploading to your local node is ``swarm up FILE``. For example, issue the following command to upload the file example.md file to your local Swarm node

.. code-block:: none

  swarm up /path/to/example.md
  > d1f25a870a7bb7e5d526a7623338e4e9b8399e76df8b634020d11d969594f24a

The hash returned is the hash of a Swarm manifest. This manifest is a JSON file that contains the example.md file as its only entry. Both the primary content and the manifest are uploaded by default.

After uploading, you can access this example.md file from swarm by pointing your browser to:

.. code-block:: none

  http://localhost:8500/bzz:/d1f25a870a7bb7e5d526a7623338e4e9b8399e76df8b634020d11d969594f24a/

The manifest makes sure you could retrieve the file with the correct MIME type.


Suppressing automatic manifest creation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
You may wish to prevent a manifest from being created alongside with your content and only upload the raw content. You might want to include it in a custom index, or handle it as a data-blob known and used only by a certain application that knows its MIME type. For this you can set ``--manifest=false``:

.. code-block:: none

  swarm --manifest=false up FILE
  > 7149075b7f485411e5cc7bb2d9b7c86b3f9f80fb16a3ba84f5dc6654ac3f8ceb

This option suppresses automatic manifest upload. It uploads the content as-is.
However, if you wish to retrieve this file, the browser can not be told unambiguously what that file represents.
In the context, the hash ``7149075b7f485411e5cc7bb2d9b7c86b3f9f80fb16a3ba84f5dc6654ac3f8ceb`` does not refer to a manifest and any attempt to retrieve it over bzz will result in a 404 Not Found Error. In order to access this file, you would have to use the :ref:`bzz-raw` scheme.


Downloading a single file
----------------------------

To download single files, use the ``swarm down`` command.
Single files can be downloaded in the following different manners. The following examples assume ``<hash>`` resolves into a single-file manifest:

.. code-block:: none

  swarm down bzz:/<hash>            #downloads the file at <hash> to the current working directory
  swarm down bzz:/<hash> file.tmp   #downloads the file at <hash> as ``file.tmp`` in the current working dir
  swarm down bzz:/<hash> dir1/      #downloads the file at <hash> to ``dir1/``

You can also specify a custom proxy with `--bzzapi`:

.. code-block:: none

  swarm --bzzapi http://localhost:8500 down bzz:/<hash>            #downloads the file at <hash> to the current working directory using the localhost node


 Downloading a single file from a multi-entry manifest can be done with (``<hash>`` resolves into a multi-entry manifest):

 .. code-block:: none

  swarm down bzz:/<hash>/index.html            #downloads index.html to the current working directory
  swarm down bzz:/<hash>/index.html file.tmp   #downloads index.html as file.tmp in the current working directory
  swarm down bzz:/<hash>/index.html dir1/      #downloads index.html to dir1/


Uploading to a remote Swarm node
-----------------------------------
You can upload to a remote Swarm node using the ``--bzzapi`` flag.
For example, you can use one of the public gateways as a proxy, in which case you can upload to swarm without even running a node.


.. code-block:: none

    swarm --bzzapi https://swarm-gateways.net up /path/to/file/or/directory

.. note:: This gateway currently only accepts uploads of limited size. In future, the ability to upload to this gateways is likely to disappear entirely.



Uploading a directory
-----------------------

Uploading directories is achieved with the ``--recursive`` flag.

.. code-block:: none

  swarm --recursive up /path/to/directory
  > ab90f84c912915c2a300a94ec5bef6fc0747d1fbaf86d769b3eed1c836733a30

The returned hash refers to a root manifest referencing all the files in the directory. If there was a file called ``index.html`` in that directory, you could now access it under

.. code-block:: none

  http://localhost:8500/bzz:/ab90f84c912915c2a300a94ec5bef6fc0747d1fbaf86d769b3eed1c836733a30/index.html

Directory with default entry
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

It is possible to declare a default entry in a manifest. In the example above, if ``index.html`` is declared as the default, then it is no longer required to append ``/index.html`` after the HASH.

.. code-block:: none

  swarm --defaultpath /path/to/directory/index.html --recursive up /path/to/directory
  > ef6fc0747d1fbaf86d769b3eed1c836733a30ab90f84c912915c2a300a94ec5b

You can now access index.html at

.. code-block:: none

  http://localhost:8500/bzz:/ef6fc0747d1fbaf86d769b3eed1c836733a30ab90f84c912915c2a300a94ec5b/index.html

and also at

.. code-block:: none

  http://localhost:8500/bzz:/ef6fc0747d1fbaf86d769b3eed1c836733a30ab90f84c912915c2a300a94ec5b/

This is especially useful when the hash (in this case ``ef6fc0747d1fbaf86d769b3eed1c836733a30ab90f84c912915c2a300a94ec5b``) is given a registered name like ``mysite.eth`` in the `Ethereum Name Service <./ens.html>`_.


Downloading a directory
--------------------------

To download a directory, use the ``swarm down --recursive`` command.
Directories can be downloaded in the following different manners. The following examples assume <hash> resolves into a multi-entry manifest:

.. code-block:: none

  swarm down --recursive bzz:/<hash>            #downloads the directory at <hash> to the current working directory
  swarm down --recursive bzz:/<hash> dir1/      #downloads the file at <hash> to dir1/

Similarly as with a single file, you can also specify a custom proxy with ``--bzzapi``:

.. code-block:: none

  swarm --bzzapi http://localhost:8500 down --recursive bzz:/<hash> #note the flag ordering




Adding entries to a manifest
-------------------------------
The command for modifying manifests is ``swarm manifest``.

To add an entry to a manifest, use the command:

.. code-block:: none

  swarm manifest add

To remove an entry from a manifest, use the command:

.. code-block:: none

  swarm manifest remove

To modify the hash of an entry in a manifest, use the command:

.. code-block:: none

  swarm manifest update


Using HTTP
======================

Swarm offers an HTTP API. Thus, a simple way to upload and download files to/from Swarm is through this API.
We can use the ``curl`` tool to exemplify how to interact with this API.

.. note:: Files can be uploaded in a single HTTP request, where the body is either a single file to store, a tar stream (application/x-tar) or a multipart form (multipart/form-data).

To upload a single file, run this:

.. code-block:: none

  curl -H "Content-Type: text/plain" --data-binary "some-data" http://localhost:8500/bzz:/

Once the file is uploaded, you will receive a hex string which will look similar to.

.. code-block:: none

  027e57bcbae76c4b6a1c5ce589be41232498f1af86e1b1a2fc2bdffd740e9b39

This is the address string of your content inside Swarm.

To download a file from Swarm, you just need the file's address string. Once you have it the process is simple. Run:

.. code-block:: none

  curl http://localhost:8500/bzz:/027e57bcbae76c4b6a1c5ce589be41232498f1af86e1b1a2fc2bdffd740e9b39/

The result should be your file:

.. code-block:: none

  some-data

And that's it. Note that if you omit the trailing slash from the url then the request will result in a redirect.

Tar stream upload
------------------

.. code-block:: none

  # create two directories with a file in each
  mkdir dir1 dir2
  echo "some-data" > dir1/file.txt
  echo "some-data" > dir2/file.txt

  # create a tar archive containing the two directories
  tar cf files.tar .

  # upload the tar archive to Swarm to create a manifest
  curl -H "Content-Type: application/x-tar" --data-binary @files.tar http://localhost:8500/bzz:/
  > 1e0e21894d731271e50ea2cecf60801fdc8d0b23ae33b9e808e5789346e3355e

You can then download the files using:

.. code-block:: none

  curl http://localhost:8500/bzz:/1e0e21894d731271e50ea2cecf60801fdc8d0b23ae33b9e808e5789346e3355e/dir1/file.txt
  > some-data

  curl http://localhost:8500/bzz:/1e0e21894d731271e50ea2cecf60801fdc8d0b23ae33b9e808e5789346e3355e/dir2/file.txt
  > some-data

GET requests work the same as before with the added ability to download multiple files by setting `Accept: application/x-tar`:

.. code-block:: none

  curl -s -H "Accept: application/x-tar" http://localhost:8500/bzz:/ccef599d1a13bed9989e424011aed2c023fce25917864cd7de38a761567410b8/ | tar t
  > dir1/file.txt
    dir2/file.txt


Multipart form upload
---------------------

.. code-block:: none

  curl -F 'dir1/file.txt=some-data;type=text/plain' -F 'dir2/file.txt=some-data;type=text/plain' http://localhost:8500/bzz:/
  > 9557bc9bb38d60368f5f07aae289337fcc23b4a03b12bb40a0e3e0689f76c177

  curl http://localhost:8500/bzz:/9557bc9bb38d60368f5f07aae289337fcc23b4a03b12bb40a0e3e0689f76c177/dir1/file.txt
  > some-data

  curl http://localhost:8500/bzz:/9557bc9bb38d60368f5f07aae289337fcc23b4a03b12bb40a0e3e0689f76c177/dir2/file.txt
  > some-data


Files can also be added to an existing manifest
------------------------------------------------

.. code-block:: none

  curl -F 'dir3/file.txt=some-other-data;type=text/plain' http://localhost:8500/bzz:/9557bc9bb38d60368f5f07aae289337fcc23b4a03b12bb40a0e3e0689f76c177
  > ccef599d1a13bed9989e424011aed2c023fce25917864cd7de38a761567410b8

  curl http://localhost:8500/bzz:/ccef599d1a13bed9989e424011aed2c023fce25917864cd7de38a761567410b8/dir1/file.txt
  > some-data

  curl http://localhost:8500/bzz:/ccef599d1a13bed9989e424011aed2c023fce25917864cd7de38a761567410b8/dir3/file.txt
  > some-other-data


Files can also be uploaded using a simple HTML form
----------------------------------------------------

.. code-block:: html

  <form method="POST" action="/bzz:/" enctype="multipart/form-data">
    <input type="file" name="dir1/file.txt">
    <input type="file" name="dir2/file.txt">
    <input type="submit" value="upload">
  </form>


Listing files
-------------

A `GET` request with ``bzz-list`` URL scheme returns a list of files contained under the path, grouped into common prefixes which represent directories:

.. code-block:: none

   curl -s http://localhost:8500/bzz-list:/ccef599d1a13bed9989e424011aed2c023fce25917864cd7de38a761567410b8/ | jq .
   > {
      "common_prefixes": [
        "dir1/",
        "dir2/",
        "dir3/"
      ]
    }

.. code-block:: none

    curl -s http://localhost:8500/bzz-list:/ccef599d1a13bed9989e424011aed2c023fce25917864cd7de38a761567410b8/dir1/ | jq .
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
