====================
Tutorial: Migrations
====================

Introduction
============

This tutorial explains:

 * Migrations: Database changes

Migrations
==========

Migrations are a means of facilitating database changes, much in
the same way UMIL was used in phpBB 3.0. Through Migrations,
extension developers are able to easily modify and add new schema
and data to the database as required by an extension.

Our Developer Docs already contain in-depth documentation for phpBB's
migrations:

Migrations: :doc:`../migrations/getting_started`.

.. seealso::

    The phpBB Customisation Database `Migrations Validation Policy <https://www.phpbb.com/extensions/rules-and-policies/validation-policy/#migrations>`_.

We will briefly summarise the key concepts of migrations here.

Database changes
----------------

Schema changes
++++++++++++++

The ``update_schema()`` method is for facilitating schema changes,
such as adding new tables, columns, keys and indexes.

The ``revert_schema()`` method should always be including to undo
any changes introduced by the ``update_schema()`` method.

We recommend putting schema changes in their own migration.

Learn more: :doc:`../migrations/schema_changes`.

Data changes
++++++++++++

The ``update_data()`` method is for inserting, updating and dropping
field data.

The ``update_data()`` method is automatically reverted during a purge
step. Calling the ``revert_data()`` method is optional, and usually
only needed to perform special changes during an extension's uninstall.

We recommend putting data changes in their own migration.

Learn more: :doc:`../migrations/data_changes`.

Migration tools
---------------

:doc:`../migrations/tools/config`
    The config tool helps adding, updating, and removing config items.

:doc:`../migrations/tools/config_text`
    The config_text tool helps adding, updating, and removing config_text
    items. The config_text table is used to store options with an arbitrary
    length value in a TEXT column. In contrast to config values,
    config_text are not cached or prefetched.

:doc:`../migrations/tools/module`
    The module tool helps adding and removing ACP, MCP, and UCP modules.

:doc:`../migrations/tools/permission`
    The permission tool helps adding, removing, setting, and unsetting
    permissions and adding or removing permission roles.

Migration dependencies
----------------------

depends_on()
++++++++++++

The ``depends_on()`` method is used to define a migration's dependencies.
Dependencies tell the migrator what order migrations must be installed in.

Learn more: :doc:`../migrations/dependencies`.

effectively_installed()
+++++++++++++++++++++++

The ``effectively_installed()`` method is used primarily to help transition
from a previous database installer method (such as a MOD that used UMIL)
to migrations. However, we recommend using it all the time to ensure
safer migrations.

When effectively_installed returns true, the migration is deemed to
already have been installed, meaning the migration will be skipped.
This helps prevent rewriting (or overwriting) existing changes to the
database that may have already been put in place by a previous migration or
MOD installation.

For example, in the following code the migration would not be applied if
the specified config value already exists in the database:

.. code-block:: php

    public function effectively_installed()
    {
       return isset($this->config['acme_demo_goodbye']);
    }

Once you are familiar with how Migrations work, continue on
to the next section to learn how to create and install an ACP
module that will allow us to configure some settings for
the Acme Demo extension.
