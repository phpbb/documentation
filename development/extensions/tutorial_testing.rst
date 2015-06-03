=================
Tutorial: Testing
=================

Introduction
============

This tutorial explains:

 * `Unit tests`_
 * `Unit tests with database interaction`_
 * `Functional testing`_

.. warning::

    It is required to run the tests from a phpBB clone of the git repository,
    because the test framework is not included in the download packages.

Unit Tests
==========

Since unit tests are explained more in details in the
:doc:`../testing/unit_testing` section of the general testing documentation and
require no changes for extensions, we only add a quick example here.

.. note::

    If you have not yet run the tests of phpBB, it is recommended to make a
    break here and try to run them first. This helps to make sure, you have set
    up everything correctly, before writing the tests for the extension.

    More details are explained in the :doc:`../testing/unit_testing` section.

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
the page. Instead
`phpunit mocks <https://phpunit.de/manual/current/en/test-doubles.html>`_ are
injected.

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

For more information about Mocks and phpunit, please have a look at the
`phpunit Documentation <https://phpunit.de/manual/current/en/test-doubles.html>`_.

phpunit configuration file
--------------------------

Before we can run the tests we need to create the configuration file for
phpunit. Don't be scared if you do not understand it, you should not need to
edit anything in that file.
The file should be stored as ``ext/acme/demo/phpunit.xml.dist``:

.. code-block:: xml

    <?xml version="1.0" encoding="UTF-8"?>
    <phpunit backupGlobals="true"
             backupStaticAttributes="true"
             colors="true"
             convertErrorsToExceptions="true"
             convertNoticesToExceptions="true"
             convertWarningsToExceptions="true"
             processIsolation="false"
             stopOnFailure="false"
             syntaxCheck="false"
             verbose="true"
             bootstrap="../../../../tests/bootstrap.php"
    >
        <testsuites>
            <testsuite name="Extension Test Suite">
                <directory suffix="_test.php">./tests</directory>
                <exclude>./tests/functional</exclude>
            </testsuite>
            <testsuite name="Extension Functional Tests">
                <directory suffix="_test.php" phpVersion="5.3.19" phpVersionOperator=">=">./tests/functional/</directory>
            </testsuite>
        </testsuites>

        <filter>
            <blacklist>
                <directory>./tests/</directory>
            </blacklist>
            <whitelist processUncoveredFilesFromWhitelist="true">
                <directory suffix=".php">./</directory>
                <exclude>
                    <directory suffix=".php">./language/</directory>
                    <directory suffix=".php">./migrations/</directory>
                    <directory suffix=".php">./tests/</directory>
                </exclude>
            </whitelist>
        </filter>
    </phpunit>

Now we can finally run the tests by executing the following command::

    $ ./phpBB/vendor/bin/phpunit -c phpBB/ext/acme/demo/phpunit.xml.dist
    PHPUnit 4.1.0 by Sebastian Bergmann.

    Configuration read from /home/nickv/phpBB/Ascraeus/phpBB/ext/acme/demo/phpunit.xml.dist

    ...

    Time: 101 ms, Memory: 9.00Mb

    OK (3 tests, 12 assertions)

Unit tests with database interaction
====================================

When testing your own tables and columns, you can not use the normal database
that phpBB's unit tests set up by default.

Migration with database changes
-------------------------------

We add a new migration file
``ext/acme/demo/migrations/add_database_changes.php`` now, which contains some
database changes, so we can test them:

.. code-block:: php

    <?php
    // ext/acme/demo/migrations/add_database_changes.php
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

    namespace acme\demo\migrations;

    use phpbb\db\migration\migration;

    class add_database_changes extends migration
    {
        public function effectively_installed()
        {
            return $this->db_tools->sql_column_exists($this->table_prefix . 'users', 'user_acme');
        }

        static public function depends_on()
        {
            return array('\acme\demo\migrations\add_module');
        }

        public function update_schema()
        {
            return array(
                'add_tables'		=> array(
                    $this->table_prefix . 'acme_demo'	=> array(
                        'COLUMNS'		=> array(
                            'acme_id'			=> array('UINT', null, 'auto_increment'),
                            'acme_name'			=> array('VCHAR:255', ''),
                        ),
                        'PRIMARY_KEY'	=> 'acme_id',
                    ),
                ),
                'add_columns'	=> array(
                    $this->table_prefix . 'users'			=> array(
                        'user_acme'				=> array('UINT', 0),
                    ),
                ),
            );
        }

        public function revert_schema()
        {
            return array(
                'drop_columns'	=> array(
                    $this->table_prefix . 'users'			=> array(
                        'user_acme',
                    ),
                ),
                'drop_tables'		=> array(
                    $this->table_prefix . 'acme_demo',
                ),
            );
        }
    }

Testing database changes
------------------------

If we add a new test, that checks for the existence of the table, we will see,
that the test fails:

