*****************
Usage
*****************

Using a local Swarm Instance
================================

.. moved the 'running your client' section to runninganode.rst where it belongs.

Uploading a file or directory to your local swarm instance
---------------------------------------------------------------

Included in the swarm repository is a shell script that makes it easy to upload a file to a local swarm node using http port 8500.

.. code-block:: none

   bash bzz/bzzup/bzzup.sh /path/to/myFileOrDirectory

If this command is successful, the output will be a hash

.. code-block:: none

   65b2a32ab2230d7d2bad2616e804d374921be68758009491cd52c727e37b4979

If unsuccessful (for example if no local node is running) the output will simply be blank.

It is also possible to upload a file or directory from the console like this

.. code-block:: none

    hash = bzz.upload("/path/to/myFileOrDirectory", "index.html")

Here the second parameter (index.html) is to be mapped to the root path '/'.

Downloading a file from your local swarm instance
---------------------------------------------------------

Your local swarm instance has an http interface running on port 8500 (by default). To download a file is thus a simple matter of pointing your browser to

.. code-block:: none

    http://localhost:8500/65b2a32ab2.. .7b4979

or, if you prefer, you can use the console

.. code-block:: none

    bzz.get(hash)


Manifests
================

In general Manifests declare a list of strings associated with swarm entries. Before we get into generalities however, let us begin with an introductory example.

A Manifest example - directory trees
---------------------------------------

Suppose we had used @command{bzzup.sh} (as described above) to upload a directory to swarm instead of just a file:

.. code-block:: none

    bash bzz/bzzup/bzzup.sh /path/to/directory

then the resulting hash points to a "manifest" - in this case a list of files within the directory along with their swarm hashes. Let us take a closer look.

The raw Manifest
-----------------------
We can see the raw Manifest by prepending @code{raw/} to the URL like so

.. code-block:: none

    wget -O - "http://localhost:8500/raw/HASH"

In our example it contains a list of all files contained in @code{/path/to/directory} together with their swarm ids (hashes) as well as their content-types. It may look like this: (whitespace added here to make it legible)

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

   http.get("http://localhost:8500/raw/hash/?content_type=\"text/plain\"")

Path Matching on Manifests
---------------------------------

A useful feature of manifests is that Urls can be matched on the paths. In some sense this makes the manifest a routing table and so the manifest swarm entry acts as if it were a host.

More concretely, continuing in our example, we can access the file

.. code-block:: js

    /path/to/directory/subdirectory/filename

by pointing the browser to

.. code-block:: js

    http://localhost:8500/HASH/subdirectory/filename

.. note:: if the filename is @code{index.html} then it can be omitted.

Manifests in general
--------------------------

Although in our example above the manifest was essentially a file listing in a directory, there is no reason for a Manifest to take this form. Manifests simply match strings with swarm id's, and there is no requirement that the strings be of the form @code{path/to/file}. Indeed swarm treats @code{path/to/file} as just another identifying string and there is nothing special about the @code{/} character.

@strong{However}, a browser will treat @code{/} as a special character. This is important to remember when specifying (relative) URL's in your Dapp.

The bzz:// URL scheme
========================
To make it easier to access swarm content, we can use the bzz URL scheme. One of its primary merits is that it allows us to use human readable addresses instead of hashes. This is achieved by a name registration contract on the blockchain.

http module for urls on the console
----------------------------------------
The in-console http client understands the bzz scheme if geth is started with swarm enabled. Syntax:

.. code-block:: js

    http.get(url)
    http.download(url, /path/to/save)

The console http module is a very simple http client, that understands the bzz scheme if bzz is enabled.

* `http.get(url)`
* `http.download(url, /path/to/save)`
* `http.loadScript(url)` should be same as JSRE.loadScript

Swarm RPC API
----------------------------

Swarm exposes an RPC API under the ``bzz`` namespace. It offers the following methods:

``bzz.upload(localfspath, indexfile)``
  returns content hash

``bzz.download(bzzpath, localdirpath)``

``bzz.put(content, contentType)``
  returns content hash

``bzz.get(bzzpath)``
  returns object with content, mime type, status code and content size

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

Name Registration for swarm content
-----------------------------------------

It is the swarm hash of a piece of data that dictates routing. Therefore its role is somehwhat analogous to an IP address in the TCP/IP internet. Domain names can be registered on the blockchain and set to resolve to any swarm hash. The Ethereum Name Service is thus analogous to DNS (and no ICANN nor any name servers are needed).

Currently the domain name is any arbitrary string in that the contract does not impose any restrictions. Since this is used in the host part of the url in the bzz scheme, we recommend using wellformed domain names so that there is interoperability with restrictive url handler libs.

ENS documentation is coming. In the meanwhile, docs are:

* ENS source code: https://github.com/ethereum/ens
* ENS EIPs 137: https://github.com/ethereum/EIPs/issues/137
* ENS EIPs 162: https://github.com/ethereum/EIPs/issues/162
* ENS Ethereum Domain Name System, talk at devcon2: https://www.youtube.com/watch?v=pLDDbCZXvTE
