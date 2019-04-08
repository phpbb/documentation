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

Install phpBB using the CLI
===========================

You need to use the ``install/phpbbcli.php``. Open the file ``docs/install-config.sample.yml`` and copy its content in a new file ``install/install-config.yml``. Change the parameters to your needs. For example a mysql database with ``mysqli`` interface, ``localhost`` and with an database user ``bertie`` with the password ``bertiepasswd`` into the database named ``bertiedb``:

.. code-block:: console

        installer:
            admin:
                name: admin
                password: mypassword
                email: admin@example.org

            board:
                lang: en
                name: My Board
                description: My amazing new phpBB board

            database:
                dbms: mysqli
                dbhost: ~
                dbport: ~
                dbuser: bertie
                dbpasswd: bertiepasswd
                dbname: bertiedb
                table_prefix: phpbb_

            email:
                enabled: false
                smtp_delivery : ~
                smtp_host: ~
                smtp_port: ~
                smtp_auth: ~
                smtp_user: ~
                smtp_pass: ~

            server:
                cookie_secure: false
                server_protocol: http://
                force_server_vars: false
                server_name: localhost
                server_port: 80
                script_path: /

            extensions: ['phpbb/viglink']

You can add more settings like the admins username, admins email-address and board-name. Make sure the file is readable by the CLI. 

Now run in the command line:

.. code-block:: console

    $ php install/phpbbcli.php install install-config.yml

The installer will start now and show its progress during the installation.

Update phpBB using the CLI
==========================

You will need the ``install/phpbbcli.php`` and a update-config.yml. Open the example file ``docs/update-config.sample.yml`` and copy its content into a new file ``install/update-config.yml``, this file will update your phpBB database and the files. Change the config file, if you have additional extensions:

.. code-block:: console

    updater:
        type: all
        extensions: ['phpbb/viglink']

The recommended update method replaces all files with the latest ones, so the file update is not necessary but the database still needs an update. Therefor use this ``update-config.yml``:

.. code-block:: console

    updater:
       type: db_only

In the next step, please run the command line:

.. code-block:: console

    $ php install/phpbbcli.php update update-config.yml

The updater will start and show its progress.