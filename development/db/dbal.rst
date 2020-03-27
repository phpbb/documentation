==========================
Database Abstraction Layer
==========================

phpBB uses a **D**\ ata\ **B**\ ase **A**\ bstraction **L**\ ayer to access the database instead of directly calling e.g. `mysql_query <http://php.net/manual/en/function.mysql-query.php>`_ functions.
You usually access the :abbr:`DBAL (Database Abstraction Layer)` using the global variable ``$db``.
This variable is included from :class:`common.php` through :class:`includes/compatibility_globals.php`:

.. code-block:: php

    /** @var \phpbb\db\driver\driver_interface $db */
    $db = $phpbb_container->get('dbal.conn');

Some database functions are within the base driver and others are within specific database drivers.
Each function below will indicate whether it is defined in the base driver or in each specific driver.
The *MySQLi* specific database driver will be used in the examples throughout this page.
|br| All drivers are located in the :class:`\\phpbb\\db\\driver` namespace.
|br| Base driver is located at :class:`\\phpbb\\db\\driver\\driver.php`
|br| Specific driver is located at :class:`\\phpbb\\db\\driver\\mysqli.php`

Connecting and disconnecting
============================
Use these methods only if you cannot include :class:`common.php` (to connect) or run ``garbage_collection()`` (to disconnect; you may also use other functions that run this function, for example ``page_footer()``).

sql_connect
-----------
Connects to the database. Defined in the specific drivers.

Example:

.. code-block:: php

    // We're using bertie and bertiezilla as our example user credentials.
    // You need to fill in your own ;D
    $db = new \phpbb\db\driver\mysqli();
    $db->sql_connect('localhost', 'bertie', 'bertiezilla', 'phpbb', '', false, false);

Example using :class:`config.php`:

.. code-block:: php

    // Extract the config.php file's data
    $phpbb_config_php_file = new \phpbb\config_php_file($phpbb_root_path, $phpEx);
    extract($phpbb_config_php_file->get_all());

    $db = new $dbms();
    $db->sql_connect($dbhost, $dbuser, $dbpasswd, $dbname, $dbport, false, false);

    // We do not need this any longer, unset for safety purposes
    unset($dbpasswd);

Parameters
++++++++++

.. csv-table::
   :header: "Parameter", "Usage"
   :delim: #

   Host # The host of the database. |br| When using config.php you should use $dbhost instead.
   Database User # The database user to connect to the database. |br| When using config.php you should use $dbuser instead.
   Database Password # The password for the user to connect to the database. |br| When using config.php you should use $dbpasswd instead.
   Database Name # The database where the phpBB tables are located. |br| When using config.php you should use $dbname instead.
   Database Port (optional) # The port to the database server. |br| Leave empty/false to use the default port. |br| When using config.php you should use $dbport instead.
   Persistence (optional) # Database connection persistence, defaults to false.
   New Link (optional) # Use a new connection to the database for this instance of the DBAL. |br| Defaults to false.

sql_close
---------
Disconnects from the DB. Defined in the base driver (``_sql_close`` is defined in the specific drivers).

Example: ``$db->sql_close();``

Preparing SQL queries
========================

sql_build_query
---------------
Builds a full SQL statement from an array.
This function should be used if you need to JOIN on more than one table to ensure the resulting statement works on all supported databases. Defined in the base driver.

Possible types of queries: SELECT, SELECT_DISTINCT.
|br| Required keys are SELECT and FROM.
|br| Optional keys are LEFT_JOIN, WHERE, GROUP_BY and ORDER_BY.

Example:

.. code-block:: php

    // Array with data for the full SQL statement
    $sql_array = [
    	'SELECT'    => 'f.*, ft.mark_time',

    	'FROM'      => [
    		FORUMS_WATCH_TABLE  => 'fw',
    		FORUMS_TABLE        => 'f',
    	],

    	'LEFT_JOIN' => [
    		[
    			'FROM'  => [FORUMS_TRACK_TABLE => 'ft'],
    			'ON'    => 'ft.forum_id = f.forum_id
    				AND ft.user_id = ' . (int) $user->data['user_id'],
    		],
    	],

    	'WHERE'     => 'f.forum_id = fw.forum_id
    		AND fw.user_id = ' . (int) $user->data['user_id'],

    	'ORDER_BY'  => 'f.left_id',
    ];

    // Build the SQL statement
    $sql = $db->sql_build_query('SELECT', $sql_array);

    // Now run the query...
    $result = $db->sql_query($sql);

