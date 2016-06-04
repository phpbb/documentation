==================
The filespec class
==================

The newly introduced files ``filespec`` class replaces the previously existing ``filespec`` class.

Passing settings to filespec class
==================================

In phpBB versions prior to 3.2, the ``$upload_ary`` and ``$upload_namespace`` were
passed to the ``filespec`` class via the constructor. Since these are now retrieved via the container
infrastructure, this is no longer possible. Instead, the new ``filespec`` class incorporates 2
methods for easily setting the necessary data:

- ``set_upload_ary($upload_ary)``
- ``set_upload_namespace($namespace)``

Each of these methods returns the current instance of the ``filespec`` class allowing for chained calls:

.. code-block:: php

    $filespec->set_upload_ary($upload_ary)
        ->set_upload_namespace($namespace);

Retrieving property values
==========================

Values of ``filespec`` properties can easily be retrieved with the ``get()`` method.
Simply pass the name of the property to retrieve and it will returns its value.

.. code-block:: php

    $filename = $filespec->get('filename');

.. note::

    ``get()`` will return false if the specified property does not exist or if the class was not properly initialized.

Clean file name
===============

``filespec`` supports several ways of cleaning the filename depending on the specified mode.
Possible modes are:

- avatar
    Builds name based on specified prefix and ID
- real
    Creates a lowercase name and removes some possibly troublesome characters
- unique
    Creates unique filename without extension
- unique_ext
    Creates unique filename with extension

Move file to location
=====================

It is possible to move the uploaded file to a specified location with the ``move_file()`` method.

.. code-block:: php

    move_file($destination, $overwrite = false, $skip_image_check = false, $chmod = false)

``$destination``: Path to move file to

``$overwrite``: Whether existing files should be overwritten

``$skip_image_check``: Whether to skip if the image is valid

``$chmod``: Permission mask file should be set to with ``chmod()``
