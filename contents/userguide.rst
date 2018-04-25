***************************
Working with Swarm content
***************************

Hashes
----------------------

SECTION MISSING

Manifests
----------------------

In general manifests declare a list of strings associated with swarm hashes. A manifest matches to exactly one hash, and it consists of a list of entries declaring the content which can be retrieved through that hash. Let us begin with an introductory example.


This is demonstrated by the following example.
Let's create a directory containing the two orange papers and an html index file listing the two pdf documents.

.. code-block:: none

  $ ls -1 orange-papers/
  index.html
  smash.pdf
  sw^3.pdf

  $ cat orange-papers/index.html
  <!DOCTYPE html>
  <html lang="en">
    <head>
      <meta charset="utf-8">
    </head>
    <body>
      <ul>
        <li>
          <a href="./sw^3.pdf">Viktor Trón, Aron Fischer, Dániel Nagy A and Zsolt Felföldi, Nick Johnson: swap, swear and swindle: incentive system for swarm.</a>  May 2016
        </li>
        <li>
          <a href="./smash.pdf">Viktor Trón, Aron Fischer, Nick Johnson: smash-proof: auditable storage for swarm secured by masked audit secret hash.</a> May 2016
        </li>
      </ul>
    </body>
  </html>

We now use the ``swarm up`` command to upload the directory to swarm to create a mini virtual site.

.. code-block:: none

  swarm --recursive --defaultpath orange-papers/index.html --bzzapi http://swarm-gateways.net/ up orange-papers/ 2> up.log
  > 2477cc8584cc61091b5cc084cdcdb45bf3c6210c263b0143f030cf7d750e894d

The returned hash is the hash of the manifest for the uploaded content (the orange-papers directory):

We now can get the manifest itself directly (instead of the files they refer to) by using the bzz-raw protocol ``bzz-raw``:

.. code-block:: none

  wget -O - "http://localhost:8500/bzz-raw:/2477cc8584cc61091b5cc084cdcdb45bf3c6210c263b0143f030cf7d750e894d"

  > {
    "entries": [
      {
        "hash": "4b3a73e43ae5481960a5296a08aaae9cf466c9d5427e1eaa3b15f600373a048d",
        "contentType": "text/html; charset=utf-8"
      },
      {
        "hash": "4b3a73e43ae5481960a5296a08aaae9cf466c9d5427e1eaa3b15f600373a048d",
        "contentType": "text/html; charset=utf-8",
        "path": "index.html"
      },
      {
        "hash": "69b0a42a93825ac0407a8b0f47ccdd7655c569e80e92f3e9c63c28645df3e039",
        "contentType": "application/pdf",
        "path": "smash.pdf"
      },
      {
        "hash": "6a18222637cafb4ce692fa11df886a03e6d5e63432c53cbf7846970aa3e6fdf5",
        "contentType": "application/pdf",
        "path": "sw^3.pdf"
      }
    ]
  }


Manifests contain content_type information for the hashes they reference. In other contexts, where content_type is not supplied or, when you suspect the information is wrong, it is possible to specify the content_type manually in the search query. For example, the manifest itself should be `text/plain`:

.. code-block:: none

   http://localhost:8500/bzz-raw:/2477cc8584cc61091b5cc084cdcdb45bf3c6210c263b0143f030cf7d750e894d?content_type="text/plain"

Now you can also check that the manifest hash matches the content (in fact swarm does it for you):

.. code-block:: none

   $ wget -O- http://localhost:8500/bzz-raw:/2477cc8584cc61091b5cc084cdcdb45bf3c6210c263b0143f030cf7d750e894d?content_type="text/plain" > manifest.json

   $ swarm hash manifest.json
   > 2477cc8584cc61091b5cc084cdcdb45bf3c6210c263b0143f030cf7d750e894d

Path Matching
^^^^^^^^^^^^^^^^^^^^^^

A useful feature of manifests is that we can match paths with URLs.
In some sense this makes the manifest a routing table and so the manifest swarm entry acts as if it was a host.

More concretely, continuing in our example, when we request:

.. code-block:: none

  GET http://localhost:8500/bzz:/2477cc8584cc61091b5cc084cdcdb45bf3c6210c263b0143f030cf7d750e894d/sw^3.pdf

swarm first retrieves the document matching the manifest above. The url path ``sw^3`` is then matched against the entries. In this case a perfect match is found and the document at 6a182226... is served as a pdf.

