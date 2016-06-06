===============
Getting started
===============

The command line interface (CLI) is a useful utility for phpBB administrators who have access to a shell (or SSH) on the server they run phpBB on, as well as for extension developers. It provides CLI commands for managing config values, extensions, running database migration, purging the cache, and more.

Most operating systems ship with a built in command line application. For Mac OS and Ubuntu it is called "Terminal" and for Windows it is called "Command Prompt". Third party software such as `PuTTY <http://www.putty.org>`_ and `iTerm <https://www.iterm2.com>`_ can also be used.

To use phpBB's CLI on a web server, you will need SSH access to your web server. You can find out from your web hosting company if they offer SSH access and how to log into your web server from the CLI.

Once you have accessed your web server via SSH, or if you are in a localhost development environment, you simply need to navigate to your phpBB forum directory via the ``cd`` command:

.. code-block:: console

    $ cd path/to/phpBB

From there, issuing commands is simply a matter of calling phpBB's CLI application.

.. code-block:: console

    $ php bin/phpbbcli.php

*If everything is working correctly, the above command should output information about the currently installed phpBB CLI console. If you receive an error message, make sure you have navigated into the root directory of your forum.*

General commands
================

The ``list`` command will show a list of all available commands available for phpBB's CLI.

.. code-block:: console

    $ php bin/phpbbcli.php list

The ``help`` command will display general help for using phpBB's CLI.

.. code-block:: console

    $ php bin/phpbbcli.php help

Using commands
==============

All phpBB commands (as described when running the ``list`` command) have integrated help documentation available within the CLI. Use the ``--help`` or ``-h`` option with any of phpBB's CLI commands to view detailed help for that command.

.. code-block:: console

    $ php bin/phpbbcli.php config:set --help

The above command will display information about the arguments and options that can be used with the specified command, in this example ``config:set``. For example, the above command will output:

.. code-block:: console

    Usage:
     config:set [-d|--dynamic] key value

Arguments or options shown inside of brackets indicates that they are optional to use. This shows us that the ``key`` and ``value`` arguments are required. However, the ``-d`` or ``--dynamic`` options available for this command are optional. Also note that ``-d`` is shorthand for ``--dynamic``. Most options have a shorthand equivalent.

General options
===============

Common options that can be used with any of phpBB's CLI commands.

.. csv-table::
   :header: "Option", "Usage"
   :delim: |

   --help (-h) | Display a help message
   --quiet (-q) | Do not output any message
   --verbose (-v,-vv,-vvv) | Increase the verbosity of messages: 1 for normal output, 2 for more verbose output and 3 for debug
   --version (-V) | Display this application version
   --ansi | Force ANSI (colors) output
   --no-ansi | Disable ANSI (colors) output
   --no-interaction (-n) | Do not ask any interactive question
   --safe-mode | Run in Safe Mode (without extensions)
