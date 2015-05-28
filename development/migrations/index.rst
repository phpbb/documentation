==========
Migrations
==========

Beginning with phpBB 3.1, database updating is performed using Migrations.

Migrations was built because of the difficulties of distributed development
and maintaining an updated database setup across all developers.

RFC Topic if you're interested in the reasons:
`<http://area51.phpbb.com/phpBB/viewtopic.php?t=41337>`_

.. toctree::
   :maxdepth: 1
   :glob:

   *
   tools/index

What do Migrations mean for me?
===============================

As a user
---------
Migrations do not affect using phpBB, only writing code for it, so
Administrators do not have to do anything differently.

Database updates between versions of phpBB and Mod/Extension updates will be
safer and, in the unlikely event something happens during database changes,
much easier to debug and correct.

As an Extension author
----------------------
Functionality (similar to UMIL for phpBB 3.0) built into phpBB for easier
management of database changes between versions and helpful tools to assist
making database changes.

As a Developer
--------------
Easier collaboration with others, less time spent managing database changes
between different branches and pull requests.

How do I use Migrations?
========================

Getting started with Migrations
-------------------------------
How to create a basic Migration file
:doc:`getting_started`

Migration Helpers
-----------------
How to use Migration helpers to perform basic database changes
:doc:`tools/index`

Using Migrations in an Extension
--------------------------------
How to use Migrations in your Extension to make database changes
:doc:`extensions`
