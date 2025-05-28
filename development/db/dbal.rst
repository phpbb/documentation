==========================
Database Abstraction Layer
==========================

phpBB uses a **D**\ ata\ **B**\ ase **A**\ bstraction **L**\ ayer to access the database instead of directly calling e.g. `mysql_query <https://php.net/manual/en/function.mysql-query.php>`_ functions.
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

.. rubric:: Parameters

.. csv-table::
   :header: Parameter, Usage
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

.. rubric:: Parameters

.. csv-table::
   :header: Parameter, Usage
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

.. rubric:: Parameters

.. csv-table::
   :header: Parameter, Usage
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


.. rubric:: Parameters

.. csv-table::
   :header: Parameter, Usage
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

.. rubric:: Parameters

.. csv-table::
   :header: Parameter, Usage
   :delim: |

   String | The string that needs to be escaped.

sql_like_expression
-------------------
Correctly adjust LIKE statements for special characters.
This should be used to ensure the resulting statement works on all databases.
Defined in the base driver (``_sql_like_expression`` is defined in the specific drivers).

The ``sql_not_like_expression`` is identical to ``sql_like_expression`` apart from that it builds a NOT LIKE statement.

.. rubric:: Parameters

.. csv-table::
   :header: Parameter, Usage
   :delim: |

   Expression | The expression to use. Every wildcard is escaped, except $db->get_any_char() and $db->get_one_char()

get_one_char
^^^^^^^^^^^^
Wildcards for matching exactly one (``_``) character within LIKE expressions.

get_any_char
^^^^^^^^^^^^
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

.. rubric:: Parameters

.. csv-table::
   :header: Parameter, Usage
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


.. rubric:: Parameters

.. csv-table::
   :header: Parameter, Usage
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


.. rubric:: Parameters

.. csv-table::
   :header: Parameter, Usage
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


.. rubric:: Parameters

.. csv-table::
   :header: Parameter, Usage
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

.. warning::
    Be cautious when using ``sql_affectedrows()`` to determine the number of rows affected by your query, especially with **SELECT** queries.
    This function's behavior can differ depending on the used database driver and whether the query was cached.

    Do not rely solely on ``sql_affectedrows()`` to confirm the number of impacted rows. Consider alternative approaches
    like checking the number of rows returned by `sql_fetchrow`_ or `sql_fetchrowset`_.

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


.. rubric:: Parameters

.. csv-table::
   :header: Parameter, Usage
   :delim: #

   Field # Name of the field that needs to be fetched.
   Row number (Optional) # If false, the current row is used, else it is pointing to the row (zero-based).
   Result (Optional) # The result that is being evaluated. |br| This result comes from a call to the sql_query method. |br| If left empty the last result will be called.

sql_fetchrowset
---------------
Returns an array with the result of using the ``sql_fetchrow`` method on every row. Defined in the base driver.

.. rubric:: Parameters

.. csv-table::
   :header: Parameter, Usage
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

.. rubric:: Parameters

.. csv-table::
   :header: Parameter, Usage
   :delim: #

   Result (Optional) # The result that is being evaluated. |br| The result comes from a call to the sql_query method. |br| If left empty the last result will be called.

sql_rowseek
-----------
Seeks to given row number. The row number is zero-based. Defined in the specific drivers.

.. rubric:: Parameters

.. csv-table::
   :header: Parameter, Usage
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

.. rubric:: Parameters

.. csv-table::
   :header: Parameter, Usage
   :delim: #

   Result (Optional) # The result that is being evaluated. |br| This result comes from a call to the sql_query method. |br| If left empty the last result will be called.

.. |br| raw:: html

    <br>

The boolean structure system
============================

Intro
-----

This feature helps extension authors to edit SQL queries in an easy and quick way without the need to parse the SQL queries, most likely, using regex and complex text editing.
Instead of a single string, this allows editing the WHERE clause in an SQL query by adding, removing and editing php arrays. Using this method, finding the portion of the query to edit should be much more straightforward.

