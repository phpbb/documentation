================================
Tutorial: Controllers and Routes
================================

Introduction
============

phpBB 3.1 introduced Symfony's `HttpKernel <http://symfony.com/doc/current/components/http_kernel.html>`__,
`Controller <https://symfony.com/doc/current/controller.html>`__ and
`Routing <http://symfony.com/doc/current/routing.html>`__ systems which
allow extensions to handle custom "front-facing" pages that users are able
to view and interact with.

This tutorial explains how to create user-facing pages:

 * `Controllers`_: User facing files
 * `Routing`_: URLs to user facing files

Controllers
===========

A controller is a class with a collection of functions that serve content
and handle interactions from the user, based on what is requested in the
URL. For example, a blog extension that displays one or more blog entries.

Currently our Acme Demo extension has a link in the navigation bar without
a target. We will use a controller to create a page the user will see, and
use routing to manage the URL to our controller.

Controller files can be placed anywhere inside an extension’s directory
structure, although to keep things organised it is best to place them in a
separate directory named ``controller/``. Controller files may also be
given any name. For the Acme Demo extension, we will use
``ext\acme\demo\controller\main.php``.

Every controller should contain at least two methods:

 1. A public ``__construct()`` method. This is optional if your controller
    has no dependencies.
 2. A public ``handle()`` method. This method can take any name, but "handle"
    is common. This method must return a Symfony Response object.

.. code-block:: php

    <?php

    use \Symfony\Component\HttpFoundation\Response;

    namespace acme\demo\controller;

    class main
    {
        /* @var \phpbb\config\config */
        protected $config;

        /* @var \phpbb\controller\helper */
        protected $helper;

        /* @var \phpbb\language\language */
        protected $language;

        /* @var \phpbb\template\template */
        protected $template;

        /**
         * Constructor
         *
         * @param \phpbb\config\config      $config
         * @param \phpbb\controller\helper  $helper
         * @param \phpbb\language\language  $language
         * @param \phpbb\template\template  $template
         */
        public function __construct(\phpbb\config\config $config, \phpbb\controller\helper $helper, \phpbb\language\language $language, \phpbb\template\template $template)
        {
            $this->config   = $config;
            $this->helper   = $helper;
            $this->language = $language;
            $this->template = $template;
        }

        /**
         * Demo controller for route /demo/{name}
         *
         * @param string $name
         * @throws \phpbb\exception\http_exception
         * @return \Symfony\Component\HttpFoundation\Response A Symfony Response object
         */
        public function handle($name)
        {
            if ($name === 'bertie')
            {
                throw new \phpbb\exception\http_exception(403, 'NO_AUTH_SPEAKING', array($name));
            }

            $l_message = !$this->config['acme_demo_goodbye'] ? 'DEMO_HELLO' : 'DEMO_GOODBYE';
            $this->template->assign_var('DEMO_MESSAGE', $this->language->lang($l_message, $name));

            return $this->helper->render('demo_body.html', $name);
        }
    }

Dependencies
------------

Now let's have a look at the constructor of the controller, before looking at
the actual controller code in the ``handle()`` method.

Our controller has several dependencies on phpBB objects. We must tell phpBB
about our controller and it's dependencies by defining it as a service in our
``config/services.yml`` file which was introduced in :doc:`tutorial_events`.
The complete ``services.yml`` file should look like:

.. code-block:: yaml

    services:
        acme.demo.controller:
            class: acme\demo\controller\main
            arguments:
                - '@config'
                - '@controller.helper'
                - '@language'
                - '@template'
        acme.demo.listener:
            class: acme\demo\event\main_listener
            tags:
                - { name: event.listener }

.. caution::

    Remember that the order of arguments must match the order of parameters in the
    constructor method definition.

Request handling
----------------

The ``handle()`` method is responsible for handling the request to display
pages. Notice it accepts the argument ``$name``. This is a variable that is
passed in from a URL parameter, as defined in the `Routing`_ configuration
file.

The handle method has a special condition that checks if the user tries to
use *bertie*. We do not want to authorise this, because people should not
interact with `Bertie <https://www.phpbb.com/shop/>`_. So we throw an
``http_exception`` with a 403 error code, which will display a nice
"unauthorised" error message to the user.

