*******************
Introduction
*******************

..  * extention allows for per-format preference for image format

..  image:: img/swarm-logo.jpg
   :height: 300px
   :width: 300 px
   :scale: 50 %
   :alt: swarm-logo
   :align: right


Swarm is a distributed storage platform and content distribution service, a native base layer service of the ethereum :dfn:`web 3` stack. The primary objective of Swarm is to provide a sufficiently decentralized and redundant store of Ethereum's public record, in particular to store and distribute dapp code and data as well as block chain data. From an economic point of view, it allows participants to efficiently pool their storage and bandwidth resources in order to provide the aforementioned services to all participants.

From the end user's perspective, Swarm is not that different from WWW, except that uploads are not to a specific server. The objective is to offer a peer-to-peer storage and serving solution that is DDOS-resistant, zero-downtime, fault-tolerant and censorship-resistant as well as self-sustaining due to a built-in incentive system which uses peer-to-peer accounting and allows trading resources for payment. Swarm is designed to deeply integrate with the devp2p multiprotocol network layer of Ethereum as well as with the Ethereum blockchain for domain name resolution, service payments and content availability insurance (the latter is to be implemented in POC 0.4 by Q2 2018).

This document provides you with information on :

* how to run and configure a local swarm node
* how to connect to the test network
* how to store and access content on swarm
* swarm architecture and concepts such as chunk, hash and manifest
* command line tools relevant to swarm
* API documentation for the http swarm proxy
* API documentation for the bzz RPC module
* how to register swarm domains with the Ethereum Name Service
* how to test, manage logging, debug and report issues

Background
=================

The primary objective of Swarm is to provide a sufficiently
decentralized and redundant store of Ethereum's public record, in
particular to store and distribute Đapp code and data as well as
block chain data. [Note that the latter is not part of the current release].

From an economic point of view, it allows participants to efficiently
pool their storage and bandwidth resources in order to provide the
aforementioned services to all participants.

These objectives entail the following design requirements:

.. this list is confusing. what is it a list of? what do "inclusivity" or "self-managed sustainability" mean? does the reader know?
.. TODO: reformulate?

* distributed storage, inclusivity, long tail of power law
* flexible expansion of space without hardware investment decisions, unlimited growth
* zero downtime
* immutable, unforgeable, verifiable yet plausibly deniable storage
* no single point of failure, fault and attack resilience
* censorship resistance, universally accessible permanent public record
* sustainability due to a incentive system
* efficient market driven pricing. tradeable trade off of memory, persistent storage, bandwidth
* efficient use of the blockchain by the swarm accounting protocol
* deposit-challenge based guaranteed storage [planned for POC 0.4 by Q2 2018]

Basics
========================



Swarm client is part of the Ethereum stack, the reference implementation is written in golang and found under the go-ethereum repository. Currently at POC (proof of concept) version 0.2 is running on all nodes.

Swarm defines the :dfn:`bzz subprotocol` running on the ethereum devp2p network. The bzz subprotocol is in flux, the
specification of the wire protocol is considered stable only with POC 0.4 expected in Q2 2018.

The swarm of Swarm is the collection of nodes of the devp2p network each of which run the bzz protocol on the same network id.

Swarm nodes are also connected to an ethereum blockchain.
Nodes running the same network id are supposed to connect to the same blockchain.
Such a swarm network is identified by its network id which is an arbitrary integer.

Swarm allows for :dfn:`upload and disappear` which means that any node can just upload content to the swarm and
then is allowed to go offline. As long as nodes do not drop out or become unavailable, the content will still
be accessible due to the 'synchronization' procedure in which nodes continuously pass along available data between each other.

.. note::
  Uploaded content is not guaranteed to persist until storage insurance is implemented (expected in POC 0.4 by Q2 2018). All participating nodes should consider  voluntary service with no formal obligation whatsoever and should be expected to delete content at their will. Therefore, users should under no circumstances regard swarm as safe storage until the incentive system is functional.

.. note::
  Swarm POC 0.2 uses no encryption. Upload of sensitive and private data is highly discouraged as there is no way to undo an upload. Users should refrain from uploading unencrypted sensitive data, in other words

  * no valuable personal content
  * no illegal, controversial or unethical content

Swarm defines 3 crucial notions

:dfn:`chunks`
  pieces of data (max 4K), the basic unit of storage and retrieval in the swarm

:dfn:`hash`
  cryptographic hash of data that serves as its unique identifier and address

:dfn:`manifest`
  data structure describing collections allow for url based access to content

In this guide, content is understood very broadly in a technical sense denoting any blob of data.
Swarm defines a specific identifier for a piece of content. This identifier serves as the retrieval address for the content.
Identifiers need to be

* collision free (two different blobs of data will never map to the same identifier)
* deterministic (same content will always receive the same identifier)
* uniformly distributed

The choice of identifier in swarm is the hierarchical swarm hash described in :ref:`swarm_hash`.
The properties above let us view the identifiers as addresses at which content is expected to be found.
Since hashes can be assumed to be collision free, they are bound to one specific version of a content, i.e. Hash addressing therefore is immutable in the strong sense that you cannot even express mutable content: "changing the content changes the hash".

Users, however, usually use some discovery and or semantic access to data, which is implemented by the ethereum name service (ENS).
The ENS enables content retrieval based on mnemonic (or branded) names, much like the DNS of the world wide web, but without servers.

Swarm nodes participating in the network also have their own :dfn:`base address (also called bzzkey)` which is derived as the (keccak 256bit sha3) hash of an ethereum address, the so called :dfn:`swarm base account` of the node. These node addresses define a location in the same address space as the data.

