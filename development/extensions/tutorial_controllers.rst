================================
Tutorial: Controllers and Routes
================================

Introduction
============

This tutorial explains:

 * Controllers: User facing files
 * Routes: URLs

Controller
==========

Currently we have an link without a target in the navigation bar. Starting from
phpBB 3.1, extensions must not have front facing files in the root directory of
the phpBB installation. Instead controllers are being used to serve the pages
and deal with requests.

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

    namespace acme\demo\controller;

    use phpbb\config\config;
    use phpbb\controller\helper;
    use phpbb\template\template;
    use phpbb\user;
    use Symfony\Component\HttpFoundation\Response;

    class main
    {
        /* @var config */
        protected $config;

        /* @var helper */
        protected $helper;

        /* @var template */
        protected $template;

        /* @var user */
        protected $user;

        /**
         * Constructor
         *
         * @param config $config
         * @param helper $helper
         * @param template $template
         * @param user $user
         */
        public function __construct(config $config, helper $helper, template $template, user $user)
        {
            $this->config = $config;
            $this->helper = $helper;
            $this->template = $template;
            $this->user = $user;
        }

        /**
         * Demo controller for route /demo/{name}
         *
         * @param string $name
         * @return Response A Symfony Response object
         */
        public function handle($name)
        {
            if ($name === 'bertie')
            {
                return $this->helper->message('NO_AUTH_SPEAKING', array($name), 'NO_AUTH_OPERATION', 403);
            }

            $l_message = empty($this->config['acme_demo_goodbye']) ? 'DEMO_HELLO' : 'DEMO_GOODBYE';
            $this->template->assign_var('DEMO_MESSAGE', $this->user->lang($l_message, $name));

            return $this->helper->render('demo_body.html', $name);
        }
    }

Dependencies
============

Now let's have a look at the constructor of the controller, before looking at
the actual "controller" code in the ``handle()`` method. In our controller we
use several features of phpBB, for example the configuration values, a helper
for controllers, the template engine and the user object to use translations.

To tell phpBB that our controller needs these objects we need to specify them in
the ``arguments`` section of the definition in the ``services.yml`` file which
was introduced in the :doc:`tutorial_basics`. The complete ``services.yml`` file
should look as follows:

.. code-block:: yaml

    services:
        acme.demo.controller:
            class: acme\demo\controller\main
            arguments:
                - @config
                - @controller.helper
                - @template
                - @user
        acme.demo.listener:
            class: acme\demo\event\main_listener
            tags:
                - { name: event.listener }

.. warning::

    The order of the constructor arguments has to match the order in the service
    definition.

There are a lot of other services defined by phpBB. You can find them in the
``config/*.yml`` files of phpBB.

Request handling
================

In the handle method we have a special treatment when someone tries to talk to
"bertie". In this case we use the ``phpbb\controller\helper::message()`` method
to throw an error, because people should not talk to Bertie.

In order to translate the error and greeting messages, we add it to the
``language/en/demo.php`` file before closing the array at the end:

.. code-block:: php

    'DEMO_GOODBYE'     => 'Goodbye %s!',
    'DEMO_HELLO'       => 'Hello %s!',
    'NO_AUTH_SPEAKING' => 'You must not try to talk to %s',

The name of the person is inserted in the ``%s`` placeholder by the
``phpbb\controller\helper::message()`` and ``phpbb\user::lang()``.

In case the name is not ``bertie`` use the ``phpbb\controller\helper`` to render
a style template file called ``demo_body.html``.

Template file
=============

The template file has to be in the ``styles/prosilver/template/`` directory,
similar to the listener file. So we create the HTML file ``demo_body.html`` in
that directory using the following content including the phpBB header and
footer:

.. code-block:: html

    <!-- INCLUDE overall_header.html -->

    <h2>{DEMO_MESSAGE}</h2>

    <!-- INCLUDE overall_footer.html -->

Routing
=======

Now the controller would display the page content, but we don't have a URL which
executes the controller. The URLs are defined in the ``config/routing.yml`` file
of our extension:

.. code-block:: yaml

    acme_demo_route:
        path: /demo/{name}
        defaults: { _controller: acme.demo.controller:handle }


.. warning::

    Similar to event and service names your route names should be prefixed with
    your vendor and extension name.

``path`` specifies the URL component. Curly braces are used as placeholders. The
name of the placeholder is the name of the variable of the controller's
``handle()`` method. The order of the arguments may also be different in the URL
and method.

In the ``defaults`` section the service name of the controller is specified. In
the `Dependencies`_ section we used ``acme.demo.controller`` as a service name.
``handle`` is the name of the method that should be called on the controller.

You can also specify a regular expression, to make sure that your controller is
only used, when a parameter matches it. For example, if we want to ensure that
``name`` is an integer, we could add the following code to the route definition:

.. code-block:: yaml

        requirements:
            page: \d+

Now if you type the link ``https://localhost/phpBB/app.php/demo/world`` into
your browser, you will see the page.

Generating links to routes
==========================

In order to populate the ``a``-element in navigation with our link, we need to
assign the link to the template variable ``U_DEMO_PAGE``.

We have to use the ``core.page_header`` event for that. So we replace our old
``getSubscribedEvents()`` method in the ``event/main_listener.php`` and also add
the template engine and controller helper as dependencies:

.. code-block:: php

        static public function getSubscribedEvents()
        {
            return array(
                'core.user_setup'  => 'load_language_on_setup',
                'core.page_header' => 'add_page_header_link',
            );
        }

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
            $this->helper = $helper;
            $this->template = $template;
        }

We also have to extend the definition of the listener in the
``config/services.yml``:

.. code-block:: yaml

        acme.demo.listener:
            class: acme\demo\event\main_listener
            arguments:
                - @controller.helper
                - @template
            tags:
                - { name: event.listener }

.. note::

    Remember to purge the cache every time you change something in the ``*.yml``
    files.

Now we add the new method ``add_page_header_link`` which creates the link,
setting the ``name`` placeholder to ``world``:

.. code-block:: php

        public function add_page_header_link($event)
        {
            $this->template->assign_vars(array(
                'U_DEMO_PAGE' => $this->helper->route('acme_demo_route', array('name' => 'world')),
            ));
        }

The navigation link should now lead to a page that says "Hello world!". When we
temporarily replace ``world`` with ``bertie`` the navigation link will lead you
to ``https://localhost/phpBB/app.php/demo/bertie`` displaying the following
message:

.. code-block:: html

    <h2>You do not have the necessary permissions to complete this operation.</h2>
    <p>You must not try to talk to bertie</p>

