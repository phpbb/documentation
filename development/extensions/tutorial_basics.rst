===========================
Tutorial: Basics and Events
===========================

Introduction
============

This tutorial explains the basic functionality of extensions:

 * Basics: `Extension folder`_ and `composer.json`_
 * `HTML Events`_
 * `PHP Events`_

.. seealso::

   If you know modifications from phpBB 3.0, you may also have a look at
   :doc:`modification_to_extension` which helps you to transform your
   modification into an extension step by step.

Extension folder
================

The first thing you need to do, in order to make phpBB aware of your extension,
is to create a ``composer.json``. The file needs to be in a subfolder of the
``ext/`` folder that is shipped with phpBB.
Inside this folder you need to create a folder with your author (vendor) name.
Then create the folder of the extension inside the vendor folder.

.. note::

    Both the vendor and extension folder names must start with a lower or
    upper case ASCII letter (a to z), followed by ASCII letters and numbers
    only!

In this tutorial we use ``acme`` as vendor name and ``demo`` as extension name.
So the ``composer.json`` should be located at ``ext/acme/demo/composer.json``.

composer.json
=============

The content of the ``composer.json`` file may look very technical, but you only
have to change a few lines. The information about the extension is stored as a
JSON array. The details are explained after the sample, but now let's have a
look at the complete file:

.. code-block:: json

    {
        "name": "acme/demo",
        "type": "phpbb-extension",
        "description": "Acme Demo Extension for phpBB 3.1",
        "homepage": "https://github.com/nickvergessen/phpbb-ext-acme-demo",
        "version": "0.1.0",
        "time": "2013-11-05",
        "license": "GPL-2.0",
        "authors": [{
                "name": "Nickv",
                "email": "nickvergessen@localhost",
                "homepage": "https://github.com/nickvergessen/",
                "role": "Lead Developer"
            }],
        "require": {
            "php": ">=5.3.3",
            "composer/installers": "~1.0"
        },
        "require-dev": {
            "phpbb/epv": "dev-master"
        },
        "extra": {
            "display-name": "Acme Demo Extension",
            "soft-require": {
                "phpbb/phpbb": "~3.1"
            }
        }
    }

.. csv-table::
   :header: "Field", "Content"
   :delim: |

   ``name`` | "Must contain the vendor and extension name, matching the folder
   structure"
   ``type`` | ``phpbb-extension`` **must not be changed**
   ``description`` | "A short description of your extension, may also be empty
   (but not skipped)"
   ``homepage`` | "Must contain a valid URL. It is recommended to use the link
   to the contribution in the customisation database, or to the repository of
   your extension (if you are using a public one like GitHub)."
   ``version`` | "The version of your extension. You may also use ``-a1``
   (alpha), ``-b1`` (beta), ``-rc1`` (release candidate) and ``-dev`` suffixes
   (although you may not submit them to the customisation database.)"
   ``time`` | "Must contain the release date of this version (date is required,
   time is optional)"
   ``license`` | The license must be ``GPL-2.0`` for now
   ``authors`` | "An array with the authors of the extension.
   See `authors`_ for more details."
   ``require`` | "An array with requirements of the extension.
   See `require`_ for more details."
   ``require-dev`` | "An array with development requirements of the extension.
   See `require-dev`_ for more details."
   ``extra`` | "An array with additional values of the extension.
   See `extra`_ for more details."

authors
-------

You may have unlimited authors. But you should at least have one.

.. csv-table::
   :header: "Field", "Content"
   :delim: |

   ``name`` | Name of the author
   ``email`` | Email address of the author
   ``homepage`` | Must contain one valid URL or be empty
   ``role`` | "Role can be used to specify what the authors did for the
   extension (e.g. Developer, Translator, Supporter, ...)"

require
-------

In the ``require`` section you can specify the technical requirements of your
extension. Examples are the ``php`` version, or
`third party libraries <https://packagist.org/>`_. Since our demo extension does
not require any additional library, we only use the PHP version requirement, to
make sure people have the right PHP version on their server, and composer
installers for some internal handling. phpBB 3.1 requires PHP 5.3.3 or higher,
so the version comparison is ``>= 5.3.3``.

