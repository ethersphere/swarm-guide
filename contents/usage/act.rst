Access Control 
===============

Swarm supports restricting access to content through several access control strategies:

- Password protection - where a number of undisclosed parties can access content using a shared secret ``(pass, act)``

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

Password protection can also be used for selective access when using the ``act`` strategy - similarly to granting access to a certain EC key
access can be also given to a party identified by a password. In fact, one could also create an ``act`` manifest that solely grants access
to grantees through passwords, without the need to know their public keys.

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
multiple parties (using the ``act`` strategy), a third unauthorized party cannot find out the identity 
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

**Accessing** restricted content is available through CLI and HTTP. When accessing content which is restricted by a password `HTTP Basic access authentication <https://en.wikipedia.org/wiki/Basic_access_authentication>`_ can be used out-of-the-box.

.. important:: When accessing content which is restricted to certain EC keys - the node which exposes the HTTP proxy that is queried must be started with the granted private key as its ``bzzaccount`` CLI parameter.


CLI usage
---------

.. important:: Restricting access to content on Swarm is a 2-step process - you first upload your content, then wrap the reference with an access control manifest. **We recommend that you always upload your content with encryption enabled**. In the following examples we will refer the uploaded content hash as ``REF``


**Protecting content with a password:**

.. note:: The ``--password`` flag when using the ``pass`` strategy refers to the password that protects the access-controlled content. This file should contain the password in plaintext. The command expects you to input the uploaded swarm content hash you'd like to limit access to (``REF``)


.. code-block:: bash

	$ echo 'mysupersecretpassword' > /path/to/password/file
	$ swarm access new pass --password /path/to/password/file <REF>
	4b964a75ab19db960c274058695ca4ae21b8e19f03ddf1be482ba3ad3c5b9f9b

The returned hash ``4b964a75ab19db960c274058695ca4ae21b8e19f03ddf1be482ba3ad3c5b9f9b`` is the hash of the access controlled manifest. When requesting this hash through the HTTP gateway you should receive an ``HTTP Unauthorized 401`` error:

.. code-block:: bash

	$ curl http://localhost:8500/bzz:/4b964a75ab19db960c274058695ca4ae21b8e19f03ddf1be482ba3ad3c5b9f9b

The same request should make an authentication dialog pop-up in the browser. You could then input the password needed and the content should correctly appear.

Requesting the same hash with HTTP basic authentication (password only) would return the content too:

.. code-block:: bash

	$ curl http://:mysupersecretpassword@localhost:8500/bzz:/4b964a75ab19db960c274058695ca4ae21b8e19f03ddf1be482ba3ad3c5b9f9b


**Protecting content with Elliptic curve keys (single grantee):**

.. note:: The ``pk`` strategy requires a ``bzzaccount`` to encrypt with. The most comfortable option in this case would be the same ``bzzaccount`` you normally start your Swarm node with - this will allow you to access your content seamlessly through that node at any given point in time.

.. note:: Grantee public keys are expected to be in an *secp256 compressed* form - 66 characters long string (e.g. ``02e6f8d5e28faaa899744972bb847b6eb805a160494690c9ee7197ae9f619181db``). Comments and other characters are not allowed.

.. code-block:: bash

	$ swarm --bzzaccount 2f1cd699b0bf461dcfbf0098ad8f5587b038f0f1 access new pk --grant-key 02e6f8d5e28faaa899744972bb847b6eb805a160494690c9ee7197ae9f619181db <REF>
	4b964a75ab19db960c274058695ca4ae21b8e19f03ddf1be482ba3ad3c5b9f9b

The returned hash ``4b964a75ab19db960c274058695ca4ae21b8e19f03ddf1be482ba3ad3c5b9f9b`` is the hash of the access controlled manifest. 

The only way to fetch the access controlled content in this case would be to request the hash through one of the nodes that were granted access and/or posses the granted private key (and that the requesting node has been started with the appropriate ``bzzaccount`` that is associated with the relevant key) - either the local node that was used to upload the content or the node which was granted access through its public key.

 **Protecting content with Elliptic curve keys and passwords (multiple grantees):**

.. note:: The ``act`` strategy requires a ``bzzaccount`` to encrypt with. The most comfortable option in this case would be the same ``bzzaccount`` you normally start your Swarm node with - this will allow you to access your content seamlessly through that node at any given point in time

.. note:: the ``act`` strategy expects a grantee public-key list and/or a list of permitted passwords to be communicated to the CLI. This is done using the ``--grant-keys`` flag and/or the ``--password`` flag. Grantee public keys are expected to be in an *secp256 compressed* form - 66 characters long string (e.g. ``02e6f8d5e28faaa899744972bb847b6eb805a160494690c9ee7197ae9f619181db``). Each grantee should appear in a separate line. Passwords are also expected to be line-separated. Comments and other characters are not allowed.

.. code-block:: bash

	$ swarm --bzzaccount 2f1cd699b0bf461dcfbf0098ad8f5587b038f0f1 access new act --grant-keys /path/to/public-keys/file --password /path/to/passwords/file <REF>
	4b964a75ab19db960c274058695ca4ae21b8e19f03ddf1be482ba3ad3c5b9f9b

The returned hash ``4b964a75ab19db960c274058695ca4ae21b8e19f03ddf1be482ba3ad3c5b9f9b`` is the hash of the access controlled manifest. 

The access controlled content could be accessed in one of the following ways:

1. Request the hash through one of the nodes that were granted access and/or posses the granted private key (and that the requesting node has been started with the appropriate ``bzzaccount`` that is associated with the relevant key) - either the local node that was used to upload the content or one of the nodes which were granted access through their public keys
2. Request the hash with HTTP authentication using one of the granted passwords

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
