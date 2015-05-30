===============
Getting started
===============

To get started with Migrations, we need to first create a Migration file that
will hold the list of database changes.

Before we get started, first you should remember that with Migrations there is
no limit to the number of Migration files. This means that you're free to create
migration files as you need, whether you want to create a single file per
version, per feature, or even for every change you make to the database -- it is
entirely up to you!

Where do I create the Migration file?
=====================================

Extension Author
----------------
Create a directory in ``ext/vendor/extension/`` called migrations. All of your
Migration files should be in this directory.

Developer
---------

phpBB Migration files are in ``phpbb/db/migration/data/``. You may make a file
in this directory OR make a subdirectory if you plan on creating multiple
Migration files for a single feature.

What must go in the Migration file?
===================================

The only absolute requirement is creating a new class that extends
``\phpbb\db\migration\migration``:

.. code-block:: php

    <?php
    class new_migration_class extends \phpbb\db\migration\migration
    {
        // Data for database changes will go in here!
    }

What should the new migration class name be?
--------------------------------------------

The class naming scheme must follow the general coding guidelines and can be
whatever you want.

What else goes in a Migration file?
===================================

Now you're ready to get started adding instructions so that the Migrator knows
what to do when it encounters your Migration file.

Migration Dependencies
----------------------

Before you start making Migration files that you want to use, you should
understand Migration dependencies and how they work.

:doc:`dependencies`

Schema Changes
--------------

If you need to make any schema changes (Creating/Changing/Removing
Tables/Columns/Indexes) you should read the following page.

:doc:`schema_changes`

Data Changes
------------
If you need to make data changes (Config settings, Adding/Removing Modules,
Adding/Removing/Setting/Unsetting Permissions, or other custom changes) you
should read the following page.

:doc:`data_changes`

Check If Effectively Installed
------------------------------

The function ``effectively_installed()`` is called before installing a
Migration. This allows you to transition from a previous database installer
method to Migrations easily.

**If it returns true, the Migration is marked as installed without applying
any changes.** *This function is not required and typically should not be
needed. This is only needed if you are trying to allow updates from a system
that may currently be installed, but where migrations haven't been run yet (e.g.
updating a mod from 3.0.x to 3.1.x).*
