=================
Tutorial: Testing
=================

Introduction
============

This tutorial explains:

 * `Unit tests`_
 * `Unit tests with database interaction`_
 * `Functional testing`_
 * `Continuous integration with Github Actions`_

.. warning::

    It is required to run the tests from a phpBB clone of the git repository,
    because the test framework is not included in the download packages.

Unit Tests
==========

Since unit tests are explained in more detail in the
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
        protected $language;
        protected $template;

        public function setUp(): void
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
            $this->language = $this->getMockBuilder('\phpbb\language\language')
                ->disableOriginalConstructor()
                ->getMock();

            $this->controller = new \acme\demo\controller\main(
                $this->config,
                $this->helper,
                $this->template,
                $this->language
            );
        }

        public function test_handle_bertie()
        {
            $this->helper->expects($this->once())
                ->method('message')
                ->with('NO_AUTH_SPEAKING', ['bertie'], 'NO_AUTH_OPERATION', 403)
                ->willReturn($this->getMock('Symfony\Component\HttpFoundation\Response'));

            $this->helper->expects($this->never())
                ->method('render');

            $response = $this->controller->handle('bertie');
            $this->assertInstanceOf('\Symfony\Component\HttpFoundation\Response', $response);
        }

        public function handle_data()
        {
            return [
                ['foo', true, 'DEMO_GOODBYE'],
                ['bar', false, 'DEMO_HELLO'],
            ];
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

            $this->language->expects($this->once())
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
use the actual phpBB classes which are used by the controller when opening
the page. Instead
`phpunit mocks <https://phpunit.readthedocs.io/en/7.5/test-doubles.html>`_ are
injected.

These mocks allow us to check how often a method is called, what the arguments
are and let us specify the return value. This helps us to verify that **our**
controller code behaves as expected. These mocks also help prevent getting
false errors in cases where using the actual phpBB classes may behave
unexpectedly.

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
                ->with('NO_AUTH_SPEAKING', ['bertie'], 'NO_AUTH_OPERATION', 403)
                ->willReturn($this->getMock('Symfony\Component\HttpFoundation\Response'));

            $this->helper->expects($this->never())
                ->method('render');

            $response = $this->controller->handle('bertie');
            $this->assertInstanceOf('\Symfony\Component\HttpFoundation\Response', $response);
        }

.. note::

    Make sure that the name of your testing method starts with ``test``.
    Otherwise the test will not be executed by phpunit.

Data providers
--------------

In most cases we will want to provide some test data to our unit test methods.
A data provider is a method that returns an array of arrays containing input
variables and expected output variables. The inner array contains the arguments
for the ``test`` method.

.. code-block:: php

        public function handle_data()
        {
            return [
                ['foo', true, 'DEMO_GOODBYE'],
                ['bar', false, 'DEMO_HELLO'],
            ];
        }

This data provider contains two arrays of test data, so our test will be called
twice, once with the arguments:

* 'foo'
* true
* 'DEMO_GOODBYE'

and a second time with:

* 'bar'
* false
* 'DEMO_HELLO'

In the test we then tell the ``phpbb\config\config`` mock to expect to be
called only once, and to return the specified value (which is passed in as an
argument) for the ``acme_demo_goodbye`` config variable.

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
config influences the ``\phpbb\language\language::lang()`` call:

.. code-block:: php

    $l_message = empty($this->config['acme_demo_goodbye']) ? 'DEMO_HELLO' : 'DEMO_GOODBYE';
    $this->template->assign_var('DEMO_MESSAGE', $this->language->lang($l_message, $name));

This is what we check with the third argument ``$expected_language`` of our test
method:

.. code-block:: php

            $this->language->expects($this->once())
                ->method('lang')
                ->with($expected_language, $name)
                ->willReturn($language_return);

For more information about Mocks and phpunit, please have a look at the
`phpunit Documentation <https://phpunit.readthedocs.io/en/7.5/test-doubles.html>`_.

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
             verbose="true"
             bootstrap="../../../../tests/bootstrap.php"
    >
        <testsuites>
            <testsuite name="Extension Test Suite">
                <directory suffix="_test.php">./tests</directory>
                <exclude>./tests/functional</exclude>
            </testsuite>
            <testsuite name="Extension Functional Tests">
                <directory suffix="_test.php">./tests/functional/</directory>
            </testsuite>
        </testsuites>

        <filter>
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

