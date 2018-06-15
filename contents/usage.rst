***************************
Working with content
***************************

In this chapter, we demonstrate features of Swarm related to storage and retrieval. First we discuss how to solve mutability of resources in a content addressed system using the Ethereum Name Service on the blockchain, then using Mutable Resource Updates in Swarm.
Then we briefly discuss how to protect your data by restricting access using encryption.
We also discuss in detail how files can be organised into collections using manifests and how this allows virtual hosting of websites. Another form of interaction with Swarm, namely mounting a Swarm manifest as a local directory using FUSE.
We conclude by summarizing the various URL schemes that provide simple http endpoints for clients to interact with Swarm.

.. _Ethereum Name Service:

Using ENS names
================

.. note:: In order to `resolve` ENS names, your Swarm node has to be connected to an Ethereum blockchain (mainnet, or testnet). See `Getting Started <./gettingstarted.html#connect-ens>`_ for instructions. This section explains how you can register your content to your ENS name.

`ENS <http://ens.readthedocs.io/en/latest/introduction.html>`_ is the system that Swarm uses to permit content to be referred to by a human-readable name, such as "theswarm.eth". It operates analogously to the DNS system, translating human-readable names into machine identifiers - in this case, the Swarm hash of the content you're referring to. By registering a name and setting it to resolve to the content hash of the root manifest of your site, users can access your site via a URL such as ``bzz://theswarm.eth/``.

.. note:: Currently The `bzz` scheme is not supported in major browsers such as Chrome, Firefox or Safari. If you want to access the `bzz` scheme through these browsers, currently you have to either use an HTTP gateway, such as https://swarm-gateways.net/bzz:/theswarm.eth/ or use a browser which supports the `bzz` scheme, such as Mist <https://github.com/ethereum/mist>.

Suppose we upload a directory to Swarm containing (among other things) the file ``example.pdf``.

.. code-block:: none

  swarm --recursive up /path/to/dir
  >2477cc8584cc61091b5cc084cdcdb45bf3c6210c263b0143f030cf7d750e894d

If we register the root hash as the ``content`` for ``theswarm.eth``, then we can access the pdf at

.. code-block:: none

  bzz://theswarm.eth/example.pdf

if we are using a Swarm-enabled browser, or at

.. code-block:: none

  http://localhost:8500/bzz:/theswarm.eth/example.pdf

via a local gateway. We will get served the same content as with:

.. code-block:: none

  http://localhost:8500/bzz:/2477cc8584cc61091b5cc084cdcdb45bf3c6210c263b0143f030cf7d750e894d/example.pdf

Please refer to the `official ENS documentation <http://ens.readthedocs.io/en/latest/introduction.html>`_ for the full details on how to register content hashes to ENS.

In short, the steps you must take are:

1. Register an ENS name.
2. Associate a resolver with that name.
3. Register the Swarm hash with the resolver as the ``content``.

We recommend using https://manager.ens.domains/. This will make it easy for you to:

- Associate the default resolver with your name
- Register a Swarm hash.

.. note:: When you register a Swarm hash with https://manager.ens.domains/ you MUST prefix the hash with 0x. For example 0x2477cc8584cc61091b5cc084cdcdb45bf3c6210c263b0143f030cf7d750e894d

Overview of ENS (video)
-----------------------

Nick Johnson on the Ethereum Name System

.. raw:: html

  <iframe width="560" height="315" src="https://www.youtube.com/embed/pLDDbCZXvTE" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
Mutable Resource Updates
========================

.. note::
  Mutable Resource Updates is a highly experimental feature, available from Swarm POC3. It is under active development, so expect things to change.

We have previously learned in this guide that when we make changes in data in Swarm, the hash returned when we upload that data will change in totally unpredictable ways. With *Mutable Resource Updates*, Swarm provides a built-in way of keeping a persistent identifier to changing data.

The usual way of keeping the same pointer to changing data is using the Ethereum Name Service ``ENS``. However, ``ENS`` is an on-chain feature, which limits functionality in some areas:

1. Every update to an ``ENS`` resolver will cost you gas to execute.
2. It is not be possible to change the data faster than the rate that new blocks are mined.
3. Correct ``ENS`` resolution requires that you are always synced to the blockchain.

