============
Unit Testing
============

Unit tests simply verify that specific portions of the source code work
properly. These tests are located in the main phpBB repository at ``tests/``
and are grouped into folders based on commonality between the functionality
they are testing. For instance, tests that are meant to test the config will
be in ``tests/config/``.

Running Unit Tests
==================

Information on how to run tests is available in the GitHub repository at
`<https://github.com/phpbb/phpbb/blob/3.1.x/tests/RUNNING_TESTS.md>`_. You
can switch the branch to check instructions for a specific version of phpBB.

Writing Unit Tests
==================

Files that contain tests should have a ``_test`` suffix, e.g.:
``tests/demo/demo_test.php``

Within unit tests, there are two categories: tests that need a database, and
those that do not. **If a test does not need a database then don't use it!**

Without a Database
------------------

.. code-block:: php

    <?php
    // tests/demo/demo_test.php

    require_once dirname(__FILE__) . '/../phpBB/includes/functions.php';

    class phpbb_demo_demo_test extends phpbb_test_case
    {
        public function phpbb_email_hash_data()
        {
            return array(
                array('wiki@phpbb.com', 126830126620),
                array('', 0),
            );
        }

        /**
         * @dataProvider phpbb_email_hash_data
         */
        public function test_phpbb_email_hash($email, $expected)
        {
            $this->assertEquals($expected, phpbb_email_hash($email));
        }
    }

You may have noted, that in the test-function there is actually no data.
There's a dataProvider-function stated in the comment, which is used for the
test. The test is then run with every array in the dataProvider array, having
the values as parameters for the test-function-call.

Using a Database
----------------

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

    class phpbb_demo_db_demo_test extends phpbb_database_test_case
    {
        public function getDataSet()
        {
            return $this->createXMLDataSet(dirname(__FILE__) . '/fixtures/three_users.xml');
        }

        public function fetchrow_data()
        {
            return array(
                array('', array(array('username_clean' => 'barfoo'),
                    array('username_clean' => 'foobar'),
                    array('username_clean' => 'bertie'))),
                array('user_id = 2', array(array('username_clean' => 'foobar'))),
                array("username_clean = 'bertie'", array(array('username_clean' => 'bertie'))),
                array("username_clean = 'phpBB'", array()),
            );
        }

        /**
         * @dataProvider fetchrow_data
         */
        public function test_fetchrow($where, $expected)
        {
            // The function from phpbb_test_case_helpers returns a new db for every test.
            $db = $this->new_dbal();

            $result = $db->sql_query('SELECT username_clean
                FROM phpbb_users
                ' . (($where) ? ' WHERE ' . $where : '') . '
                ORDER BY user_id ASC');

            $ary = array();
            while ($row = $db->sql_fetchrow($result))
            {
                $ary[] = $row;
            }
            $db->sql_freeresult($result);

            $this->assertEquals($expected, $ary);
        }
    }

Most important to know for db-tests is:

1. All data from the database is truncated first.
2. The data from the getDataSet function is loaded into the database. **No data from any other test is available!**
3. If you use a table that has a column which has no default value specified (such as text columns), be sure to specify them. (see `PHPBB3-10667 <http://tracker.phpbb.com/browse/PHPBB3-10667>`_)

Code of a DB-DataSet
--------------------

.. code-block:: xml

    <?xml version="1.0" encoding="UTF-8" ?>
    <dataset>
        <table name="table_name">
            <column>column_name_1</column>
            <column>column_name_2</column>
            <row>
                <value>value for column 1</value>
                <value>value for column 2</value>
            </row>
            <row>
                <value>another row, value for column 1</value>
                <value>another row, value for column 2</value>
            </row>
        </table>
    </dataset>


Using permissions ($auth)
-------------------------

When you need to use the auth class, you should use a mock object for it. Here
is a short example of how to use it. Please note, that you need to specify the
result for every function and all values you use. Also when the forum_id is
not casted to int, you need to specify a second row for each permission.
(Marked with ``// Called without int cast`` below)
For more information how these test doubles work, see:
`<https://phpunit.de/manual/current/en/test-doubles.html>`_

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

    require_once dirname(__FILE__) . '/../phpBB/includes/auth.php';

    class phpbb_demo_demo_test extends phpbb_test_case
    {
        public function test_auth_mock_hash($email, $expected)

            $auth = $this->getMock('auth');
            $acl_get_map = array(
                array('f_read', 23, true),
                array('f_read', '23', true),// Called without int cast
                array('m_', 23, true),
                array('m_', '23', true),// Called without int cast
            );

            $auth->expects($this->any())
                ->method('acl_get')
                ->with($this->stringContains('_'),
                    $this->anything())
                ->will($this->returnValueMap($acl_get_map));
            $this->assertTrue($auth->acl_get('f_read', 23));
            $this->assertTrue($auth->acl_get('f_read', '23'));
            $this->assertFalse($auth->acl_get('f_read', 12));
            $this->assertFalse($auth->acl_get('f_read', '12'));
        }
    }
