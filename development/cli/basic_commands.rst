===============
Common commands
===============

Available commands
==================

Common commands that can be run at any time.

.. code-block:: console

    $ php bin/phpbbcli.php help

.. code-block:: console

    $ php bin/phpbbcli.php list

.. csv-table::
   :header: "Command", "Usage"
   :delim: |

   help | Displays help for a command
   list | Lists commands

Options
=======

Common options that can be used with any of phpBB's CLI commands.

.. csv-table::
   :header: "Option", "Usage"
   :delim: |

   --help (-h) | Display a help message
   --quiet (-q) | Do not output any message
   --verbose (-v,-vv,-vvv) | Increase the verbosity of messages: 1 for normal output, 2 for more verbose output and 3 for debug
   --version (-V) | Display this application version
   --ansi | Force ANSI output
   --no-ansi | Disable ANSI output
   --no-interaction (-n) | Do not ask any interactive question
   --safe-mode | Run in Safe Mode (without extensions)
