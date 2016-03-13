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
    /**
    * Short description of the event
    *
    * @event vendor.name.identifier
    * @var  string  var1  A variable to make available to the event
    * @var  string  var2  A second variable to make available to the event
    * @since 3.1-A1
    */
    $vars = array('var1', 'var2');
    extract($phpbb_dispatcher->trigger_event('vendor.name.identifier', compact($vars)));

In this case, var1 and var2 refer to the implied variables $var1 and $var2 from
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

The name of your event should be in the form of vendor.name.identifer, where
vendor.name matches the value in your composer.json.

Using service collection
========================
