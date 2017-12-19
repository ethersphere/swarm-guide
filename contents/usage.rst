.. _usage:

*****************
Usage
*****************

Using swarm from the command line
==================================

Uploading a file or directory to swarm
---------------------------------------------------------------

Make sure you have compiled the swarm command

.. code-block:: none

  cd $GOPATH/src/github.com/ethereum/go-ethereum
  go install ./cmd/swarm

The `swarm up` subcommand makes it easy to upload files and directories. Usage:

.. code-block:: none

  swarm up /path/to/file/or/directory

By default this assumes that you are running your own swarm node with a local http proxy on the default port (8500).
See :ref:`run_swarm_client` to learn how to run a local node.
It is possible to specify alternative proxy endpoints with the ``--bzzapi`` option.

You can use one of the public gateways as a proxy, in which case you can upload to swarm without even running a node.

.. note:: This treat is likely to disappear or be seriously restricted in the future. It currently also accepts limited file sizes.


.. code-block:: none

    swarm --bzzapi http://swarm-gateways.net up /path/to/file/or/directory

Example: uploading a file
^^^^^^^^^^^^^^^^^^^^^^^^^^

Issue the following command to upload the go-ethereum README file to your swarm

.. code-block:: none

  swarm up $GOPATH/src/github.com/ethereum/go-ethereum/README.md

It produces the following output

.. code-block:: none

  > d1f25a870a7bb7e5d526a7623338e4e9b8399e76df8b634020d11d969594f24a

The hash returned is the swarm hash of a manifest that contains the README.md file as its only entry. So by default both the primary content and the manifest is uploaded.
You can access this file from swarm by pointing your browser to

.. code-block:: none

  http://localhost:8500/bzz:/d1f25a870a7bb7e5d526a7623338e4e9b8399e76df8b634020d11d969594f24a

The manifest makes sure you could retrieve the file with the correct mime type.

You may wish to prevent a manifest to be created for your content and only upload the raw content. Maybe you want to include it in a custom index, or it is handled as a datablob known and used only by some application that knows its mimetype. For this you can set `--manifest=false`:

.. code-block:: none

  swarm --manifest=false --bzzapi http://swarm-gateways.net/ up yellowpaper.pdf 2> up.log
  > 7149075b7f485411e5cc7bb2d9b7c86b3f9f80fb16a3ba84f5dc6654ac3f8ceb

This option supresses automatic manifest upload. It uploads the content as-is.
However, if you wish to retrieve this file, the browser can not be told unambiguously what that file represents. Thus, swarm will return a 404 Not Found. In order to access this file, you can use the ``bzz-raw`` scheme, see :ref:`bzz-raw`.

Example: Uploading a directory
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Uploading directories is achieved with ``swarm --recursive up``.

Let us create some test files

.. code-block:: none

  mkdir upload-test
  echo "one" > upload-test/one.txt
  echo "two" > upload-test/two
  mkdir upload-test/three
  echo "four" > upload-test/three/four

We can upload this directory with

.. code-block:: none

  swarm --recursive up upload-test/

The output again is the root hash of your uploaded directory, which can be used to retrieve the complete directory 

.. code-block:: none

  ab90f84c912915c2a300a94ec5bef6fc0747d1fbaf86d769b3eed1c836733a30

You could then retrieve the files relative to the root manifest like so:

.. code-block:: none

  curl http://localhost:8500/bzz:/ab90f84c912915c2a300a94ec5bef6fc0747d1fbaf86d769b3eed1c836733a30/three/four

The result should be

.. code-block:: none

  four 


If you'd like to be able to access your content via a human readable name like 'mysite.eth' instead of the long hex string above, see the section on `Ethereum Name Service`_ below.


Content retrieval: hashes and manifests
==============================================

Retrieving content using the http proxy
---------------------------------------------------------

As indicated above, your local swarm instance has an HTTP API running on port 8500 (by default). Retrieving content is simple matter of pointing your browser to

.. code-block:: none

    GET http://localhost:8500/bzz:/HASH

where HASH is the id of a swarm manifest.
This is the most common usecase whereby swarm can serve the web.

It looks like HTTP content transfer from servers, but in fact it is using swarm's serverless architecture.

The general pattern is:

.. code-block:: none

  <HTTP proxy>/<URL SCHEME>:/<DOMAIN OR HASH>/<PATH>?<QUERY_STRING>

The HTTP proxy part can be eliminated if you register the appropriate scheme handler with your browser or you use Mist.

Swarm offers 3 distinct url schemes:

bzz url schemes
--------------------

bzz
^^^^

Example:


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

    GET http://localhost:8500/bzz-list:/2477cc8584cc61091b5cc084cdcdb45bf3c6210c263b0143f030cf7d750e894d

Returns a list of all files contained in <manifest> under <path> grouped into common prefixes using ``/`` as a delimiter. The response is a JSON-encoded object with ``common_prefixes`` string field and ``entries`` list field.

bzzr and bzzi
^^^^^^^^^^^^^^
Schemes with short names bzzr and bzzi are deprecated in favour of bzz-raw and bzz-immutable, respectably. They are kept for backward compatibility, and will be removed on the next release.


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

Path Matching on Manifests
---------------------------------

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

Ethereum Name Service
======================

ENS is the system that Swarm uses to permit content to be referred to by a human-readable name, such as "orangepapers.eth". It operates analogously to the DNS system, translating human-readable names into machine identifiers - in this case, the swarm hash of the content you're referring to. By registering a name and setting it to resolve to the content hash of the root manifest of your site, users can access your site via a URL such as `bzz://orange-papers.eth/`.

If we take our earlier example and set the hash 2477cc85... as the content hash for the domain `` orangepapers.eth``, we can request:

.. code-block:: none

  GET http://localhost:8500/bzz:/orange-papers.eth/sw^3.pdf

and get served the same content as with:

.. code-block:: none

  GET http://localhost:8500/bzz:/2477cc8584cc61091b5cc084cdcdb45bf3c6210c263b0143f030cf7d750e894d/sw^3.pdf

Full documentation on ENS is `available here <https://github.com/ethereum/ens/wiki>`_.

If you just want to set up ENS so that you can host your Swarm content on a domain, here's a quick set of steps to get you started.

Content Retrieval using ENS
----------------------------

The default configuration of swarm is to use names registered on the Ropsten testnet. In order for you to be able to resolve names to swarm hashes, all that needs to happen is that your swarm client is connected to a geth node synced on the Ropsten testnet. See section "Running the swarm client" `here <./runninganode.html#using-swarm-together-with-the-ropsten-testnet-blockchain>`_.

Registering names for your swarm content
----------------------------------------

There are several steps involved in registering a new name and assigning a swarm hash to it. To start off, you'll need to register a domain, then you need to assign a resolver to the domain and then you add the swarm hash to the resolver.

.. note:: The ENS system will let you register even invalid names - names with upper case characters, or prohibited unicode characters, for instance - but your browser will never resolve them. As a result, take care to make sure any domain you try to register is well-formed before registering it

Preparation
^^^^^^^^^^^^^^^
The first step to take is to download `ensutils.js <https://github.com/ethereum/ens/blob/master/ensutils.js>`_ (`direct link <https://raw.githubusercontent.com/ethereum/ens/master/ensutils.js>`_).

You should of course have geth running and connected to ropsten (`geth --testnet`). Connect to the geth console:

.. code-block:: none

  ./geth attach ipc:/path/to/geth.ipc

Once inside the console, run:

.. code-block:: none

    loadScript('/path/to/ensutils.js')

Note: You can leave the console at any time by pressing ctrl+D

Registering a .test domain
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The easiest option is to register a `.test domain <https://github.com/ethereum/ens/wiki/Registering-a-name-with-the-FIFS-registrar>`_. These domains can be registered by anyone at any time, but they automatically expire after 28 days.

We will be sending a transactions on Ropsten, so if you have not already done so, get yourself some ropsten testnet ether. You can `get some for free here <http://faucet.ropsten.be:3001/>`_.


Before being able to send the transaction, you will need to unlock your account using ``personal.unlockAccount(account)`` i.e.

.. code-block:: none

  personal.unlockAccount(eth.accounts[0])

Then, still inside the geth console (with ensutils.js loaded) type the following (replacing MYNAME with the name you wish to register):

.. code-block:: none

  testRegistrar.register(web3.sha3('MYNAME'), eth.accounts[0], {from: eth.accounts[0]});