Using *Mutable Resource Updates* you only need to register the data resource *once* with ``ENS``. After this, your lookup calls to that ``ENS`` name will automatically resolve to the latest update existing in Swarm.

Creating a mutable resource
----------------------------
.. important::
  If you run your node with the ``--ens-api`` flag, the node will make an ``ENS`` lookup on create and update operations to ensure that the node account is the owner of the ``ENS`` name before allowing the updates to go through. If you run the node *without* this flag, updates will *not* be checked, but will still be checked by other nodes in the network. Updates from illegitimate owners will be discarded by other nodes, and will not propagate in the network.

When you create a mutable resource, you will have to supply an expected update frequency. This is an indication of how often (in number of blocks) your resource will change. Don't worry; as we will see later you can always update the resource inbetween these intervals if you want.

Let's say we will want to update some data every 42 blocks (roughly every 10 minutes). The resulting resource constructor will be as follows:

.. code-block:: none

  SWARMHASH=`swarm up foo.html` && curl -X POST http://localhost:8500/bzz-resource:/yourdomainname.eth/42 --data $SWARMPAGE

This will result in json output along the lines of:

.. code-block:: none

  {"manifest":"94f373bb8df041687d5cc9a6cbf72ccd8886e816c7b25aa1e7776a21c55a540c","resource":"yourdomainname.eth","update":"fed6fe4ee69a45181535f11f22f2592b6d21a9de0dfd77dda358612d0cb34067"}

To use ``ENS`` lookups for this resource, you use the ``setContent`` method of your ``ENS`` resolver to point to the hash in the ``manifest`` entry above. Once this is mined, you will be able to view the contents of ``foo.html`` in a browser by visiting ``http://localhost:8500/bzz:/yourdomainname.eth``

Now for the magic; to change this resource, you issue:

.. code-block:: none

  SWARMHASH=`swarm up bar.html` && curl -X POST http://localhost:8500/bzz-resource:/yourdomainname.eth --data $SWARMPAGE

After this, when you enter ``http://localhost:8500/bzz:/yourdomainname.eth`` in the browser, you will see the contents of ``bar.html`` instead. Note that no update to ``ENS`` has been made in the meantime. You've saved a bit of money, and the update happens at the speed of storing a Swarm chunk.

Retrieving a mutable resource
------------------------------

The above example is limited to updating Swarm web content. But Mutable Resource Updates can just as well be used to store and retrieve "raw" data aswell. This is done using the ``/raw`` subpath in the url upon update. An example:

.. code-block:: none

  curl -X POST http://localhost:8500/bzz-resource:/yourdomainname.eth/raw --data foo
  curl -X GET http://localhost:8500/bzz-resource:/yourdomainname.eth

  curl -X POST http://localhost:8500/bzz-resource:/yourdomainname.eth/raw --data bar
  curl -X GET http://localhost:8500/bzz-resource:/yourdomainname.eth

The above two HTTP GET requests with curl will return "foo" and "bar" repectively.

.. important::
  Updates made using the *raw* subpath are served with the ``applcation/octet-stream`` mime type. This means that the receiving application needs to know itself how to interpret the underlying data.

Mutable resource versioning
----------------------------

As explained above, we need to specify a frequency parameter when we create a resource, which indicates the number of blocks that are expected to pass between each update. In Mutable Resourceswe call this the *period*. When you make an update, it will always belong to the *upcoming period*.

Let's make this less obscure with some concrete examples:

* Mutable Resource is created at block height ``4200000`` with frequency ``13``.
* Update made at block height ``4200010``. Update will belong to block height ``4200013``.
* Update made at block height ``4200014``. Update will belong to block height ``4200026``.
* Update made at block height ``4200021``. Update will *also* belong to block height ``4200026``.
* Update made at block height ``4200026``. Update will belong to block height ``4200039``.

.. important::
  Notice that if you make an update on the block height of an actual period, the update will belong to the *next* period.

This behavior is analogous to versioning. And indeed, Mutable Resources allow for retrieval of particular versions aswell. However, instead of using block heights for the versioning scheme, we instead use incremental serial numbers, where the starting block is update ``1``, the starting block plus frequency is update ``2`` and so forth.