Parameters
++++++++++
.. csv-table::
   :header: "Parameter", "Usage"
   :delim: #

   Query Type # Type of query which needs to be created (SELECT, SELECT_DISTINCT)
   Associative array # An associative array with the items to add to the query. |br| SELECT and FROM are required. |br| LEFT_JOIN, WHERE, GROUP_BY and ORDER_BY are optional.

sql_build_array
---------------
Builds part of a SQL statement from an array. Possible types of queries: INSERT, INSERT_SELECT, UPDATE, SELECT. Defined in the base driver.

Example:

.. code-block:: php

    // Array with the data to build
    $data = [
    	'username' 	=> 'Bertie',
    	'email' 	=> 'bertie@example.com',
    ];

    // First executing a SELECT query.
    // Note: By using the SELECT type, it always uses AND in the conditions.
    $sql = 'SELECT user_password
    	FROM ' . USERS_TABLE . '
    	WHERE ' . $db->sql_build_array('SELECT', $data);
    $result = $db->sql_query($sql);

    // And executing an UPDATE query: (Using the same data as for SELECT)
    $sql = 'UPDATE ' . USERS_TABLE . '
    	SET ' . $db->sql_build_array('UPDATE', $data) . '
    	WHERE user_id = ' . (int) $user_id;
    $db->sql_query($sql);

    // And lastly, executing an INSERT query
    $sql = 'INSERT INTO ' . USERS_TABLE . ' ' . $db->sql_build_array('INSERT', $data);
    $db->sql_query($sql);

Parameters
++++++++++
.. csv-table::
   :header: "Parameter", "Usage"
   :delim: #

   Query Type # Type of query which needs to be created (UPDATE, INSERT, INSERT_SELECT or SELECT)
   Associative array (optional) # An associative array with the items to add to the query. |br| The key of the array is the field name, the value of the array is the value for that field. |br| If left empty, ''false'' will be returned.

sql_in_set
----------
Builds IN, NOT IN, = and <> sql comparison string.  Defined in the base driver.

Example:

.. code-block:: php

    $sql_in = [2, 58, 62];

    $sql = 'SELECT *
    	FROM ' . USERS_TABLE . '
    	WHERE ' . $db->sql_in_set('user_id', $sql_in);


Parameters
++++++++++
.. csv-table::
   :header: "Parameter", "Usage"
   :delim: |

   Column | Name of the sql column that shall be compared
   Array | Array of values that are allowed (IN) or not allowed (NOT IN)
   Negate (Optional) | true for NOT IN (), false for IN () (default)
   Allow empty set (Optional) | If true, allow $array to be empty, this function will return 1=1 or 1=0 then. Default to false.

sql_escape
----------

Escapes a string in a SQL query. ``sql_escape`` is different for every DBAL driver and written specially for that driver, to be sure all characters that need escaping are escaped. Defined in the specific drivers.

Example:

.. code-block:: php

    $sql = 'SELECT *
    	FROM ' . POSTS_TABLE . '
    	WHERE post_id = ' . (int) $integer . "
    		AND post_text = '" . $db->sql_escape($string) . "'";

Parameters
++++++++++
.. csv-table::
   :header: "Parameter", "Usage"
   :delim: |

   String | The string that needs to be escaped.

sql_like_expression
-------------------
Correctly adjust LIKE statements for special characters.
This should be used to ensure the resulting statement works on all databases.
Defined in the base driver (``_sql_like_expression`` is defined in the specific drivers).

The ``sql_not_like_expression`` is identical to ``sql_like_expression`` apart from that it builds a NOT LIKE statement.