.. note:: Warning: do not register names with UPPER CASE letters. The ENS will let you register them, but your browser will never resolve them.

The output will be a transaction hash. Once this transaction is mined on the testnet you can verify that the name MYNAME.test belongs to you:

.. code-block:: none

  eth.accounts[0] == ens.owner(namehash('MYNAME.test'))

Registering a .eth domain
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Registering a .eth domain has more work involved. If you're just wanting to test things out quickly, start with a .test domain.
The .eth domains take a while to register, as they use an auction system, (while .test domains can be registered instantly, but only persist for 28 days). Further, .eth domains are also restricted to being at least 7 characters long.
For complete documentation `see here <https://github.com/ethereum/ens/wiki/Registering-a-name-with-the-auction-registrar>`_.

Just as when registering a .test domain, you will need testnet ether and you must unlock your account. Then you may `start bidding on a domain <https://github.com/ethereum/ens/wiki/Registering-a-name-with-the-auction-registrar>`_.

Quick Reference:

1. Prepare:

.. code-block:: js

  personal.unlockAccount(eth.accounts[0])
  loadScript('/path/to/ensutils.js')

2. Make a bid:

.. code-block:: js

  bid = ethRegistrar.shaBid(web3.sha3('myname'), eth.accounts[0], web3.toWei(1, 'ether'), web3.sha3('secret'));

3. Reveal your bid:

.. code-block:: js

  ethRegistrar.unsealBid(web3.sha3('myname'), eth.accounts[0], web3.toWei(1, 'ether'), web3.sha3('secret'), {from: eth.accounts[0], gas: 500000});

4. Finalise:

.. code-block:: js

  ethRegistrar.finalizeAuction(web3.sha3('myname'), {from: eth.accounts[0], gas: 500000});

For info on how to increase your bids, check the current highest bid, check when an auction ends, check if a name is available in the first place and more please consult `the official documentation <https://github.com/ethereum/ens/wiki/Registering-a-name-with-the-auction-registrar>`_.

Setting up a resolver
^^^^^^^^^^^^^^^^^^^^^^^^^

The next step is to set up a resolver for your new domain name. While it's possible to write and deploy your own custom resolver, for everyday use with Swarm, a general purpose one is provided, and is already deployed on the testnet.

On the geth (testnet) console:

.. code-block:: none

    loadScript('/path/to/ensutils.js')
    personal.unlockAccount(eth.accounts[0], "")
    ens.setResolver(namehash('MYNAME.test'), publicResolver.address, {from: eth.accounts[0], gas: 100000});


Registering a swarm hash on the publicResolver
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Finally, after uploading your content to Swarm as detailed above, you can update your site with this command:

.. code-block:: none

    publicResolver.setContent(namehash('MYNAME.test'), 'HASH', {from: eth.accounts[0], gas: 100000})

Again, replace 'MYNAME.test' with the name you registered, and replace 'HASH' with the hash you got when uploading your content to swarm, starting with 0x.


After this has executed successfully, anyone running a correctly configured and synchronised Swarm client will be able to access the current version of your site on `bzz://MYNAME.test/`.

.. code-block:: none

  http://localhost:8500/bzz:/MYNAME.test

Looking up names in the ENS manually
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

After registering your names and swarm hashes, you can check that everything is updated correctly by looking up the name manually.

Connect to the geth console and load ensutils.js just as before. Then type

.. code-block:: none

    getContent('MYNAME.test')

You can also check this in your swarm console with:

.. code-block:: none

    bzz.resolve('MYNAME.test')

If everything worked correctly, it will return the hash you specified when you called `setContent` earlier.

Updating your content
^^^^^^^^^^^^^^^^^^^^^^^^^

Each time you update your site's content afterwards, you only need to repeat the last step to update the mapping between the name you own and the content you want it to point to. Anyone visiting your site by its name will always see the version you most recently updated using `setHash`, above.

.. code-block:: none

    publicResolver.setContent(namehash('MYNAME.test'), 'NEWHASH', {from: eth.accounts[0], gas: 100000})




The HTTP API
=========================

GET http://localhost:8500/bzz:/domain/some/path
  retrieve document at domain/some/path allowing domain to resolve via the `Ethereum Name Service`_

