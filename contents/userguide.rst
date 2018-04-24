


Working with content
==============================================

Hashes
----------------------




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


Encryption
----------------------

Introduced in POC 0.3, symmetric encryption using ``SHA3 Keccak256`` is now readily available to be used with swarm upload commands.
The encryption mechanism is meant to protect your information and make the chunked data unreadable to any handling swarm node, putting the
concepts of plausible deniability and censorship resistence to work.

More info about how we handle encryption at Swarm can be found `here <https://github.com/ethersphere/swarm/wiki/Symmetric-Encryption-for-Swarm-Content>`_.

.. note::
  Swarm currently supports both encrypted and unencrypted ``up`` commands through usage of the ``--encrypt`` flag.
  This might change in the future as we will refine and make Swarm a safer network.

.. note::
  When you upload content to Swarm using the `--encrypt` flag, the hash received in response will be
  longer than the standard Swarm hash you're used to - that's because the resulting hash is a concatenated
  string of the content hash and the encryption key used to encrypt the content.


.. important::
  The encryption feature is non-deterministic (due to a random seed generated on every upload request) and as a result not idempotent by design, thus uploading the same resource twice to Swarm with encryption enabled will not result in the same output hash.


Example usage:

.. code-block:: none

  swarm up --encrypt foo.txt
  > c2ebba57da7d97bc4725a542ff3f0bd37163fd564e0298dd87f320368ae4faddd1f25a870a7bb7e5d526a7623338e4e9b8399e76df8b634020d11d969594f24a
  # note the longer response hash


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



Ethereum Name Service
======================

ENS is the system that Swarm uses to permit content to be referred to by a human-readable name, such as "orangepapers.eth". It operates analogously to the DNS system, translating human-readable names into machine identifiers - in this case, the swarm hash of the content you're referring to. By registering a name and setting it to resolve to the content hash of the root manifest of your site, users can access your site via a URL such as `bzz://orange-papers.eth/`.

If we take our earlier example and set the hash 2477cc85... as the content hash for the domain `` orangepapers.eth``, we can request:

.. code-block:: none

  GET http://localhost:8500/bzz:/orange-papers.eth/sw^3.pdf

and get served the same content as with:

.. code-block:: none

  GET http://localhost:8500/bzz:/2477cc8584cc61091b5cc084cdcdb45bf3c6210c263b0143f030cf7d750e894d/sw^3.pdf

Full documentation on ENS is `available here <http://ens.readthedocs.io/en/latest/introduction.html>`_.

If you just want to set up ENS so that you can host your Swarm content on a domain, here's a quick set of steps to get you started.

Content Retrieval using ENS
----------------------------

The default configuration of swarm is to use names registered on the Ropsten testnet. In order for you to be able to resolve names to swarm hashes, all that needs to happen is that your swarm client is connected to a geth node synced on the Ropsten testnet. See section `"Running the swarm client" <./runninganode.html#using-swarm-together-with-the-ropsten-testnet-blockchain>`_.

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


PSS
======================

``PSS`` (Postal Service over Swarm) is a messaging protocol over Swarm. This means nodes can send messages to each other without being directly connected with each other, while taking advantage of the efficient routing algorithms that swarm uses for transporting and storing data.

.. note::
  ``PSS`` is under active development and is available as of POC3 of Swarm. Expect things to change.


Configuration
---------------

``PSS`` has builtin encryption functionality. To use this functionality to send a message, recipients first have to be registered with the node. This registration includes the following data:

1. ``Encryption key`` - can be a ECDSA public key or a 32 byte symmetric key. It must be coupled with a peer address (or an address space) in the node prior to sending

2. ``Topic`` - an arbitrary 4 byte word (``0x0000`` is reserved for ``raw`` messages).

3. ``Address``- the swarm overlay address to use for the routing.

   The registration returns a key id which is used to refer to the stored key in ensuing operations.

After you associate an encryption key with an address they will be checked against any message that comes through (when sending or receiving) given it matches the topic and the address space of the message.

Sending a message
-------------------

There are a few prerequisits for sending a message over ``PSS``:

1. ``Encryption key id`` - id of the stored recipient's encryption key.

2. ``Topic`` - an arbitrary 4 byte word (with the exception of ``0x0000`` to be reserved for ``raw`` messages).

3. ``Message payload`` - the message data as an arbitrary byte sequence.


.. note:: In case you would like to send just ``raw`` messages - defining an encryption key is not mandatory

Upon sending the message it is encrypted and passed on from peer to peer. Any node along the route that can successfully decrypt the message is regarded as a recipient. Recipients continue to pass on the message to their peers, to make traffic analysis attacks more difficult.

.. note::
The Address that is coupled with the encryption key is used for routing the message.
This does *not* need to be a full address; the network will route the message to the best
of its ability with the information that is available.
If *no* address is given (zero-length byte slice), routing is effectively deactivated,
and the message is passed to all peers by all peers.

After you associate an encryption key with an address space they will be checked against any message that comes through (when sending or receiving) given it matches the topic and the address space of the message.

.. important::
  When using the internal encryption methods, you MUST associate keys (whether symmetric or asymmetric) with an address space AND a topic before you will be able to send anything.

You can subscribe to incoming messages using a topic.
You can subscribe to messages on topic 0x0000 and handle the encryption on your side,  This even enables you to use the swarm node as a multiplexer for different keypair identities.

Sending a raw message
----------------------

It is also possible to send a message without using the builtin encryption. In this case no recipient registration is made, but the message is sent directly, with the following input data:

1. ``Message payload`` - the message data as an arbitrary byte sequence.

2. ``Address``- the swarm overlay address to use for the routing.


.. important::
  ``PSS`` does not guarantee message ordering (`Best-effort delivery <https://en.wikipedia.org/wiki/Best-effort_delivery>`_)
  nor message delivery (e.g. messages to offline nodes will not be cached and replayed) at the moment


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