If done correctly, incompatibilities between extensions that use the same SQL query can be averted. Where a regex match could easly force the author into making very complex matches. With this, finding and replacing the content is just tree-like transversal as they are only arrays. Compatibility between extensions becomes much easier.

Althought this will definitely reduce the probability of inter-incompatibilities between extensions, it is not magic. This is just a tool that helps solving the same issue.


Main use-case ideals
--------------------

1. To flexibly the build of the WHERE clause in SQL queries
2. To ease, simplify and prevent errors when doing SQL query editing by phpBB's extensions

Why not...
----------

1. Doctrine dbal -> The issue with Doctrine dbal is that its query builder is not ready for the 2nd major use case listed above. There is no way of altering an SQL query. If you want to alter something, you have to rebuild the whole SQL query.
2. Linq -> I didn't know the assistance of Linq until today. From what I searched, not only it has the same issue as Doctrine, while also its interface is unnecessarily complex for the common folk who just wants to change a small amount of information.


The Data structure
------------------

This builder uses a tree-like information organization for the boolean comparisons in SQL queries.
Each node of such tree is a php array.
Each node can have one of 3 formats:

type1
^^^^^

The 1st type contains 3 elements:

Left hand, operator, right hand.
E.g.

.. code-block:: php

	['f.forum_id', '=', 1]
	['f.forum_id', '<>', 1]
	['f.forum_id', 'IN', []]
	['f.forum_id', 'IN', [1,2,5,6,7]]
	['f.forum_id', 'NOT_IN', [1,2,5,6,7]]
	['f.forum_id', 'IS', NULL]

For the operator, there are 6 special values (everything else is taken literally):

1. IN
2. NOT_IN
3. LIKE
4. NOT_LIKE
5. IS
6. IS_NOT

All of them are special because they call the dbal's methods to process the data.
For example, if you use the **IN** operator, it calls $db->sql_in_set() with the right hand data.

type2
^^^^^

The 2nd type is variable length. It is identified by having the string 'AND', 'OR' or 'NOT' in the first position of the array.

The first element contains the boolean operator that is used to join together all its other elements.

E.g.

.. code-block:: php

	['OR',
		['t.forum_id', '=', 3],
		['t.topic_type', '=', 0],
		['t.topic_id', 'IN', [2,3,4]],
	)

which outputs (after reindenting)

.. code-block:: SQL

	t.forum_id = 3 OR
	t.topic_type = 0 OR
	t.topic_id IN (2, 3, 4)


type3
^^^^^

The 3rd type has 5 elements
Left hand, operator, sub query operator, sub query SELECT type, the sub query.

This is used when you require a subquery in your DB query.
Essentially, what this does is that it will call sql_build_query() recursively with the 4th and the 5th elements.

.. code-block:: php

	['f.forum_id', '=', 'ANY', 'SELECT', [
		'SELECT' => [/*...*/],
		'FROM' => [/*...*/],
	]]

	['f.forum_id', '', 'IN', 'SELECT', [
		'SELECT' => [/*...*/],
		'FROM' => [/*...*/],
	]]

Why arrays?
-----------

The motivation to use arrays comes from the needs:

1. This is information that is going to be used quite a lot.
	1.1. In the ideal case, every SQL query with either an ON or a WHERE clause (just about all) will use this.
2. The implementation on which this works on top of already uses arrays.
3. Editing arrays is a quite trivial task for any piece of code.

Why not Objects?
^^^^^^^^^^^^^^^^

1. Tranversing Objects forming a tree is **seriously slow** in php.
	1.1. This wouldn't much be noticed on vanilla phpBB but, as you add extensions, it would easily be dead slow.
2. Doing this with immutable objects is completely unviable.
	2.1. It would require the code that manipulates it to know how to rebuild everything related for almost any change.
3. Mutable objects with an easy-enough-to-use API is hell to design.
	3.1. How would a script know how to specify the changes that are required to make without using a complex API?
	3.2. How would a user script swiftly test if a query has the correct format?

