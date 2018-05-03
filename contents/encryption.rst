
Encryption
===========

Introduced in POC 0.3, symmetric encryption is now readily available to be used with the ``go-swarm up`` upload command.
The encryption mechanism is meant to protect your information and make the chunked data unreadable to any handling Swarm node.

Swarm uses `Counter mode encryption <https://en.wikipedia.org/wiki/Block_cipher_mode_of_operation#Counter_(CTR)>`_ to encrypt and decrypt content.
The reference returned will be longer than the standard unencrypted Swarm reference.
That is because the resulting reference is a concatenation of the ciphertext hash and the decryption key.

More info about how we handle encryption at Swarm can be found `here <https://github.com/ethersphere/swarm/wiki/Symmetric-Encryption-for-Swarm-Content>`_.

.. note::
  Swarm currently supports both encrypted and unencrypted ``go-swarm up`` commands through usage of the ``--encrypt`` flag.
  This might change in the future as we will refine and make Swarm a safer network.

.. note::
  When you upload content to Swarm using the ``--encrypt`` flag, the refernce returned will be longer than the standard Swarm reference you're used to - that's because the resulting hash is a concatenation of the ciphertext hash and the decryption key.


.. important::
  The encryption feature is non-deterministic (due to a random key generated on every upload request) and users of the API should not rely on the result being idempotent; thus uploading the same content twice to Swarm with encryption enabled will not result in the same reference.


Example usage:

.. code-block:: none

  go-swarm up --encrypt foo.txt
  > c2ebba57da7d97bc4725a542ff3f0bd37163fd564e0298dd87f320368ae4faddd1f25a870a7bb7e5d526a7623338e4e9b8399e76df8b634020d11d969594f24a
  # note the longer reference
