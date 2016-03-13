=========================================================
Tutorial: Allowing other extensions extend your extension
=========================================================

This tutorial is based on the work by `imkingdavid <https://www.phpbb.com/community/viewtopic.php?f=461&t=2210001>`_

Introduction
============

This tutorial explains:

* `Adding a PHP event to your extension`_
* `Adding a template event to your extension`_
* `Using service collections`_
* `Using the phpBB finder tool`_

Adding a PHP event to your extension
====================================
The first of the these is probably the easiest, but is limited in abilities once
implemented. Basically, this involves you, the extension author, making your own
events at key points in the code of your extension that other extensions can then
listen for. If your extension is not enabled, the relevant code in other
extensions will be ignored. When your extension is enabled and the event in
question is called, the listeners in the other enabled extensions that are
listening for that event will be run.

This is what an event looks like:

.. code-block:: php

    <?php
    /**
    * Short description of the event
    *
    * @event acme.demo.identifier
    * @var  string  var1  A variable to make available to the event
    * @var  string  var2  A second variable to make available to the event
    * @since 3.1-A1
    */
    $vars = array('var1', 'var2');
    extract($phpbb_dispatcher->trigger_event('acme.demo.identifier', compact($vars)));

In this case, ``var1`` and ``var2`` refer to the implied variables ``$var1`` and ``$var2`` from
the current scope. These are passed into the event and are available through the
$event array. They can be used and altered as needed and then passed back from the
event. When making a custom event, be sure to provide several variables from the
event's scope for listeners to use.

.. warning::
  It is important once you create an event that is contained in a full release
  that you do not change the event's identifier or otherwise alter the event in such
  a way that breaks backwards compatibility unless absolutely necessary. Otherwise,
  other extensions may break without warning! It is probably best to publish a
  list of events provided by your extension and make public note of any event
  changes prior to releasing a new version.

The name of your event should be in the form of acme.demo.identifer, where
vendor.name matches the value in your composer.json.

Adding a template event to your extension
=========================================
Besides PHP events there are also template events. Template events can be used
to extend the template of a extension. To create a template event you simply add
the EVENT tag to your template:

.. code-block:: html

  <!-- EVENT acme_demo_identifier -->

The event can be used in the same way as the template events in the phpBB Core.
See :doc:`tutorial_basics` on how to use these events.

.. warning::
  Like with PHP events you should not change the identifier of the event after
  a release of your extension. Other extensions might use your event and be broken
  afterwards.

Using service collections
=========================
In 3.1, a new concept is that of "services". You can read up on exactly what a
service is `here <http://symfony.com/doc/current/book/service_container.html>`_;
the rest of this guide will assume you have basic knowledge of services and how
to use them (if you have further questions, feel free to ask). A service
collection is basically what it sounds like: a collection of services. Basically,
when you define your service, you give it a special "tag", which associates it
with a the collection of services. Later on, this can be used to easily get a
list of services for use by your extension.

To use this, you first create a service for your service collection. This will
actually point to a core phpBB object called ``phpbb\di\service_collection``.

.. code-block:: yaml

  acme.demo.foobar_collection:
      class: phpbb\di\service_collection
      arguments:
          - '@service_container'
      tags:
          - { name: service_collection, tag: acme.demo.foobar_service }

Of course the service name and the tag name may be whatever you like.

.. note::
  To prevent duplicates in your tag you should use a unique tag name, preferably
  in the form of acme.demo.tagname.

Now, when you want to add a service to your collection, just do the following:

.. code-block:: yaml

  acme.demo.thing_one:
      class: acme\demo\thingy\thing_one
      tags:
          - { name: acme.demo.foobar_service }

Notice that the tag "name" value here corresponds to the tag "tag" value in the
previous service definition. Also, keep in mind that if the class (in this case,
``thing_one``) extends another class, you will need to provide the correct services
and values for any parameters defined in the constructor for the parent class,
if necessary.

Finally, to use the collection of services, just pass the first service as an
argument to another service class. For instance, let's say I have a manager
object for my foobar extension and I want the manager to know about all of the
services in the "foobar_collection" service. When defining the manager class, I
just have to give the first service I showed you as an argument to the manager
service.

.. code-block:: yaml

  acme.demo.foobar_manager:
      arguments:
          - '@acme.demo.foobar_collection'

That argument will return an instance of ``phpbb\di\service_collection``, which
extends ``ArrayObject`` so it can be used as an array containing the service name
of each item in the collection as the key, and an instance of each of the items
as the corresponding value.

This system is used in the core for several features, including notifications
and authentication providers.

Using the phpBB finder tool
===========================
This is probably the least used method because it requires a rigid file and
directory naming structure, but in doing so it provides the most reliable
organization of files, so you always can be sure where to look if you want to
find a certain feature. The extension finder object is used to traverse the
directory tree to look for files that are located in specific folders and adhere
to a set of requirements. It is used, for example, to locate migration files,
both in the core, and in extensions, without those files having to all be
registered as services.

The ``\phpbb\extension\finder`` is available from the service container as
``ext.finder`` and can be used as follows. The following example is part of what
is used to find all routing files, both for extensions and core routes.

.. code-block:: php

  $finder
      ->directory('config')
      ->suffix('routing.yml')
      ->find();

As you can see, you are able to chain method calls together (ending with ``find()``).
Check out the class definition for more information about the different methods
that are available (such as specifying a different directory for extensions than
core files, and getting class names based on files it finds). The return of the
``find()`` method is an array of file paths that match the given criteria.
