
Encryption
===========

Introduced in POC 0.3, symmetric encryption is now readily available to be used with the ``go-swarm up`` upload command.
The encryption mechanism is meant to protect your information and make the chunked data unreadable to any handling Swarm node.

More info about how we handle encryption at Swarm can be found `here <https://github.com/ethersphere/swarm/wiki/Symmetric-Encryption-for-Swarm-Content>`_.

.. note::
  Swarm currently supports both encrypted and unencrypted ``go-swarm up`` commands through usage of the ``--encrypt`` flag.
  This might change in the future as we will refine and make Swarm a safer network.

.. note::
  When you upload content to Swarm using the ``--encrypt`` flag, the hash returned will be longer than the standard Swarm hash you're used to - that's because the resulting hash is a concatenation of the content hash and the encryption key.


.. important::
  The encryption feature is non-deterministic (due to a random seed generated on every upload request) and as a result not idempotent by design, thus uploading the same resource twice to Swarm with encryption enabled will not result in the same output hash.


Example usage:

.. code-block:: none

  go-swarm up --encrypt foo.txt
  > c2ebba57da7d97bc4725a542ff3f0bd37163fd564e0298dd87f320368ae4faddd1f25a870a7bb7e5d526a7623338e4e9b8399e76df8b634020d11d969594f24a
  # note the longer response hash

In the response hash, the first half is the Swarm hash of the manifest while the second half is the encryption-and-decryption key.