If more updates are made within one period, they will be sequentially numbered aswell. So returning to our above example, the updates can be referenced by the following version numbers:

* Update creation = version ``1.1``
* Block height ``4200010`` = version ``2.1``
* Block height ``4200014`` = version ``3.1``
* Block height ``4200021`` = version ``3.2``
* Block height ``4200026`` = version ``4.1``

Retrieving a specific mutable resource version
-----------------------------------------------

We can retrieve specific Mutable Resource Update versions by adding the version numbers to the url.

Either we can choose to only name the period, in which case we will get the latest version of that period. Thus, again referring to the above examples:

.. code-block:: none

  curl -X GET http://localhost:8500/bzz-resource:/yourdomainname.eth/1

Will return the content of version ``1.1``

.. code-block:: none

  curl -X GET http://localhost:8500/bzz-resource:/yourdomainname.eth/3

Will return the content of version ``3.2``

.. code-block:: none

  curl -X GET http://localhost:8500/bzz-resource:/yourdomainname.eth/3/1

Will return the content of version ``3.1``

.. code-block:: none

  curl -X GET http://localhost:8500/bzz-resource:/yourdomainname.eth

Will of course return the version ``4.1``

Manifests
==============


Manifests in Swarm
----------------------

In general manifests declare a list of strings associated with Swarm hashes. A manifest matches to exactly one hash, and it consists of a list of entries declaring the content which can be retrieved through that hash. Let us begin with an introductory example.


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
          <a href="./sw^3.pdf">Viktor Trón, Aron Fischer, Dániel Nagy A and Zsolt Felföldi, Nick Johnson: swap, swear and swindle: incentive system for Swarm.</a>  May 2016
        </li>
        <li>
          <a href="./smash.pdf">Viktor Trón, Aron Fischer, Nick Johnson: smash-proof: auditable storage for Swarm secured by masked audit secret hash.</a> May 2016
        </li>
      </ul>
    </body>
  </html>

We now use the ``swarm up`` command to upload the directory to Swarm to create a mini virtual site.

.. note::
   In this example we are using the public gateway through the `bzz-api` option in order to upload. The examples below assume a node running on localhost to access content. Make sure to run a local node to reproduce these examples

.. code-block:: none

  swarm --recursive --defaultpath orange-papers/index.html --bzzapi http://swarm-gateways.net/ up orange-papers/ 2> up.log
  > 2477cc8584cc61091b5cc084cdcdb45bf3c6210c263b0143f030cf7d750e894d

The returned hash is the hash of the manifest for the uploaded content (the orange-papers directory):

We now can get the manifest itself directly (instead of the files they refer to) by using the bzz-raw protocol ``bzz-raw``:

.. code-block:: none

  wget -O- "http://localhost:8500/bzz-raw:/2477cc8584cc61091b5cc084cdcdb45bf3c6210c263b0143f030cf7d750e894d"

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

Now you can also check that the manifest hash matches the content (in fact Swarm does it for you):

.. code-block:: none

   $ wget -O- http://localhost:8500/bzz-raw:/2477cc8584cc61091b5cc084cdcdb45bf3c6210c263b0143f030cf7d750e894d?content_type="text/plain" > manifest.json

   $ swarm hash manifest.json
   > 2477cc8584cc61091b5cc084cdcdb45bf3c6210c263b0143f030cf7d750e894d


Path Matching
-----------------

A useful feature of manifests is that we can match paths with URLs.
In some sense this makes the manifest a routing table and so the manifest acts as if it was a host.

More concretely, continuing in our example, when we request:

.. code-block:: none

  GET http://localhost:8500/bzz:/2477cc8584cc61091b5cc084cdcdb45bf3c6210c263b0143f030cf7d750e894d/sw^3.pdf

Swarm first retrieves the document matching the manifest above. The url path ``sw^3`` is then matched against the entries. In this case a perfect match is found and the document at 6a182226... is served as a pdf.