.. code-block:: php

    <?php
    // ext/acme/demo/tests/migrations/database/add_database_changes.php
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

    namespace acme\demo\tests\migrations;

    class add_database_changes_test extends \phpbb_database_test_case
    {
        /** @var \phpbb\db\tools */
        protected $db_tools;

        /** @var string */
        protected $table_prefix;

        public function getDataSet()
        {
            return $this->createXMLDataSet(dirname(__FILE__) . '/fixtures/add_database_changes.xml');
        }

        public function setUp()
        {
            parent::setUp();

            global $table_prefix;

            $this->table_prefix = $table_prefix;
            $db = $this->new_dbal();
            $this->db_tools = new \phpbb\db\tools($db);
        }

        public function test_user_acme_column()
        {
            $this->assertTrue($this->db_tools->sql_column_exists(USERS_TABLE, 'user_acme'), 'Asserting that column "user_acme" exists');
        }

        public function test_acme_demo_table()
        {
            $this->assertTrue($this->db_tools->sql_table_exists($this->table_prefix . 'acme_demo'), 'Asserting that column "' . $this->table_prefix . 'acme_demo" does not exist');
        }
    }

Before we can run the database test, we need to create the fixture file we
specified in the ``getDataSet()`` method. This file can be used to create
database entries before each test run is executed. We will make use of this
later. For now we just want to check if our tables have been created, so we
specify an empty config table
``ext/acme/demo/tests/migrations/database/fixtures/add_database_changes.xml``:

.. code-block:: xml

    <?xml version="1.0" encoding="UTF-8" ?>
    <dataset>
        <table name="phpbb_config">
            <column>config_name</column>
            <column>config_value</column>
            <column>is_dynamic</column>
        </table>
    </dataset>

Execution
---------

When we now execute the tests again they will fail::

    $ ./phpBB/vendor/bin/phpunit -c phpBB/ext/acme/demo/phpunit.xml.dist
    PHPUnit 4.1.0 by Sebastian Bergmann.

    Configuration read from /home/nickv/phpBB/Ascraeus/phpBB/ext/acme/demo/phpunit.xml.dist

    ...FF

    Time: 5.27 seconds, Memory: 10.75Mb

    There were 2 failures:

    1) acme\demo\tests\migrations\add_database_changes_test::test_user_acme_column
    Asserting that column "user_acme" exists
    Failed asserting that false is true.

    /home/nickv/phpBB/Ascraeus/phpBB/ext/acme/demo/tests/migrations/add_database_changes_test.php:42

    2) acme\demo\tests\migrations\add_database_changes_test::test_acme_demo_table
    Asserting that column "phpbb_acme_demo" does not exist
    Failed asserting that false is true.

    /home/nickv/phpBB/Ascraeus/phpBB/ext/acme/demo/tests/migrations/add_database_changes_test.php:47

    FAILURES!
    Tests: 5, Assertions: 14, Failures: 2.

In order to get our database changes executed in unit tests, we need to tell
phpBB that this test needs the extension to be set up. We can do this by
overwriting the ``\phpbb_database_test_case::setup_extensions()`` method of the
test and returning an array with the extension name:

.. code-block:: php

    class add_database_changes_test extends \phpbb_database_test_case
    {
        static protected function setup_extensions()
        {
            return array('acme/demo');
        }

    ...

and now the execution passes successfully::

    $ ./phpBB/vendor/bin/phpunit -c phpBB/ext/acme/demo/phpunit.xml.dist
    PHPUnit 4.1.0 by Sebastian Bergmann.

    Configuration read from /home/nickv/phpBB/Ascraeus/phpBB/ext/acme/demo/phpunit.xml.dist

    .....

    Time: 5.45 seconds, Memory: 13.75Mb

    OK (5 tests, 14 assertions)

.. note::

    As you could see, the time for the test execution went up from a few
    hundred milliseconds to a few seconds. This is, because database tests
    set up the database and populate it, which just takes time.

    Therefor it is recommended to only use database tests, when you really need
    the database. It is better to split your test file into a database-test and
    a non-database one, to keep the run time short.

Using fixtures
--------------

Now let's make use of the fixture file to populate the database for our test.
Therefor we replace the content of the
``ext/acme/demo/tests/migrations/database/fixtures/add_database_changes.xml``
file with the following content:

.. code-block:: xml

    <?xml version="1.0" encoding="UTF-8" ?>
    <dataset>
        <table name="phpbb_acme_demo">
            <column>acme_id</column>
            <column>acme_name</column>
            <row>
                <value>1</value>
                <value>one</value>
            </row>
            <row>
                <value>2</value>
                <value>two</value>
            </row>
        </table>
    </dataset>

.. note::

    You can leave out columns from the tables, if you do not want to specify
    values for them.

.. warning::

    Database columns that are specified as ``TEXT_UNI`` columns need to be
    specified, otherwise your test will fail on some databases.

After we added the content to the database we add a new test at the end of the
file, that queries our table to the
``ext/acme/demo/tests/migrations/database/add_database_changes.php`` and tests
whether the values are really in the database:

.. code-block:: php

    ...

        public function data_acme_demo_content()
        {
            return array(
                array(1, 'one'),
                array(2, 'two'),
            );
        }

        /**
         * @dataProvider data_acme_demo_content
         *
         * @param int $acme_id
         * @param string $expected
         */
        public function test_acme_demo_content($acme_id, $expected)
        {
            /** @var \phpbb\db\driver\driver_interface $db */
            $db = $this->new_dbal();

            $sql = 'SELECT acme_name
                FROM ' . $this->table_prefix . 'acme_demo
                WHERE acme_id = ' . (int) $acme_id;
            $result = $db->sql_query($sql);
            $value = $db->sql_fetchfield('acme_name');
            $db->sql_freeresult($result);

            $this->assertEquals($expected, $value);
        }
    }

