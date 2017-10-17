==========================
Database Abstraction Layer
==========================

phpBB uses a **d**\ ata\ **b**\ ase **a**\ bstraction **l**\ ayer to access the database instead of directly calling e.g. `mysql_query <http://php.net/manual/en/function.mysql-query.php>`_ functions. You usually access the DBAL using the global variable $db. This variable is defined in common.php:

.. code-block:: php

    require($phpbb_root_path . 'includes/db/' . $dbms . '.' . $phpEx);
    // ...
    $db			= new $sql_db();

Connecting and disconnecting
============================
Use these methods only if you cannot include common.php (to connect) or run garbage_collection() (to disconnect; you may also use other functions that run this function, for example page_footer()).

sql_connect
-----------
Connects to the database. Defined in dbal_* class.

Example:

.. code-block:: php

    include($phpbb_root_path . 'includes/db/mysql.' . $phpEx);

    $db = new dbal_mysql();
    // we're using bertie and bertiezilla as our example user credentials. You need to fill in your own ;D
    $db->sql_connect('localhost', 'bertie', 'bertiezilla', 'phpbb', '', false, false);


Example using config.php:

.. code-block:: php

    include($phpbb_root_path . 'config.' . $phpEx);
    include($phpbb_root_path . 'includes/db/' . $dbms . '.' . $phpEx);

    $db = new $sql_db();

    $db->sql_connect($dbhost, $dbuser, $dbpasswd, $dbname, $dbport, false, false);

    // We do not need this any longer, unset for safety purposes
    unset($dbpasswd);

**Important**: The variable $dbms must be set to the name of the used driver. This variable is needed in /includes/db/dbal.php to set $sql_db.

Parameters
++++++++++

.. csv-table::
   :header: "Parameter", "Usage"
   :delim: |

   Host | The host of the database. When using config.php you should use $dbhost instead.
   Database User | The database user to connect to the database. When using config.php you should use $dbuser instead.
   Database Password | The password for the user to connect to the database. When using config.php you should use $dbpasswd instead.
   Database Name | The database where the phpBB tables are located. When using config.php you should use $dbname instead.
   Database Port (optional) | The port to the database server. Leave empty/false to use the default port. When using config.php you should use $dbport instead.
   Persistance (optional) | Database connection persistence, defaults to false.
   New Link (optional) | Use a new connection to the database for this instance of the DBAL. Defaults to false.

sql_close
---------
Disconnects from the DB. Defined in dbal class (_sql_close is defined in dbal_* class).

Example: ``$db->sql_close();``

Preparing SQL queries
========================

sql_build_array
---------------
Builds SQL statement from array. Possible types of queries: INSERT, INSERT_SELECT, UPDATE, SELECT. Defined in dbal class.

Example:

.. code-block:: php

    //Array with the data to insert
    $data = array(
    	'username' 	=> 'Bertie',
    	'email' 	=> 'bertie@example.com',
    );

    // First doing a select with this data.
    // Note: By using the SELECT type, it uses always AND in the query.
    $sql = 'SELECT user_password
    	FROM ' . USERS_TABLE . '
    	WHERE ' . $db->sql_build_array('SELECT', $data);
    $result = $db->sql_query($sql);

    // And doing an update query: (Using the same data as for SELECT)
    $sql = 'UPDATE ' . USERS_TABLE . ' SET ' . $db->sql_build_array('UPDATE', $data) . ' WHERE user_id = ' . (int) $user_id;
    $db->sql_query($sql);

    // And as last, a insert query
    $sql = 'INSERT INTO ' . USERS_TABLE . ' ' . $db->sql_build_array('INSERT', $data);
    $db->sql_query($sql);

Parameters
++++++++++
.. csv-table::
   :header: "Parameter", "Usage"
   :delim: |

   Query Type | Type of query which needs to be created (UPDATE, INSERT, INSERT_SELECT or SELECT)
   Associative array (optional) | An associative array with the items to add to the query. The key of the array is the field name, the value of the array is the value for that field. If left empty, ''false'' will be returned.

