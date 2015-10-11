===========================
The boolean structure system
===========================

Intro
=============

This feature helps extension authors to edit SQL queries in an easy and quick way without the need to parse the SQL queries, most likely, using regex and complex text editing.
Instead of a single string, this allows editing the WHERE clause in an SQL query by adding, removing and editing php arrays. Using this method, finding the portion of the query to edit

If done correctly, incompatibilities between extensions that use the same SQL query can either much easily be averted (and warned) or where a regex match could fault while finding the wanted content the fact they are only arrays, they can be come automatically compatible.

This is not magic thought It will definitely reduce the probability of inter-incompatibilities between extensions but it will not solve them by any means.


Main use-case ideals
=============

1. To flexibly the build of the WHERE clause in SQL queries
2. To ease, simplify and prevent errors when doing SQL query editing by phpBB's extensions

Why not...
=============

1. Doctrine dbal -> The issue with Doctrine dbal is that its query builder is not ready for the 2nd major use case listed above. There is no way of altering an SQL query. If you want to alter something, you have to rebuild the whole SQL query.
2. Linq -> I didn't know the assistance of Linq until today. From what I searched, not only it has the same issue as Doctrine, while also its interface is unnecessarily complex for the common folk who just wants to change a small amount of information.


The Data structure
=============

This builder uses a tree-like information organization for the boolean comparisons in SQL queries.
Each node of such tree is a php array.
Each node can have one of 3 formats:

type1
-------

The 1st type contains 3 elements:

Left hand, operator, right hand.
E.g.

.. code-block:: php

	array('f.forum_id', '=', 1)
	array('f.forum_id', '<>', 1)
	array('f.forum_id', 'IN', array())
	array('f.forum_id', 'IN', array(1,2,5,6,7))
	array('f.forum_id', 'NOT_IN', array(1,2,5,6,7))
	array('f.forum_id', 'IS', NULL)

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
-------

The 2nd type is variable length. It is identified by having the string 'AND', 'OR' or 'NOT' in the first position of the array.

The first element contains the boolean operator that is used to join together all its other elements.

E.g.

.. code-block:: php

		array('OR',
			array('t.forum_id', '=', 3),
			array('t.topic_type', '=', 0),
			array('t.topic_id', 'IN', array(2,3,4)),
		)

which outputs (after reindenting)

.. code-block:: php

		t.forum_id = 3 OR
		t.topic_type = 0 OR
		t.topic_id IN (2, 3, 4)


type3
-------

The 3rd type has 5 elements  
Left hand, operator, sub query operator, sub query SELECT type, the sub query.

This is used when you require a subquery in your DB query.  
Essentially, what this does is that it will call sql_build_query() recursively with the 4th and the 5th elements.

.. code-block:: php

	array('f.forum_id', '=', 'ANY', 'SELECT', array(
						'SELECT' => array(/*...*/),
						'FROM' => array(/*...*/),
					)
	)

	array('f.forum_id', '', 'IN', 'SELECT', array(
						'SELECT' => array(/*...*/),
						'FROM' => array(/*...*/),
					)
	)

Why arrays?
=============

De motivation to use arrays comes from the needs:

1. This is information that is going to be used quite a lot.
	1.1. In the ideal case, every SQL query with either an ON or a WHERE clause (just about all) will use this.
2. The implementation on which this works on top of already uses arrays.
3. Editing arrays is a quite trivial task for any piece of code.

Why not Objects?
-------

1. Tranversing Objects forming a tree is **seriously slow** in php.
	1.1 This wouln't much be noticed on vanilla phpBB but, as you add extensions, it would easily be dead slow.
2. Doing this with immutable objects is completely unviable.
	2.1 It would require the code that manipulates it to know how to rebuild everything related for almost any change.
3. Mutable objects with an easy-enough-to-use API is hell to design.
	3.1 How would a script know how to specify the changes that are required to make without using a complex API?
	3.2 How would a user script swiftly test if a query has the correct format?

Mostly due to those reasons above arrays was decided as the medium.

How to use
=============

This system is used when building queries using the db's sql_build_query() method.

While building the array to send to it as the 2nd parameter, when writting the WHERE clause, you may use this system instead of simply typing a string or making your own accumulator of conditionals.

For the sake of the examples below, I will simulate an execution that exists in phpBB and assume that the query has to go through an event that does a small change to it.


How to use in phpBB
=============
In the ideal situation, all DB queries that may use multiple stages where SQL data is manipulated or changed should use this, specially if they also go through an event.