require-dev
-----------

In the ``require-dev`` section you can specify the technical requirements of your
extension, which are only required for development. We use the
`Extension PreValidation <https://packagist.org/packages/phpbb/epv>`_ Tool from
the phpBB Extensions Team here, to perform some basic validation when running
our tests on Travis CI in :doc:`tutorial_testing`. Since we always want to have
the newest version, we require ``dev-master``.

.. todo:: add link to testing/travis section.

extra
-----

This section contains only additional information and is up to free usage in
terms of the composer-specification. However, phpBB is using two special entries
in this array for extensions:

.. csv-table::
   :header: "Field", "Content"
   :delim: |

   ``display-name`` | "Display name of the extension (can be different than the
   folder name)"
   ``soft-require`` | "Soft requirements are basically like `require`_. The only
   difference is that composer does not know that these requirements exist.
   This allows us, for example, to compare the phpBB version, although there
   might not be a phpBB package with the specified version. In this case we
   require any 3.1 version. This can be done, by prefixing it with a ``~``:
   ``""phpbb/phpbb"": ""~3.1""``"

Enable extension
================

After you filled the ``composer.json`` with the content as described above, you
can go to the "Administration Control Panel" (ACP) > "Customise" > "Extensions"
and enable the extension.

HTML Events
===========

So far, all we have done is create an extension that does nothing. So let's
create some code to generate output and verify that the extension is working.

Listening to an event
---------------------

In order to add new HTML elements to the output, we need to create a listener,
which is then included by phpBB when the event happens. You can find a full list
of events in the `Event list <https://wiki.phpbb.com/Event_List>`_ on the Wiki.

For now we will use the ``overall_header_navigation_prepend`` event, to add a
new link before the existing links in the navigation bar.

In order to "subscribe" to an event, you need to create an HTML file that is
named the same as the event. So in our case the file is named
``overall_header_navigation_prepend.html``. The file needs to be inside an
``event`` subfolder of the template of your style: e.g.
``styles/prosilver/template/event/overall_header_navigation_prepend.html``.

You can also put the file into ``styles/all/template/event/``. This will make
phpBB include the listener (``overall_header_navigation_prepend.html``) in all
styles.

Inside the listener, we create a simple list element, with a link and a
description:

.. code-block:: html

    <li class="small-icon icon-faq no-bulletin">
        <a href="{U_DEMO_PAGE}">
            {L_DEMO_PAGE}
        </a>
    </li>

.. note::

    The template syntax is explained on the
    `Template Syntax <https://wiki.phpbb.com/Tutorial.Template_syntax#Syntax_elements>`_
    Wiki page.

After saving the file, you should see a new link at the top left, with the icon
of the FAQ link and the text ``DEMO_PAGE``. We will fix the link description in
the next section.

.. note::

    If the link does not show up for you, you might need to purge the cache on
    the front page of the ACP. You should also make sure that
    "Recompile stale style components" is enabled in the "General" > "Load
    settings" section, to avoid having to purge the cache each time you modify
    an existing template/style file.

Triggering an event (advanced)
------------------------------

You can also include template events in your own template files, so other
extensions can manipulate the output of your extension. You can do this by
adding ``<!-- EVENT acme_demo_myevent -->`` in the desired location. Other
extensions could then create a ``acme_demo_myevent.html`` file to listen to this
event.

.. warning::

    You must always prefix your event names with your vendor and extension name.

.. warning::

    It is not recommended to reuse existing event names in different locations.
    This should only be done if the code (nested HTML elements) around the
    event is the same for both locations. Also think about other extensions: do
    they always want to listen to both places, or just one? In case of doubt:
    use a new event and unique.

PHP Events
==========

In order to fix the description of the link in the previous section, we are
going to load a language file that contains the ``DEMO_PAGE`` language variable
we used.

Creating the language file
--------------------------

The language file should be placed in the ``language/`` folder of the extension.
Since this tutorial is in English, we only add the English language file:
``language/en/demo.php``