When content is uploaded to swarm it is chopped up into pieces called chunks. Each chunk is accessed at the address defined by its swarm hash. The hashes of data chunks themselves are packaged into a chunk which in turn has its own hash. In this way the content gets mapped to a chunk tree. This hierarchical swarm hash construct allows for merkle proofs for chunks within a piece of content, thus providing swarm with integrity protected random access into (large) files (allowing for instance skipping safely in a streaming video).

The current version of swarm implements a :dfn:`strictly content addressed distributed hash table` (DHT). Here 'strictly content addressed' means that the node(s) closest to the address of a chunk do not only serve information about the content but actually host the data. (Note that although it is part of the protocol, we cannot have any sort of guarantee that it will be preserved. this is a caveat worth stating again: no guarantee of permanence and persistence). In other words, in order to retrieve a piece of content (as a part of a larger collection/document) a chunk must reach its destination from the uploader to the storer when storing/uploading and must also be served back to a requester when retrieving/downloading.
The viability of both hinges on the assumption that any node (uploader/requester) can 'reach' any other node (storer). This assumption is guaranteed with a special :dfn:`network topology` (called :dfn:`kademlia`), which offers (very low) constant time for lookups logarithmic to the network size.

.. note:: There is no such thing as delete/remove in swarm. Once data is uploaded there is no way you can initiate her to revoke it.

Nodes cache content that they pass on at retrieval, resulting in an auto scaling elastic cloud: popular (oft-accessed) content is replicated throughout the network decreasing its retrieval latency. Caching also results in a :dfn:`maximum resource utilisation` in as much as nodes will fill their dedicated storage space with data passing through them. If capacity is reached, least accessed chunks are purged by a garbage collection process. As a consequence, unpopular content will end up
getting deleted. Storage insurance (to be implemented in POC 0.4 expected by Q2 of 2018) will be used to protect important content from this fate.

Swarm content access is centred around the notion of a manifest. A manifest file describes a document collection, e.g.,

* a filesystem directory
* an index of a database
* a virtual server

Manifests specify paths and corresponding content hashes allowing for url based content retrieval.
Manifests can therefore define a routing table for (static) assets (including dynamic content using for instance static javascript).
This offers the functionality of :dfn:`virtual hosting`, storing entire directories or web(3)sites, similar to www but
without servers.

You can read more about these components in :ref:`architecture`.

About
===================

This document
---------------------

This document's source code is found at https://github.com/ethersphere/swarm-guide
The most up-to-date swarm book in various formats is available on the old web
http://ethersphere.org/swarm/docs as well as on swarm bzz://swarm/guide


Status
---------------

The status of swarm is proof of concept vanilla prototype tested on a toy network.
This version is POC 0.2.5

.. note:: Swarm is experimental code and untested in the wild. Use with extreme care.

License
-------------


Credits
---------------------

Swarm is code by Ethersphere (ΞTHΞRSPHΞЯΞ) `https://github.com/ethersphere`

the team behind swarm:

* Viktor Trón @zelig
* Dániel A. Nagy @nagydani
* Aron Fischer @homotopycolimit
* Nick Johnson @Arachnid
* Zsolt Felföldi @zsfelfoldi

Swarm is funded by the Ethereum Foundation.

Special thanks to

* Felix Lange, Alex Leverington for inventing and implementing devp2p/rlpx;
* Jeffrey Wilcke and the go team for continued support, testing and direction;
* Gavin Wood and Vitalik Buterin for the vision;
* Alex Van der Sande, Fabian Vogelsteller, Bas van Kervel and the Mist team
* Nick Savers, Alex Beregszaszi, Daniel Varga, Juan Benet for inspiring discussions and ideas
* Participants of the orange lounge research group
* Roman Mandeleil and Anton Nashatyrev for the java implementation
* Igor Sharudin for example dapps
* Community contributors for feedback and testing


Community
-------------------

Daily development and discussions are ongoing in various gitter channels:

* https://gitter.im/ethereum/swarm: general public chatroom about swarm dev
* https://gitter.im/ethersphere/orange-lounge: our reading/writing/working group and R&D sessions
* https://gitter.im/ethereum/pss: about postal services on swarm - messaging with deterministic routing
* https://gitter.im/ethereum/swatch: variable bitrate media streaming and multicast/broadcast solution

Swarm discussions also on the Ethereum subreddit: http://www.reddit.com/r/ethereum

Reporting a bug and contributing
-------------------------------------

Issues are tracked on github and github only. Swarm related issues and PRs are labeled with swarm:
https://github.com/ethereum/go-ethereum/labels/swarm

Please include the commit and branch when reporting an issue.

Pull requests should by default commit on the `master` branch (edge).

Roadmap and Resources
--------------------------

Swarm roadmap and tentative plan for features and POC series are found on the wiki:
https://github.com/ethereum/go-ethereum/wiki/swarm-roadmap
https://github.com/ethereum/go-ethereum/wiki/swarm---POC-series

the *swarm homepage* is accessible via swarm at bzz://swarm or the gateway http://swarm-gateways.net/bzz:/swarm/

The swarm page also contains a list of swarm-related talks (video recording and slides).

You can also find the (first 2) ethersphere orange papers there.

Public gateways are:

* http://swarm-gateways.net/
* http://web3.download/
* http://ethereum-swarm.net/

Swarm testnet monitor: http://stats.ens.domains/

Source code is at https://github.com/ethereum/go-ethereum/

Example dapps are at https://github.com/ethereum/swarm-dapps

This document source https://github.com/ethersphere/swarm-guide

