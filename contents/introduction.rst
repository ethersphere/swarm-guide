*******************
Introduction
*******************

..  * extension allows for per-format preference for image format

..  image:: img/swarm.png
   :height: 300px
   :width: 238px
   :scale: 50 %
   :alt: swarm-logo
   :align: right


Swarm is a distributed storage platform and content distribution service, a native base layer service of the ethereum :dfn:`Web3.0` stack. The primary objective of Swarm is to provide a sufficiently decentralized and redundant store of Ethereum's public record, in particular to store and distribute dapp code and data as well as blockchain data. From an economic point of view, it allows participants to efficiently pool their storage and bandwidth resources in order to provide these services to all participants of the network, all while being incentivised by Ethereum.

.. raw:: html

  <iframe width="560" height="315" src="https://www.youtube.com/embed/VgTZV471WFM" style="margin-bottom: 30px;" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>



Objective
==========

Swarm's broader objective is to provide infrastructure services for developers of decentralised web applications (dapps), notably: messaging, data streaming, peer to peer accounting, mutable resource updates, storage insurance, proof of custody scan and repair, payment channels and database services.

From the end user's perspective, Swarm is not that different from the world wide web, with the exception that uploads are not hosted on a specific server. Swarm offers a peer-to-peer storage and serving solution that is DDoS-resistant, has zero-downtime, fault-tolerant and censorship-resistant as well as self-sustaining due to a built-in incentive system which uses peer-to-peer accounting and allows trading resources for payment. Swarm is designed to deeply integrate with the devp2p multiprotocol network layer of Ethereum as well as with the Ethereum blockchain for domain name resolution (using ENS), service payments and content availability insurance.

.. raw:: html

  <iframe width="560" height="315" src="https://www.youtube.com/embed/xrw9rvee7rc" style="margin-bottom: 30px;" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

Please refer to our `development roadmap <https://github.com/ethersphere/swarm/wiki/roadmap>`_ and our `roadmap board <https://github.com/orgs/ethersphere/projects/5>`_ to stay informed with our progress.

Overview
========================

Swarm is set out to provide base layer infrastructure for a new decentralised internet.
Swarm is a peer-to-peer network of nodes providing distributed digital services by contributing resources (storage, message forwarding, payment processing) to each other. These contributions are accurately accounted for on a peer to peer basis, allowing nodes to trade resource for resource, but offering monetary compensation to nodes consuming less than they serve.

.. image:: img/swarm-intro.svg
   :alt: Swarm storage and message routing
   :width: 500

The Ethereum Foundation operates a Swarm testnet that can be used to test out functionality in a similar manner to the Ethereum testnet (ropsten).
Everyone can join the network by running the Swarm client node on their server, desktop, laptop or mobile device. See :ref:`Getting Started` for how to do this.
The Swarm client is part of the Ethereum stack, the reference implementation is written in golang and found under the go-ethereum repository. Currently at POC (proof of concept) version 0.3 is running on all nodes.

Swarm offers a **local HTTP proxy** API that dapps or command line tools can use to interact with Swarm. Some modules like `messaging  <PSS>`_ are   only available through RPC-JSON API. The foundation servers on the testnet are offering public gateways, which serve to easily demonstrate functionality and allow free access so that people can try Swarm without even running their own node.

.. note::
  The Swarm public gateways are temporary and users should not rely on their existence for production services.

The Swarm is the collection of nodes of the devp2p network each of which run the :ref:`bzz protocol suite` on the same network id.

Swarm nodes can also connect with one (or several) ethereum blockchains for domain name resolution and one ethereum blockchain for bandwidth and storage compensation.
Nodes running the same network id are supposed to connect to the same blockchain for payments. A Swarm network is identified by its network id which is an arbitrary integer.

Swarm allows for :dfn:`upload and disappear` which means that any node can just upload content to the Swarm and
then is allowed to go offline. As long as nodes do not drop out or become unavailable, the content will still
be accessible due to the 'synchronization' procedure in which nodes continuously pass along available data between each other.

.. note::
  Uploaded content is not guaranteed to persist on the testnet until storage insurance is implemented (expected in POC4 2019). All participating nodes should consider participation a  voluntary service with no formal obligation whatsoever and should be expected to delete content at their will. Therefore, users should under no circumstances regard Swarm as safe storage until the incentive system is functional.

.. note::
  The Swarm public gateways are temporary and users should not rely on their existence for production services.

.. note::
  Uploaded content is not guaranteed to persist on the testnet until storage insurance is implemented (expected in POC4 2019). All participating nodes should consider participation a voluntary service with no formal obligation whatsoever and should be expected to delete content at their will. Therefore, users should under no circumstances regard Swarm as safe storage until the incentive system is functional.

.. note::
  Swarm POC3 allows for encryption. Upload of unencrypted sensitive and private data is highly discouraged as there is no way to undo an upload. Users should refrain from uploading illegal, controversial or unethical content.