Functional testing
==================

Functional tests simulate calling a URL and allow you to filter the output then
and check whether certain elements have a specific content.

.. note::

    Again it is recommended to run the functional tests of phpBB first, before
    writing the tests for the extension.

    More details are explained in the :doc:`../testing/functional_testing`
    section.

Again like with the database changes we need to tell phpBB that the test depends
on the extension, then phpBB will take care of enabling the extension before the
test execution. Our little test opens the route we added and then checks for the
right message, like the unit test we wrote in `unit tests`_ at the beginning:

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

    namespace acme\demo\tests\functional;

    /**
     * @group functional
     */
    class demo_test extends \phpbb_functional_test_case
    {
        static protected function setup_extensions()
        {
            return array('acme/demo');
        }

        public function test_demo_world()
        {
            $this->add_lang_ext('acme/demo', 'demo');

            $crawler = self::request('GET', 'app.php/demo/world');
            $this->assertContains($this->lang('DEMO_HELLO', 'world'), $crawler->filter('h2')->text());
        }

        public function test_demo_bertie()
        {
            $this->add_lang_ext('acme/demo', 'demo');

            $crawler = self::request('GET', 'app.php/demo/bertie');
            $this->assertContains($this->lang('NO_AUTH_SPEAKING', 'bertie'), $crawler->filter('#message p')->text());
        }
    }

Running this test, however, will fail::

    $ ./phpBB/vendor/bin/phpunit -c phpBB/ext/acme/demo/phpunit.xml.dist
    PHPUnit 4.1.0 by Sebastian Bergmann.

    Configuration read from /home/nickv/phpBB/Ascraeus/phpBB/ext/acme/demo/phpunit.xml.dist

    ........F

    Time: 22.37 seconds, Memory: 17.25Mb

    There was 1 failure:

    1) acme\demo\tests\functional\demo_test::test_demo_bertie
    HTTP status code does not match
    Failed asserting that 403 matches expected 200.

    /home/nickv/phpBB/Ascraeus/tests/test_framework/phpbb_functional_test_case.php:900
    /home/nickv/phpBB/Ascraeus/tests/test_framework/phpbb_functional_test_case.php:859
    /home/nickv/phpBB/Ascraeus/tests/test_framework/phpbb_functional_test_case.php:138
    /home/nickv/phpBB/Ascraeus/phpBB/ext/acme/demo/tests/functional/demo_test.php:38

    FAILURES!
    Tests: 9, Assertions: 49, Failures: 1.

The reason is, that the test suite compares the response for the correct format
(valid HTML, without debug errors) and a successful status code ``200``.

Therefor we need to adjust the bertie test, because we return a ``403`` status
in the controller, if someone tries to talk to bertie:

.. code-block:: php

        public function test_demo_bertie()
        {
            $this->add_lang_ext('acme/demo', 'demo');

            $crawler = self::request('GET', 'app.php/demo/bertie', array(), false);
            self::assert_response_html(403);
            $this->assertContains($this->lang('NO_AUTH_SPEAKING', 'bertie'), $crawler->filter('#message p')->text());
        }

Now the tests will pass correctly::

    $ ./phpBB/vendor/bin/phpunit -c phpBB/ext/acme/demo/phpunit.xml.dist
    PHPUnit 4.1.0 by Sebastian Bergmann.

    Configuration read from /home/nickv/phpBB/Ascraeus/phpBB/ext/acme/demo/phpunit.xml.dist

    .........

    Time: 22.11 seconds, Memory: 17.00Mb

    OK (9 tests, 52 assertions)

.. note::

    Functional tests are **slow**. Depending on your server, it might take up to
    2 seconds per page view. phpBB is installed via page views aswell, which
    takes another 20 to 100 seconds, depending on various configurations, for
    the first functional tests. Subsequent functional tests **do not reinstall**
    the board, so they do not have the huge setup time.
