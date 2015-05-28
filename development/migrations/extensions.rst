==========
Extensions
==========

Using Migrations in your Extension is a very simple thing to do.

Automatically install/revert Migrations when enabled/purged
===========================================================

If you wish to have your Migrations installed and removed automatically when
your extension is enabled and purged respectively, all you need to do is put
your Migration files in::

    ext/<your vendor name>/<your extension name>/migrations/


Check if latest Migration is installed
======================================

To check if the latest Migration is installed that is included with your
extension (to, for example, make sure all updates have been applied) call the
following function:

.. code-block:: php

    $phpbb_db_migrator->migration_state('<migration name (e.g. "\phpbb\db\migration\data\v30x\release_3_0_11")>')

If the returned value is boolean false (compare to ``=== false``), then the
migration is not installed, otherwise it is at least partially installed
(assuming everything went well during the install process, it should be fully
installed or not installed at all).

To check if fully installed, if bool false is not returned, an array will be
containing the two keys ``migration_schema_done`` and ``migration_data_done``.
If both of these are true (``=== true``) then it is fully installed.

Run Updates
===========

If the user has updated your extension and new migration files were added, they
will be automatically installed when re-enabling the extension.