..
   [sql_build_query]
   Builds full SQL statement from array. Possible types of queries: SELECT, SELECT_DISTINCT Defined in dbal class.
   See [[db.sql_build_query|dbal::sql_build_query]] manual page.

sql_in_set
----------
Builds IN, NOT IN, = and <> sql comparison string.  Defined in dbal class.

Example:

.. code-block:: php

    $sql_in = array(2, 58, 62);

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

Escapes a string in a SQL query. sql_escape is different for every DBAL driver and written specially for that driver, to be sure all characters that need escaping are escaped. Defined in dbal_* class.

Example:

.. code-block:: php

    $sql = 'SELECT *
    	FROM ' . POSTS_TABLE . '
    	WHERE post_id = ' . (int) $integer . "
    		AND post_text = '" . $db->sql_escape($data) . "'";

Parameters
++++++++++
.. csv-table::
   :header: "Parameter", "Usage"
   :delim: |

   String | The string that needs to be escaped.

Running SQL queries
===================

sql_query
---------
For selecting basic data from the database, the function sql_query() is enough. If you want to use any variable in your query, you should use (If it isn't a integer) [[Database_Abstraction_Layer#sql_escape|$db->sql_escape()]] to be sure the data is safe. Defined in dbal_* class.

Example:

.. code-block:: php

    $integer = 0;
    $data = "This is ' some data";

    $sql = 'SELECT *
    	FROM ' . POSTS_TABLE . '
    	WHERE post_id = ' . (int) $integer . "
    		AND post_text = '" . $db->sql_escape($data) . "'";
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
Gets/changes/deletes only selected number of rows. Defined in dbal class (_sql_query_limit is defined in dbal_* class).

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
Builds and runs more than one insert statement. Defined in dbal class.

Example:

.. code-block:: php

    // Users which will be added to group
    $users = array(11, 57, 87, 98, 154, 211);
    $sql_ary = array();

    foreach ($users as $user_id)
    {
    	$sql_ary[] = array(
    		'user_id'		=> (int) $user_id,
    		'group_id'		=> 154,
    		'group_leader'	=> 0,
    		'user_pending'	=> 0,
    	);
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
All methods in this part of article are defined in dbal_* class.

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
Fetches field. Defined in dbal class.

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
   :delim: |

   Field | Name of the field that needs to be fetched.
   Row number (Optional) | If false, the current row is used, else it is pointing to the row (zero-based).
   Result (Optional) | The result that is being evaluated. This result comes from a call to the sql_query method. If left empty the last result will be called.

sql_fetchrowset
---------------
Returns an array with the result of using the sql_fetchrow method on every row. Defined in dbal class.


Parameters
++++++++++
.. csv-table::
   :header: "Parameter", "Usage"
   :delim: |

   Result (Optional) | The result that is being evaluated. This result comes from a call to the sql_query-Method. If left empty the last result will be called.

sql_fetchrow
------------
Fetches current row. Defined in dbal_* class.

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
   :delim: |

   Result (Optional) | The result that is being evaluated. The result comes from a call to the sql_query method. If left empty the last result will be called.

sql_rowseek
-----------
Seeks to given row number. The row number is zero-based. Defined in dbal_* class.


Parameters
++++++++++
.. csv-table::
   :header: "Parameter", "Usage"
   :delim: |

   Row number | The number of the row which needs to be found (zero-based).
   Result | The result that is being evaluted. This result comes from a call to sql_query method. If left empty the last result will be called.

sql_freeresult
--------------
Clears result of SELECT query. Defined in dbal_* class.

Example:

.. code-block:: php

    $sql = 'SELECT *
    	FROM ' . POSTS_TABLE . '
    	WHERE post_id = ' . (int) $integer . "
    		AND post_text = '" . $db->sql_escape($data) . "'";
    $result = $db->sql_query($sql);

    // Fetch the data
    $post_data = $db->sql_fetchrow($result);

    // We don't need to do anything with our query anymore, so lets set it free
    $db->sql_freeresult($result);


Parameters
++++++++++
.. csv-table::
   :header: "Parameter", "Usage"
   :delim: |

   Result (Optional) | The result that is being evaluated. This result comes from a call to the sql_query method. If left empty the last result will be called.
