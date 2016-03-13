========================================================
Tutorial: Letting other extensions extend your extension
========================================================

This tutorial is based on the work by `imkingdavid <https://www.phpbb.com/community/viewtopic.php?f=461&t=2210001>`_

Introduction
============

This tutorial explains:

* Adding a PHP event to your extension
* Using service collection
* Using the phpBB finder tool

Adding a PHP event to your extension
====================================
The first of the three is probably the easiest, but is limited in abilities once
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

It is also important once you create an event that is contained in a full release
that you do not change the event's identifier or otherwise alter the event in such
a way that breaks backwards compatibility unless absolutely necessary. Otherwise,
other extensions may break without warning! It is probably best to publish a
list of events provided by your extension and make public note of any event
changes prior to releasing a new version.

The name of your event should be in the form of acme.demo.identifer, where
vendor.name matches the value in your composer.json.

Using service collection
========================
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
extends ``ArrayObject`` so it can be used an array containing the service name of
each item in the collection as the key, and an instance of each of the items as
the corresponding value.

This system is used in the core for several features, including notifications
and authentication providers.