Parameters
++++++++++
.. csv-table::
   :header: "Parameter", "Usage"
   :delim: |

   Expression | The expression to use. Every wildcard is escaped, except $db->get_any_char() and $db->get_one_char()

get_one_char
++++++++++++
Wildcards for matching exactly one (``_``) character within LIKE expressions.

get_any_char
++++++++++++
Wildcards for matching any (``%``) character within LIKE expressions

Example:

.. code-block:: php

    $username = 'Bert';

    // Lets try to find "Bertie"
    $sql = 'SELECT username, user_id, user_colour
    	FROM ' . USERS_TABLE . '
    	WHERE username_clean ' . $db->sql_like_expression(utf8_clean_string($username) . $db->get_any_char());
    $result = $db->sql_query($sql);

sql_lower_text
--------------
For running LOWER on a database text column, so it returns lowered text strings. Defined in the base driver.

Example:

.. code-block:: php

    $keyword = 'Bertie';
    $keyword = strtolower($keyword);

    $like = $db->sql_like_expression($db->get_any_char() . $keyword . $db->get_any_char());

    $sql = 'SELECT *
    	FROM ' . LOGS_TABLE . '
    	WHERE ' . $db->sql_lower_text('log_data') . ' ' . $like;
    $result = $db->sql_query_limit($sql, 10);

Parameters
++++++++++
.. csv-table::
   :header: "Parameter", "Usage"
   :delim: |

   Column name | The column name to LOWER the value for.

Running SQL queries
===================

