====
Cron
====

Basics
======

The cron CLI commands allow you to list and run available cron tasks.

cron:list
=========

Prints a list of ready and unready cron jobs.

.. code-block:: console

    $php phpBB/bin/phpbbcli.php cron:list

cron:run
========

Runs all ready cron tasks.

.. code-block:: console

    $php phpBB/bin/phpbbcli.php cron:run

.. code-block:: console

    $php phpBB/bin/phpbbcli.php cron:run task_name

.. csv-table::
   :header: "Arguments", "Usage"
   :delim: |

   name | Name of the task to be run (optional)
