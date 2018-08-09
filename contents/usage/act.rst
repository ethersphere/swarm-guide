Access Control 
===============

Swarm supports restricting access to content through several access control strategies:

- Password protection - where a number of undisclosed parties can access content using a shared secret ``(pass)``

- Selective access using `Elliptic Curve <https://en.wikipedia.org/wiki/Elliptic-curve_cryptography>`_ key-pairs:

    - For an undisclosed party - where only one grantee can access the content ``(pk)``

    - For a number of undisclosed parties - where every grantee can access the content ``(act)``

Password protection 
-------------------

The simplest type of credential is a passphrase. In typical use cases, the
passphrase is distributed by off-band means, with adequate security measures. 
Any user that knows the passphrase can access the content.

When using password protection, a given content reference (e.g.: a given Swarm manifest address or, alternatively, 
a Mutable Resource address) is encrypted using `scrypt <https://en.wikipedia.org/wiki/Scrypt>`_
with a given passphrase and a random salt. 
The encrypted reference and the salt are then embedded into an unencrypted manifest which can be freely
distributed but only accessed by undisclosed parties that posses knowledge of the passphrase.

Selective access using EC keys
-------------------------------

A more sophisticated type of credential is an `Elliptic Curve <https://en.wikipedia.org/wiki/Elliptic-curve_cryptography>`_
private key, identical to those used throughout Ethereum for accessing accounts. 

In order to obtain the content reference, an
`Elliptic-curve Diffie–Hellman <https://en.wikipedia.org/wiki/Elliptic-curve_Diffie%E2%80%93Hellman>`_ `(ECDH)` 
key agreement needs to be performed between a provided EC public key (that of the content publisher) 
and the authorized key, after which the undisclosed authorized party can decrypt the reference to the 
access controlled content.

Whether using access control to disclose content to a single party (by using the ``pk`` strategy) or to 
multiple parties (using the ``act`` strategy), a third unauthorized party cannot assert the identity 
of the authorized parties.
The third party can, however, know the number of undisclosed grantees to the content. 
This, however, can be mitigated by adding bogus grantee keys while using the ``act`` strategy 
in cases where masking the number of grantees is necessary. This is not the case when using the ``pk`` strategy, as it as
by definition an agreement between two parties and only two parties (the publisher and the grantee).

.. important::
  Accessing content which is access controlled is enabled only when using a `local` Swarm node (e.g. running on `localhost`) in order to keep
  your data, passwords and encryption keys safe. This is enforced through an in-code guard.

.. danger:: 
  **NEVER (EVER!) use an external gateway to upload or download access controlled content as you will be putting your privacy at risk!
  You have been fairly warned!**

Usage
-----

**Creating** access control for content is currently supported only through CLI usage.

**Accessing** restricted content is available through CLI. Accessing content which is restricted 
by a passphrase is also available through the HTTP API 
using `HTTP Basic access authentication <https://en.wikipedia.org/wiki/Basic_access_authentication>`_.


CLI usage
---------

HTTP usage
----------

Accessing restricted content on Swarm through the HTTP API is, as mentioned, limited to your local node
due to security considerations.
Whenever requesting a restricted resource without the proper credentials via the HTTP proxy, the Swarm node will respond 
with an ``HTTP 401 Unauthorized`` response code.

*When accessing password protected content:*

When accessing a resource protected by a passphrase without the appropriate credentials the browser will 
receive an ``HTTP 401 Unauthorized`` response and will show a pop-up dialog asking for a username and password.
For the sake of decrypting the content - only the password input in the dialog matters and the username field can be left blank.

The credentials for accessing content protected by a password can be provided in the initial request in the form of:
``http://:<password>@localhost:8500/bzz:/<hash or ens name>``

.. important:: Access controlled content should be accessed through the ``bzz://`` protocol

*When accessing EC key protected content:*

When accessing a resource protected by EC keys, the node that requests the content will try to decrypt the restricted
content reference using its **own** EC key which is associated with the current `bzz account` that 
the node was started with (see the ``--bzzaccount`` flag). If the node's key is granted access - the content will be
decrypted and displayed, otherwise - an ``HTTP 401 Unauthorized`` error will be returned by the node.