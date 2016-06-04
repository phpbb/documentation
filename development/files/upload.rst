================
The upload class
================

The newly introduced files ``upload`` class replaces the previously existing ``fileupload`` class.

Passing settings to upload class
================================

In phpBB versions prior to 3.2, the settings like maximum image dimensions could be passed directly
to the ``fileupload`` class via the constructor. Since these are now retrieved via the container
infrastructure, this is no longer possible. Instead, the new ``upload`` class incorporates several
methods for easily setting the necessary upload requirements:

- ``set_allowed_extensions($allowed_extensions)``
- ``set_allowed_dimensions($min_width, $min_height, $max_width, $max_height)``
- ``set_max_filesize($max_filesize)``
- ``set_disallowed_content($disallowed_content)``
- ``set_error_prefix($error_prefix)``

Each of these methods returns the current instance of the ``upload`` class allowing for chained calls:

.. code-block:: php

    $upload->set_allowed_extensions(array('png', 'jpg'))
        ->set_allowed_dimensions(20, 20, 90, 90)
        ->set_max_filesize(65536)
        ->set_error_prefix('AVATAR_');

Uploading files
===============

The previously existing ``form_upload()``, ``remote_upload``, and ``local_upload`` methods no longer exist. Instead, the ``upload`` class now contains the ``handle_upload`` method.

.. code-block:: php

    $files_upload->handle_upload('files.type.local', $source_file, $filedata);

The method expects the upload type as the first argument. Types that are available by default are

- ``files.types.form``
- ``files.types.local``
- ``files.types.remote``

Extensions can of course add new upload types and use them provided that they implement ``phpbb\files\types\type_interface``.
Any arguments after the type will passed on to the upload type class. These have to implement the upload method and retrieve the passed arguments with ``func_get_args()``.

Converting uses of ``fileupload`` class
=======================================

It is recommended to use the ``files`` factory for retrieving the ``files`` classes. In this example we will
however use the phpBB container.

Empty constructor
*****************

In phpBB 3.1, the basic use of the ``fileupload`` class looked as follows:

.. code-block:: php

    include_once($phpbb_root_path . 'includes/functions_upload.' . $phpEx);
    $upload = new fileupload();
    $upload->set_disallowed_content(array());
    $extensions = $cache->obtain_attach_extensions((($is_message) ? false : (int) $forum_id));
    $upload->set_allowed_extensions(array_keys($extensions['_allowed_']));
    $file = ($local) ? $upload->local_upload($local_storage, $local_filedata, $mimetype_guesser) : $upload->form_upload($form_name, $mimetype_guesser, $plupload);

As of phpBB 3.2, this is changed to:

.. code-block:: php

    $upload = $phpbb_container->get('files.upload');
    $upload->set_disallowed_content(array());
    $extensions = $cache->obtain_attach_extensions((($is_message) ? false : (int) $forum_id));
    $upload->set_allowed_extensions(array_keys($extensions['_allowed_']));
    $file = ($local) ? $upload->handle_upload('files.types.local', $local_storage, $local_filedata) : $upload->handle_upload('files.types.form', $form_name);

.. note::

    Services like ``phpbb\mimetype\guesser`` and ``phpbb\plupload\plupload`` are no longer passed to the upload methods.


The calls can of course also be chained:

.. code-block:: php

    $extensions = $cache->obtain_attach_extensions((($is_message) ? false : (int) $forum_id));
    $file = $phpbb_container->get('files.upload')
        ->set_disallowed_content(array())
        ->set_allowed_extensions(array_keys($extensions['_allowed_']))
        ->handle_upload('files.types.local', $local_storage, $local_filedata);

Settings passed to constructor
******************************

phpBB 3.1 also allowed passing the settings directly to the constructor of the ``fileupload`` class:

.. code-block:: php

    $upload = new fileupload(
        $error_prefix,
        $allowed_extensions,
        $max_filesize,
        $min_width,
        $min_height,
        $max_width,
        $max_height,
        $disallowed_content
    );

Since the ``upload`` class is retrieved with the container or the factory, passing these settings to the
constructor is no longer possible. Instead, these should be passed with the accompanying ``set_`` methods:

.. code-block:: php

    $upload = $files_factory->get('files.upload')
        ->set_error_prefix($error_prefix)
        ->set_allowed_extensions($allowed_extensions)
        ->set_max_filesize($max_filesize)
        ->set_allowed_dimensions($min_width, $min_height, $max_width, $max_height)
        ->set_disallowed_content($disallowed_content);

This can also be chained to directly call the ``handle_upload()`` method:

.. code-block:: php

    $upload = $files_factory->get('files.upload')
        ->set_error_prefix($error_prefix)
        ->set_allowed_extensions($allowed_extensions)
        ->set_max_filesize($max_filesize)
        ->set_allowed_dimensions($min_width, $min_height, $max_width, $max_height)
        ->set_disallowed_content($disallowed_content)
        ->handle_upload('files.types.local', $local_storage, $local_filedata);

Reset settings
==============

The settings like maximum file size, allowed dimensions, and error prefix can easily be reset using the
``reset_vars()`` method.

Perform common checks on upload
===============================

The ``common_checks()`` method can be used to perform common checks on the ``filespec`` object returned
by the ``handle_upload()`` method. These include checks for the file size of the uploaded file, the file's
name and extension, and disallowed file content.
This can be performed by simply passing the ``filespec`` object:

.. code-block:: php

    $upload->common_checks($filespec);

.. note::

    ``common_checks()`` does not have a function return. Instead, please check the ``$filespec->error```
    property after running ``common_checks()``

Check form for validity
=======================

One can check if a form is valid for file uploads by simply passing the form name to the ``is_valid()`` method.
It will return true on valid forms and false if the form does not exist or contains invalid content.

.. code-block:: php

    $valid_form = $upload->is_valid('acme_form');