As you can see the manifest contains 4 entries, although our directory contained only 3. The extra entry is there because of the ``--defaultpath orange-papers/index.html`` option to ``swarm up``, which associates the empty path with the file you give as its argument. This makes it possible to have a default page served when the url path is empty.
This feature essentially implements the most common webserver rewrite rules used to set the landing page of a site served when the url only contains the domain. So when you request

.. code-block:: none

  GET http://localhost:8500/bzz:/2477cc8584cc61091b5cc084cdcdb45bf3c6210c263b0143f030cf7d750e894d/

you get served the index page (with content type ``text/html``) at ``4b3a73e43ae5481960a5296a08aaae9cf466c9d5427e1eaa3b15f600373a048d``.

Paths and directories
-----------------------

Swarm manifests don't "break" like a file system. In a file system, the directory matches at the path separator (`/` in linux) at the end of a directory name:


.. code-block:: none

  -- dirname/
  ----subdir1/
  ------subdir1file.ext
  ------subdir2file.ext
  ----subdir2/
  ------subdir2file.ext

In Swarm, path matching does not happen on a given path separator, but **on common prefixes**. Let's look at an example:
The current manifest for the ``theswarm.test`` homepage is as follows:

.. code-block:: none

  wget -O- "http://open.swarm-gateways.net/bzz-raw:/theswarm.test/ > manifest.json

  > {"entries":[{"hash":"ee55bc6844189299a44e4c06a4b7fbb6d66c90004159c67e6c6d010663233e26","path":"LICENSE","mode":420,"size":1211,"mod_time":"2018-06-12T15:36:29Z"},
              {"hash":"57fc80622275037baf4a620548ba82b284845b8862844c3f56825ae160051446","path":"README.md","mode":420,"size":96,"mod_time":"2018-06-12T15:36:29Z"},
              {"hash":"8919df964703ccc81de5aba1b688ff1a8439b4460440a64940a11e1345e453b5","path":"Swarm_files/","contentType":"application/bzz-manifest+json","mod_time":"0001-01-01T00:00:00Z"},
              {"hash":"acce5ad5180764f1fb6ae832b624f1efa6c1de9b4c77b2e6ec39f627eb2fe82c","path":"css/","contentType":"application/bzz-manifest+json","mod_time":"0001-01-01T00:00:00Z"},
              {"hash":"0a000783e31fcf0d1b01ac7d7dae0449cf09ea41731c16dc6cd15d167030a542","path":"ethersphere/orange-papers/","contentType":"application/bzz-manifest+json","mod_time":"0001-01-01T00:00:00Z"},
              {"hash":"b17868f9e5a3bf94f955780e161c07b8cd95cfd0203d2d731146746f56256e56","path":"f","contentType":"application/bzz-manifest+json","mod_time":"0001-01-01T00:00:00Z"},
              {"hash":"977055b5f06a05a8827fb42fe6d8ec97e5d7fc5a86488814a8ce89a6a10994c3","path":"i","contentType":"application/bzz-manifest+json","mod_time":"0001-01-01T00:00:00Z"},
              {"hash":"48d9624942e927d660720109b32a17f8e0400d5096c6d988429b15099e199288","path":"js/","contentType":"application/bzz-manifest+json","mod_time":"0001-01-01T00:00:00Z"},
              {"hash":"294830cee1d3e63341e4b34e5ec00707e891c9e71f619bc60c6a89d1a93a8f81","path":"talks/","contentType":"application/bzz-manifest+json","mod_time":"0001-01-01T00:00:00Z"},
              {"hash":"12e1beb28d86ed828f9c38f064402e4fac9ca7b56dab9cf59103268a62a2b35f","contentType":"text/html; charset=utf-8","mode":420,"size":31371,"mod_time":"2018-06-12T15:36:29Z"}
    ]}


Note the ``path`` for entry ``b17868...``: It is ``f``. This means, there are more than one entries for this manifest which start with an `f`, and all those entries will be retrieved by requesting the hash ``b17868...`` and through that arrive at the matching manifest entry:

