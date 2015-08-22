=====
FixUp
=====

Basics
======

The fixup CLI commands allow you to run administrative tasks to repair data in the database.

fixup:recalculate-email-hash
============================

Recalculates the user_email_hash column of the users table.

.. code-block:: console

    $ php bin/phpbbcli.php fixup:recalculate-email-hash
