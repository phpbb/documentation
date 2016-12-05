==========================
Tutorial: Advanced Lessons
==========================

Introduction
============

This tutorial explains:

* `Adding a PHP event to your extension`_
* `Adding a template event to your extension`_
* `Using installation commands in ext.php`_
* `Using service collections`_
* `Using the phpBB finder tool`_
* `Using service replacement`_
* `Using service decoration`_
* `Replacing the phpBB Datetime class`_
* `Extension version checking`_

Adding a PHP event to your extension
====================================
You can add PHP events to your own extension, allowing other extensions to
hook into parts of your extension to add functionality or modify its behaviour.
Basically, this involves you, the extension author, making your own
events at key points in the code of your extension that other extensions can then
listen for. If your extension is not enabled, the relevant code in other
extensions will be ignored. When your extension is enabled and the event in
question is called, the listeners in the other enabled extensions will be run.

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

You will need to replace ``identifier`` with the name of your event. This must
be prefixed by your vendor and extension name and use only underscores and
lowercase letters for the prefix and name which have to be separated with a dot.

Furthermore, ``var1`` and ``var2`` refer to the implied variables ``$var1`` and ``$var2`` from
the current scope. These are passed into the event and are available through the
$event array. They can be used and altered as needed and then passed back from the
event. When making a custom event, be sure to provide as many variables from the
event's scope as you can for listeners to use.

.. warning::
  It is important once you create an event that is contained in a full release
  that you do not change the event's identifier or otherwise alter the event in such
  a way that breaks backwards compatibility unless absolutely necessary. Otherwise,
  other extensions may break without warning! It is probably best to publish a
  list of events provided by your extension and make public note of any event
  changes prior to releasing a new version.

If an event does not need any arguments, you can use this short version:

.. code-block:: php

    $phpbb_dispatcher->dispatch('acme.demo.identifier');

.. note::
    The ``$phpbb_dispatcher`` object is available from phpBB's dependency injection
    container or as a global variable, so if you do not pass it as a parameter to
    your method, use global ``$phpbb_dispatcher`` to make it available.

Adding a template event to your extension
=========================================
Besides PHP events there are also template events. Template events can be used
to extend the template of an extension, so other
extensions can manipulate the output of your extension. To create a template event you simply add
the EVENT tag to your template:

.. code-block:: html

  <!-- EVENT acme_demo_identifier -->

The event can be used in the same way as the template events in the phpBB Core.
See :doc:`tutorial_events` on how to use these events.

You must always prefix your event names with your vendor and extension name.
Make sure to only use underscores, numbers and lowercase letters.

.. warning::
  Like with PHP events you should not change the identifier of the event after
  a release of your extension. Other extensions might already be using your event
  and would risk breaking.

.. tip::
  If you prefer Twig instead of the phpBB template syntax, you can use:

  .. code-block:: html

    {% EVENT acme_demo_identifier %}

.. caution::
  It is not recommended to reuse existing event names in different locations.
  This should only be done if the code (nested HTML elements) around the
  event is the same for both locations. Also think about other extensions: do
  they always want to listen to both places, or just one? In case of doubt:
  use a new and unique event.

Using installation commands in ext.php
======================================
There are times when an extension may need to execute code while it is being
enabled, disabled or purged. Some examples may be to check that the board meets
the requirements of the extension, or to run some sort of set-up or clean-up
processes.

This is done by adding a class to the root directory of an extension called ``ext.php``.
It must extend ``\phpbb\extension\base``. Extending the base class permits
custom code to be executed during the enabling, disabling or purging of an
extension with the following inherited methods:

  - ``is_enableable()``
  - ``enable_step()``
  - ``disable_step()``
  - ``purge_step()``

Suppose an extension wants to strictly requires phpBB 3.1.5 or later. We can override the
``is_enableable()`` method, and use it to check phpBB's version, and return a
boolean result.

.. code-block:: php

    <?php

    namespace acme\demo;

    class ext extends \phpbb\extension\base
    {
        public function is_enableable()
        {
            $config = $this->container->get('config');
            return phpbb_version_compare($config['version'], '3.1.5', '>=');
        }
    }

If false is returned, the extension will not be installed and the user will be
notified their board does not meet the requirements of the extension. If it returns true,
installation will proceed.

The ``ext.php`` class may contain any special installation commands in the
``enable_step()``, ``disable_step()`` and ``purge_step()`` methods. As it is, these methods
are defined in ``\phpbb\extension\base``, which this class extends, but you can
overwrite them to give special instructions to each step. For example:

.. code-block:: php

	public function enable_step($old_state)
	{
		if ($old_state === false)
		{
			// do something...

			return 'did_something';
		}

		return parent::enable_step($old_state);
	}

Notice that we execute our code only if the incoming ``$old_state`` is false.
Once we have finished we must return an arbitrary value. Otherwise, we simply
return the state of the parent class.

The phpBB
`Board Rules <https://github.com/phpbb-extensions/boardrules/blob/master/ext.php>`_
extension shows another example of this in order to prepare the notifications
system for the extension when enabling, disabling and deleting the extension.