sql_query
---------
For selecting basic data from the database, the function ``sql_query()`` is enough. If you want to use any variable in your query, you should use (if it isn't an integer) ``$db->sql_escape()`` to be sure the data is safe. Defined in the specific drivers.

Example:

.. code-block:: php

    $integer = 0;
    $string = "This is ' some string";

    $sql = 'SELECT *
    	FROM ' . POSTS_TABLE . '
    	WHERE post_id = ' . (int) $integer . "
    		AND post_text = '" . $db->sql_escape($string) . "'";
    $result = $db->sql_query($sql);


Parameters
++++++++++
.. csv-table::
   :header: "Parameter", "Usage"
   :delim: |

   Query | Contains the SQL query which shall be executed
   Cache (Optional) | Either 0 to avoid caching or the time in seconds which the result shall be kept in cache.

sql_query_limit
---------------
Gets/changes/deletes only selected number of rows. Defined in the base driver (``_sql_query_limit`` is defined in the specific drivers).

Example:

.. code-block:: php

    $start = 25;

    $sql = 'SELECT *
    	FROM ' . POSTS_TABLE . '
    	WHERE topic_id = 1045';
    $result = $db->sql_query_limit($sql, $config['topics_per_page'], $start);


Parameters
++++++++++
.. csv-table::
   :header: "Parameter", "Usage"
   :delim: |

   Query | Contains the SQL query which shall be executed.
   Total | Number of rows which should be selected,
   Offset (Optional) | Number of rows should be skipped before starting selecting rows.
   Cache (Optional) | Either 0 to avoid caching or the time in seconds which the result shall be kept in cache.

sql_multi_insert
----------------
Builds and runs more than one INSERT statement. Defined in the base driver.

Example:

.. code-block:: php

    // Users which will be added to group
    $users = [11, 57, 87, 98, 154, 211];
    $sql_ary = [];

    foreach ($users as $user_id)
    {
    	$sql_ary[] = [
    		'user_id'	=> (int) $user_id,
    		'group_id'	=> 154,
    		'group_leader'	=> 0,
    		'user_pending'	=> 0,
    	];
    }

    $db->sql_multi_insert(USER_GROUP_TABLE, $sql_ary);


Parameters
++++++++++
.. csv-table::
   :header: "Parameter", "Usage"
   :delim: |

   Table name | Table name to run the statements on.
   Data | Multi-dimensional array holding the statements data.

Methods useful after running INSERT and UPDATE queries
======================================================
All methods in this part of article are defined in the specific drivers.

sql_affectedrows
----------------
Get the number of affected rows by the last INSERT, UPDATE, REPLACE or DELETE query.

Example:

.. code-block:: php

    $sql = 'DELETE FROM ' . TOPICS_TRACK_TABLE . "
    	WHERE user_id = {$user->data['user_id']}";
    $db->sql_query($sql);

    $affected_rows = $db->sql_affectedrows();

sql_nextid
----------
Retrieves the ID generated for an AUTO_INCREMENT column by the previous INSERT query.

Example:

.. code-block:: php

    $sql = 'INSERT INTO ' . USERS_TABLE . ' ' . $db->sql_build_array('INSERT', $user_ary);
    $db->sql_query($sql);

    $user_id = $db->sql_nextid();

Methods useful after running SELECT queries
===========================================

sql_fetchfield
--------------
Fetches field. Defined in the base driver.

Example:

.. code-block:: php

    $sql = 'SELECT COUNT(post_id) AS num_posts
    	FROM ' . POSTS_TABLE . "
    	WHERE topic_id = $topic_id
    		AND post_time >= $min_post_time
    		" . (($auth->acl_get('m_approve', $forum_id)) ? '' : 'AND post_approved = 1');
    $result = $db->sql_query($sql);

    $total_posts = (int) $db->sql_fetchfield('num_posts');


Parameters
++++++++++
.. csv-table::
   :header: "Parameter", "Usage"
   :delim: #

   Field # Name of the field that needs to be fetched.
   Row number (Optional) # If false, the current row is used, else it is pointing to the row (zero-based).
   Result (Optional) # The result that is being evaluated. |br| This result comes from a call to the sql_query method. |br| If left empty the last result will be called.

sql_fetchrowset
---------------
Returns an array with the result of using the ``sql_fetchrow`` method on every row. Defined in the base driver.


Parameters
++++++++++
.. csv-table::
   :header: "Parameter", "Usage"
   :delim: #

   Result (Optional) # The result that is being evaluated. |br| This result comes from a call to the sql_query method. |br| If left empty the last result will be called.

sql_fetchrow
------------
Fetches current row. Defined in the specific drivers.

Example:

.. code-block:: php

    $sql = 'SELECT *
    	FROM ' . TOPICS_TABLE . '
        WHERE topic_id = 1045';
    $result = $db->sql_query($sql);

    $topic_data = $db->sql_fetchrow($result);


Example with a while-loop:

.. code-block:: php

    $sql = 'SELECT config_name, config_value
    	FROM ' . CONFIG_TABLE;
    $result = $db->sql_query($sql);

    while ($row = $db->sql_fetchrow($result))
    {
    	$config[$row['config_name']] = $row['config_value'];
    }


Parameters
++++++++++
.. csv-table::
   :header: "Parameter", "Usage"
   :delim: #

   Result (Optional) # The result that is being evaluated. |br| The result comes from a call to the sql_query method. |br| If left empty the last result will be called.

sql_rowseek
-----------
Seeks to given row number. The row number is zero-based. Defined in the specific drivers.


Parameters
++++++++++
.. csv-table::
   :header: "Parameter", "Usage"
   :delim: #

   Row number # The number of the row which needs to be found (zero-based).
   Result # The result that is being evaluated. |br| This result comes from a call to sql_query method. |br| If left empty the last result will be called.

sql_freeresult
--------------
Clears result of SELECT query. Defined in the specific drivers.

Example:

.. code-block:: php

    $sql = 'SELECT *
    	FROM ' . POSTS_TABLE . '
    	WHERE post_id = ' . (int) $integer . "
    		AND post_text = '" . $db->sql_escape($string) . "'";
    $result = $db->sql_query($sql);

    // Fetch the data
    $post_data = $db->sql_fetchrow($result);

    // We don't need to do anything with our query anymore, so lets set it free
    $db->sql_freeresult($result);


Parameters
++++++++++
.. csv-table::
   :header: "Parameter", "Usage"
   :delim: #

   Result (Optional) # The result that is being evaluated. |br| This result comes from a call to the sql_query method. |br| If left empty the last result will be called.

.. |br| raw:: html

    <br>
