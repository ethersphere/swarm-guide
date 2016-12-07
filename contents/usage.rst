*****************
Usage
*****************

Using swarm from the command line
==================================

Uploading a file or directory  to the swarm
---------------------------------------------------------------

Make sure you have compiled bzzup

.. code-block:: none

  cd $GOPATH/src/github.com/ethereum/go-ethereum
  go build ./cmd/bzzup

The bzzup program makes it easy to upload files and directories. Usage:

.. code-block:: none

  ./bzzup /path/to/file/or/directory

By default bzzup assumes that you are running your own swarm node with a local http proxy on the default port (8500).
See :ref:`Running a node` to learn how to run a local node.
It is possible to specify alternative proxy endpoints with the ``--bzzapi`` option.

You can use one of the public gateways as a proxy, in which case you can upload to swarm without even running a node.

.. note:: This treat is likely to disappear or be seriously restricted in the future.


.. code-block:: none

    bzzup --bzzapi http://swarm-gateways.net/ /path/to/file/or/directory

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
  
if you'd like to be able to access your content via a human readable name like 'mysite.eth' intead of the long hex string above, see the section on :ref:`Ethereum Name Service` below.

Content retrieval: hashes and manifests
==============================================

Retrieving content using the http proxy
---------------------------------------------------------

As indicated above, your local swarm instance has an http interface running on port 8500 (by default). Retrieving content is simple matter of pointing your browser to

.. code-block:: none

    http://localhost:8500/bzz:/HASH

where HASH is the id of a swarm manifest.
This is the most common usecase whereby swarm can serve the web.

Disregarding the clunky proxy part, it looks like http transfering content from servers, but in fact it is using swarm's serverless architecture.

The general pattern is: <HTTP proxy>/<URL SCHEME>:/<DOMAIN OR HASH>/<PATH>?<QUERY_STRING>

The http proxy part can be eliminated if you register the appropriate scheme handler with your browser or you use Mist.

Swarm offers 3 distinct url schemes:

bzz url schemes
--------------------

bzz
^^^^

The bzz scheme assumes a manifest and follows the path (the empty path if the url ends in the hash) and serves that content with content type specified in the manifest.

This generic scheme supports name resolution for domains registered on the Ethereum Name Service
(ENS, see :ref:`Ethereum Name Service`). This is a read-only scheme meaning that it only supports GET requests and serves to retrieve content from swarm.

bzzi (immutable)
^^^^^^^^^^^^^^^^^^^^

The same as the generic scheme but there is no ENS domain resolution, the domain part of the path needs to be valid hash. This is also a read-only scheme but explicit in its integrity protection. A particular bzzi url will always nececssarily address the exact same fixed immutable content.

bzzr (raw)
^^^^^^^^^^^^^^

When responding to GET requests to the bzzr scheme, swarm does not assume a manifest just  serves the asset addressed by the url directly.

The ``content_type`` query parameter can be supplied to specify the mime you want otherwise content is served as a default octet stream. For instance if you have an image (not the manifest wrapping it) at hash ``abc123...ef`` then  ``bzzr://abc123...ef?content_type=image/jpeg`` will properly serve it.

Importantly and somewhat unusually for generic schemes, the raw scheme supports POST and PUT requests. This is a crucially important way in which swarm is different from the internet as we know it.

The possibility to POST makes swarm an actual cloud service, bringing upload functionality to your browsing.

In fact under the hood, the command line tool ``bzzup`` uses the http proxy with the bzz raw scheme.


Manifests
----------------------

In general manifests declare a list of strings associated with swarm hashes. Before we get into generalities however, let us begin with an introductory example.

Suppose we had used ``bzzup`` (as described above) to upload a directory to swarm:

.. code-block:: none

    ./bzzup --recursive /path/to/directory

then the returned hash is actually the address of the manifest. The manifest in this case a list of files within the directory along with their swarm hashes. Let us take a closer look.

We can see the retrieve the manifest directly (instead of the files they refer to) by using the bzz-raw protocol ``bzzr``:

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


Manifests contain content-type information for the hashes they reference. In other contexts, where content-type is not supplied or, when you suspect the information is wrong, it is possible to specify the content-type manually in the search query.

.. code-block:: js

   GET http://localhost:8500/bzzr:/HASH?content_type=\"text/plain\"")

Path Matching on Manifests
---------------------------------

A useful feature of manifests is that urls can be matched on the paths.
Directory trees, routing tables and database indexes all share this problem.
In some sense this makes the manifest a routing table and so the manifest swarm entry acts as if it were a host.

More concretely, continuing in our example, we can access the file

.. code-block:: none

    /path/to/directory/subdirectory/filename

by pointing the browser to

.. code-block:: none

    http://localhost:8500/bzz:/HASH/subdirectory/filename

manifest entries can specify an empty path, in which case the pointing to the hash of the manifest will serve that entry.

The ``bzzup`` command line tool allows you to specify a path to a file that will be mapped to the empty path.


The HTTP API
=========================

What determines

POST http://localhost:8500/bzzr:
  The post request is the simplest upload method. Manifest is NOT created. You need be a member, so expect
  to create first a photo of you.


