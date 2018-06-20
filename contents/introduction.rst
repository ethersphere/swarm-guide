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

The Ethereum Foundation Swarm team is operating a Swarm testnet where Swarm can be tried out.
Everyone can join the network by running the Swarm client node on their server, desktop, laptop or mobile device. See `Getting Started` for how to do this.
The Swarm client is part of the Ethereum stack, the reference implementation is written in golang and found under the go-ethereum repository. Currently at POC (proof of concept) version 0.3 is running on all nodes.

Swarm offers a **local HTTP proxy*** API that dapps or command line tools can use to interact with Swarm. Some modules like `messaging  <PSS>`_ are   only available through RPC-JSON API. The foundation servers on the testnet are offering public gateways, which serve to easily demonstrate functionality and allow free access so that people can try Swarm without even running their own node.

.. note::
  The Swarm public gateways are temporary and users should not rely on their existence for production services.




The swarm of Swarm is the collection of nodes of the devp2p network each of which run the bzz protocol suite on the same network id.

Swarm nodes can also connect with one (or several) ethereum blockchains for domain name resolution and one ethereum blockchain for bandwidth and storage compensation.
Nodes running the same network id are supposed to connect to the same blockchain for payments. A Swarm network is identified by its network id which is an arbitrary integer.

Swarm allows for :dfn:`upload and disappear` which means that any node can just upload content to the Swarm and
then is allowed to go offline. As long as nodes do not drop out or become unavailable, the content will still
be accessible due to the 'synchronization' procedure in which nodes continuously pass along available data between each other.

.. note::
  Uploaded content is not guaranteed to persist on the testnet until storage insurance is implemented (expected in POC4 by Q1 2019). All participating nodes should consider participation a  voluntary service with no formal obligation whatsoever and should be expected to delete content at their will. Therefore, users should under no circumstances regard Swarm as safe storage until the incentive system is functional.

.. note::
  The Swarm public gateways are temporary and users should not rely on their existence for production services.

.. note::
  Uploaded content is not guaranteed to persist on the testnet until storage insurance is implemented (expected in POC4 2019). All participating nodes should consider participation a voluntary service with no formal obligation whatsoever and should be expected to delete content at their will. Therefore, users should under no circumstances regard Swarm as safe storage until the incentive system is functional.

.. note::
  Swarm POC3 allows for encryption. Upload of unencrypted sensitive and private data is highly discouraged as there is no way to undo an upload. Users should refrain from uploading illegal, controversial or unethical content.