Mostly due to those reasons above arrays was decided as the medium.

How to use
----------

This system is used when building queries using the db's sql_build_query() method.

While building the array to send to it as the 2nd parameter, when writing the WHERE clause, you may use this system instead of simply typing a string or making your own accumulator of conditionals.

For the sake of the examples below, I will simulate an execution that exists in phpBB and assume that the query has to go through an event that does a small change to it.


How to use in phpBB
-------------------
In the ideal situation, all DB queries that may use multiple stages where SQL data is manipulated or changed should use this, specially if they also go through an event.


Translate SQL to the structured conditional
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Here's a step-by-step guide to transform a query made using a string into the format that this feature uses.

Now imagine you want something like this (source: viewforum.php:277):

.. code-block:: php

	$sql = 'SELECT COUNT(topic_id) AS num_topics
	FROM ' . TOPICS_TABLE . "
	WHERE forum_id = $forum_id
		AND (topic_last_post_time >= $min_post_time
			OR topic_type = " . POST_ANNOUNCE . '
			OR topic_type = ' . POST_GLOBAL . ')
		AND ' . $phpbb_content_visibility->get_visibility_sql('topic', $forum_id);


Looks quite direct to the point, right?
OK, **step1**, prepare it for sql_build_query();

According to the manual for this transformation, it should look like this:


.. code-block:: php

	$sql_ary = [
		'SELECT'	=> 'COUNT(topic_id) AS num_topics',
		'FROM'		=> [
			TOPICS_TABLE		=> '',
		],
		'WHERE'		=> "forum_id = $forum_id
			AND (topic_last_post_time >= $min_post_time
				OR topic_type = " . POST_ANNOUNCE . '
				OR topic_type = ' . POST_GLOBAL . ')
			AND ' . $phpbb_content_visibility->get_visibility_sql('topic', $forum_id),
	];

	$db->sql_build_query('SELECT', $sql_ary);

That's fine and all but it does not use this processor yet.
**Step 2**
Now to focus on the WHERE clause only

Hum... Let's see... There's a set of AND's to join in. Let's start there.

.. code-block:: php

	// ...
	'WHERE'		=> ['AND,
		"forum_id = $forum_id",
		"(topic_last_post_time >= $min_post_time
			OR topic_type = " . POST_ANNOUNCE . '
			OR topic_type = ' . POST_GLOBAL . ')',
		$phpbb_content_visibility->get_visibility_sql('topic', $forum_id)
	],
	// ...

Inside the set of AND's, one of them is a set of OR's.

.. code-block:: php

	// ...
	'WHERE'		=> ['AND,
		"forum_id = $forum_id",
		['OR',
			"topic_last_post_time >= $min_post_time",
			'topic_type = ' . POST_ANNOUNCE,
			'topic_type = ' . POST_GLOBAL,
		),
		$phpbb_content_visibility->get_visibility_sql('topic', $forum_id)
	),
	// ...

There! Better! But it still isn't that easy to work with. There's a string for each comparison. BUT! If I use the type1 array mentioned above, I can separate each one of those into a single thing! In this case...