.. note:: The Swarm is a `Persistent Data Structure <https://en.wikipedia.org/wiki/Persistent_data_structure>`_, therefore there is no notion of delete/remove action in Swarm. This is because content is disseminated to swarm nodes who are incentivised to serve it.

.. important:: Always use encryption for sensitive content! For encrypted content, uploaded data is 'protected', i.e. only those that know the reference to the root chunk (the swarm hash of the file as well as the decryption key) can access the content. Since publishing this reference (on ENS or with MRU) requires an extra step, users are mildly protected against careless publishing as long as they use encryption. Even though there is no guarantees for removal, unaccessed content that is not explicitly insured will eventually disappear from the Swarm, as nodes will be incentivised to garbage collect it in case of storage capacity limits.

Available APIs
================

Swarm offers several APIs:
 * CLI
 * JSON-RPC - using web3.0 bindings over Geth's IPC
 * HTTP interface - every Swarm node exposes a local HTTP proxy that implements the :ref:`bzz protocol suite`
 * Javascript - available through the `swarm-js <https://github.com/MaiaVictor/swarm-js>`_ or `swarmgw <https://www.npmjs.com/package/swarmgw>`_ packages


Code
========

Source code is at https://github.com/ethereum/go-ethereum/ and our team's working copy is at https://github.com/ethersphere/go-ethereum/

Status
---------------

* The status of Swarm is proof of concept 3 release series (POC3).
* Roadmap time board https://github.com/orgs/ethersphere/projects/5
* https://github.com/ethersphere/Swarm/wiki/roadmap
* https://github.com/ethereum/go-ethereum/wiki/Swarm---POC-series

.. note:: Swarm is experimental code and untested in the wild. Use with extreme care. We encourage developers to connect to the testnet with their permanent nodes and give us feedback.

Testnets with public gateways
-------------------------------

* Public alpha testnet running POC3 with gateway https://swarm-gateways.net/
* Staging network running experimental code with gateway https://open.swarm-gateways.net/

.. note:: The Swarm public gateways are temporary and users should not rely on their existence for production services.

License
-------------

Swarm is part of the go-ethereum library and (i.e. all code outside of the `cmd` directory) is licensed under the
`GNU Lesser General Public License v3.0 <https://www.gnu.org/licenses/lgpl-3.0.en.html>`_, also
included in our repository in the `COPYING.LESSER <https://github.com/ethereum/go-ethereum/blob/master/COPYING.LESSER>`_ file.

The go-ethereum binaries (i.e. all code inside of the `cmd` directory) is licensed under the
`GNU General Public License v3.0 <https://www.gnu.org/licenses/gpl-3.0.en.html>`_, also included
in our repository in the `COPYING <https://github.com/ethereum/go-ethereum/blob/master/COPYING.LESSER>`_ file.


Example dapps
-------------

* http://swarm-gateways.net/bzz://swarmapps.eth
* source code: https://github.com/ethersphere/Swarm-dapps


Swarm dev onboarding
---------------------

https://github.com/ethersphere/Swarm/wiki/Swarm

Reporting a bug and contributing
-------------------------------------

Issues are tracked on GitHub and GitHub only. Swarm related issues and PRs are labeled with Swarm:

* https://github.com/ethereum/go-ethereum/labels/Swarm
* https://github.com/ethersphere/go-ethereum/issues
* `Good first issues <https://github.com/ethersphere/go-ethereum/issues?utf8=✓&q=is%3Aopen+is%3Aissue+label%3A"good+first+issue">`_

Please include the commit and branch when reporting an issue.

Pull requests should by default commit on the `master` branch (edge).

Prospective contributors please read `the Developer's Guide <>`


Credits
===============

Swarm is funded by the Ethereum Foundation and industry sponsors.

Swarm is code by Ethersphere `https://github.com/ethersphere`

The Core team
----------------

* Viktor Trón - @zelig
* Daniel A. Nagy - @nagydani
* Aron Fischer- @homotopycolimit
* Louis Holbrook- @nolash
* Lewis Marshal- @lmars
* Fabio Barone- @holisticode
* Anton Evangelatov- @nonsense
* Janos Gulyas- @janos
* Balint Gabor- @gbalint
* Elad Nachmias- @justelad

were on the core team:

* Zahoor Mohamed- @jmozah
* Zsolt Felföldi- @zsfelfoldi
* Nick Johnson- @Arachnid

Sponsors and collaborators
-----------------------------

* http://status.im
* http://livepeer.org
* http://jaak.io
* http://datafund.io
* http://mainframe.com
* http://wolk.com
* http://riat.at
* http://datafund.org
* http://216.com
* http://cofound.it
* http://iconomi.net
* http://infura.io
* http://epiclabs.io
* http://asseth.fr


Special thanks
------------------

