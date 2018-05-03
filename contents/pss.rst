*********
PSS
*********

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
You can subscribe to messages on topic 0x0000 and handle the encryption on your side,  This even enables you to use the Swarm node as a multiplexer for different keypair identities.

Sending a raw message
----------------------

It is also possible to send a message without using the builtin encryption. In this case no recipient registration is made, but the message is sent directly, with the following input data:

1. ``Message payload`` - the message data as an arbitrary byte sequence.

2. ``Address``- the swarm overlay address to use for the routing.


.. important::
  ``PSS`` does not guarantee message ordering (`Best-effort delivery <https://en.wikipedia.org/wiki/Best-effort_delivery>`_)
  nor message delivery (e.g. messages to offline nodes will not be cached and replayed) at the moment
