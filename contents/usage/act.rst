Access Control 
===============

Swarm supports restricting access to content through several access control strategies:

1. Password protection - where a number of undisclosed parties can access content using a shared secret

2. Selective access using `Elliptic Curve <https://en.wikipedia.org/wiki/Elliptic-curve_cryptography>`_ key-pairs:

    2.1. For an undisclosed party - where only one grantee can access the content

    2.2. For a number of undisclosed parties - where every grantee can access the content

Password protection
-------------------

The simplest type of credential is a passphrase. In typical use cases, the
passphrase is distributed by off-band means, with adequate security measures. 
Any user that knows the passphrase can access the content.

When using password protection, a given content reference (e.g.: a given Swarm manifest address or a 
Mutable Resource root chunk address) is encrypted using `scrypt <https://en.wikipedia.org/wiki/Scrypt>`_
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
  your data, passwords and encryption keys _safe_. This is enforced through an in-code guard.

.. danger:: 
  NEVER (EVER!) use an external gateway to upload or download access controlled content as you will be putting your privacy at risk!
  You have been fairly warned!



