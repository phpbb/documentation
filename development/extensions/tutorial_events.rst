==============================
Tutorial: Events and Listeners
==============================

Introduction
============

phpBB 3.1 introduced a system of events throughout the codebase and template files
that allow extensions to use listeners to add features, inject code, and modify existing
functionality and behaviour.

This tutorial explains how to use events and listeners:

 * `Template Events & Listeners`_
 * `PHP Core Events & Listeners`_


.. _template-events-label:

Template Events & Listeners
===========================

Template events allow extensions to inject code into the template files. Events
can be found throughout the template structure of phpBB's styles, providing
multiple useful injection points. A typical template event looks like:

::

    {% EVENT event_name_and_position %}

.. seealso::

    View the full list of `Template events <https://area51.phpbb.com/docs/dev/3.3.x/extensions/events_list.html#template-events>`_.

Listening for an event
----------------------

To *subscribe* to a template event, we must create a *listener*, a template file
with exactly the same name as the identifier of the template event we want to
use, and place it in the ``event/`` subdirectory of a style’s template folder.

For example, we will use the ``overall_header_navigation_prepend`` event to add a
new link before the existing links in the board's navigation bar. The listener
for this event will be:

::

    acme/demo/styles/prosilver/template/event/overall_header_navigation_prepend.html

.. tip::

    If you want a template listener to be used by all styles, it should be placed
    in the ``all/`` style directory, e.g. ``vendor/extname/styles/all/template/event/``.
    This helps prevent code duplication and eases style file management.

    The prosilver and subsilver2 directories should be used for template files that
    must be custom tailored to each style. Similarly, if a 3rd-party style
    requires additional customisation to maintain compatibility, a folder for that
    style should be included with those template files.

    To add ACP template listeners, place those files in ``vendor/extname/adm/style/event/``.

Inside the template listener, we will create a nav-bar link. This consists of a
simple list element, with a link and a description:

.. code-block:: html

    <li class="small-icon icon-faq no-bulletin">
        <a href="{{ U_DEMO_PAGE }}">
            {{ lang('DEMO_PAGE') }}
        </a>
    </li>

Once the template listener has been created, you should be able to see the new link
in the board's nav-bar, with the icon of the FAQ link and the
text ``DEMO_PAGE``. We will fix the link text in the next section.

.. tip::

    If the link does not appear, you may need to purge the board cache from
    the main page of the ACP. You can also enable ``DEBUG_MODE`` in your
    ``config.php`` file, which will force the template engine to always
    look for template listeners when a page is being rendered.

Prioritising template event listeners (optional)
---------------------------------------

In rare cases, some extensions could cause a conflict when template listeners
from different extensions are subscribed to the same template event. In such cases
phpBB allows to assign the priority to template event listeners, which allows
to determine the order template event listeners will be compiled.
This can be accomplished using PHP core event listener subscribed to the
``core.twig_event_tokenparser_constructor`` core event, which should use
``template_event_priority_array`` array variable to assign the template event listener priority.
``template_event_priority_array`` array has the following format:

::

	'<author>_<extension_name>' => [
		'event/<template_event_name>' => <priority_number>,
	],

Example:

.. code-block:: php

    <?php

    namespace acme\demo\event;

    use Symfony\Component\EventDispatcher\EventSubscriberInterface;

    class main_listener implements EventSubscriberInterface
    {
        /**
         * Assign functions defined in this class to event listeners in the core
         *
         * @return array
         */
        static public function getSubscribedEvents()
        {
            return [
                'core.twig_event_tokenparser_constructor' => 'set_template_event_priority',
            ];
        }

        /**
         * Assign priority to template event listener
         *
         * @param \phpbb\event\data $event The event object
         */
        public function set_template_event_priority($event)
        {
            $template_event_priority_array = $event['template_event_priority_array'];
            $template_event_priority_array['acme_demo'] = [
                'event/navbar_header_quick_links_after' => $priority,
            ];
            $event['template_event_priority_array'] = $template_event_priority_array;
        }
    }

In this example, ``$priority`` is an integer, the value of which defaults to 0.
Setting this integer to higher values equals more importance and therefore that
template event listener will be compiled earlier than others subscribed to the same template event.
In case of equal priority values, template event listeners will be compiled in the order
they have been read from their locations.

PHP Core Events & Listeners
===========================

Events allow extensions to execute code in many locations within core phpBB code,
without modifying any of the code. That way extensions can easily add features,
remove functionality or modify behaviour, while maintaining compatibility and
simple update procedures.

Terminology
-----------

Events
    Events are dispatched at various places in the core phpBB code. Listeners in
    extensions subscribe to these events. They are able to execute code whenever
    the respective event has occurred. An alternative name for events is “hook locations”.

Listeners
    Listeners are triggered by events. They are methods that can process incoming
    data and manipulate variables in the scope of the event. So they can change phpBB's
    behaviour, add new functionality or if used in the context of templates, modify the
    output. Numerous listeners form part of a subscriber. An alternative name for
    listeners is "hooks".

.. seealso::

    View the full list of supported `PHP events <https://area51.phpbb.com/docs/dev/3.3.x/extensions/events_list.html#php-events>`_.

The event listener
------------------