.. note:: There is no such thing as delete/remove in Swarm. Once data is uploaded there is no way you can initiate her to revoke it.
This is because content is disseminated to swarm nodes who are incentivised to serve it.
Always use encryption for sensitive content.
For encrypted content, uploaded data is 'protected' (ie., only those that know the reference to the root chunk (the swarm hash of the file as well as the decryption key) can access the content. Since publishing this reference (on ENS or with MRU) requires an extra step, users are mildly protected against careless publishing as long as they use encryption. Eventhough there is no guarantees for removal, unaccessed content that is not explicitly insured will eventually disappear from the swarm, as nodes will be incentivised to garbage collect it in case of storage capacity limits.

Available APIs
================

Swarm offers several APIs:
 * CLI
 * JSON-RPC - using web3.0 bindings over Geth's IPC
 * HTTP interface - every Swarm node exposes a local HTTP proxy that implements the :ref:`bzz protocol suite`
 * Javascript - available through the `swarm-js <https://github.com/MaiaVictor/swarm-js>`_ or `swarmgw <https://www.npmjs.com/package/swarmgw>`_ packages


Code
========

Source code is at https://github.com/ethereum/go-ethereum/ and our team working copy  https://github.com/ethersphere/go-ethereum/

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

.. note::
The Swarm public gateways are temporary and users should not rely on their existence for production services.

License
-------------

Swarm is part of the go-ethereum library and (i.e. all code outside of the `cmd` directory) is licensed under the
[GNU Lesser General Public License v3.0 https://www.gnu.org/licenses/lgpl-3.0.en.html, also
included in our repository in the COPYING.LESSER https://github.com/ethereum/go-ethereum/blob/master/COPYING.LESSER file.

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

Issues are tracked on github and github only. Swarm related issues and PRs are labeled with Swarm:

* https://github.com/ethereum/go-ethereum/labels/Swarm
* https://github.com/ethersphere/go-ethereum/issues
* Good first issues:  https://github.com/ethersphere/go-ethereum/issues?utf8=✓&q=is%3Aopen+is%3Aissue+label%3A"good+first+issue"+

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


Swarm hangouts
-------------------

* https://hangouts.google.com/hangouts/_/ethereum.org/Swarm
* standup: Monday to Friday 4pm CEST -
* weekly roundtable: Tuesday 4.30pm CEST





Documentation and resources
==================================

Swarm guide (this document)
-------------------------------

* This document's source code is found at https://github.com/ethersphere/Swarm-guide
* The HTML rendered version is available at https://swarm-guide.readthedocs.io/en/latest/

Homepage
--------

the *Swarm homepage* is accessible via Swarm at `theSwarm.eth`. The page can be accessed through the public gateway on http://swarm-gateways.net/bzz:/theswarm.eth/

POC2 blogpost
---------------

https://blog.ethereum.org/2016/12/15/Swarm-alpha-public-pilot-basics-Swarm/

Swarm Orange Summit
----------------------

* Swarm summit 2018 promo video: http://open.swarm-gateways.net/bzz:/
* 2018 May 7-11 Ljubljana: https://ethersphere.github.io/Swarm-summit-2018/
* 2017 June 4-10 Berlin: https://open.swarm-gateways.net/bzz:/summit2017.ethersphere.eth/Recent:


Orange papers
--------------

* Viktor Trón, Aron Fischer, Dániel Nagy A and Zsolt Felföldi, Nick Johnson: swap, swear and swindle: incentive system for Swarm. May 2016 - https://30399.open.swarm-gateways.net/bzz:/theSwarm.test/ethersphere/orange-papers/1/sw^3.pdf
* Viktor Trón, Aron Fischer, Nick Johnson: smash-proof: auditable storage for Swarm secured by masked audit secret hash. May 2016 - https://30399.open.swarm-gateways.net/bzz:/theSwarm.test/ethersphere/orange-papers/2/smash.pdf
* Viktor Trón, Aron Fischer, Ralph Pilcher, Fabio Barone: swap swear and swindle games: scalable infrastructure for decentralised service economies. Work in progress. June 2018. - https://www.sharelatex.com/1452913241cqmzrpfpjkym
* Viktor Trón, Aron Fischer, Daniel A. Nagy. Swarm: a decentralised peer-to-peer network for messaging and storage. Work in progress. June, 2018. - https://www.sharelatex.com/6741568343dhhjfkjpnfwz
* P.O.T. data structures and databases on swarm. In preparation.
* Mutable Resource Updates. An off-chain scheme for versioning content in Swarm. In preparation.
* Privacy on swarm. Encryption, access control, private browsing in Swarm. Tentative.
* Analysis of attack resilience of swarm storage. Tentative.


Podcasts
-------------
https://oktahedron.diskordia.org/?podcast=oh003-Swarm




Videos
--------------


Aron Fischer, Louis Holbrook, Daniel A. Nagy: Swarm Development Update - devcon3 cancun, Nov 2017


.. raw:: html

  <iframe width="560" height="315" src="https://www.youtube.com/embed/kT7BgOH49Sk" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

------------





Viktor Trón and Aron Fischer - Swap, Swear and Swindle Games - devcon3 cancun, Nov 2017

.. raw:: html

  <iframe width="560" height="315" src="https://www.youtube.com/embed/9Cgyhsjsfbg" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

++++++++++++



sw3 london

.. raw:: html

  <iframe width="560" height="315" src="https://www.youtube.com/embed/Bn65-bI-S1o" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

++++++++++++


Louis Holbrook: resource updates ethcc - EthCC, Paris, March 2018

.. raw:: html

  <iframe width="560" height="315" src="https://www.youtube.com/embed/CgvRFsezTI4" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

++++++++++++


Daniel A Nagy: encryption in Swarm - EthCC, Paris, March 2018

.. raw:: html

  <iframe width="560" height="315" src="https://www.youtube.com/embed/ZW7E8KTplgg" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

++++++++++++

Viktor Tron
`Base layer infrastructure services for web3 <https://www.youtube.com/watch?v=JgOU9MdgTGM#t=31m00s>`_ - EthCC, Paris, March 2018

++++++++++++


Louis Holbrook (Ethersphere, Jaak) PSS - Node to node Communication Over Swarm - devcon3 cancun, Nov 2017

.. raw:: html

  <iframe width="560" height="315" src="https://www.youtube.com/embed/fNlO5XJv9mI" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

++++++++++++

Daniel A Nagy - Scalable Responsive Đapps with Swarm and ENS - devcon3 cancun, Nov 2017

.. raw:: html

  <iframe width="560" height="315" src="https://www.youtube.com/embed/y01YJ_e5oHw" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

++++++++++++

Aron Fischer - Data retrieval in Swarm - Swarm orange summit, Berlin, June 2017

.. raw:: html

  <iframe width="560" height="315" src="https://www.youtube.com/embed/moEbbjOUUHI" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

++++++++++++

Zahoor Mohamed (EF, Swarm team): Swarm Fuse Demo - Ethereum Meetup, Berlin, June 2017

.. raw:: html

  <iframe width="560" height="315" src="https://www.youtube.com/embed/LObSTf2jozM" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

++++++++++++

Daniel Nagy: Network topology for distributed storage - Swarm orange summit, Berlin, June 2017

.. raw:: html

  <iframe width="560" height="315" src="https://www.youtube.com/embed/kKoGcAzEnJQ" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

++++++++++++

Fabian Vogelsteller - Swarm Integration in Mist - Swarm orange summit, Berlin, June 2017

.. raw:: html

  <iframe width="560" height="315" src="https://www.youtube.com/embed/AFVeWiP4ibQ" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

++++++++++++

Daniel Nagy (EF, Swarm team): Plausible Deniability (2 parts) - Swarm orange summit, Berlin, June 2017

.. raw:: html

  <iframe width="560" height="315" src="https://www.youtube.com/embed/fOJgNPdwy18" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

++++++++++++

.. raw:: html

  <iframe width="560" height="315" src="https://www.youtube.com/embed/dHCWaiHtxOw" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

++++++++++++

Elad Verbin: Data structures and security on Swarm (2 parts) - Swarm orange summit, Berlin, June 2017

.. raw:: html

  <iframe width="560" height="315" src="https://www.youtube.com/embed/h5msn6FcP5o" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

++++++++++++

.. raw:: html

  <iframe width="560" height="315" src="https://www.youtube.com/embed/IjYkEypa-ww" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

++++++++++++

Louis Holbrook (Ethersphere, Jaak): PSS - internode messaging protocol - Swarm orange summit, Berlin, June 2017

.. raw:: html

  <iframe width="560" height="315" src="https://www.youtube.com/embed/x9Rs23itEXo" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

++++++++++++

Viktor Tron - Distributed Database Services - Swarm Orange Summit 2017

.. raw:: html

  <iframe width="560" height="315" src="https://www.youtube.com/embed/H9MclB0J6-A" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

++++++++++++

Viktor Tron - network testing framework and visualisation - Ethereum Meetup, Berlin, June 2017

.. raw:: html

  <iframe width="560" height="315" src="https://www.youtube.com/embed/-c_kTW_aNgg" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

++++++++++++

Doug Petkanics (Livepeer): Realtime video streaming on Swarm - Swarm orange summit, Berlin, June 2017

.. raw:: html

  <iframe width="560" height="315" src="https://www.youtube.com/embed/MB-drzcRCD8" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

++++++++++++

.. raw:: html

  <iframe width="560" height="315" src="https://www.youtube.com/embed/pQjwySXLm6Y" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>


++++++++++++

Nick Johnson on the Ethereum Name System

.. raw:: html

  <iframe width="560" height="315" src="https://www.youtube.com/embed/pLDDbCZXvTE" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>



++++++++++++

Viktor Trón, Aron Fischer: Swap, Swear and Swindle. Swarm Incentivisation.

.. raw:: html

  <iframe width="560" height="315" src="https://www.youtube.com/embed/DZbhjnhP5g4" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>



++++++++++++

Viktor Trón: Towards Web3 Infrastructure.

.. raw:: html

  <iframe width="560" height="315" src="https://www.youtube.com/embed/RF8L6V_E-MM" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>


++++++++++++

Dániel A. Nagy: Developing Scalable Decentralized Applications for Swarm and Ethereum

.. raw:: html

  <iframe width="560" height="315" src="https://www.youtube.com/embed/xrw9rvee7rc" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>


++++++++++++

Aron Fischer, Dániel A. Nagy, Viktor Trón: Swarm - Ethereum.

.. raw:: html

  <iframe width="560" height="315" src="https://www.youtube.com/embed/Y9kch84cbPA" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>



++++++++++++

Viktor Trón, Nick Johnson: Swarm, web3, and the Ethereum Name Service.

.. raw:: html

  <iframe width="560" height="315" src="https://www.youtube.com/embed/BAAAhZI7qRQ" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>


++++++++++++

Nagy Dániel, Trón Viktor: Ethereum és Swarm: okos szerződések és elosztott világháló.

.. raw:: html

  <iframe width="560" height="315" src="https://www.youtube.com/embed/vD8PAJvhH-4" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>


++++++++++++

Dániel Nagy: Swarm: Distributed storage for Ethereum, the Turing-complete blockchain.

.. raw:: html

  <iframe width="560" height="315" src="https://www.youtube.com/embed/N_vtxw6nfmQ" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>


++++++++++++

Viktor Trón, Dániel A. Nagy: Swarm. Ethereum Devcon1, London, Nov 2015.

.. raw:: html

  <iframe width="560" height="315" src="https://www.youtube.com/embed/VOC45AgZG5Q" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>


++++++++++++

Dániel A. Nagy: Keeping the public record safe and accessible. Ethereum Devcon0, Berlin, Dec 2014.

.. raw:: html

  <iframe width="560" height="315" src="https://www.youtube.com/embed/QzYZQ03ON2o" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