With a valid name, the handle method will create a simple message to
display to the user and assign it to the controller's template variables
array.

Then we use the ``phpbb\controller\helper`` Helper object to render our
page with the ``render()`` method. It takes the template filename, the page
title, and the status code as its arguments. The page title defaults to an
empty string and the status code defaults to 200. We are using the
`Controller template`_ ``demo_body.html``.

.. note::

    The ``phpbb\controller\helper:render()`` method returns a Symfony
    Response object for us. If you choose to not use the Helper object, you
    will need to manually return a Symfony Response object. The Reponse
    object takes two arguments:

        1. Response message - This should be the full, rendered page source
           that will be output on the screen.
        2. Status code - This defaults to 200, which is the status code "OK".
           If you are sending a response about being unable to find some
           information, you would use the 404 ("Not Found") status. 403 would
           be used if the user lacks the appropriate permissions, and 500
           would be for an unknown error.

    .. code-block:: php

        return new \Symfony\Component\HttpFoundation\Response($template_file, 200);

.. warning::

    A controller should never call ``trigger_error()`` to generate output.
    Instead it should always return Symfony Response or JsonResponse objects,
    or throw a phpBB http_exception.

Controller template
-------------------

Every controller requires an HTML template file. The Acme Demo extension uses
``demo_body.html`` located in the ``styles/prosilver/template/`` directory,
with the following content including the phpBB header and footer:

.. code-block:: html

    <!-- INCLUDE overall_header.html -->

    <h2>{DEMO_MESSAGE}</h2>

    <!-- INCLUDE overall_footer.html -->

.. note::

    A template file this simple could be stored in the ``all/`` style folder
    because it clearly has no HTML markup specific to the prosilver style.


Routing
=======

At this point, we now have a controller that can create and serve a
user-facing page, but we don't yet have a URL through which to access the
page.

To solve this, each controller must define a *route* in a ``config/routing.yml``
file of the extension. This file is responsible for associating a controller's
access name (i.e. what is typed in the URL) with its service (i.e. what we
covered in `Dependencies`_).

Recall that our controller expects a URL parameter to be passed to it as
the ``$name`` variable. Therefore, we want our URL to look like:
``/app.php/demo/<name>``.

.. note::

    All extension controller files are accessed via ``app.php``. However,
    boards can turn on the Enable URL rewriting feature in the ACP to hide
    the ``app.php/`` component of the URL.

Our ``routing.yml`` file should look like:

.. code-block:: yaml

    acme_demo_route:
        path: /demo/{name}
        defaults: { _controller: acme.demo.controller:handle, name: "world" }

The above routing definition says that when the user goes to the URL
``/app.php/demo/<name>`` it should load the ``acme.demo.controller``
service and call the ``handle`` method, giving the value of the ``{name}``
"slug" to the ``$name`` argument (the names of the slug and argument must
match). If no value is given for ``{name}`` (i.e. the URL is
``/app.php/demo``) it will pass the default value of "world" to the
``handle`` method.

As you can see, slugs offer a powerful way to interact with your controller
through URL parameters. You must specify a slug for every required parameter
in your method. Optional parameters do not have to be provided in the
Routing definition, in which case they will take the default value given in
the method definition.

You can also specify regular expressions for the slugs, to more tightly
control the type of data being passed to the method. For example, if we want
to ensure that ``name`` is an integer, we would append the following code to
our route definition:

.. code-block:: yaml

        requirements:
            name: \d+

.. csv-table::
   :header: "Item", "Description"
   :delim: |

       route | "The route name is a unique name and must be prefixed with the vendor and extension names. Use only lowercase letters and underscores."
       path | "The path of the URL component, including slugs wrapped in curly braces. If a path does not match any route a 404 error is returned."
       defaults | "The service name of the controller and the name of the method to call, separated by a colon. Optionally, default values for slugs can be defined."
       requirements | "Used to make a specific route only match under specific conditions."

The ``routing.yml`` can hold multiple route definitions for multiple URLs,
as may be required by the needs of the extension. Routes are compared in
the order of their declaration in the ``routing.yml`` file, which is
important to consider when defining routes. For example:

.. code-block:: yaml

    acme_blog_home:
        path: /blog
        defaults: { _controller: acme.blog.controller:handle }

    acme_blog_entry:
        path: /blog/{id}
        defaults: { _controller: acme.blog.controller:handle }
        requirements:
            id: \d+

    acme_blog_edit:
        path: /blog/{id}/edit
        defaults: { _controller: acme.blog.controller:handle }
        requirements:
            id: \d+

Generating links to routes
--------------------------

Now that we are able to access our user-facing page from a URL, we need to
add that URL to the nav-bar link we created earlier with the template listener.

Recall that our template listener has a ``U_DEMO_PAGE`` variable. We will now
revisit our PHP event listener and update it to generate a URL for our route
and assign it to ``U_DEMO_PAGE``.

First, we will use the ``core.page_header`` event. This is an ideal event
to use when you want to manipulate code when the header of a phpBB page is
generated. We must update the ``getSubscribedEvents()`` method in the
``event/main_listener.php`` as follows:

.. code-block:: php

        static public function getSubscribedEvents()
        {
            return array(
                'core.user_setup'  => 'load_language_on_setup',
                'core.page_header' => 'add_page_header_link',
            );
        }

Next we will add a new method to the event listener which creates our link
and assigns it to our template variable:

.. code-block:: php

        /**
         * Add a page header nav bar link
         *
         * @param \phpbb\event\data $event The event object
         */
        public function add_page_header_link($event)
        {
            $this->template->assign_vars(array(
                'U_DEMO_PAGE' => $this->helper->route('acme_demo_route', array('name' => 'world')),
            ));
        }

In this new method we use the Controller Helper object's ``route()``
method to create the link to our controller. Note that it takes two
arguments:

 1. The name of the route, as defined in the ``routing.yml``. In this
    case, ``acme_demo_route``.
 2. An optional array of parameters. In this case, we are passing the
    value ``world`` to the ``name`` parameter as a default value.

.. note::

    The URL generated will look like ``./app.php/demo/world`` which is
    equivalent to ``./app.php/demo?name=world``.

Notice that our new method ``add_page_header_link()`` requires the
Controller Helper and Template objects from phpBB. Therefore, we must
also add a new constructor to our event listener in order to
inject these dependencies. Putting everything together, the complete
event listener should look like:

.. code-block:: php

    namespace acme\demo\event;

    use Symfony\Component\EventDispatcher\EventSubscriberInterface;

    class main_listener implements EventSubscriberInterface
    {
        /* @var \phpbb\controller\helper */
        protected $helper;

        /* @var \phpbb\template\template */
        protected $template;

        /**
         * Constructor
         *
         * @param \phpbb\controller\helper $helper
         * @param \phpbb\template\template $template
         */
        public function __construct(\phpbb\controller\helper $helper, \phpbb\template\template $template)
        {
            $this->helper   = $helper;
            $this->template = $template;
        }

        static public function getSubscribedEvents()
         {
            return array(
             'core.user_setup'	=> 'load_language_on_setup',
             'core.page_header'	=> 'add_page_header_link',
            );
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
            $lang_set_ext[] = array(
                'ext_name' => 'acme/demo',
                'lang_set' => 'demo',
            );
            $event['lang_set_ext'] = $lang_set_ext;
        }

        /**
         * Add a page header nav bar link
         *
         * @param \phpbb\event\data $event The event object
         */
        public function add_page_header_link($event)
        {
            $this->template->assign_vars(array(
                'U_DEMO_PAGE' => $this->helper->route('acme_demo_route', array('name' => 'world')),
            ));
        }
    }

Remember to also update the event listener's service definition in
``config/services.yml`` with the new dependencies:

.. code-block:: yaml

        acme.demo.listener:
            class: acme\demo\event\main_listener
            arguments:
                - '@controller.helper'
                - '@template'
            tags:
                - { name: event.listener }

.. note::

    Remember to purge the cache every time you change something in
    the ``*.yml`` files.

Now our link in the nav-bar should open a new user-facing page that
says "Hello world!" If we temporarily replace "world" with some other
string, for example "foo" the page should say "Hello foo!". And if we
use "bertie" then we should be shown a 403 error page.

We have completed our user-facing controller page. Continue on to the
next section to learn how to add an ACP module to our extension so we
can give it some configuration settings.
