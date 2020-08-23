==========
UI Testing
==========

UI tests extend functional tests by also supporting the execution of JavaScript
and jQuery in addition to HTML only execution. They should be used in cases
where functionality that is only executed with jQuery or JS should be tested.
phpBB allows you to write such tests. This document will tell you how.

Running UI Tests
================

Information on how to run ui tests is available in the GitHub repository at
`<https://github.com/phpbb/phpbb/blob/3.3.x/tests/RUNNING_TESTS.md>`_. You
can switch the branch to check instructions for a specific version of phpBB.

Writing UI Tests
========================

Your test case will have to inherit from the ``phpbb_ui_test_case``
class. You will be able to make requests to a fresh phpBB installation. Also,
be sure to put the file into the ``tests/ui/`` folder and to add the
``@group ui`` doc block above the class, so the tests are correctly
executed.

.. code-block:: php

    <?php
    // tests/ui/my_test.php

    /**
     * @group ui
     */
    class phpbb_ui_my_test extends phpbb_ui_test_case
    {
        public function setUp()
        {
            parent::setUp();
            // setup code
        }

        public function test_index()
        {
            // test code
        }
    }


There is a ``setUp()`` method where you can put code that is run before the
test. Here you can set up some objects after the installation that are required
for your test. Then you can define your tests, just as you would normally, by
prefixing methods with ``test_``. In this case we will be testing the index.

WebDriver and Assertions
------------------------

The UI testing framework is built using `Facebook's PHP WebDriver <https://github.com/facebook/php-webdriver>`_,
which makes HTTP requests and allows us to interact with the page. The remote WebDriver
is available in your tests through ``$this->visit($url)``. Alternatively, you can also
use it directly via ``$this->getDriver()``.
The PHP WebDriver does offer a wiki with several examples on how to use the WebDriver:
`PHP WebDriver Wiki <https://github.com/facebook/php-webdriver/wiki>`_

Here is an example of using the WebDriver:

.. code-block:: php

    <?php
    // tests/ui/my_test.php

    /**
     * @group ui
     */
    class phpbb_ui_my_test extends phpbb_ui_test_case
    {
        public function test_index()
        {
            $this->visit('index.php');
            $this->assertGreaterThan(0, count($this->getDriver()->findElements(WebDriverBy::cssSelector('.topiclist'))));
        }
    }

We perform a GET request to ``index.php``, then find elements that fit into the
CSS selector. Then we make sure our query matched something.

If the board's index page were broken, our test would catch this, allowing us
to detect the issue and fix it. The more things you test, the more breakages
you will catch early.

Authentication
--------------

Many ui tests will require the user to be logged in. To do so, you can
use the ``login()`` and ``admin_login()`` methods inherited from the ``phpbb_ui_test_case``
class. This method will assign the user's SID to the inherited class property
``$this->sid``. You will need to append this to the URLs that the logged-in
user will be navigating to in order to hold the session. For usage examples,
view the permission roles test in
`tests/ui/permission_roles_test.php <https://github.com/phpbb/phpbb/blob/3.3.x/tests/ui/permission_roles_test.php>`_.

Localisation
------------

In tests, as in phpBB itself, do not use hard-coded language unless absolutely
necessary. Instead, use the ``$this->add_lang()`` and ``$this->lang()``
methods. Both act very similarly to their counterparts in the ``\phpbb\user``
class. Note that ``language/en/common.php`` is automatically loaded by the test
framework.

.. code-block:: php

    public function test_example()
    {
        // include the file at ./phpBB/language/en/ucp.php
        $this->add_lang('ucp');

        // we can also include multiple ones:
        $this->add_lang(['memberlist', 'mcp']);

        // Let's use a language key
        $this->assertEquals('Login', $this->lang('LOGIN'));

        // And let's use a language key formatted for use with sprintf
        $this->assertEquals('Logout [ user ]', $this->lang('LOGOUT_USER', 'user'));
    }

For more usage examples, please view
`tests/ui/permission_roles_test.php <https://github.com/phpbb/phpbb/blob/3.3.x/tests/ui/permission_roles_test.php>`_.
