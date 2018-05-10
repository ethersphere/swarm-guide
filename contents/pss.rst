*********
PSS
*********

``PSS`` (Postal Service over Swarm) is a messaging protocol over Swarm. With ``PSS`` you can send messages to any swarm in a network even though you're just connected to a single one. The messages are sent in the same manner as when you store data. However, instead of storing the data in the message, the message content will instead be passed on to _code handlers_ in the recipient nodes. 

.. note::
  ``PSS`` is still an experimental feature and under active development and is available as of POC3 of Swarm. Expect things to change.

Configuration
---------------

``PSS`` has builtin encryption functionality. In fact, in the eyes of ``PSS``, a message recipient is not only who the message is _addressed_ to, but also just as much _who_ can _decrypt_ that message. Encryption can be done using asymmetric or symmetric encryption methods.

.. note:: In case you would like to send just ``raw`` messages - defining an encryption key is not mandatory. See below for details.

To use this functionality to send a message, recipients first have to be registered with the node. This registration includes the following data:

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

.. note::
  The Address that is coupled with the encryption key is used for routing the message.
  This does *not* need to be a full address; the network will route the message to the best
  of its ability with the information that is available.
  If *no* address is given (zero-length byte slice), routing is effectively deactivated,
  and the message is passed to all peers by all peers.

Upon sending the message it is encrypted and passed on from peer to peer. Any node along the route that can successfully decrypt the message is regarded as a recipient. If the address used asrecipient is not a full swarm address, recipients will continue to pass on the message to their peers, to make it harder for anyone spying on the traffic to tell where the message "ended up."

After you associate an encryption key with an address space they will be checked against any message that comes through (when sending or receiving) given it matches the topic and the address space of the message.

.. important::
  When using the internal encryption methods, you MUST associate keys (whether symmetric or asymmetric) with an address space AND a topic before you will be able to send anything.

You can subscribe to incoming messages using a topic. You can subscribe to messages on topic 0x0000 and handle the encryption on your side, This even enables you to use the Swarm node as a multiplexer for different keypair identities.

Sending a raw message
----------------------

It is also possible to send a message without using the builtin encryption. In this case no recipient registration is made, but the message is sent directly, with the following input data:

1. ``Message payload`` - the message data as an arbitrary byte sequence.

2. ``Address``- the swarm overlay address to use for the routing.

.. important::
  ``PSS`` does not guarantee message ordering (`Best-effort delivery <https://en.wikipedia.org/wiki/Best-effort_delivery>`_)
  nor message delivery (e.g. messages to offline nodes will not be cached and replayed) at the moment.

Advanced features
-----------------

.. note:: This functionalities are optional features in pss. They are compiled in by default, but can be omitted by providing the appropriate build tags.

Handshakes
^^^^^

``PSS`` provides a convenience implementation of Diffie-Hellman handshakes using ephemeral symmetric keys. Peers keep separate sets of keys for a limited amount of incoming and outgoing communications, and create and exchange new keys when the keys expire.


Protocols
^^^^^

A framework is also in place for making ``devp2p`` protocols available using ``PSS`` connections. This feature is only available using lower-level integration, and documentation is out of scope of this document.
