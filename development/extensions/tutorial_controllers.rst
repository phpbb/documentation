================================
Tutorial: Controllers and Routes
================================

Introduction
============

This tutorial explains the basic functionality of extensions:

 * Controllers (Frontpage)
 * Routes (URLs)

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
                return $this->helper->message('NO_AUTH_GREETING', array($name), 'NO_AUTH_OPERATION', 403);
            }

            $l_message = empty($this->config['acme_demo_goodbye']) ? 'DEMO_HELLO' : 'DEMO_GOODBYE';
            $this->template->assign_var('DEMO_MESSAGE', $this->user->lang($l_message, $name));

            return $this->helper->render('demo_body.html', $name);
        }
    }

Dependencies
------------

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