.. code-block:: php

    <?php
    /**
     *
     * This file is part of the phpBB Forum Software package.
     *
     * @copyright (c) phpBB Limited <https://www.phpbb.com>
     * @license GNU General Public License, version 2 (GPL-2.0)
     *
     * For full copyright and license information, please see
     * the docs/CREDITS.txt file.
     *
     */

    if (!defined('IN_PHPBB'))
    {
        exit;
    }

    if (empty($lang) || !is_array($lang))
    {
        $lang = array();
    }

    $lang = array_merge($lang, array(
        'DEMO_PAGE'			=> 'Demo',
    ));

.. warning::

    The check for ``IN_PHPBB`` is mandatory for all php files, which contain
    code that is immediately executed:

    .. code-block:: php

        if (!defined('IN_PHPBB'))
        {
            exit;
        }

Loading the language file
-------------------------

Now there is a bit of magic involved in this section, but you may ignore the
details, if you just want to get the demo working.

Similar to the `HTML Events`_ phpBB also has PHP events. Those can be used, to
execute PHP code. In order to subscribe to a PHP event, you need to create a
class that extends Symfony's
``Symfony\Component\EventDispatcher\EventSubscriberInterface`` interface. This
interface contains a static method ``getSubscribedEvents()`` which returns an
array, with ``'name of the event' => 'name of the method to call'`` pairs.
In case when the event is triggered, the method will be called, with an array
argument, containing all variables that are supported by the PHP event.

A full list of the supported PHP events, including the version they have been
added in, can be found in the Wiki
`Event list <https://wiki.phpbb.com/Event_List>`_.

Writing the listener
++++++++++++++++++++

Since we want to load the new language file everywhere, we subscribe to the
``core.user_setup`` event. In the listener method we add our language file to
the ``lang_set_ext`` array. phpBB will then load the file automatically:

.. code-block:: php

    <?php
    /**
     *
     * This file is part of the phpBB Forum Software package.
     *
     * @copyright (c) phpBB Limited <https://www.phpbb.com>
     * @license GNU General Public License, version 2 (GPL-2.0)
     *
     * For full copyright and license information, please see
     * the docs/CREDITS.txt file.
     *
     */

    namespace acme\demo\event;

    use Symfony\Component\EventDispatcher\EventSubscriberInterface;

    /**
     * Event listener
     */
    class main_listener implements EventSubscriberInterface
    {
        static public function getSubscribedEvents()
        {
            return array(
                'core.user_setup' => 'load_language_on_setup',
            );
        }

        public function load_language_on_setup($event)
        {
            $lang_set_ext = $event['lang_set_ext'];
            $lang_set_ext[] = array(
                'ext_name' => 'acme/demo',
                'lang_set' => 'demo',
            );
            $event['lang_set_ext'] = $lang_set_ext;
        }
    }

.. warning::

    Due to a limitation in PHP itself, you can not add entries to arrays of the
    event argument. In order to do that you need to create a copy of the array,
    add the value and then reassign the new array to the event array.

Registering the listener
++++++++++++++++++++++++

To have phpBB execute our listener, we need to register the event listener, so
phpBB knows, how to create it.

This is done by creating a ``config/services.yml`` file. ``#`` is used to start
inline comments in ``yaml`` files.

.. code-block:: yaml

    services:
        acme.demo.listener:       # name of the service you want to register
            class: acme\demo\event\main_listener
            tags:
                - { name: event.listener }

.. caution::

    ``yaml`` is indentation sensitive, so make sure that each line that is a
    child of the previous line is indented with four additional spaces and do
    **not use tabs**.

The first line tells phpBB that a list of services is being registered. On the
next line we specify the name of the service.

.. warning::

    Similar to event names your service names should be prefixed with your
    vendor and extension name.

The ``class`` attribute must contain the namespace and class name of the service
we want to register. The class and namespace depends on the file's location,
whereby the ``ext/`` is the root of the name. So the our file
``ext/acme/demo/event/main_listener.php`` has the namespace ``acme\demo\event``
and class name ``main_listener``. The full name of the class is therefor
``acme\demo\event\main_listener`` which is what we need to specify here.

In the ``tags`` list we tell phpBB that the defined service is an event
listener.

After purging the cache in the ACP, the description of the link in the
navigation bar should now be ``Demo`` instead of ``DEMO_PAGE``.