Now we can finally run the test suite by executing the following command:

.. code-block:: sh

    $ ./phpBB/vendor/bin/phpunit -c phpBB/ext/acme/demo/phpunit.xml.dist

Results:

.. code-block:: sh

    PHPUnit 7.5.20 by Sebastian Bergmann and contributors.

    Runtime:       PHP 7.1.33 with Xdebug 2.7.2
    Configuration: /home/user/phpBB/phpBB/ext/acme/demo/phpunit.xml.dist

    ...             3 / 3 (100%)

    Time: 101 ms, Memory: 9.00Mb

    OK (3 tests, 12 assertions)

To run only the tests from one file just append the relative path to the call:

.. code-block:: sh

    $ ./phpBB/vendor/bin/phpunit -c phpBB/ext/acme/demo/phpunit.xml.dist phpBB/ext/acme/demo/tests/controller/main_test.php

Results:

.. code-block:: sh

    PHPUnit 7.5.20 by Sebastian Bergmann and contributors.

    Runtime:       PHP 7.1.33 with Xdebug 2.7.2
    Configuration: /home/user/phpBB/phpBB/ext/acme/demo/phpunit.xml.dist

    ...             3 / 3 (100%)

    Time: 92 ms, Memory: 9.00Mb

    OK (3 tests, 12 assertions)


Unit tests with database interaction
====================================

When testing your own tables and columns, you can not use the normal database
that phpBB's unit tests set up by default.

Migration with database changes
-------------------------------

Our extension has a migration file
``ext/acme/demo/migrations/add_database_changes.php``, which contains some
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
            return ['\acme\demo\migrations\add_module'];
        }

        public function update_schema()
        {
            return [
                'add_tables'		=> [
                    $this->table_prefix . 'acme_demo'	=> [
                        'COLUMNS'		=> [
                            'acme_id'			=> ['UINT', null, 'auto_increment'],
                            'acme_name'			=> ['VCHAR:255', ''],
                        ],
                        'PRIMARY_KEY'	=> 'acme_id',
                    ],
                ],
                'add_columns'	=> [
                    $this->table_prefix . 'users'			=> [
                        'user_acme'				=> ['UINT', 0],
                    ],
                ],
            ];
        }

        public function revert_schema()
        {
            return [
                'drop_columns'	=> [
                    $this->table_prefix . 'users'			=> [
                        'user_acme',
                    ],
                ],
                'drop_tables'		=> [
                    $this->table_prefix . 'acme_demo',
                ],
            ];
        }
    }

Testing database changes
------------------------

If we add a new test that checks for the existence of the table, we will see
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

        public function setUp(): void
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

When we now execute the tests again they will fail:

.. code-block:: sh

    $ ./phpBB/vendor/bin/phpunit -c phpBB/ext/acme/demo/phpunit.xml.dist
    PHPUnit 7.5.20 by Sebastian Bergmann and contributors.

    Runtime:       PHP 7.1.33 with Xdebug 2.7.2
    Configuration: /home/user/phpBB/phpBB/ext/acme/demo/phpunit.xml.dist

    ...FF             5 / 5 (100%)

    Time: 5.27 seconds, Memory: 10.75Mb

    There were 2 failures:

    1) acme\demo\tests\migrations\add_database_changes_test::test_user_acme_column
    Asserting that column "user_acme" exists
    Failed asserting that false is true.

    /home/user/phpBB/phpBB/ext/acme/demo/tests/migrations/add_database_changes_test.php:42

    2) acme\demo\tests\migrations\add_database_changes_test::test_acme_demo_table
    Asserting that column "phpbb_acme_demo" does not exist
    Failed asserting that false is true.

    /home/user/phpBB/phpBB/ext/acme/demo/tests/migrations/add_database_changes_test.php:47

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
            return ['acme/demo'];
        }

    ...

and now the test passes successfully:

.. code-block:: sh

    $ ./phpBB/vendor/bin/phpunit -c phpBB/ext/acme/demo/phpunit.xml.dist
    PHPUnit 7.5.20 by Sebastian Bergmann and contributors.

    Runtime:       PHP 7.1.33 with Xdebug 2.7.2
    Configuration: /home/user/phpBB/phpBB/ext/acme/demo/phpunit.xml.dist

    .....             5 / 5 (100%)

    Time: 5.45 seconds, Memory: 13.75Mb

    OK (5 tests, 14 assertions)

.. note::

    As you can see, the time for the test execution went up from a few
    hundred milliseconds to a few seconds. This is because database tests
    set up the database and populate it, which just takes time.

    Therefore it is recommended to only use database tests when you really need
    the database. It is better to split your test file into a database-test and
    a non-database one, to keep the run time short.

Using fixtures
--------------

Now let's make use of the fixture file to populate the database for our test.
Therefore we replace the content of the
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
            return [
                [1, 'one'],
                [2, 'two'],
            ];
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
            return ['acme/demo'];
        }

        public function test_demo_world()
        {
            $this->add_lang_ext('acme/demo', 'demo');

            $crawler = self::request('GET', 'app.php/demo/world');
            $this->assertStringContainsString($this->lang('DEMO_HELLO', 'world'), $crawler->filter('h2')->text());
        }

        public function test_demo_bertie()
        {
            $this->add_lang_ext('acme/demo', 'demo');

            $crawler = self::request('GET', 'app.php/demo/bertie');
            $this->assertStringContainsString($this->lang('NO_AUTH_SPEAKING', 'bertie'), $crawler->filter('#message p')->text());
        }
    }

Running this test, however, will fail:

.. code-block:: sh

    $ ./phpBB/vendor/bin/phpunit -c phpBB/ext/acme/demo/phpunit.xml.dist
    PHPUnit 7.5.20 by Sebastian Bergmann and contributors.

    Runtime:       PHP 7.1.33 with Xdebug 2.7.2
    Configuration: /home/user/phpBB/phpBB/ext/acme/demo/phpunit.xml.dist

    ........F             9 / 9 (100%)

    Time: 22.37 seconds, Memory: 17.25Mb

    There was 1 failure:

    1) acme\demo\tests\functional\demo_test::test_demo_bertie
    HTTP status code does not match
    Failed asserting that 403 matches expected 200.

    /home/user/phpBB/tests/test_framework/phpbb_functional_test_case.php:900
    /home/user/phpBB/tests/test_framework/phpbb_functional_test_case.php:859
    /home/user/phpBB/tests/test_framework/phpbb_functional_test_case.php:138
    /home/user/phpBB/phpBB/ext/acme/demo/tests/functional/demo_test.php:38

    FAILURES!
    Tests: 9, Assertions: 49, Failures: 1.

The reason is that the test suite compares the response for the correct format
(valid HTML, without debug errors) and a successful status code ``200``.

Therefore we need to adjust the bertie test, because we return a ``403`` status
in the controller, if someone tries to talk to bertie:

.. code-block:: php

        public function test_demo_bertie()
        {
            $this->add_lang_ext('acme/demo', 'demo');

            $crawler = self::request('GET', 'app.php/demo/bertie', [], false);
            self::assert_response_html(403);
            $this->assertStringContainsString($this->lang('NO_AUTH_SPEAKING', 'bertie'), $crawler->filter('#message p')->text());
        }

Now the tests will pass correctly:

.. code-block:: sh

    $ ./phpBB/vendor/bin/phpunit -c phpBB/ext/acme/demo/phpunit.xml.dist
    PHPUnit 7.5.20 by Sebastian Bergmann and contributors.

    Runtime:       PHP 7.1.33 with Xdebug 2.7.2
    Configuration: /home/user/phpBB/phpBB/ext/acme/demo/phpunit.xml.dist

    .........             9 / 9 (100%)

    Time: 22.11 seconds, Memory: 17.00Mb

    OK (9 tests, 52 assertions)