The enable/disable/purge step methods allow for large processes to be paused and
resumed. If the returned value from the step method is not false, then the returned
value will be serialised and stored in the database. When the step method is
called again, the last known state will be de-serialised, and it will continue to be
executed until such time as false is returned.

.. warning::
    The serialised data is stored in the *phpbb_ext* table under the *ext_state*
    field. Developers should never manipulate this field directly as the
    serialisation is handled internally by phpBB.

Using service collections
=========================
In 3.1, a new concept is that of "services". You can read up on exactly what a
service is `here <http://symfony.com/doc/current/book/service_container.html>`_.
The rest of this guide will assume you have basic knowledge of services and how
to use them. A service
collection is basically what it sounds like: a collection of services. Basically,
when you define your service, you give it a special "tag", which associates it
with a collection of services. Later on, this can be used to easily get a
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
  in the form of vendor.extname.tag_name.

Now, when you want to add a service to your collection, just tag it:

.. code-block:: yaml

  acme.demo.thing_one:
      class: acme\demo\thingy\thing_one
      tags:
          - { name: acme.demo.foobar_service }

Notice that the tag "name" value here corresponds to the tag "tag" value in the
previous service collection definition. Also, keep in mind that if the class (in this case,
``thing_one``) extends another class, you will need to provide the correct services
and values for any parameters defined in the constructor of the parent class,
if necessary.

Finally, to use the collection of services, just pass the first service as an
argument to another service class. For instance, let's say I have a manager
object for my foobar extension and I want the manager to know about all of the
services in the "foobar_collection" service. When defining the manager class,
just give it the service collection as an argument.

.. code-block:: yaml

  acme.demo.foobar_manager:
      arguments:
          - '@acme.demo.foobar_collection'

That argument will return an instance of ``phpbb\di\service_collection``, which
extends ``ArrayObject`` so it can be used as an array containing the service name
of each item in the collection as the key, and an instance of each of the service items
as the corresponding value.

This system is used in the core for several features, including notifications
and authentication providers.

Ordered service collection
--------------------------
.. note::
  Ordered service collections were introduced in phpBB 3.2.

Ordered service collections allow you to define the order in which services are
loaded, which is especially useful in cases where service priority and/or dependency
requires they be loaded in a specified order.

Ordered service collections are based on a normal service collection, but the
collection is sorted with `ksort <http://php.net/ksort>`_. The usage of the
sorted service collection is nearly the same as a normal service collection,
except instead of using ``service_collection`` you should use ``ordered_service_collection``:

.. code-block:: yaml

  acme.demo.foobar_collection:
      class: phpbb\di\ordered_service_collection
      arguments:
          - '@service_container'
      tags:
          - { name: service_collection, tag: acme.demo.foobar_service }

And adding a service to the ordered service collection:

.. code-block:: yaml

  acme.demo.foobar_foo:
       class: acme\demo\foobar_foo
       tags:
           - { name: acme.demo.foobar_service, order: 1 }

   acme.demo.foobar_bar:
       class: acme\demo\foobar_bar
       tags:
           - { name: acme.demo.foobar_service, order: 2 }

Using the phpBB finder tool
===========================
This is probably the least used method because it requires a rigid file and
directory naming structure, but in doing so it provides the most reliable
organization of files, so you can always be sure where to look if you want to
find a certain feature. The extension finder object is used to traverse the
directory tree to look for files that are located in specific folders and adhere
to a set of requirements. It is used, for example, to locate migration files,
both in the core, and in extensions, without those files having to be
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

For example, assume you have an extension and you need to get a collection of all
PNG image files from one of its directories. You could use the extension manager
to load the finder, and traverse the extension's image directory as follows:

.. code-block:: php

  $finder = $extension_manager->get_finder();

  $images = $finder
      ->extension_suffix('.png')
      ->extension_directory('/images')
      ->find_from_extension('demo', $phpbb_root_path . 'ext/acme/demo/');

The ``$images`` array would look something like (as you can see the image paths are
contained in the array keys):

.. code-block:: php

  array(
      'ext/acme/demo/images/image1.png' => 'demo',
      'ext/acme/demo/images/image2.png' => 'demo',
  );

.. note::
  The method ``find_from_extension`` used above will only search in the specified
  extension. If you want to search for png files in the entire extension directory you
  can use:

  .. code-block:: php

    $finder = $extension_manager->get_finder();

    $images = $finder
        ->find('.png')
        ->core_path('ext/')
        ->find();

.. note::
  Depending on how the Finder class is configured, the find method searches both
  the phpBB core files and the extensions directories. You can use the ``extension_*``
  methods in the Finder class to configure extension specific searches, and you can
  use the ``core_*`` methods to configure core specific searches.

Using service replacement
=========================
.. warning::
  Only use service replacement if your extensions needs to be compatible with
  phpBB 3.1. For 3.2 and later, see `Using service decoration`_.