.. code-block:: none

   $ wget -O- http://localhost:8500/bzz-raw:/b17868f9e5a3bf94f955780e161c07b8cd95cfd0203d2d731146746f56256e56/

   {"entries":[{"hash":"25e7859eeb7366849f3a57bb100ff9b3582caa2021f0f55fb8fce9533b6aa810","path":"avicon.ico","mode":493,"size":32038,"mod_time":"2018-06-12T15:36:29Z"},
               {"hash":"97cfd23f9e36ca07b02e92dc70de379a49be654c7ed20b3b6b793516c62a1a03","path":"onts/glyphicons-halflings-regular.","contentType":"application/bzz-manifest+json","mod_time":"0001-01-01T00:00:00Z"}
    ]}

So we can see that the ``f`` entry in the root hash resolves to a manifest containing ``avicon.ico`` and ``onts/glyphicons-halflings-regular``. The latter is interesting in itself: its ``content_type`` is ``application/bzz-manifest+json``, so it points to another manifest. Its ``path`` also does contain a path separator, but that does not result in a new manifest after the path separator like a directory (e.g. at ``onts/``). The reason is that on the file system on the hard disk, the ``fonts`` directory only contains *one* directory named ``glyphicons-halflings-regular``, thus creating a new manifest for just ``onts/`` would result in an unnecessary lookup. This general approach has been chosen to limit unnecessary lookups that would only slow down retrieval, and manifest "forks" happen in order to have the logarythmic bandwidth needed to retrieve a file in a directory with thousands of files.

When requesting ``wget -O- "http://open.swarm-gateways.net/bzz-raw:/theswarm.test/favicon.ico``, swarm will first retrieve the manifest at the root hash, match on the first ``f`` in the entry list, resolve the hash for that entry and finally resolve the hash for the ``favicon.ico`` file.

For the ``theswarm.test`` page, the same applies to the ``i`` entry in the root hash manifest. If we look up that hash, we'll find entries for ``mages/`` (a further manifest), and ``ndex.html``, whose hash resolves to the main ``index.html`` for the web page.

Paths like ``css/`` or ``js/`` get their own manifests, just like common directories, because they contain several files.

.. note::
   If a request is issued which Swarm can not resolve unambiguosly, a ``300 "Multiplce Choices"`` HTTP status will be returned.
   In the example above, this would apply for a request for ``http://open.swarm-gateways.net/bzz:/theswarm.test/i``, as it could match both ``images/`` as well as ``index.html``

Encryption
===========

Introduced in POC 0.3, symmetric encryption is now readily available to be used with the ``swarm up`` upload command.
The encryption mechanism is meant to protect your information and make the chunked data unreadable to any handling Swarm node.

Swarm uses `Counter mode encryption <https://en.wikipedia.org/wiki/Block_cipher_mode_of_operation#Counter_(CTR)>`_ to encrypt and decrypt content. When you upload content to Swarm, the uploaded data is split into 4 KB chunks. These chunks will all be encoded with a separate randomly generated encryption key. The encryption happens on your local Swarm node, unencrypted data is not shared with other nodes. The reference of a single chunk (and the whole content) will be the concatenation of the hash of encoded data and the decryption key. This means the reference will be longer than the standard unencrypted Swarm reference (64 bytes instead of 32 bytes).

When your node syncs the encrypted chunks of your content with other nodes, it does not share the the full references (or the decryption keys in any way) with the other nodes. This means that other nodes will not be able to access your original data, moreover they will not be able to detect whether the synchronized chunks are encrypted or not.

When your data is retrieved it will only get decrypted on your local Swarm node. During the whole retrieval process the chunks traverse the network in their encrypted form, and none of the participating peers are able to decrypt them. They are only decrypted and assembled on the Swarm node you use for the download.

More info about how we handle encryption at Swarm can be found `here <https://github.com/ethersphere/swarm/wiki/Symmetric-Encryption-for-Swarm-Content>`_.

.. note::
  Swarm currently supports both encrypted and unencrypted ``swarm up`` commands through usage of the ``--encrypt`` flag.
  This might change in the future as we will refine and make Swarm a safer network.

.. important::
  The encryption feature is non-deterministic (due to a random key generated on every upload request) and users of the API should not rely on the result being idempotent; thus uploading the same content twice to Swarm with encryption enabled will not result in the same reference.