.. note::

    Functional tests are **slow**. Depending on your server, it might take up to
    2 seconds per page view. phpBB is installed via page views as well, which
    takes another 20 to 100 seconds, depending on various configurations, for
    the first functional tests. Subsequent functional tests **do not reinstall**
    the board, so they do not have the long setup time.

Continuous integration with Github Actions
==========================================

As a final step in this tutorial, we want to explain how to set up automated
testing of your extension using Github Actions. In order to do that, your extension must
first be set up as a project repository on `GitHub <https://github.com>`_ (free of charge
for public open source repositories).

If you need help setting up git and creating your GitHub project, please have
a look at the `Help section <https://help.github.com/>`_ on Github, particularly
the following two help topics:

* `Set Up Git <https://help.github.com/articles/set-up-git>`_
* `Create A Repo <https://help.github.com/articles/create-a-repo>`_

.. note::

    It is recommended to use the root of the extension (``ext/acme/demo``) as
    the root for the Git repository. Otherwise the scripts that phpBB provides for
    easy test execution on Travis CI will not work correctly.

    View one of phpBB's official extension repositories as an example:
    `Board Rules <https://github.com/phpbb-extensions/boardrules>`_.

Create your Github Action Workflow file
---------------------------------------

From your repository on GitHub.com, click **Add File** and select **Create new file**
and name the file ``.github/workflows/tests.yml``.

Copy the following into the ``tests.yml`` file:

.. code-block:: yaml

    name: Tests

    env:
        EXTNAME: acme/demo  # Your extension vendor/package name
        SNIFF: 1            # Run code sniffer on your code? 1 or 0
        IMAGE_ICC: 1        # Run icc profile sniffer on your images? 1 or 0
        EPV: 1              # Run EPV (Extension Pre Validator) on your code? 1 or 0
        EXECUTABLE_FILES: 1 # Run check for executable files? 1 or 0
        PHPBB_BRANCH: 3.3.x # The phpBB branch to run tests on

    on:
        push:
            branches:        # Run tests when commits are pushed to these branches in your repo
                - master
                - develop
        pull_request:        # Run tests when pull requests are made on these branches in your repo
            branches:
                - master
                - develop

    jobs:
        # START Basic Checks Job (EPV, code sniffer, images check, etc.)
        basic-checks:
            runs-on: ubuntu-20.04
            strategy:
                matrix:
                    include:
                        - php: '7.2'
                          db: "none"
                          NOTESTS: 1

            name: PHP ${{ matrix.php }} - ${{ matrix.db }}

            steps:
                - name: Checkout phpBB
                  uses: actions/checkout@v3
                  with:
                      repository: phpbb/phpbb
                      ref: ${{ env.PHPBB_BRANCH }}
                      path: phpBB3

                - name: Checkout extension
                  uses: actions/checkout@v3
                  with:
                      path: phpBB3/phpBB/ext/${{ env.EXTNAME }}

                - name: Setup PHP
                  uses: shivammathur/setup-php@v2
                  with:
                      php-version: ${{ matrix.php }}
                      extensions: dom, curl, libxml, mbstring, zip, pcntl, pdo, mysqli, sqlite, pdo_sqlite, intl, gd, exif, iconv, sqlsrv, pdo_sqlsrv, ldap
                      coverage: none

                - name: Setup environment for phpBB
                  env:
                      DB: ${{ matrix.db }}
                      PHP_VERSION: ${{ matrix.php }}
                      NOTESTS: '1'
                  run: .github/setup-phpbb.sh $DB $PHP_VERSION $NOTESTS
                  working-directory: ./phpBB3

                - name: Setup EPV
                  if: ${{ env.EPV != 0 }}
                  run: composer require phpbb/epv:dev-master --dev --no-interaction --ignore-platform-reqs
                  working-directory: ./phpBB3/phpBB

                - name: Run code sniffer
                  if: ${{ env.SNIFF != 0 }}
                  env:
                      NOTESTS: '1'
                  run: .github/ext-sniff.sh $EXTNAME $NOTESTS
                  working-directory: ./phpBB3

                - name: Check image ICC profiles
                  if: ${{ env.IMAGE_ICC != 0 }}
                  run: .github/check-image-icc-profiles.sh
                  working-directory: ./phpBB3

                - name: Check executable files
                  if: ${{ env.EXECUTABLE_FILES != 0 }}
                  run: .github/ext-check-executable-files.sh ./ $EXTNAME
                  working-directory: ./phpBB3

                - name: Run EPV
                  if: ${{ env.EPV != 0 }}
                  run: phpBB/vendor/bin/EPV.php run --dir="phpBB/ext/$EXTNAME/"
                  working-directory: ./phpBB3
        # END Basic Checks Job

        # START MySQL and MariaDB Job
        mysql-tests:
            runs-on: ubuntu-20.04
            strategy:
                matrix:
                    include:
                        - php: '7.2'
                          db: "mariadb:10.1"
                        - php: '7.2'
                          db: "mariadb:10.2"
                        - php: '7.2'
                          db: "mariadb:10.3"
                        - php: '7.2'
                          db: "mariadb:10.4"
                        - php: '7.2'
                          db: "mariadb:10.5"
                        - php: '7.2'
                          db: "mysql:5.6"
                          db_alias: "MyISAM Tests"
                          MYISAM: 1
                        - php: '7.2'
                          db: "mysql:5.6"
                        - php: '7.2'
                          db: "mysql:5.7"
                        - php: '7.3'
                          db: "mysql:5.7"
                        - php: '7.4'
                          db: "mysql:5.7"
                        - php: '7.4'
                          db: "mysql:8.0"
                        - php: '8.0'
                          db: "mysql:5.7"
                        - php: '8.1'
                          db: "mysql:5.7"
                        - php: '8.2'
                          db: "mysql:5.7"

            name: PHP ${{ matrix.php }} - ${{ matrix.db_alias != '' && matrix.db_alias || matrix.db }}

            services:
                mysql:
                    image: ${{ matrix.db }}
                    env:
                        MYSQL_ALLOW_EMPTY_PASSWORD: yes
                        MYSQL_DATABASE: phpbb_tests
                    ports:
                        - 3306:3306
                    options: >-
                        --health-cmd="mysqladmin ping"
                        --health-interval=10s
                        --health-timeout=5s
                        --health-retries=3

                redis:
                    image: redis
                    options: >-
                        --health-cmd "redis-cli ping"
                        --health-interval 10s
                        --health-timeout 5s
                        --health-retries 5
                    ports:
                        - 6379:6379

            steps:
                - name: Checkout phpBB
                  uses: actions/checkout@v3
                  with:
                      repository: phpbb/phpbb
                      ref: ${{ env.PHPBB_BRANCH }}
                      path: phpBB3

                - name: Checkout extension
                  uses: actions/checkout@v3
                  with:
                      path: phpBB3/phpBB/ext/${{ env.EXTNAME }}

                - id: database-type
                  env:
                      MATRIX_DB: ${{ matrix.db }}
                  run: |
                      db=$(echo "${MATRIX_DB%%:*}")
                      echo "db=$db" >> $GITHUB_OUTPUT

                - name: Setup PHP
                  uses: shivammathur/setup-php@v2
                  with:
                      php-version: ${{ matrix.php }}
                      extensions: dom, curl, libxml, mbstring, zip, pcntl, pdo, mysqli, sqlite, pdo_sqlite, intl, gd, exif, iconv, sqlsrv, pdo_sqlsrv, ldap
                      coverage: none

                - name: Setup environment for phpBB
                  env:
                      DB: ${{steps.database-type.outputs.db}}
                      PHP_VERSION: ${{ matrix.php }}
                      NOTESTS: '0'
                  run: .github/setup-phpbb.sh $DB $PHP_VERSION ${NOTESTS:-0}
                  working-directory: ./phpBB3

                - name: Setup database
                  env:
                      DB: ${{steps.database-type.outputs.db}}
                      MYISAM: ${{ matrix.MYISAM != 1 && '0' || '1' }}
                  run: .github/setup-database.sh $DB $MYISAM
                  working-directory: ./phpBB3

                - name: Setup PHPUnit files
                  run: mkdir -p phpBB/ext/$EXTNAME/.github && cp .github/phpunit* $_
                  working-directory: ./phpBB3

                - name: Run unit tests
                  env:
                      DB: ${{steps.database-type.outputs.db}}
                  run: phpBB/vendor/bin/phpunit --configuration phpBB/ext/$EXTNAME/.github/phpunit-$DB-github.xml --bootstrap ./tests/bootstrap.php
                  working-directory: ./phpBB3
        # END MySQL and MariaDB Job

        # START PostgreSQL Job
        postgres-tests:
            runs-on: ubuntu-20.04
            strategy:
                matrix:
                    include:
                        - php: '7.2'
                          db: "postgres:9.5"
                        - php: '7.2'
                          db: "postgres:9.6"
                        - php: '7.2'
                          db: "postgres:10"
                        - php: '7.2'
                          db: "postgres:11"
                        - php: '7.2'
                          db: "postgres:12"
                        - php: '7.2'
                          db: "postgres:13"
                        - php: '7.3'
                          db: "postgres:13"
                        - php: '7.4'
                          db: "postgres:13"
                        - php: '8.0'
                          db: "postgres:12"
                        - php: '8.0'
                          db: "postgres:13"
                        - php: '8.1'
                          db: "postgres:14"
                        - php: '8.2'
                          db: "postgres:14"

            name: PHP ${{ matrix.php }} - ${{ matrix.db }}

            services:
                postgres:
                    image: ${{ matrix.db != 'postgres:9.5' && matrix.db != 'postgres:9.6' && matrix.db != 'postgres:10' && matrix.db != 'postgres:11' && matrix.db != 'postgres:12' && matrix.db != 'postgres:13' && 'postgres:10' || matrix.db }}
                    env:
                        POSTGRES_HOST: localhost
                        POSTGRES_USER: postgres
                        POSTGRES_PASSWORD: postgres
                    ports:
                        - 5432:5432
                    options: >-
                        -v /var/run/postgresql:/var/run/postgresql
                        --health-cmd pg_isready
                        --health-interval 10s
                        --health-timeout 5s
                        --health-retries 5

                redis:
                    image: redis
                    options: >-
                        --health-cmd "redis-cli ping"
                        --health-interval 10s
                        --health-timeout 5s
                        --health-retries 5
                    ports:
                        - 6379:6379

            steps:
                - name: Checkout phpBB
                  uses: actions/checkout@v3
                  with:
                      repository: phpbb/phpbb
                      ref: ${{ env.PHPBB_BRANCH }}
                      path: phpBB3

                - name: Checkout extension
                  uses: actions/checkout@v3
                  with:
                      path: phpBB3/phpBB/ext/${{ env.EXTNAME }}

                - id: database-type
                  env:
                      MATRIX_DB: ${{ matrix.db }}
                  run: |
                      db=$(echo "${MATRIX_DB%%:*}")
                      echo "db=$db" >> $GITHUB_OUTPUT

                - name: Setup PHP
                  uses: shivammathur/setup-php@v2
                  with:
                      php-version: ${{ matrix.php }}
                      extensions: dom, curl, libxml, mbstring, zip, pcntl, pdo, mysqli, sqlite, pdo_sqlite, intl, gd, exif, iconv, sqlsrv, pdo_sqlsrv, ldap
                      coverage: none

                - name: Setup environment for phpBB
                  env:
                      DB: ${{steps.database-type.outputs.db}}
                      PHP_VERSION: ${{ matrix.php }}
                      NOTESTS: '0'
                  run: .github/setup-phpbb.sh $DB $PHP_VERSION ${NOTESTS:-0}
                  working-directory: ./phpBB3

                - name: Setup database
                  env:
                      DB: ${{steps.database-type.outputs.db}}
                      MYISAM: '0'
                  run: .github/setup-database.sh $DB $MYISAM
                  working-directory: ./phpBB3

                - name: Setup PHPUnit files
                  run: mkdir -p phpBB/ext/$EXTNAME/.github && cp .github/phpunit* $_
                  working-directory: ./phpBB3

                - name: Run unit tests
                  env:
                      DB: ${{steps.database-type.outputs.db}}
                  run: phpBB/vendor/bin/phpunit --configuration phpBB/ext/$EXTNAME/.github/phpunit-$DB-github.xml --bootstrap ./tests/bootstrap.php
                  working-directory: ./phpBB3
        # END PostgreSQL Job

        # START Other Tests Job (SQLite 3 and mssql)
        other-tests:
            runs-on: ubuntu-20.04
            strategy:
                matrix:
                    include:
                        - php: '7.2'
                          db: "sqlite3"
                        - php: '7.2'
                          db: "mcr.microsoft.com/mssql/server:2017-latest"
                          db_alias: 'MSSQL 2017'
                        - php: '7.2'
                          db: "mcr.microsoft.com/mssql/server:2019-latest"
                          db_alias: 'MSSQL 2019'

            name: PHP ${{ matrix.php }} - ${{ matrix.db_alias != '' && matrix.db_alias || matrix.db }}

            services:
                mssql:
                    image: ${{ matrix.db != 'mcr.microsoft.com/mssql/server:2017-latest' && matrix.db != 'mcr.microsoft.com/mssql/server:2019-latest' && 'mcr.microsoft.com/mssql/server:2017-latest' || matrix.db }}
                    env:
                        SA_PASSWORD: "Pssw0rd_12"
                        ACCEPT_EULA: "y"
                    ports:
                        - 1433:1433
                    options: >-
                        --health-cmd="/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'Pssw0rd_12' -Q \"Use [master]; CREATE DATABASE [phpbb_tests] COLLATE Latin1_General_CI_AS\" || exit 1"
                        --health-interval 10s
                        --health-timeout 5s
                        --health-retries 5
                        --health-start-period 10s

                redis:
                    image: redis
                    options: >-
                        --health-cmd "redis-cli ping"
                        --health-interval 10s
                        --health-timeout 5s
                        --health-retries 5
                    ports:
                        - 6379:6379

            steps:
                - name: Checkout phpBB
                  uses: actions/checkout@v3
                  with:
                      repository: phpbb/phpbb
                      ref: ${{ env.PHPBB_BRANCH }}
                      path: phpBB3

                - name: Checkout extension
                  uses: actions/checkout@v3
                  with:
                      path: phpBB3/phpBB/ext/${{ env.EXTNAME }}

                - id: database-type
                  env:
                      MATRIX_DB: ${{ matrix.db }}
                  run: |
                      if [ $MATRIX_DB == 'mcr.microsoft.com/mssql/server:2017-latest' ] || [ $MATRIX_DB == 'mcr.microsoft.com/mssql/server:2019-latest' ]
                      then
                          db='mssql'
                      else
                          db=$(echo "${MATRIX_DB%%:*}")
                      fi
                      echo "db=$db" >> $GITHUB_OUTPUT

                - name: Setup PHP
                  uses: shivammathur/setup-php@v2
                  with:
                      php-version: ${{ matrix.php }}
                      extensions: dom, curl, libxml, mbstring, zip, pcntl, pdo, mysqli, sqlite, pdo_sqlite, intl, gd, exif, iconv, sqlsrv, pdo_sqlsrv, ldap
                      coverage: none

                - name: Setup environment for phpBB
                  env:
                      DB: ${{steps.database-type.outputs.db}}
                      PHP_VERSION: ${{ matrix.php }}
                      NOTESTS: '0'
                  run: .github/setup-phpbb.sh $DB $PHP_VERSION ${NOTESTS:-0}
                  working-directory: ./phpBB3

                - name: Setup database
                  env:
                      DB: ${{steps.database-type.outputs.db}}
                      MYISAM: '0'
                  run: .github/setup-database.sh $DB $MYISAM
                  working-directory: ./phpBB3

                - name: Setup PHPUnit files
                  run: mkdir -p phpBB/ext/$EXTNAME/.github && cp .github/phpunit* $_
                  working-directory: ./phpBB3

                - name: Run unit tests
                  env:
                      DB: ${{steps.database-type.outputs.db}}
                  run: phpBB/vendor/bin/phpunit --configuration phpBB/ext/$EXTNAME/.github/phpunit-$DB-github.xml --bootstrap ./tests/bootstrap.php
                  working-directory: ./phpBB3
        # END Other Tests Job