As you can see the manifest contains 4 entries, although our directory contained only 3. The extra entry is there because of the ``--defaultpath orange-papers/index.html`` option to ``swarm up``, which associates the empty path with the file you give as its argument. This makes it possible to have a default page served when the url path is empty.
This feature essentially implements the most common webserver rewrite rules used to set the landing page of a site served when the url only contains the domain. So when you request

.. code-block:: none

  GET http://localhost:8500/bzz:/2477cc8584cc61091b5cc084cdcdb45bf3c6210c263b0143f030cf7d750e894d

you get served the index page (with content type ``text/html``) at ``4b3a73e43ae5481960a5296a08aaae9cf466c9d5427e1eaa3b15f600373a048d``.



Content Retrieval Using a Proxy
-------------------------------

Retrieving content is simple matter of pointing your browser to

.. code-block:: none

    GET http://localhost:8500/bzz:/<HASH>

where HASH is the id of a swarm manifest.
This is the most common usecase whereby swarm can serve the web.

It looks like HTTP content transfer from servers, but in fact it is using swarm's serverless architecture.

The general pattern is:

.. code-block:: none

  <HTTP proxy>/<URL SCHEME>:/<DOMAIN OR HASH>/<PATH>?<QUERY_STRING>

The HTTP proxy part can be eliminated if you register the appropriate scheme handler with your browser or you use Mist.


Resource Updates
------------------------

