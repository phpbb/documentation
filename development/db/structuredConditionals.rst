===========================
The boolean structure system
===========================

Intro
=============

This feature helps extension authors to edit SQL queries in an easy and quick way without the need to parse the SQL queries, most likely, using regex and complex text editing.
Instead of a single string, this allows editing the WHERE clause in an SQL query by adding, removing and editing php arrays. Using this method, finding the portion of the query to edit

If done correctly, incompatibilities between extensions that use the same SQL query can either much easily be averted (and warned) or where a regex match could fault while finding the wanted content the fact they are only arrays, they can be come automatically compatible.

This is not magic thought It will definitely reduce the probability of inter-incompatibilities between extensions but it will not solve them by any means.


Why use
=============




Main use-case ideals
=============

1. To flexibly the build of the WHERE clause in SQL queries
2. To ease, simplify and prevent errors when doing SQL query editing by phpBB's extensions

Why not...
=============

1. Doctrine dbal -> The issue with Doctrine dbal is that it's query builder is not ready for the 2nd major use case listed above. There is no way of altering an SQL query. If you want to alter something, you have to rebuild the whole SQL query.
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
	1.1 This wouln't much be noticed on vanilla phpBB but as you add extensions, it would easily be dead slow.
2. Doing this with immutable objects is completely unviable.
	2.1 It would require the code that manipulates it to know how to rebuild everything related for almost any change.
3. Mutable objects with an easy-enough-to-use API is hell to design.
	3.1 How would a script know how to specify the changes that are required to make without using a complex API?
	3.2 How would a user script swiftly test if a query has the correct format?

Mostly due to those reasons above arrays was decided as the medium.

How to use
=============




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
	