GET http://localhost:8500/bzz-immutable:/HASH/some/path
  retrieve document at HASH/some/path where HASH is a valid swarm hash

GET http://localhost:8500/bzz-raw:/domain/some/path
  retrieve the raw content at domain/some/path allowing domain to resolve via the `Ethereum Name Service`_

POST http://localhost:8500/bzz-raw:
  The post request is the simplest upload method. Direct upload of files - no manifest is created.
  It returns the hash of the uploaded file

PUT http://localhost:8500/bzz:/HASH|domain/some/path
  The PUT request publishes the uploaded asset to the manifest. 
  It looks for the manifest by domain or hash, makes a copy of it and updates its collection with the new asset.
  It returns the hash of the newly created manifest.

Swarm IPC API
========================

Swarm exposes an RPC API under the ``bzz`` namespace.

.. note:: Note that this is not the recommended way for users or dapps to interact with swarm and is only meant for debugging ad testing purposes. Given that this module offers local filesystem access, allowing dapps to use this module or exposing it via remote connections creates a major security risk. For this reason ``swarm`` only exposes this api via local ipc (unlike geth not allowing websockets or http).

The API offers the following methods:

``bzz.upload(localfspath, defaultfile)``
  uploads the file or directory at ``localfspath``. The second optional argument specifies the path to the file which will be served when the empty path is matched. It is common to match the empty path to :file:`index.html`

  it returns content hash of the manifest which can then be used to download it.

``bzz.download(bzzpath, localdirpath)``
  it recursively downloads all the paths starting from the manifest at ``bzzpath`` and downloads them in a corresponding directory structure under ``localdirpath`` using the slashes in the paths to indicate subdirectories.

  assuming ``dirpath.orig`` is the root of any aribitrary directory tree containing no soft links or special files,
  uploading and downloading will result in identical data on your filesystem:

  bzz.download(bzz.upload(dirpath.orig), dirpath.replica)
  diff -r dirpath.orig dirpath.replica || echo "identical"

``bzz.put(content, contentType)``
  can be used to push a raw data blob to swarm. Creates a manifest with an entry. This entry has the empty path and specifies the content type given as second argument.
  It returns content hash of this manifest.

``bzz.get(bzzpath)``
  It downloads the manifest at ``bzzpath`` and returns a response json object with content, mime type, status code and content size. This should only be used for small pieces of data, since the content gets instantiated in memory.

``bzz.resolve(domain)``
  resolves the domain name to a content hash using ENS and returns that. If swarm is not connected to a blockchain it returns an error. Note that your eth backend needs to be syncronised in order to get uptodate domain resolution.

``bzz.info()``
  returns information about the swarm node

``bzz.hive()``
  outputs the kademlia table in a human-friendly table format

Mounting Swarm
--------------
Another way of intracting with Swarm is by mounting it as a local filesystem using Fuse (a.k.a swarmfs). There are three IPC api's which help in doing this.

.. note:: Fuse needs to be installed on your Operating System for these commands to work. Windows is not supported by Fuse, so these command will work only in Linux, Mac OS and FreeBSD. For installation instruction for your OS, see "Installing FUSE" section below.
  

``swarmfs.mount(HASH|domain, mountpoint))``
  mounts swarm contents represented by a swarm hash or a ens domain name to the specified local directory. The local directory has to be writable and should be empty.
  Once this command is succesfull, you should see the contents in the local directory. The HASH is mounted in a rw mode, which means any change insie the directory will be automatically reflected in swarm. Ex: if you copy a file from somewhere else in to mountpoint, it is equvivalent of using a "swarm up <file>" command.    

``swarmfs.unmount(mountpoint)``
  This command unmounts the HASH|domain mounted in the specified mountpoint. If the device is busy, unmounting fails. In that case make sure you exit the process that is using the directory and try unmounting again.

``swarmfs.listmounts()``
  For every active mount, this command display three things. The mountpoint, start HASH supplied and the latest HASH. Since the HASH is mounted in rw mode, when ever there is a change to the file system (adding file, removing file etc), a new HASH is computed. This hash is called the latest HASH.

Installing FUSE
^^^^^^^^^^^^^^^

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



Chequebook RPC API
------------------------------

Swarm also exposes an RPC API for the chequebook offering the followng methods:

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
