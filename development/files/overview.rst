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

The filespec and upload classes are defined with the prototype scope.
This results in the container returning a new instance of these classes every time one calls the get() method.