As of POC 0.3 Swarm offers mutable resources updates. This does not infer that the underlying chunks are actually
modified, but rather provides a deterministic blockchain-time-based (e.g. relies on the blockchain's generation time)
hashing system that enables the Swarm node to look for the most recent version of a resource (or, in turn, a specific requested version).

``bzz-resource`` resources are meant to serve as a mechanism to push updates to an ``ENS`` identifier.
Thus, a typical way to access them would be to simply point at the ``bzz-resource`` URL:

.. code-block:: none

  bzz-resource:/theswarm.eth

This will make sure that you always get the most current version of ``theswarm.eth``.
You can also point to a specific version by specifying an Ethereum block height and a version specifier. If the
requested version cannot be found, the Swarm node will try to fetch the latest version in relative to that requested version (but not a newer one).

.. note::
  To simplify things, think of immutable resources as a layer between your Dapp and ENS, facilitating faster and cheaper
  resource updates. Architecture wise, this means your ENS record will point to a versionless ``bzz-resource``. This will allow
  a browser pointing to the ENS record to retrive the newest version of your resource. A resource update does not infer that the ENS
  record gets updated.

.. important::
  Creating or updating a mutable resource involves, under the hood, a proper configration that ensures that the actor that is trying to make a mutable
  resource update is indeed the owner of the ENS record. This means your node has to be configured accordingly. If your Swarm node isn't configured with the
  ``--ens-api`` switch, ``bzz-resource`` updates will be disabled entirely.


Creating a mutable resource
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Given the correct configuration, creating a new mutable resource is as simple as:

.. code-block:: none

  curl -X POST --header "Content-Type:application/octet-stream" --data-binary <BINARY_DATA> http://localhost:8500/bzz-resource:/yourdomainname.eth/<period>


  curl -X POST --header "Content-Type:application/octet-stream" --data-binary <BINARY_DATA> http://localhost:8500/bzz-resource:/yourdomainname.eth/

The Swarm node will ensure that you are indeed the owner of the ENS record, and if so, will commit the resource change.


Retrieving a mutable resource
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Retrieval of a mutable resource is as easy as:

.. code-block:: none

  curl http://localhost:8500/bzz-resource:/yourdomainname.eth

This will retrieve the newest version of the resource you've requested, regardless of ownership


Retrieving a specific version
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You can also retrieve a specific version of the resource, specifying a block height and a (incremental) version identifier:

.. code-block:: none

  curl http://localhost:8500/bzz-resource:/yourdomainname.eth/3/1




BZZ URL schemes
--------------------
Swarm offers 8 distinct url schemes:



.. code-block:: none

    GET http://localhost:8500/bzz:/theswarm.test

The bzz scheme assumes that the domain part of the url points to a manifest. When retrieving the asset addressed by the url, the manifest entries are matched against the url path. The entry with the longest matching path is retrieved and served with the content type specified in the corresponding manifest entry.

Example:

.. code-block:: none

    GET http://localhost:8500/bzz:/2477cc8584cc61091b5cc084cdcdb45bf3c6210c263b0143f030cf7d750e894d/read

returns a readme.md file if the manifest at the given hash address contains such an entry.

If the manifest contains multiple entries to which the URL could be resolved, like, in the example above, the manifest has entries for `readme.md` and `reading-list.txt`, the API returns a HTTP response "300 Multiple Choices", indicating that the request could not be unambiguously resolved. A list of available entries is returned via HTTP or JSON.


This generic scheme supports name resolution for domains registered on the Ethereum Name Service
(ENS, see `Ethereum Name Service`). This is a read-only scheme meaning that it only supports GET requests and serves to retrieve content from swarm.


bzz-immutable
^^^^^^^^^^^^^^^^^^^^

.. code-block:: none

    GET http://localhost:8500/bzz-immutable:/2477cc8584cc61091b5cc084cdcdb45bf3c6210c263b0143f030cf7d750e894d

The same as the generic scheme but there is no ENS domain resolution, the domain part of the path needs to be a valid hash. This is also a read-only scheme but explicit in its integrity protection. A particular bzz-immutable url will always necessarily address the exact same fixed immutable content.



bzz-resource
^^^^^^^^^^^^^^^^^^^^

``bzz-resource`` allows you to receive hash pointers to content that the ENS entry resolved to at different versions

bzz-resource://<id> - get latest update
bzz-resource://<id>/<n> - get latest update on period n
bzz-resource://<id>/<n>/<m> - get update version m of period n
<id> = ens name




.. _bzz-raw:
bzz-raw
^^^^^^^^^^^^^^

.. code-block:: none

    GET http://localhost:8500/bzz-raw:/2477cc8584cc61091b5cc084cdcdb45bf3c6210c263b0143f030cf7d750e894d


When responding to GET requests with the bzz-raw scheme, swarm does not assume a manifest, just serves the asset addressed by the url directly.

The ``content_type`` query parameter can be supplied to specify the mime type you are requesting, otherwise content is served as an octet stream per default. For instance if you have a pdf document (not the manifest wrapping it) at hash ``6a182226...`` then the following url will properly serve it.

.. code-block:: none

    GET http://localhost:8500/bzz-raw:/6a18222637cafb4ce692fa11df886a03e6d5e63432c53cbf7846970aa3e6fdf5?content_type=application/pdf


Importantly and somewhat unusually for generic schemes, the raw scheme supports POST and PUT requests. This is a crucially important way in which swarm is different from the internet as we know it.

The possibility to POST makes swarm an actual cloud service, bringing upload functionality to your browsing.

In fact the command line tool ``swarm up`` uses the http proxy with the bzz raw scheme under the hood.

bzz-list
^^^^^^^^^^^^^^

.. code-block:: none

    GET http://localhost:8500/bzz-list:/2477cc8584cc61091b5cc084cdcdb45bf3c6210c263b0143f030cf7d750e894d/path

Returns a list of all files contained in <manifest> under <path> grouped into common prefixes using ``/`` as a delimiter. If path is ``/``, all files in manifest are returned. The response is a JSON-encoded object with ``common_prefixes`` string field and ``entries`` list field.

bzz-hash
^^^^^^^^^^^^^^

.. code-block:: none

    GET http://localhost:8500/bzz-hash:/theswarm.test


Swarm accepts GET requests for bzz-hash url scheme and responds with the hash value of the raw content, the same content returned by requests with bzz-raw scheme. Hash of the manifest is also the hash stored in ENS so bzz-hash can be used for ENS domain resolution.

Response content type is *text/plain*.

bzzr and bzzi
^^^^^^^^^^^^^^
Schemes with short names bzzr and bzzi are deprecated in favour of bzz-raw and bzz-immutable, respectively. They are kept for backward compatibility, and will be removed on the next release.





FUSE
======================

Another way of intracting with Swarm is by mounting it as a local filesystem using FUSE (a.k.a swarmfs). There are three IPC API's which help in doing this.

.. note:: FUSE needs to be installed on your Operating System for these commands to work. Windows is not supported by FUSE, so these command will work only in Linux, Mac OS and FreeBSD. For installation instruction for your OS, see "Installing FUSE" section below.

Installing FUSE
----------------

1. Linux (Ubuntu)

.. code-block:: none

	sudo apt-get install fuse
	sudo modprobe fuse
	sudo chown <username>:<groupname> /etc/fuse.conf
	sudo chown <username>:<groupname> /dev/fuse

2. Mac OS

   Either install the latest package from https://osxfuse.github.io/ or use brew as below

.. code-block:: none

	brew update
	brew install caskroom/cask/brew-cask
	brew cask install osxfuse
