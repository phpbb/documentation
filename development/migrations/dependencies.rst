============
Dependencies
============

Dependencies tell the Migrator what order Migrations must be installed in.

Declaring Dependencies
======================

In your Migration file, add a static public function named depends_on(),
returning an array.

.. code-block:: php

    static public function depends_on()
    {
        return array();
    }

All that is needed is to add the class name(s) of the Migration(s) that the
current Migration depends on.

For example, the migration ``phpbb\db\migration\data\v310\dev`` depends on the
extensions, style update, reported posts display, and timezone migrations to
have already been installed.

.. code-block:: php

    static public function depends_on()
    {
        return array(
            '\phpbb\db\migration\data\v310\extensions',
            '\phpbb\db\migration\data\v310\style_update_p2',
            '\phpbb\db\migration\data\v310\timezone_p2',
            '\phpbb\db\migration\data\v310\reported_posts_display',
            '\phpbb\db\migration\data\v310\migrations_table',
        );
    }

**Note:** It is highly recommended to add a dependency for all migrations. If
the migration is the first migration of your extension just depend on the
release migration of the minimum phpBB requirement of your extension, e.g.
3.1.4:

.. code-block:: php

    static public function depends_on()
    {
        return array(
            '\phpbb\db\migration\data\v31x\v314',
        );
    }

depends_on creates a tree
=========================

Imagine the following situation:

.. csv-table::
   :header: "Migration", "Dependencies", "Note"
   :delim: |

   ``migration_1`` | ``phpbb\db\migration\data\\v310\\dev`` | Initial release, 1.0.0, requires phpBB 3.1.0
   ``migration_2`` | ``migration_1`` | New feature for 1.0.1 (during development)
   ``migration_3`` | ``migration_1`` | Another new feature for 1.0.1 (during development)
   ``migration_4`` | ``migration_2`` | Modifying the feature in ``migration_2``
   ``migration_5`` | ``migration_3``, ``migration_4`` | Release 1.0.1

This dependency setup would cause the following Migrations to be additionally
installed when an individual Migration was installed manually. *Assumes*
``phpbb\db\migration\data\v310\dev`` *is already installed.*


.. csv-table::
   :header: "Install", "Migrations that are installed"
   :delim: |

   ``migration_1`` | ``migration_1``
   ``migration_2`` | ``migration_1``, ``migration_2``
   ``migration_3`` | ``migration_1``, ``migration_3``
   ``migration_4`` | ``migration_1``, ``migration_2``, ``migration_4``
   ``migration_5`` | ``migration_1``, ``migration_2``, ``migration_4``, ``migration_3``, ``migration_5``

What does this mean for me?
===========================

You must specify all dependencies that the current Migration has, but not any
that the dependencies list as dependencies for their own installation.

This means that ``migration_5`` doesn't need to list ``migration_1`` through
``migration_4`` as a dependency, only ``migration_3`` and ``migration_4``
because those Migrations already require ``migration_1`` and ``migration_2``.

This also means that the desired order of operations is preserved. In the above
example, ``migration_4`` modifies the feature in ``migration_2`` and must be
applied after ``migration_2`` is installed. Similarly, in the above example,
``migration_5`` is the release of 1.0.1, which requires both of the two new
features to be installed before it is 1.0.1.
