.. _bzz protocol suite:

BZZ URL schemes
=======================

Swarm offers 8 distinct URL schemes:

bzz
^^^^^


The bzz scheme assumes that the domain part of the url points to a manifest. When retrieving the asset addressed by the URL, the manifest entries are matched against the URL path. The entry with the longest matching path is retrieved and served with the content type specified in the corresponding manifest entry.

Example:

.. code-block:: none

    GET http://localhost:8500/bzz:/2477cc8584cc61091b5cc084cdcdb45bf3c6210c263b0143f030cf7d750e894d/readme.md

returns a readme.md file if the manifest at the given hash address contains such an entry.

If the manifest does not contain an file at ``readme.md`` itself, but it does contain multiple entries to which the URL could be resolved, like, in the example above, the manifest has entries for ``readme.md.1`` and ``readme.md.2``, the API returns an HTTP response "300 Multiple Choices", indicating that the request could not be unambiguously resolved. A list of available entries is returned via HTTP or JSON.


.. _bzz-raw:

bzz-raw
^^^^^^^^^^^^^^

.. code-block:: none

    GET http://localhost:8500/bzz-raw:/2477cc8584cc61091b5cc084cdcdb45bf3c6210c263b0143f030cf7d750e894d


When responding to GET requests with the bzz-raw scheme, Swarm does not assume that the hash resolves to a manifest. Instead it just serves the asset referenced by the hash directly.

The ``content_type`` query parameter can be supplied to specify the MIME type you are requesting, otherwise content is served as an octet-stream per default. For instance if you have a pdf document (not the manifest wrapping it) at hash ``6a182226...`` then the following url will properly serve it.

.. code-block:: none

    GET http://localhost:8500/bzz-raw:/6a18222637cafb4ce692fa11df886a03e6d5e63432c53cbf7846970aa3e6fdf5?content_type=application/pdf


Importantly and somewhat unusually for generic schemes, the raw scheme supports POST and PUT requests. This is a crucially important way in which swarm is different from the internet as we know it.

The possibility to POST makes Swarm an actual cloud service, bringing upload functionality to your browsing.

In fact the command line tool ``swarm up`` uses the HTTP proxy with the bzz-raw scheme under the hood.

bzz-list
^^^^^^^^^^^^^^

.. code-block:: none

    GET http://localhost:8500/bzz-list:/2477cc8584cc61091b5cc084cdcdb45bf3c6210c263b0143f030cf7d750e894d/path

Returns a list of all files contained in <manifest> under <path> grouped into common prefixes using ``/`` as a delimiter. If no path is supplied, all files in manifest are returned. The response is a JSON-encoded object with ``common_prefixes`` string field and ``entries`` list field.

bzz-hash
^^^^^^^^^^^^^^

.. code-block:: none

    GET http://localhost:8500/bzz-hash:/theswarm.eth/


Swarm accepts GET requests for bzz-hash url scheme and responds with the hash value of the raw content, the same content returned by requests with bzz-raw scheme. Hash of the manifest is also the hash stored in ENS so bzz-hash can be used for ENS domain resolution.

Response content type is *text/plain*.


bzz-immutable
^^^^^^^^^^^^^^^^^^^^

.. code-block:: none

    GET http://localhost:8500/bzz-immutable:/2477cc8584cc61091b5cc084cdcdb45bf3c6210c263b0143f030cf7d750e894d

The same as the generic scheme but there is no ENS domain resolution, the domain part of the path needs to be a valid hash. This is also a read-only scheme but explicit in its integrity protection. A particular bzz-immutable url will always necessarily address the exact same fixed immutable content.



bzz-resource
^^^^^^^^^^^^^^^^^^^^

``bzz-resource`` allows you to receive hash pointers to content that the ENS entry resolved to at different versions

bzz-resource://<id> - get latest update
bzz-resource://<id>/<n> - get latest update on period n
bzz-resource://<id>/<n>/<m> - get update version m of period n
<id> = ens name