Example usage:

.. code-block:: none

  swarm up foo.txt
  > 4b964a75ab19db960c274058695ca4ae21b8e19f03ddf1be482ba3ad3c5b9f9b
  # note the short reference of the unencrypted upload
  swarm up --encrypt foo.txt
  > c2ebba57da7d97bc4725a542ff3f0bd37163fd564e0298dd87f320368ae4faddd1f25a870a7bb7e5d526a7623338e4e9b8399e76df8b634020d11d969594f24a
  # note the longer reference of the encrypted upload
  swarm up --encrypt foo.txt
  >
  e76efd76ef1161e4903acc43b5dc634c02fbba7e5f242c32726e78d4e71ffa9cf5a6ca8a19cbada15f38cac79557a930055d5a465a9f868d07122428267045ba
  # note the different reference on the second upload (because of the random encryption key)

FUSE
======================


Another way of interacting with Swarm is by mounting it as a local filesystem using `FUSE <https://en.wikipedia.org/wiki/Filesystem_in_Userspace>`_ (Filesystem in Userspace). There are three IPC API's which help in doing this.

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


CLI Usage
-----------

The Swarm CLI now integrates commands to make FUSE usage easier and streamlined.

.. note:: When using FUSE from the CLI, we assume you are running a local Swarm node on your machine. The FUSE commands attach to the running node through `bzzd.ipc`

Mount
^^^^^^^^

One use case to mount a Swarm hash via FUSE is a file sharing feature accessible via your local file system.
Files uploaded to Swarm are then transparently accessible via your local file system, just as if they were stored locally.

To mount a Swarm resource, first upload some content to Swarm using the `swarm up <resource>` command.
You can also upload a complete folder using `swarm --recursive up <directory>`.
Once you get the returned manifest hash, use it to mount the manifest to a mount point
(the mount point should exist on your hard drive):

.. code-block:: none

	swarm fs mount --ipcpath <path-to-bzzd.ipc> <manifest-hash> <mount-point>

For example:

.. code-block:: none

	swarm fs mount --ipcpath /home/user/ethereum/bzzd.ipc <manifest-hash> /home/user/swarmmount

Your running Swarm node terminal output should show something similar to the following in case the command returned successfuly:

.. code-block:: none

	Attempting to mount /path/to/mount/point
	Serving 6e4642148d0a1ea60e36931513f3ed6daf3deb5e499dcf256fa629fbc22cf247 at /path/to/mount/point
	Now serving swarm FUSE FS                manifest=6e4642148d0a1ea60e36931513f3ed6daf3deb5e499dcf256fa629fbc22cf247 mountpoint=/path/to/mount/point

You may get a "Fatal: had an error calling the RPC endpoint while mounting: context deadline exceeded" error if it takes too long to retrieve the content.

In your OS, via terminal or file browser, you now should be able to access the contents of the Swarm hash at ``/path/to/mount/point``, i.e. ``ls /home/user/swarmmount``


Access
^^^^^^^^
Through your terminal or file browser, you can interact with your new mount as if it was a local directory. Thus you can add, remove, edit, create files and directories just as on a local directory. Every such action will interact with Swarm, taking effect on the Swarm distributed storage. Every such action also will result **in a new hash** for your mounted directory. If you would unmount and remount the same directory with the previous hash, your changes would seem to have been lost (effectively you are just mounting the previous version). While you change the current mount, this happens under the hood and your mount remains up-to-date.

Unmount
^^^^^^^^
To unmount a swarmfs mount, either use the List Mounts command below, or use a known mount point:

.. code-block:: none

	swarm fs unmount --ipcpath <path-to-bzzd.ipc> <mount-point>
	> 41e422e6daf2f4b32cd59dc6a296cce2f8cce1de9f7c7172e9d0fc4c68a3987a

The returned hash is the latest manifest version that was mounted.
You can use this hash to remount the latest version with the most recent changes.


List Mounts
^^^^^^^^^^^^^^^^^^
To see all existing swarmfs mount points, use the List Mounts command:

.. code-block:: none

	swarm fs list --ipcpath <path-to-bzzd.ipc>

Example Output:

.. code-block:: none

	Found 1 swarmfs mount(s):
	0:
		Mount point: /path/to/mount/point
		Latest Manifest: 6e4642148d0a1ea60e36931513f3ed6daf3deb5e499dcf256fa629fbc22cf247
		Start Manifest: 6e4642148d0a1ea60e36931513f3ed6daf3deb5e499dcf256fa629fbc22cf247

.. _bzz protocol suite:

BZZ URL schemes
=======================

Swarm offers 8 distinct URL schemes:

bzz
------


The bzz scheme assumes that the domain part of the url points to a manifest. When retrieving the asset addressed by the URL, the manifest entries are matched against the URL path. The entry with the longest matching path is retrieved and served with the content type specified in the corresponding manifest entry.

Example:

.. code-block:: none

    GET http://localhost:8500/bzz:/2477cc8584cc61091b5cc084cdcdb45bf3c6210c263b0143f030cf7d750e894d/readme.md

returns a readme.md file if the manifest at the given hash address contains such an entry.

If the manifest does not contain an file at ``readme.md`` itself, but it does contain multiple entries to which the URL could be resolved, like, in the example above, the manifest has entries for ``readme.md.1`` and ``readme.md.2``, the API returns an HTTP response "300 Multiple Choices", indicating that the request could not be unambiguously resolved. A list of available entries is returned via HTTP or JSON.


.. _bzz-raw:

bzz-raw
------------

.. code-block:: none

    GET http://localhost:8500/bzz-raw:/2477cc8584cc61091b5cc084cdcdb45bf3c6210c263b0143f030cf7d750e894d


When responding to GET requests with the bzz-raw scheme, Swarm does not assume that the hash resolves to a manifest. Instead it just serves the asset referenced by the hash directly.

The ``content_type`` query parameter can be supplied to specify the MIME type you are requesting, otherwise content is served as an octet-stream per default. For instance if you have a pdf document (not the manifest wrapping it) at hash ``6a182226...`` then the following url will properly serve it.

.. code-block:: none

    GET http://localhost:8500/bzz-raw:/6a18222637cafb4ce692fa11df886a03e6d5e63432c53cbf7846970aa3e6fdf5?content_type=application/pdf


Importantly and somewhat unusually for generic schemes, the raw scheme supports POST and PUT requests. This is a crucially important way in which Swarm is different from the internet as we know it.

The possibility to POST makes Swarm an actual cloud service, bringing upload functionality to your browsing.

In fact the command line tool ``swarm up`` uses the HTTP proxy with the bzz-raw scheme under the hood.

bzz-list
-------------

.. code-block:: none

    GET http://localhost:8500/bzz-list:/2477cc8584cc61091b5cc084cdcdb45bf3c6210c263b0143f030cf7d750e894d/path

Returns a list of all files contained in <manifest> under <path> grouped into common prefixes using ``/`` as a delimiter. If no path is supplied, all files in manifest are returned. The response is a JSON-encoded object with ``common_prefixes`` string field and ``entries`` list field.

bzz-hash
-------------

.. code-block:: none

    GET http://localhost:8500/bzz-hash:/theswarm.eth/


Swarm accepts GET requests for bzz-hash url scheme and responds with the hash value of the raw content, the same content returned by requests with bzz-raw scheme. Hash of the manifest is also the hash stored in ENS so bzz-hash can be used for ENS domain resolution.

Response content type is *text/plain*.


bzz-immutable
------------------

.. code-block:: none

    GET http://localhost:8500/bzz-immutable:/2477cc8584cc61091b5cc084cdcdb45bf3c6210c263b0143f030cf7d750e894d

The same as the generic scheme but there is no ENS domain resolution, the domain part of the path needs to be a valid hash. This is also a read-only scheme but explicit in its integrity protection. A particular bzz-immutable url will always necessarily address the exact same fixed immutable content.



bzz-resource
-----------------

``bzz-resource`` allows you to receive hash pointers to content that the ENS entry resolved to at different versions

bzz-resource://<id> - get latest update
bzz-resource://<id>/<n> - get latest update on period n
bzz-resource://<id>/<n>/<m> - get update version m of period n
<id> = ens name