PUT http://localhost:8500/bzzr:/some/path
  The PUT request modifies the manifest so that the uploaded asset's hash will be added to the collection addressed by context
  under pass. Note that the manifest is NOT ACTUALLY modified. In essence the manifest is copied and updated and its new hash will replace.


Swarm IPC API
========================

Swarm exposes an RPC API under the ``bzz`` namespace.

.. note:: Note that this is not the recommended way for users or dapps to interact with swarm.
Given that this module offers local filesystem access, allowing dapps to use this module or exposing it via remote connections creates a major security risk. For this reason ``bzzd`` only exposes this api via local ipc (unlike geth not allowing websockets or http).

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
  It downloads the manifest at ``bzzpath`` and returns a reponse json object with content, mime type, status code and content size. This should only be used for small pieces of data, since the content gets instantiated in memory.


``bzz.resolve(domain)``
  resolves the domain name to a content hash using ENS and returns that. If swarm is not connected to a blockchain it returns an error. Note that your eth backend needs to be syncronised in order to get uptodate domain resolution.

``bzz.info()``
  returns information about the swarm node

``bzz.hive()``
  outputs the kademlia table in a human-friendly table format

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


Example use of the console
------------------------------

It is possible to upload files from the bzzd console (without the need for bzzup or an http proxy). The console command is

.. code-block:: none

    bzz.upload("/path/to/file/or/directory", "filename")

The command returns the root hash of a manifest. The second argument is optional; it specifies what the empty path should resolve to (often this would be :file:`index.html`). Continuing form above (note ``bzzd.ipc`` instead of ``geth.ipc``)

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

We only recommend using this API for testing purposes or command line scripts. Since they save on http file upload, their performance is somewhat better than using the http API.

As an alternative to http to retrieve content, you can use ``bzz.get(HASH)`` or ``bzz.download(HASH, /path/to/donwload/to)`` on the bzzd console (note ``bzzd.ipc`` instead of ``geth.ipc``)

.. code-block:: none

    ./geth --exec 'bzz.get(HASH)' attach ipc:$DATADIR/bzzd.ipc
    ./geth --exec 'bzz.download(HASH, "/path/to/download/to")' attach ipc:$DATADIR/bzzd.ipc

Ethereum Name Service
=========================================

ENS is the system that Swarm uses to permit content to be referred to by a human-readable name, such as "myname.eth". It operates analagously to the DNS system, translating human-readable names into machine identifiers - in this case, the swarm hash of the content you're referring to. By registering a name and setting it to resolve to the content hash of the root manifest of your site, users can access your site via a URL such as `bzz://mysite.eth/`.

Full documentation on ENS is [available here](https://github.com/ethereum/ens/wiki).

If you just want to set up ENS so that you can host your Swarm content on a domain, here's a quick set of steps to get you started.

First, you'll need to register a domain. You can do this by following the guide for either [registering a .eth domain](https://github.com/ethereum/ens/wiki/Registering-a-name-with-the-auction-registrar) or registering a [.test domain](https://github.com/ethereum/ens/wiki/Registering-a-name-with-the-FIFS-registrar). .eth domains take a while to register, as they use an auction system, while .test domains can be registered instantly, but only persist for 28 days. .eth domains are also restricted to being at least 7 characters long, while .test names may be of any length. If you're just wanting to test things out quickly, start with a .test domain.

Next, set up a resolver for your new domain name. While it's possible to write and deploy your own custom resolver, for everyday use with Swarm, a general purpose one is provided, and is already deployed on the testnet.

If you haven't already, download [ensutils.js](https://github.com/ethereum/ens/blob/master/ensutils.js), and start up a geth console connnected to the Ropsten test network (you can do this with `geth --testnet console` if you're running a recent version of geth). Inside the console, run:

    loadScript('/path/to/ensutils.js')
    ens.setResolver(namehash('myname.eth'), publicResolver.address, {from: eth.accounts[0], gas: 100000});

Replace 'myname.eth' with the name you registered earlier.

Finally, after uploading your content to Swarm as detailed above, you can update your site with this command:

    publicResolver.setContent(namehash('myname.eth'), '0x6c64ae708609be4cc34027b38b1104f0ea8dafd5164343117ce421f7714b5e98', {from: eth.accounts[0], gas: 100000})

Again, replace 'myname.eth' with the name you registered, and replace the hash with the hash you got when uploading your content to swarm.

After this has executed successfully, anyone running a correctly configured and synchronised Swarm client will be able to access the current version of your site on `bzz://myname.eth/`. You can check that everything's updated correctly with the following command:

    getContent('myname.eth')
    
You can also check this in your bzzd console with:

    bzz.resolve('myname.eth')
    
If everything worked correctly, it will return the hash you specified when you called `setContent` earlier.

Each time you update your site's content afterwards, you only need to repeat this last step to update the mapping between the name you own and the content you want it to point to. Anyone visiting your site by its name will always see the version you most recently updated using `setContent`, above.

Note that the ENS system will let you register even invalid names - names with upper case characters, or prohibited unicode characters, for instance - but your browser will never resolve them. As a result, take care to make sure any domain you try to register is well-formed before registering it.