* Felix Lange, Alex Leverington for inventing and implementing devp2p/rlpx
* Jeffrey Wilcke, Peter Szilagyi and the entire ethereum foundation go team for continued support, testing and direction
* Gavin Wood and Vitalik Buterin for the holy trinity vision of web3
* Nick Johnson for ENS and ENS Swarm integration
* Alex Van der Sande, Fabian Vogelsteller, Bas van Kervel, Victor Maia, Everton Fraga and the Mist team
* Elad Verbin for his continued technical involvement as an advisor and ideator
* Nick Savers for his unrelenting support and meticulous reviews of our papers
* Gregor Zavcer, Alexei Akhunov, Alex Beregszaszi, Daniel Varga, Julien Boutloup for inspiring discussions and ideas
* Juan Benet and the IPFS team for continued inspiration
* Carl Youngblood, Shane Howley, Paul De Cam, Doug Leonard and the mainframe team for their contribution to PSS and MRU
* Sourabh Niyogi and the entire Wolk team for the inspiring collaboration on databases
* Ralph Pilcher for implementing the swap swear and swindle contract suite in solidity/truffle and Oren Sokolowsky for the initial version
* Javier Peletier from Epiclabs (ethergit) for his contribution to MRUs
* Jarrad Hope and Carl Bennet (Status) for their support
* Participants of the orange lounge research group and the Swarm orange summits
* Roman Mandeleil and Anton Nashatyrev for an early java implementation of swarm
* Igor Sharudin, Dean Vaessen for example dapps
* Community contributors for feedback and testing
* Daniel Kalman, Benjamin Kampmann, Daniel Lengyel, Anand Jaisingh for contributing to the swarm websites
* Felipe Santana, Paolo Perez and Paratii team for filming at the 2017 swarm summit and making the summit website

Community
-------------------

Daily development and discussions are ongoing in various gitter channels:

* https://gitter.im/ethereum/swarm: general public chatroom about Swarm dev support
* https://gitter.im/ethersphere/orange-lounge: our open engine room
* https://gitter.im/ethersphere/pss: about postal services on Swarm - messaging with deterministic routing
* https://gitter.im/ethersphere/hq: our internal engine room

Swarm discussions also on the Ethereum subreddit: http://www.reddit.com/r/ethereum


Swarm Hangouts
-------------------

* https://hangouts.google.com/hangouts/_/ethereum.org/Swarm
* standup: Monday to Friday 4pm CEST
* weekly roundtable: Tuesday 4.30pm CEST


Documentation and resources
==================================

Swarm guide (this document)
-------------------------------

* This document's source code is found at https://github.com/ethersphere/Swarm-guide
* The HTML rendered version is available at https://swarm-guide.readthedocs.io/en/latest/

Homepage
--------

the *Swarm homepage* is accessible via Swarm at `theswarm.eth`. The page can be accessed through the public gateway on http://swarm-gateways.net/bzz:/theswarm.eth/

POC2 blogpost
---------------

https://blog.ethereum.org/2016/12/15/Swarm-alpha-public-pilot-basics-Swarm/

Swarm Orange Summit
----------------------

* `Swarm summit 2018 promo video <https://swarm-gateways.net/bzz:/079b4f4155d7e8b5ee76e8dd4e1a6a69c5b483d499654f03d0b3c588571d6be9/>`_
* `2018 May 7-11 Ljubljana <https://ethersphere.github.io/swarm-summit-2018/>`_
* 2017 June 4-10 Berlin


Orange papers
--------------

* `Viktor Trón, Aron Fischer, Dániel Nagy A and Zsolt Felföldi, Nick Johnson: swap, swear and swindle: incentive system for Swarm. May 2016 <https://open.swarm-gateways.net/bzz:/theswarm.test/ethersphere/orange-papers/1/sw^3.pdf>`_
* `Viktor Trón, Aron Fischer, Nick Johnson: smash-proof: auditable storage for Swarm secured by masked audit secret hash. May 2016 <https://open.swarm-gateways.net/bzz:/theswarm.test/ethersphere/orange-papers/2/smash.pdf>`_
* `Viktor Trón, Aron Fischer, Ralph Pilcher, Fabio Barone: swap swear and swindle games: scalable infrastructure for decentralised service economies. Work in progress. June 2018. <https://www.sharelatex.com/1452913241cqmzrpfpjkym>`_
* `Viktor Trón, Aron Fischer, Daniel A. Nagy. Swarm: a decentralised peer-to-peer network for messaging and storage. Work in progress. June, 2018. <https://www.sharelatex.com/6741568343dhhjfkjpnfwz>`_
* P.O.T. data structures and databases on swarm. In preparation.
* Mutable Resource Updates. An off-chain scheme for versioning content in Swarm. In preparation.
* Privacy on swarm. Encryption, access control, private browsing in Swarm. Tentative.
* Analysis of attack resilience of swarm storage. Tentative.
