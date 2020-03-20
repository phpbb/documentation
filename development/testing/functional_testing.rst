==================
Functional Testing
==================

Functional tests test software the way a user would. They simulate a user
browsing the website, but they do these steps in an automated way. phpBB
allows you to write such tests. This document will tell you how.

Running Functional Tests
========================

Information on how to run tests is available in the GitHub repository at
`<https://github.com/phpbb/phpbb/blob/3.2.x/tests/RUNNING_TESTS.md>`_. You
can switch the branch to check instructions for a specific version of phpBB.

Writing Functional Tests
========================

Your test case will have to inherit from the ``phpbb_functional_test_case``
class. You will be able to make requests to a fresh phpBB installation. Also,
be sure to put the file into the ``tests/functional/`` folder and to add the
``@group functional`` doc block above the class, so the tests are correctly
executed.

.. code-block:: php

    <?php
    // tests/functional/my_test.php

    /**
     * @group functional
     */
    class phpbb_functional_my_test extends phpbb_functional_test_case
    {
        public function bootstrap()
        {
            // setup code
        }

        public function test_index()
        {
            // test code
        }
    }


There is a ``bootstrap()`` method where you can put code that is run before the
test. Here you can set up some objects after the installation that are required
for your test. Then you can define your tests, just as you would normally, by
prefixing methods with ``test_``. In this case we will be testing the index.

Goutte and Assertions
---------------------

The functional testing framework is built using
`Goutte <https://github.com/fabpot/Goutte>`_, which makes HTTP requests and
allows us to interact with the page. The Goutte "client" is available in your
tests through ``$this->request($method, $path)``. Alternatively you can also
access it directly through ``$this->client``.

When calling ``request()``, you will get a crawler, which allows you to fetch
parts of the page using CSS selectors. Here is an example:

.. code-block:: php

    <?php
    // tests/functional/my_test.php

    /**
     * @group functional
     */
    class phpbb_functional_my_test extends phpbb_functional_test_case
    {
        public function test_index()
        {
            $crawler = $this->request('GET', 'index.php');
            $this->assertGreaterThan(0, $crawler->filter('.topiclist')->count());
        }
    }


We perform a GET request to ``index.php``, then apply a CSS filter, querying
for the .topiclist class. Then we make sure our query matched something.

If the board's index page were broken, our test would catch this, allowing us
to detect the issue and fix it. The more things you test, the more breakages
you will catch early.

For more information what you can do with Goutte, check out the
`GitHub project <https://github.com/fabpot/Goutte>`_,
`Ryan Weaver's Goutte tutorial <http://www.phparch.com/2010/04/four-new-php-5-3-components-and-goutte-a-simple-web-scraper/>`_
and `Symfony's testing documentation <http://symfony.com/doc/2.0/book/testing.html#the-test-client>`_.

Authentication
--------------

Many functional tests will require the user to be logged in. To do so, you can
use the ``login()`` method inherited from the ``phpbb_functional_test_case``
class. This method will assign the user's SID to the inherited class property
``$this->sid``. You will need to append this to the URLs that the logged-in
user will be navigating to in order to hold the session. For usage examples,
view the logout test in
`tests/functional/auth_test.php <https://github.com/phpbb/phpbb/blob/3.2.x/tests/functional/auth_test.php>`_.

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
`tests/functional/lang_test.php <https://github.com/phpbb/phpbb/blob/3.2.x/tests/functional/lang_test.php>`_.