.. code-block:: php

	// ...
	'WHERE'		=> ['AND,
		['forum_id', '=', $forum_id],
		['OR',
			['topic_last_post_time', '>=', $min_post_time],
			['topic_type', '=', POST_ANNOUNCE],
			['topic_type', '=', POST_GLOBAL],
		),
		[$phpbb_content_visibility->get_visibility_sql('topic', $forum_id)],
	// ...

There you go! No variable interpolation, no explicit string concatenation, in case of a requirement to build it or change it later, it becomes a very straightforward task (see next section) and all data is properly escaped.

Just for the last piece of code in this section, here's how the full SQL query should be written when using this system:


.. code-block:: php

	$sql_ary = [
		'SELECT'	=> 'COUNT(topic_id) AS num_topics',
		'FROM'		=> [
			TOPICS_TABLE		=> '',
		],
		'WHERE'		=> ['AND,
			['forum_id', '=', $forum_id],
			['OR',
				['topic_last_post_time', '>=', $min_post_time],
				['topic_type', '=', POST_ANNOUNCE],
				['topic_type', '=', POST_GLOBAL],
			],
			[$phpbb_content_visibility->get_visibility_sql('topic', $forum_id)],
		],
	];

	$db->sql_build_query('SELECT', $sql_ary);


Modify the structured conditional in an extension
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
One of the major reasons why this feature is designed in this very way is mostly because of what is exemplified in this section.
Same as the sub-section above, I will present you practical example(s) on how to use this feature.
Piking up the code above as an example:

.. code-block:: php

	$sql = [
		'SELECT'	=> 'COUNT(topic_id) AS num_topics',
		'FROM'		=> [
			TOPICS_TABLE		=> '',
		],
		'WHERE'		=> ['AND,
			['forum_id', '=', $forum_id],
			['OR',
				['topic_last_post_time', '>=', $min_post_time],
				['topic_type', '=', POST_ANNOUNCE],
				['topic_type', '=', POST_GLOBAL],
			),
			[$phpbb_content_visibility->get_visibility_sql('topic', $forum_id)]
		],
	];


Imagine you are building an extension that requires modifying that query above. For example, you want to make topic_last_post_time as a forced requirement for this query.
In other words, you want the query to be like this:

.. code-block:: php

	$sql = [
		'SELECT'	=> 'COUNT(topic_id) AS num_topics',
		'FROM'		=> [
			TOPICS_TABLE		=> '',
		],
		'WHERE'		=> ['AND,
			['forum_id', '=', $forum_id],
			['topic_last_post_time', '>=', $min_post_time],
			[$phpbb_content_visibility->get_visibility_sql('topic', $forum_id)],
		],
	];

Just as a good practice and to help other extension writers to modify this query in an easier way, let's make it like this instead:

.. code-block:: php

	$sql = [
		'SELECT'	=> 'COUNT(topic_id) AS num_topics',
		'FROM'		=> [
			TOPICS_TABLE		=> '',
		],
		'WHERE'		=> ['AND,
			['forum_id', '=', $forum_id],
			['OR',
				['topic_last_post_time', '>=', $min_post_time],
			],
			[$phpbb_content_visibility->get_visibility_sql('topic', $forum_id)],
		],
	];

Do notice that I kept the OR clause. This is just so that these changes have as little chance as possible to break other extensions.
Anyway, moving on.

In your function:

.. code-block:: php

	function eventGrabber($event)
	{

You will have an $event['sql'] which will contain the query.
Below, I use nesting of "if", if you prefer, you may use exceptions instead.
In order to access what we want, we can do it like this:

.. code-block:: php

	// May be required by PHP
	$sql = $event['sql'];
	// Is the element I expect there?
	if(isset($sql['WHERE'][2][0]))
	{
		if(is_array($sql['WHERE'][2]))
		{
			if($sql['WHERE'][2][0] === 'OR')
			{
				// This should be the array with the OR I wanted
				if(isset($sql['WHERE'][2][0][1]) && $sql['WHERE'][2][0][1][0] === 'topic_last_post_time')
				{
					// Confirmed to be what I want it to be!
					// this array_slice() will remove the elements after the above-mentioned topic_last_post_time
					$sql['WHERE'][2][0][1] = array_slice($sql['WHERE'][2][0][1], 1);

					$event['sql'] = $sql;
					return;
				}
			}
			else
			{
				// For example, write code to log this happened so that an admin can help you making your
				// extension compatible with other extensions or even for you to be warned about phpBB changes.
			}
		}
		else
		{
			// For example, write code to log this happened so that an admin can help you making your
			// extension compatible with other extensions or even for you to be warned about phpBB changes.
		}
	}
	else
	{
		// For example, write code to log this happened so that an admin can help you making your
		// extension compatible with other extensions or even for you to be warned about phpBB changes.
	}



If you are thinking:
Eh?!??!? That's too complicated... How is this better than before?!?!

Well, I'm just safeguarding myself above. I'm just doing in a way to make sure it will surely work.
If you don't feel like it, however, then this is enough:

.. code-block:: php

	function myEventListener($event)
	{
		$sql = $event['sql'];
		$sql['WHERE'][2][0][1] = array_slice($sql['WHERE'][2][0][1], 1);
		$event['sql'] = $sql;
	}

Or to protect yourself slightly:

.. code-block:: php

	function myEventListener($event)
	{
		$sql = $event['sql'];
		if(!empty($sql['WHERE'][2][0][1]) && is_array($sql['WHERE'][2][0][1]))
		{
			$sql['WHERE'][2][0][1] = array_slice($sql['WHERE'][2][0][1], 1);
		}
		else
		{
			// For example, write code to log this happened so that an admin can help you making your
			// extension compatible with other extensions or even for you to be warned about phpBB changes.
		}
		$event['sql'] = $sql;
	}

I've shown you the above one first because I wanted you to experience the will to do everybody's work the easiest and most flexible way.

**Example 2:**

Now imagining that you want to add a condition to the OR statement list.
For example, you want sticky posts to not be counted.

The long/self.protected way uses just about the same formula as 3 samples above.
The short way is about as much as this:

.. code-block:: php

	function myEventListener($event)
	{
		$sql = $event['sql'];
		if(!empty($sql['WHERE'][2][0][1]) && is_array($sql['WHERE'][2][0][1]))
		{
			$sql['WHERE'][2][0][1][] = ['topic_type', '=', POST_STICKY];
		}
		else
		{
			// For example, write code to log this happened so that an admin can help you making your
			// extension compatible with other extensions or even for you to be warned about phpBB changes.
		}
		$event['sql'] = $sql;
	}

... And you are done. No Regex, no need to write down your own 'OR' or anything like that.
As a bonus, if what you write follows basic rules on how SQL is written, it is guaranteed that the output will be valid SQL.

Usage examples
--------------
Here I present code samples that exemplify how to use this system.

In phpBB's code
^^^^^^^^^^^^^^^

.. code-block:: php

	$db->sql_build_query('SELECT', [
		'SELECT' => ['f.forum_id', 'f.forum_title'],
		'FROM' => [
			FORUMS_TABLE  => 'f',
			TOPICS_TABLE => 't',
		],
		'WHERE' => [
			'AND',
			['t.topic_poster', '=', 1],
			['f.forum_id', '>=', 'ALL', 'SELECT', [
				'SELECT' => ['t.forum_id'],
				'FROM' => [TOPICS_TABLE  => 't'],
				'WHERE' => ['t.topic_poster', '=', 1],
			],
		],
	);

.. code-block:: php

	['OR',
		['t.forum_id', '=', 3],
		['t.topic_type', '=', 0],
	)

.. code-block:: php

	['AND,
		['t.forum_id', '=', 3],
		['t.topic_type', '=', 0],
		['t.topic_id', '>', 5],
		['t.topic_poster', '<>', 5],
	),

.. code-block:: php

	['AND,
		['t.forum_id', '=', 3],
		['NOT',
			['t.topic_type', '=', 0],
		],
		['t.topic_id', '>', 5],
		['t.topic_poster', '<>', 5],
	],

.. code-block:: php

	t.forum_id = 3
	AND NOT ( t.topic_type = 0 )
	AND t.topic_id > 5
	AND t.topic_poster <> 5

In phpBB's extensions code
^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: php

	function myEventListener($event)
	{
		$sql = $event['sql'];
		$sql['WHERE'][2][0][1] = array_slice($sql['WHERE'][2][0][1], 1);
		$event['sql'] = $sql;
	}

More will come as people submit more useful examples.
