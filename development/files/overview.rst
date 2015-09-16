=================
The files classes
=================

phpBB 3.2 introduces two new classes for uploading files: filespec and upload.
These have been refactored and are based on the previously available filespec
and fileupload classes. In addition to that, there is also a factory class which
can be used for easy access to the files classes.

Overview of available classes
=============================

factory
*******
``\phpbb\files\factory``

Provides easier access to files classes, e.g. inside the files classes
themselves.

filespec
********
``\phpbb\files\filespec```

Responsible for holding all file relevant information, as well as doing
file-specific operations.

upload
******
``\phpbb\files\upload``

Used for actual file uploads. Is also used for checking for valid files and
moving files.

Using the container to retrieve the classes
===========================================

The files classes can easily be retrieved using the container:

.. code-block:: php

    $factory = $phpbb_container->get('files.factory');
    $upload = $phpbb_container->get('files.upload');
    $filespec = $phpbb_container->get('files.filespec');

The filespec and upload classes are defined with the prototype scope.
This results in the container returning a new instance of these classes every time one calls the get() method.

Using the factory to retrieve the classes
=========================================

The factory class can be used to retrieve the files classes without the need to use the container itself.
It can be passed as a service to a class:

.. code-block:: yaml

    myclass:
        class: some\namespace\myclass
        arguments:
            - @files.factory

Of course, the class can also be instantiated manually:

.. code-block:: php

    $files_factory = new phpbb\files\factory($phpbb_container);

Once the factory is available, the other class can be retrieved using the ``get()`` method:

.. code-block:: php

    $filespec = $files_factory->get('filespec');

The main classes ``filespec`` and ``upload`` do not need to be prefixed with ``files.``.