.. warning::
  You can't assume the order of a service is defined in phpBB if other extensions
  are installed. Be really carefully when using service replacement.

With service replacement you can replace an existing service in phpBB (or in an
extension) with your own service. Your replacement should type match the original
service (so if the original service implements an interface, you should at least
implement that same interface. If it is a concrete class, you will need to
extend that class). The best way to accomplish this is by extending the original
class, and only replace the features you want to change.

To replace a core phpBB service, you simply name your extension's service name
with the same name as the service in phpBB's core.

For example, to replace the config class, replace the ``config`` service in phpBB
with your own implementation:

.. code-block:: yaml

  config:
      class: acme\demo\config\db
      arguments:
          - '@auth'
          - '@passwords.manager'
          - '@acme.demo.db_reader'

The original config class in ``\phpbb\config\db`` does not implement an interface.
This means you need to extend the original ``\phpbb\config\db``, otherwise the type
won't match the type hinting in the constructors which use the config service.
If the original service implements an interface directly, and all type hints
are referencing the interface, you are not required to extend the original class
and should instead implement the interface.

.. warning::
  If you are using EPV in travis, or during submission to the extensions database
  at phpBB.com, you will receive a warning that your service configuration
  doesn't follow the extensions database policies. As you are overwriting a core
  service, you can simply ignore this message. However, in all cases you should
  inform the phpBB extensions team why you received the warning.

Using service decoration
========================
.. seealso::
  Read about Service Decoration at
  `Symfony <http://symfony.com/doc/current/components/dependency_injection/advanced.html#decorating-services>`_
  for complete documentation.

From phpBB 3.2, you can use service decoration as the preferred method to replace
existing services, in the core or from other extensions. Decoration will update
an existing service with a new name, leaving it intact so that it can be referenced
in the new service.

For example, to replace ``config`` with ``acme.demo.decorated.config``, simply
add the ``decorates`` option to its service definition:

.. code-block:: yaml

  acme.demo.decorated.config:
    class: '\acme\demo\decorated\config'
    decorates: 'config'

In Symfony, the old config service will have been renamed to ``acme.demo.decorated.config.inner``,
so you can inject it into your new service by adding it to your service's arguments:

.. code-block:: yaml

  acme.demo.decorated.config:
    class: '\acme\demo\decorated\config'
    decorates: 'config'
    arguments:
      - '@acme.demo.decorated.config.inner'

Again, keep in mind that your new class type matches the original class.

Replacing the phpBB Datetime class
==================================
If you want to replace the phpBB Datetime class, for example to use
a different type of calendar, you can set the ``datetime.class`` parameter in your
`services.yml`:

.. code-block:: yaml

  parameters:
      datetime.class: '\acme\demo\datetime'

Your class should extend the phpBB datetime class ``\phpbb\datetime``.

Extension version checking
==========================
The extension manager can check for the latest version of your extension, and notify users
when their installation of your extension is out of date.

.. note::

    Extensions released through phpBB's Customisation Database will have this
    feature provided for free, and can ignore this section.

This requires the ``version-check`` meta data in your extension's ``composer.json``
file:

.. code-block:: yaml

    "extra": {
        "version-check": {
            "host": "my.site.com",
            "directory": "/versions",
            "filename": "acme_version_file.json"
        }
    }

.. csv-table::
    :header: "Parameter", "Description"
    :delim: |

    ``host`` | "Full URL to the host domain server."
    ``directory`` | "Path from the domain root to the directory containing the file, starting with a leading slash."
    ``filename`` | "A JSON file containing the latest version information."

Notice that a JSON file is required, hosted from your own server. In the example above
it would be: ``http://my.site.com/versions/acme_version_file.json``

The content of the JSON file should look like:

.. code-block:: json

    {
        "stable": {
            "1.0": {
                "current": "1.0.0",
                "announcement": "http://my.site.com/version_1.0.0",
                "download": "http://my.site.com/version_1.0.0.zip",
                "eol": null,
                "security": false
            }
        },
        "unstable": {
            "1.0": {
                "current": "1.0.1",
                "announcement": "http://my.site.com/version_1.0.1",
                "eol": null,
                "security": false
            },
            "1.1": {
                "current": "1.1.0-b4",
                "announcement": "http://my.site.com/version_1.1.0",
                "eol": null,
                "security": false
            }
        }
    }

The branches "stable" and "unstable" are optional, but at least one of them
has to be defined. The Extension Manager has a setting that allows admins to
check for unstable versions. For this reason, stable branches should only be
used for stable release versions suitable for a live forum. The unstable
branch can be used to provide links to versions in development.

.. csv-table::
    :header: "Parameter", "Description"
    :delim: |

    ``current`` | "The current version of the extension in a given branch."
    ``announcement`` | "A URL to a page about this version of the extension (e.g. a topic in phpBB's Extensions in Development forum)."
    ``download`` | "(Optional) A URL to download this version of the extension."
    ``eol`` | "This is currently not being used yet. Use ``null``"
    ``security`` | "This is currently not being used yet. Use ``false``"