.. note::

    You must change the ``EXTNAME`` variable to your extension's name (as you defined it in
    your composer.json file) in the ``env`` section at the top of this file:

    .. code-block:: yaml

        env:
            EXTNAME: acme/demo  # Your extension vendor/package name
            SNIFF: 1            # Run code sniffer on your code? 1 or 0
            IMAGE_ICC: 1        # Run icc profile sniffer on your images? 1 or 0
            EPV: 1              # Run EPV (Extension Pre Validator) on your code? 1 or 0
            EXECUTABLE_FILES: 1 # Run check for executable files? 1 or 0
            PHPBB_BRANCH: 3.3.x # The phpBB branch to run tests on

To save and run your workflow, scroll to the bottom of the page and select
**Create a new branch for this commit and start a pull request**. Then, to create a pull
request, click **Propose new file**. After you merge this pull request, all future
commits and pull requests on your master branch will trigger this CI workflow and
your unit, database and functional tests will be executed.

Customising Your Test Workflow
------------------------------

You'll notice the ``env`` section of the workflow has options where you can enable or
disable basic tests such as the EPV, Code Sniffer, checking any images in your extension
for ICC profiles and checking for executable text files by changing their variables to
either 1 or 0.

You can also set the version of phpBB you want your extension tested in using the
``PHPBB_BRANCH`` variable. This tutorial is using the current version of phpBB which
is the 3.3.x branch. Older branches of phpBB are not being supported with Github Actions,
but can instead be used with `Travis-CI.com <https://travis-ci.com>`_ .