Translate SQL to the structured conditional
----------
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
 
	$sql_ary = array(
		'SELECT'	=> 'COUNT(topic_id) AS num_topics',
		'FROM'		=> array(
			TOPICS_TABLE		=> '',
		),
		'WHERE'		=> "forum_id = $forum_id
				AND (topic_last_post_time >= $min_post_time
					OR topic_type = " . POST_ANNOUNCE . '
					OR topic_type = ' . POST_GLOBAL . ')
				AND ' . $phpbb_content_visibility->get_visibility_sql('topic', $forum_id),
	);
	
	$db->sql_build_query('SELECT', $sql_ary);

That's fine and all but it does not use this processor yet.
**Step 2**
Now to focus on the WHERE clause only

Hum... Let's see... There's a set of AND's to join in. Let's start there.

.. code-block:: php

	// ...
		'WHERE'		=> array('AND',
			"forum_id = $forum_id",
			"(topic_last_post_time >= $min_post_time
					OR topic_type = " . POST_ANNOUNCE . '
					OR topic_type = ' . POST_GLOBAL . ')',
			$phpbb_content_visibility->get_visibility_sql('topic', $forum_id)
		),
	// ...

Inside the set of AND's, one of them is a set of OR's.

.. code-block:: php

	// ...
		'WHERE'		=> array('AND',
			"forum_id = $forum_id",
			array('OR',
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
		'WHERE'		=> array('AND',
			array('forum_id', '=', $forum_id),
			array('OR',
				array('topic_last_post_time', '>=', $min_post_time),
				array('topic_type', '=', POST_ANNOUNCE),
				array('topic_type', '=', POST_GLOBAL),
			),
			array($phpbb_content_visibility->get_visibility_sql('topic', $forum_id)),
	// ...

There you go! No variable interpolation, no explicit string concatenation, in case of a requirement to build it or change it later, it becomes a very straightforward task (see next section) and all data is properly escaped.

Just for the last piece of code in this section, here's how the full SQL query should be written when using this system:


.. code-block:: php
 
	$sql_ary = array(
		'SELECT'	=> 'COUNT(topic_id) AS num_topics',
		'FROM'		=> array(
			TOPICS_TABLE		=> '',
		),
		'WHERE'		=> array('AND',
			array('forum_id', '=', $forum_id),
			array('OR',
				array('topic_last_post_time', '>=', $min_post_time),
				array('topic_type', '=', POST_ANNOUNCE),
				array('topic_type', '=', POST_GLOBAL),
			),
			array($phpbb_content_visibility->get_visibility_sql('topic', $forum_id)),
		),
	);
	
	$db->sql_build_query('SELECT', $sql_ary);


Modify the structured conditional in an extension
----------
One of the major reasons why this feature is designed in this very way is mostly because of what is exemplified in this section.  
Same as the sub-section above, I will present you practical example(s) on how to use this feature.  
Piking up the code above as an example:
	
.. code-block:: php

	$sql = array(
		'SELECT'	=> 'COUNT(topic_id) AS num_topics',
		'FROM'		=> array(
			TOPICS_TABLE		=> '',
		),
		'WHERE'		=> array('AND',
			array('forum_id', '=', $forum_id),
			array('OR',
				array('topic_last_post_time', '>=', $min_post_time),
				array('topic_type', '=', POST_ANNOUNCE),
				array('topic_type', '=', POST_GLOBAL),
			),
			array($phpbb_content_visibility->get_visibility_sql('topic', $forum_id)),
		),
	);


Imagine you are building an extension that requires modifying that query above. For example, you want to make topic_last_post_time as a forced requirement for this query.
In other words, you want the query to be like this:

.. code-block:: php

	$sql = array(
		'SELECT'	=> 'COUNT(topic_id) AS num_topics',
		'FROM'		=> array(
			TOPICS_TABLE		=> '',
		),
		'WHERE'		=> array('AND',
			array('forum_id', '=', $forum_id),
			array('topic_last_post_time', '>=', $min_post_time),
			array($phpbb_content_visibility->get_visibility_sql('topic', $forum_id)),
		),
	);

Just as a good practice and to help other extension writers to modify this query in an easier way, let's make it like this instead:

.. code-block:: php

	$sql = array(
		'SELECT'	=> 'COUNT(topic_id) AS num_topics',
		'FROM'		=> array(
			TOPICS_TABLE		=> '',
		),
		'WHERE'		=> array('AND',
			array('forum_id', '=', $forum_id),
			array('OR',
				array('topic_last_post_time', '>=', $min_post_time),
			),
			array($phpbb_content_visibility->get_visibility_sql('topic', $forum_id)),
		),
	);

Do notice that I kept the OR clause. This is just so that these changes have as little chance as possible to break other extensions.
Anyway, moving on.

In your function:

.. code-block:: php
	
	function eventGrabber($event){
	
You will have an $event['sql'] which will contain the query.  
Below, I use nesting of "if", if you prefer, you may use exceptions instead.  
In order to access what we want, we can do it like this:

.. code-block:: php

	// May be required by PHP
	$sql = $event['sql'];
	// Is the element I expect there?
	if(isset($sql['WHERE'][2][0])){
		if(is_array($sql['WHERE'][2])){
			if($sql['WHERE'][2][0] === 'OR'){
				// This should be the array with the OR I wanted
				if(isset($sql['WHERE'][2][0][1]) && $sql['WHERE'][2][0][1][0] === 'topic_last_post_time'){
					// Confirmed to be what I want it to be!
					// this array_slice() will remove the elements after the above-mentioned topic_last_post_time
					$sql['WHERE'][2][0][1] = array_slice($sql['WHERE'][2][0][1], 1);
					
					$event['sql'] = $sql;
					return;
				}
			} else {
				// For example, write code to log this happened so that an admin can help you making your
				// extension compatible with other extensions or even for you to be warned about phpBB changes.
		} else {
			// For example, write code to log this happened so that an admin can help you making your
			// extension compatible with other extensions or even for you to be warned about phpBB changes.
		}
	} else {
		// For example, write code to log this happened so that an admin can help you making your
		// extension compatible with other extensions or even for you to be warned about phpBB changes.
	}
	
	

If you are thinking:
Eh?!??!? That's too complicated... How is this better than before?!?!

Well, I'm just safeguarding myself above. I'm just doing in a way to make sure it will surely work.
If you don't feel like it, however, then this is enough:

.. code-block:: php
	
	function myEventListener($event){
		$sql = $event['sql'];
		$sql['WHERE'][2][0][1] = array_slice($sql['WHERE'][2][0][1], 1);
		$event['sql'] = $sql;
	}

Or to protect yourself slightly:

.. code-block:: php
	
	function myEventListener($event){
		$sql = $event['sql'];
		if(!empty($sql['WHERE'][2][0][1]) && is_array($sql['WHERE'][2][0][1])){
			$sql['WHERE'][2][0][1] = array_slice($sql['WHERE'][2][0][1], 1);
		} else {
			// For example, write code to log this happened so that an admin can help you making your
			// extension compatible with other extensions or even for you to be warned about phpBB changes.
		}
		$event['sql'] = $sql;
	}

I've shown you the above one first because I wanted you to experience the wilness to do everybody's work the easiest and most flexible way.

**Example 2:**

Now imagining that you want to add a condition to the OR statement list.
For example, you want sticky posts to not be counted.

The long/self.protected way uses just about the same formula as 3 samples above.
The short way is about as much as this:

.. code-block:: php
	
	function myEventListener($event){
		$sql = $event['sql'];
		if(!empty($sql['WHERE'][2][0][1]) && is_array($sql['WHERE'][2][0][1])){
			$sql['WHERE'][2][0][1][] = array('topic_type', '=', POST_STICKY);
		} else {
			// For example, write code to log this happened so that an admin can help you making your
			// extension compatible with other extensions or even for you to be warned about phpBB changes.
		}
		$event['sql'] = $sql;
	}
	
... And you are done. No Regex, no need to write down your own 'OR' or anything like that.
As a bonus, if what you write follows basic rules on how SQL is written, it is guaranteed that the output will be valid SQL.

Usage examples
=============
Here I present code samples that examplify how to use this system.

In phpBB's code
-------


.. code-block:: php	
	
	array('f.forum_id', '=', 'ANY', 'SELECT', array(
							'SELECT' => array(/*...*/),
							'FROM' => array(/*...*/),
						)
		)
		
		
	$db->sql_build_query('SELECT', array(
		'SELECT' => array('f.forum_id', 'f.forum_title'),
		'FROM' => array(
			FORUMS_TABLE  => 'f',
			TOPICS_TABLE => 't',
		),
		'WHERE' => array(
			'AND',
			array('t.topic_poster', '=', 1),
			array('f.forum_id', '>=', 'ALL', 'SELECT', array(
				'SELECT' => array('t.forum_id'),
				'FROM' => array(TOPICS_TABLE  => 't'),
				'WHERE' => array('t.topic_poster', '=', 1),
			),
		),
	)
	


.. code-block:: php

		array('OR',
			array('t.forum_id', '=', 3),
			array('t.topic_type', '=', 0),
		)

.. code-block:: php

		array('AND',
				array('t.forum_id', '=', 3),
				array('t.topic_type', '=', 0),
				array('t.topic_id', '>', 5),
				array('t.topic_poster', '<>', 5),
			),


		array('AND',
				array('t.forum_id', '=', 3),
				array('NOT',
					array('t.topic_type', '=', 0),
				),
				array('t.topic_id', '>', 5),
				array('t.topic_poster', '<>', 5),
			),
	

.. code-block:: php

	t.forum_id = 3
	AND NOT ( t.topic_type = 0 )
	AND t.topic_id > 5
	AND t.topic_poster <> 5

	
In phpBB's extensions code
-------
	