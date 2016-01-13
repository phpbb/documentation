================
The upload class
================

The newly introduced files ``upload`` class replaces the previously existing ``fileupload`` class.

Passing settings to upload class
================================

In phpBB versions prior to 3.2, the settings like maximaum image dimensions were
passed to the ``fileupload`` class via the constructor. Since these are now retrieved via the container
infrastructure, this is no longer possible. Instead, the new ``upload`` class incorporates several
methods for easily setting the necessary upload requirements:

- ``set_allowed_extensions($allowed_extensions)``
- ``set_allowed_dimensions($min_width, $min_height, $max_width, $max_height)``
- ``set_max_filesize($max_filesize)``
- ``set_disallowed_content($disallowed_content)``
- ``set_error_prefix($error_prefix)``

Each of these methods return the instance of the ``upload`` class allowing for chained calls:

.. code-block:: php

    $upload->set_allowed_extensions(array('png', 'jpg'))
        ->set_allowed_dimensions(20, 20, 90, 90)
        ->set_max_filesize(65536)
        ->set_error_prefix('AVATAR_');