Finally you may also make changes to the jobs. This tutorial's workflow is split up into several
jobs based on the databases being tested:

* Basic Checks: The ``basic-checks`` job does not do any PHPUnit testing. This is where EPV, Code Sniffer and Image Profile checks run. If you never intend to run these checks you may either delete or comment out the entire ``basic-checks`` job.

* MySQL Tests: The ``mysql-tests`` job runs PHPUnit tests in various MySQL and MariaDB and PHP combinations. They are all defined in the ``matrix`` section. This workflow only runs in versions of PHP 7 and PHP 8 but you could, for example, add tests for versions of PHP 5. (Note that to include PHP 5 in the test matrix you must change the ubuntu server for that job to ``runs-on: ubuntu-16.04``). You may delete or comment out some of the tests in the matrix if you do not want to test certain versions of PHP or MySQL or MariaDB.

* PostgreSQL Tests: The ``postgres-tests`` job runs PHPUnit tests in various versions of PostgreSQL. The PHP version is consistent throughout since the mysql-checks job is where we do most of our PHP environment checks. You may add additional checks to this matrix or you may either delete or comment out the entire ``postgres-tests`` job if you do not intend to test PostgreSQL.

* MSSQL, SQLite: The ``other-tests`` job runs PHPUnit tests in various versions of MSSQL and SQLite3. You may either delete or comment out the MSSQL or SQLite3 checks in the matrix if you do not want to test on either of those databases, or delete or comment out the entire ``other-tests`` job if you do not intend to test any of these databases.

Final Thoughts on Extension Testing
-----------------------------------

Well written tests help prevent regressions (breaking other parts of your code)
by alerting you to any problems resulting from changes to your code while fixing bugs,
adding new features and other code changes to your extension.

If your tests fail after committing changes, you will receive a notification email
from GitHub. The logs from your Github Actions can be a little daunting at first,
but once you get used to reading them they can help you pinpoint unforeseen bugs
and regressions in your code that must be fixed.

Github Actions also provides Build Status badges. They provide you the code in markdown
format so you can add the badge to your repository's README so visitors can see
the build status of your extension. For example (Just change ``GITHUB-USERNAME/REPO-NAME``
to your repository):

    .. code-block:: text

    [![Build Status](https://github.com/GITHUB-USERNAME/REPO-NAME/workflows/Tests/badge.svg)](https://github.com/GITHUB-USERNAME/REPO-NAME/actions)
