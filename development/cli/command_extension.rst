==========
Extensions
==========

Basics
======

The extension CLI commands allow you to enable, disable, purge and list available extensions.

extension:disable
=================

Disables the specified extension.

.. code-block:: console

    $php phpBB/bin/phpbbcli.php extension:disable vendor_name/package_name

.. csv-table::
   :header: "Arguments", "Usage"
   :delim: |

   extension-name | Name of the extension (required)

extension:enable
================

Enables the specified extension.

.. code-block:: console

    $php phpBB/bin/phpbbcli.php extension:enable vendor_name/package_name

.. csv-table::
   :header: "Arguments", "Usage"
   :delim: |

   extension-name | Name of the extension (required)

extension:purge
===============

Purges the specified extension.

.. code-block:: console

    $php phpBB/bin/phpbbcli.php extension:purge vendor_name/package_name

.. csv-table::
   :header: "Arguments", "Usage"
   :delim: |

   extension-name | Name of the extension (required)

extension:show
==============

Lists all extensions in the database and on the filesystem.

.. code-block:: console

    $php phpBB/bin/phpbbcli.php extension:show