In the previous section we created a template listener that adds a link for the Acme
Demo extension to phpBB's nav-bar. We will now use PHP events to load a language
file that contains the ``DEMO_PAGE`` language key so that our nav-bar link will
display with the correct text.

To do so, we need to create a PHP event listener class (a.k.a. subscriber class).
This class includes a set of listener methods, each of which can *subscribe*
to PHP events in phpBB's codebase. The listener class must be created in the
``event/`` subdirectory of the extension directory or it will not work. It must also
conform to the following requirements:

* Follow extension class name-spacing conventions: ``vendor\extname\event\subscribername.php``.
* Implement Symfony's ``Symfony\Component\EventDispatcher\EventSubscriberInterface``
  interface.
* Use the static method ``getSubscribedEvents()`` to subscribe methods in the listener
  to specific events, the keys of which contain event names and the values of which
  contain listener function names.

In the Acme Demo extension, we want to load our language file everywhere. Therefore
we will subscribe a listener function to phpBB's ``core.user_setup`` event:

.. code-block:: php

    <?php

    namespace acme\demo\event;

    use Symfony\Component\EventDispatcher\EventSubscriberInterface;

    class main_listener implements EventSubscriberInterface
    {
        /**
         * Assign functions defined in this class to event listeners in the core
         *
         * @return array
         */
        static public function getSubscribedEvents()
        {
            return [
                'core.user_setup' => 'load_language_on_setup',
            ];
        }

        /**
         * Load the Acme Demo language file
         *     acme/demo/language/en/demo.php
         *
         * @param \phpbb\event\data $event The event object
         */
        public function load_language_on_setup($event)
        {
            $lang_set_ext = $event['lang_set_ext'];
            $lang_set_ext[] = [
                'ext_name' => 'acme/demo',
                'lang_set' => 'demo',
            ];
            $event['lang_set_ext'] = $lang_set_ext;
        }
    }

So what is the ``main_listener.php`` class above actually doing?

The ``getSubscribedEvents()`` method is subscribing our listener function
``load_language_on_setup()`` to the event named ``core.user_setup``. This means
that when this event occurs, our function will execute.

.. tip::

    You can assign multiple listener functions to a single event using an array:

    .. code-block:: php

        'core.user_setup' => [['foo_method'], ['bar_method']]

The ``load_language_on_setup()`` listener method simply adds
our language file to phpBB's language data array. Generally speaking, a listener
is simply a public function in the subscriber class, referred to in the array
returned by ``getSubscribedEvents()``. It takes one argument, ``$event``. This
parameter allows you to access and modify the variables that are given to the
event from the core code. In this case we are modifying the ``lang_set_ext``
variable by adding Acme Demo's language file to it.

.. note::

    Note how the ``lang_set_ext`` event variable is first copied by assigning
    it to a local variable, then modified, and then copied back. This shortcut
    does not work: ``$event['foo']['bar'] = $baz;`` This is because the event
    variables are overloaded, which is a limitation in PHP.

Registering the listener
------------------------

To have phpBB autoload and execute our event listener class, we need to create a
service definition for it. This is done by creating a ``config/services.yml``
file in the extension:

.. code-block:: yaml

    services:
        acme.demo.listener:
            class: acme\demo\event\main_listener
            tags:
                - { name: event.listener }

.. warning::

    YAML files are indentation sensitive. They require an indentation size
    of 4 spaces per indent, **do not use tabs**.

The first line tells phpBB that a list of services is being registered. On
the next line we specify the name of the service, which is for our event
listener in this case.

.. important::

    Service names must be prefixed with your vendor and extension name.

The ``class`` attribute must contain the name-space and class name of the
service being registered. The name-space depends on the file's location,
within the ``ext/`` directory. Thus, the file ``ext/acme/demo/event/main_listener.php``
has the namespace ``acme\demo\event`` and class name ``main_listener``.
The full name of the class is therefore ``acme\demo\event\main_listener``
which is what we need to specify here.

The ``tags`` attribute tells phpBB that the service is an event listener.

Once the services YAML file has been created (or modified), phpBB's cache
needs to be purged. After purging the cache in the ACP, the description of
the link in the navigation bar should now display ``Demo`` instead of
``DEMO_PAGE``.

.. note::

    phpBB’s core PHP and template files have been prepared with dozens of event locations.
    However, if there are no events where your extension may need one, the phpBB development
    team welcomes event requests at the
    `area51.com Event Requests <https://area51.phpbb.com/phpBB/viewforum.php?f=111>`_ forum.

Prioritising event listeners (optional)
---------------------------------------

Sometimes different extensions can run into problems when competing for use of
the same PHP core events. In trying to resolve these issues, the extension
developer may want to prioritise their extension over others, so that their
extension will be triggered before other extensions.

In such cases, the ``getSubscribedEvents()`` method provides an argument for
setting a priority for event listener methods. For example:

.. code-block:: php

    static public function getSubscribedEvents()
    {
        return [
            'core.user_setup' => ['foo_method', $priority]
        ];
    }

In this example, ``$priority`` is an integer, the value of which defaults to 0.
Setting this integer to higher values equals more importance and therefore that
listener will be triggered earlier than others subscribed to this event.

We have now used events and listeners to modify phpBB and insert a nice link into
the nav-bar. However, the link still does not work yet. Continue on to the next
section to learn how to use controllers and routing to make our nav-bar link open
up a custom user facing page.
