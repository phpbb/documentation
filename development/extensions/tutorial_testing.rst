=================
Tutorial: Testing
=================

Introduction
============

This tutorial explains:

 * Unit tests
 * Unit tests with database interaction
 * Functional testing
 * Continuous testing with Travis CI

.. note::

    It is required to run the tests from a phpBB clone of the git repository,
    because the test framework is not included in the download packages.

Unit Testing
============

Since unit tests are explained more in details in the
:doc:`../testing/unit_testing` section of the general testing documentation and
require no changes for extensions, we only add a quick example here.

.. code-block:: php

    <?php
    // ext/acme/demo/tests/controller/main_test.php
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

    namespace acme\demo\tests\controller;

    class main_test extends \phpbb_test_case
    {
        /** @var \acme\demo\controller\main */
        protected $controller;

        protected $config;
        protected $helper;
        protected $template;
        protected $user;

        public function setUp()
        {
            parent::setUp();

            $this->config = $this->getMockBuilder('\phpbb\config\config')
                ->disableOriginalConstructor()
                ->getMock();
            $this->helper = $this->getMockBuilder('\phpbb\controller\helper')
                ->disableOriginalConstructor()
                ->getMock();
            $this->template = $this->getMockBuilder('\phpbb\template\template')
                ->disableOriginalConstructor()
                ->getMock();
            $this->user = $this->getMockBuilder('\phpbb\user')
                ->disableOriginalConstructor()
                ->getMock();

            $this->controller = new \acme\demo\controller\main(
                $this->config,
                $this->helper,
                $this->template,
                $this->user
            );
        }

        public function test_handle_bertie()
        {
            $this->helper->expects($this->once())
                ->method('message')
                ->with('NO_AUTH_SPEAKING', array('bertie'), 'NO_AUTH_OPERATION', 403)
                ->willReturn($this->getMock('Symfony\Component\HttpFoundation\Response'));

            $this->helper->expects($this->never())
                ->method('render');

            $response = $this->controller->handle('bertie');
            $this->assertInstanceOf('\Symfony\Component\HttpFoundation\Response', $response);
        }

        public function handle_data()
        {
            return array(
                array('foo', true, 'DEMO_GOODBYE'),
                array('bar', false, 'DEMO_HELLO'),
            );
        }

        /**
         * @dataProvider handle_data
         */
        public function test_handle($name, $config, $expected_language)
        {
            $language_return = $expected_language . '#' .  $name;

            $this->config->expects($this->once())
                ->method('offsetExists')
                ->with('acme_demo_goodbye')
                ->willReturn(true);
            $this->config->expects($this->once())
                ->method('offsetGet')
                ->with('acme_demo_goodbye')
                ->willReturn($config);

            $this->user->expects($this->once())
                ->method('lang')
                ->with($expected_language, $name)
                ->willReturn($language_return);

            $this->template->expects($this->once())
                ->method('assign_var')
                ->with('DEMO_MESSAGE', $language_return);

            $this->helper->expects($this->once())
                ->method('render')
                ->with('demo_body.html',test_handle_bertie() $name, 200, false)
                ->willReturn($this->getMock('Symfony\Component\HttpFoundation\Response'));

            $response = $this->controller->handle($name);
            $this->assertInstanceOf('\Symfony\Component\HttpFoundation\Response', $response);
        }
    }

Using mocks
-----------

In the ``setUp()`` method we create our controller object. However, we do not
use the actual classes of phpBB which are used by the controller, when opening
the page. Instead `phpunit mocks<>`_ are injected.

These mocks allow to check how often a method is called, what the arguments are
and let you specify the return value. This helps us to verify that **our**
controller code behaves as expected. We do not want to get an error, when phpBB
itself behaves unexpected.

Testing a method
----------------

In our controller we added special handling when the provided name is
``bertie``. So our first test is whether the
``phpbb\controller\helper::message()`` method is called **once** with the
``NO_AUTH_SPEAKING`` error message. We also want to make sure that the
``phpbb\controller\helper::render()`` method is not called in this case.

Then we call the controller's ``handle()`` method. If the methods are invoked
correctly the test will pass.

.. code-block:: php

        public function test_handle_bertie()
        {
            $this->helper->expects($this->once())
                ->method('message')
                ->with('NO_AUTH_SPEAKING', array('bertie'), 'NO_AUTH_OPERATION', 403)
                ->willReturn($this->getMock('Symfony\Component\HttpFoundation\Response'));

            $this->helper->expects($this->never())
                ->method('render');

            $response = $this->controller->handle('bertie');
            $this->assertInstanceOf('\Symfony\Component\HttpFoundation\Response', $response);
        }

.. note::

    Make sure that the name of your testing method starts with ``test``.
    Otherwise it is not being executed as a test by phpunit.

Data providers
--------------

For the normal case we use a data provider. A data provider is a method that
returns an array of arrays. The inner array contains the arguments for the
``test`` method.

.. code-block:: php

        public function handle_data()
        {
            return array(
                array('foo', true, 'DEMO_GOODBYE'),
                array('bar', false, 'DEMO_HELLO'),
            );
        }

So in our case the test will be called twice, once with the arguments:

* 'foo'
* true
* 'DEMO_GOODBYE'

and a second time with:

* 'bar'
* false
* 'DEMO_HELLO'

In the test we then tell the ``phpbb\config\config`` mock to return the
specified value which is passed in as an argument.

.. code-block:: php

        /**
         * @dataProvider handle_data
         */
        public function test_handle($name, $config, $expected_language)
        {
            // ...

            $this->config->expects($this->once())
                ->method('offsetGet')
                ->with('acme_demo_goodbye')
                ->willReturn($config);

If we have a short look at our controller again, we see that the value of the
config influences the ``\phpbb\user::lang()`` call:

.. code-block:: php

    $l_message = empty($this->config['acme_demo_goodbye']) ? 'DEMO_HELLO' : 'DEMO_GOODBYE';
    $this->template->assign_var('DEMO_MESSAGE', $this->user->lang($l_message, $name));

This is what we check with the third argument ``$expected_language`` of our test
method:

.. code-block:: php

            $this->user->expects($this->once())
                ->method('lang')
                ->with($expected_language, $name)
                ->willReturn($language_return);

phpunit configuration file
--------------------------

Before we can run the tests we need to create the configuration file for
phpunit. Don't be scared if you do not understand it, you should not need to
edit anything in that file.
The file should be stored as ``phpunit.xml.dist``:

.. code-block:: xml




















