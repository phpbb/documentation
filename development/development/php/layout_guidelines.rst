3. Code Layout/Guidelines
=========================

Please note that these guidelines apply to all php, html, javascript and css files.

3.i. Variable/Function/Class Naming
-----------------------------------

We will not be using any form of hungarian notation in our naming conventions. Many of us believe that hungarian naming is one of the primary code obfuscation techniques currently in use.

Variable Names
++++++++++++++

In PHP, variable names should be in all lowercase, with words separated by an underscore, example:

``$current_user`` is right, but ``$currentuser`` and ``$currentUser`` are not.

In JavaScript, variable names should use camel case:

``currentUser`` is right, but ``currentuser`` and ``current_user`` are not.

Names should be descriptive, but concise. We don't want huge sentences as our variable names, but typing an extra couple of characters is always better than wondering what exactly a certain variable is for.

Loop Indices
++++++++++++

The **only** situation where a one-character variable name is allowed is when it's the index for some looping construct. In this case, the index of the outer loop should always be ``$i``. If there's a loop inside that loop, its index should be ``$j``, followed by ``$k``, and so on. If the loop is being indexed by some already-existing variable with a meaningful name, this guideline does not apply, example:

.. code:: php

    for ($i = 0; $i < $outer_size; $i++)
    {
       for ($j = 0; $j < $inner_size; $j++)
       {
          foo($i, $j);
       }
    }

Function Names
++++++++++++++

Functions should also be named descriptively. We're not programming in C here, we don't want to write functions called things like "stristr()". Again, all lower-case names with words separated by a single underscore character in PHP, and camel caps in JavaScript. Function names should be prefixed with `phpbb_` and preferably have a verb in them somewhere. Good function names are ``phpbb_print_login_status()``, ``phpbb_get_user_data()``, etc. Constructor functions in JavaScript should begin with a capital letter.

Function Arguments
++++++++++++++++++

Arguments are subject to the same guidelines as variable names. We don't want a bunch of functions like: ``do_stuff($a, $b, $c)``. In most cases, we'd like to be able to tell how to use a function by just looking at its declaration.

Class Names
+++++++++++

Apart from following the rules for function names, all classes should meet the following conditions:

- Every class must be defined in a separate file.
- The classes have to be located in a subdirectory of ``phpbb/``.
- Classnames must be namespaced with ``\phpbb\`` to avoid name clashes.
- Class names/namespaces have to reflect the location of the file they are defined in. The namespace must be the directory in which the file is located. So the directory names must not contain any underscores, but the filename may.
- Directories should typically be a singular noun (e.g. ``dir`` in the example below, not ``dirs``.

So given the following example directory structure you would result in the below listed lookups

.. code:: text

    phpbb/
      class_name.php
      dir/
        class_name.php
          subdir/
            class_name.php

.. code:: text

    \phpbb\class_name            - phpbb/class_name.php
    \phpbb\dir\class_name        - phpbb/dir/class_name.php
    \phpbb\dir\subdir\class_name - phpbb/dir/subdir/class_name.php

Summary
+++++++

The basic philosophy here is to not hurt code clarity for the sake of laziness. This has to be balanced by a little bit of common sense, though; ``phpbb_print_login_status_for_a_given_user()`` goes too far, for example -- that function would be better named ``phpbb_print_user_login_status()``, or just ``phpbb_print_login_status()``.

Special Namings
+++++++++++++++

For all emoticons use the term ``smiley`` in singular and ``smilies`` in plural. For emails we use the term ``email`` (without dash between “e” and “m”).

3.ii. Code Layout
-----------------

Always include the braces
+++++++++++++++++++++++++

This is another case of being too lazy to type 2 extra characters causing problems with code clarity. Even if the body of some construct is only one line long, do not drop the braces. Just don't, examples:

**These are all wrong:**

.. code:: php

    if (condition) do_stuff();

    if (condition)
        do_stuff();

    while (condition)
        do_stuff();

    for ($i = 0; $i < size; $i++)
        do_stuff($i);

**These are all right:**

.. code:: php

    if (condition)
    {
        do_stuff();
    }

    while (condition)
    {
        do_stuff();
    }

    for ($i = 0; $i < size; $i++)
    {
        do_stuff();
    }

Where to put the braces
+++++++++++++++++++++++

In PHP code, braces always go on their own line. The closing brace should also always be at the same column as the corresponding opening brace, examples:

.. code:: php

    if (condition)
    {
        while (condition2)
        {
            ...
        }
    }
    else
    {
        ...
    }

    for ($i = 0; $i < $size; $i++)
    {
        ...
    }

    while (condition)
    {
        ...
    }

    function do_stuff()
    {
        ...
    }

Use spaces between tokens
+++++++++++++++++++++++++

This is another simple, easy step that helps keep code readable without much effort. Whenever you write an assignment, expression, etc.. Always leave one space between the tokens. Basically, write code as if it was English. Put spaces between variable names and operators. Don't put spaces just after an opening bracket or before a closing bracket. Don't put spaces just before a comma or a semicolon. This is best shown with a few examples, examples:

**Each pair shows the wrong way followed by the right way:**

.. code:: php

    $i=0;
    $i = 0;

    if($i<7) ...
    if ($i < 7) ...

    if ( ($i < 7)&&($j > 8) ) ...
    if ($i < 7 && $j > 8) ...

    do_stuff( $i, 'foo', $b );
    do_stuff($i, 'foo', $b);

    for($i=0; $i<$size; $i++) ...
    for ($i = 0; $i < $size; $i++) ...

    $i=($j < $size)?0:1;
    $i = ($j < $size) ? 0 : 1;

Operator precedence
+++++++++++++++++++

Do you know the exact precedence of all the operators in PHP? Neither do I. Don't guess. Always make it obvious by using brackets to force the precedence of an equation so you know what it does. Remember to not over-use this, as it may harden the readability. Basically, do not enclose single expressions. Examples:

**What's the result? who knows:**

``$bool = ($i < 7 && $j > 8 || $k == 4);``

**Now you can be certain what I'm doing here:**

``$bool = (($i < 7) && (($j < 8) || ($k == 4)));``

**But this one is even better, because it is easier on the eye but the intention is preserved:**

``$bool = ($i < 7 && ($j < 8 || $k == 4));``

Quoting strings
+++++++++++++++

There are two different ways to quote strings in PHP - either with single quotes or with double quotes. The main difference is that the parser does variable interpolation in double-quoted strings, but not in single quoted strings. Because of this, you should always use single quotes unless you specifically need variable interpolation to be done on that string. This way, we can save the parser the trouble of parsing a bunch of strings where no interpolation needs to be done.

Also, if you are using a string variable as part of a function call, you do not need to enclose that variable in quotes. Again, this will just make unnecessary work for the parser. Note, however, that nearly all of the escape sequences that exist for double-quoted strings will not work with single-quoted strings. Be careful, and feel free to break this guideline if it's making your code easier to read, examples:

**Wrong:**

.. code:: php

    $str = "This is a really long string with no variables for the parser to find.";

    do_stuff("$str");

**Right:**

.. code:: php

    $str = 'This is a really long string with no variables for the parser to find.';

    do_stuff($str);

**Sometimes single quotes are just not right:**

.. code:: php

    $post_url = $phpbb_root_path . 'posting.' . $phpEx . '?mode=' . $mode . '&amp;start=' . $start;

**Double quotes are sometimes needed to not overcrowd the line with concatenations:**

.. code:: php

    $post_url = "{$phpbb_root_path}posting.$phpEx?mode=$mode&amp;start=$start";

In SQL statements mixing single and double quotes is partly allowed (following the guidelines listed here about SQL formatting), else one should try to only use one method - mostly single quotes.

Array syntax
++++++++++++

Short array syntax is preferred over the classical array syntax and **SHOULD** be used.

**Not recommended:**

.. code:: php

    $foo = array(
        'bar' => 42,
        'boo' => 23,
    );

**Recommended:**

.. code:: php

    $foo = [
        'bar' => 42,
        'boo' => 23,
    ];


Commas after every array element
++++++++++++++++++++++++++++++++

If an array is defined with each element on its own line, you still have to modify the previous line to add a comma when appending a new element. PHP allows for trailing (useless) commas in array definitions. These should always be used so each element including the comma can be appended with a single line. In JavaScript, do not use the trailing comma, as it causes browsers to throw errors.

**Wrong:**

.. code:: php

    $foo = [
        'bar' => 42,
        'boo' => 23
    ];

**Right:**

.. code:: php

    $foo = [
        'bar' => 42,
        'boo' => 23,
    ];

Associative array keys
++++++++++++++++++++++

In PHP, it's legal to use a literal string as a key to an associative array without quoting that string. We don't want to do this -- the string should always be quoted to avoid confusion. Note that this is only when we're using a literal, not when we're using a variable, examples:

**Wrong:**

.. code:: php

    $foo = $assoc_array[blah];

**Right:**

.. code:: php

    $foo = $assoc_array['blah'];

**Wrong:**

.. code:: php

    $foo = $assoc_array["$var"];

**Right:**

.. code:: php

    $foo = $assoc_array[$var];

Comments
++++++++

Each complex function should be preceded by a comment that tells a programmer everything they need to know to use that function. The meaning of every parameter, the expected input, and the output are required as a minimal comment. The function's behaviour in error conditions (and what those error conditions are) should also be present - but mostly included within the comment about the output.

Especially important to document are any assumptions the code makes, or preconditions for its proper operation. Any one of the developers should be able to look at any part of the application and figure out what's going on in a reasonable amount of time.

Avoid using ``/* */`` comment blocks for one-line comments, ``//`` should be used for one/two-liners.

Magic numbers
+++++++++++++

Don't use them. Use named constants for any literal value other than obvious special cases. Basically, it's ok to check if an array has 0 elements by using the literal 0. It's not ok to assign some special meaning to a number and then use it everywhere as a literal. This hurts readability AND maintainability. The constants ``true` and `false`` should be used in place of the literals 1 and 0 -- even though they have the same values (but not type!), it's more obvious what the actual logic is when you use the named constants. Typecast variables where it is needed, do not rely on the correct variable type (PHP is currently very loose on typecasting which can lead to security problems if a developer does not keep a very close eye on it).

Shortcut operators
++++++++++++++++++

The only shortcut operators that cause readability problems are the shortcut increment $i++ and decrement $j-- operators. These operators should not be used as part of an expression. They can, however, be used on their own line. Using them in expressions is just not worth the headaches when debugging, examples:

**Wrong:**

.. code:: php

    $array[++$i] = $j;
    $array[$i++] = $k;

**Right:**

.. code:: php

    $i++;
    $array[$i] = $j;

    $array[$i] = $k;
    $i++;

Inline conditionals
+++++++++++++++++++

Inline conditionals should only be used to do very simple things. Preferably, they will only be used to do assignments, and not for function calls or anything complex at all. They can be harmful to readability if used incorrectly, so don't fall in love with saving typing by using them, examples:

**Bad place to use them:**

.. code:: php

    ($i < $size && $j > $size) ? do_stuff($foo) : do_stuff($bar);

**OK place to use them:**

.. code:: php

    $min = ($i < $j) ? $i : $j;

Don't use uninitialized variables
+++++++++++++++++++++++++++++++++

For phpBB, we intend to use a higher level of run-time error reporting. This will mean that the use of an uninitialized variable will be reported as a warning. These warnings can be avoided by using the built-in isset() function to check whether a variable has been set - but preferably the variable is always existing. For checking if an array has a key set this can come in handy though, examples:

**Wrong:**

.. code:: php

    if ($forum) ...

**Right:**

.. code:: php

    if (isset($forum)) ...

**Also possible:**

.. code:: php

    if (isset($forum) && $forum == 5)

The ``empty()`` function is useful if you want to check if a variable is not set or being empty (an empty string, 0 as an integer or string, NULL, false, an empty array or a variable declared, but without a value in a class). Therefore empty should be used in favor of ``isset($array) && count($array) > 0`` - this can be written in a shorter way as ``!empty($array)``.

Switch statements
+++++++++++++++++

Switch/case code blocks can get a bit long sometimes. To have some level of notice and being in-line with the opening/closing brace requirement (where they are on the same line for better readability), this also applies to switch/case code blocks and the breaks. An example:

**Wrong:**

.. code:: php

    switch ($mode)
    {
        case 'mode1':
            // I am doing something here
            break;
        case 'mode2':
            // I am doing something completely different here
            break;
    }

**Good:**


.. code:: php

    switch ($mode)
    {
        case 'mode1':
            // I am doing something here
        break;

        case 'mode2':
            // I am doing something completely different here
        break;

        default:
            // Always assume that a case was not caught
        break;
    }

**Also good, if you have more code between the case and the break:**

.. code:: php

    switch ($mode)
    {
        case 'mode1':

            // I am doing something here

        break;

        case 'mode2':

            // I am doing something completely different here

        break;

        default:

            // Always assume that a case was not caught

        break;
    }

Even if the break for the default case is not needed, it is sometimes better to include it just for readability and completeness.

If no break is intended, please add a comment instead. An example:

**Example with no break:**

.. code:: php

    switch ($mode)
    {
        case 'mode1':

            // I am doing something here

        // no break here

        case 'mode2':

            // I am doing something completely different here

        break;

        default:

            // Always assume that a case was not caught

        break;
    }

Class Members
+++++++++++++

Use the explicit visibility qualifiers ``public``, ``private`` and ``protected`` for all properties instead of ``var``.

Place the ``static`` qualifier *after* the visibility qualifiers.

**Wrong:**

.. code:: php

    var $x;
    static private function f()

**Right:**

.. code:: php

    public $x;
    private static function f()

Constants
+++++++++

Prefer class constants over global constants created with ``define()``.

Type declarations
+++++++++++++++++

Use type declarations for arguments, properties and return types.
The declaration of return types is optional for ``void`` types but preferred for uniformity.

There **SHALL BE** *no* space before the colon and *exactly* one space after the colon for type declarations.

**Wrong:**

.. code:: php

    public $x;

    private function do_stuff($input) : string
    {
        return $input . 'appended';
    }

**Right:**

.. code:: php

    public int $x;

    private function do_stuff(string $input): string
    {
        return $input . 'appended';
    }

`Union types <https://wiki.php.net/rfc/union_types_v2>` **SHALL** be used when more than one type is allowed. This does also include nullable types.
The `null` type **SHALL** be the last element, other types **SHALL** follow alphabetical order.

**Wrong:**

.. code:: php

    public bool|int|null|string $x;

    private function do_stuff(?string $input) : ?string
    {
        return $input !== null ? $input . 'appended' : null;
    }

**Right:**

.. code:: php

    public bool|int|string|null $x;

    private function do_stuff(string|null $input): string|null
    {
        return $input !== null ? $input . 'appended' : null;
    }

3.iii. SQL/SQL Layout
---------------------

Common SQL Guidelines
+++++++++++++++++++++

All SQL should be cross-DB compatible, if DB specific SQL is used alternatives must be provided which work on all supported DB's (MySQL3/4/5, MSSQL (7.0 and 2000), PostgreSQL (8.3+), SQLite, Oracle8, ODBC (generalised if possible)).

All SQL commands should utilise the DataBase Abstraction Layer (DBAL)

SQL code layout
+++++++++++++++

SQL Statements are often unreadable without some formatting, since they tend to be big at times. Though the formatting of sql statements adds a lot to the readability of code. SQL statements should be formatted in the following way, basically writing keywords:

.. code:: php

    $sql = 'SELECT *
    <-one tab->FROM ' . SOME_TABLE . '
    <-one tab->WHERE a = 1
    <-two tabs->AND (b = 2
    <-three tabs->OR b = 3)
    <-one tab->ORDER BY b';

**Here the example with the tabs applied:**

.. code:: php

    $sql = 'SELECT *
        FROM ' . SOME_TABLE . '
        WHERE a = 1
            AND (b = 2
                OR b = 3)
        ORDER BY b';

SQL Quotes
++++++++++

Use double quotes where applicable. (The variables in these examples are typecasted to integers beforehand.) Examples:

**Wrong:**

.. code:: php

    "UPDATE " . SOME_TABLE . " SET something = something_else WHERE a = $b";

    'UPDATE ' . SOME_TABLE . ' SET something = ' . $user_id . ' WHERE a = ' . $something;

**Right:**

.. code:: php

    'UPDATE ' . SOME_TABLE . " SET something = something_else WHERE a = $b";

    'UPDATE ' . SOME_TABLE . " SET something = $user_id WHERE a = $something";

In other words use single quotes where no variable substitution is required or where the variable involved shouldn't appear within double quotes. Otherwise use double quotes.

Avoid DB specific SQL
+++++++++++++++++++++

The "not equals operator", as defined by the SQL:2003 standard, is "<>"

**Wrong:**

.. code:: php

    $sql = 'SELECT *
        FROM ' . SOME_TABLE . '
        WHERE a != 2';

**Right:**

.. code:: php

    $sql = 'SELECT *
        FROM ' . SOME_TABLE . '
        WHERE a <> 2';

Common DBAL methods
+++++++++++++++++++

sql_escape()
^^^^^^^^^^^^

Always use ``$db->sql_escape()`` if you need to check for a string within an SQL statement (even if you are sure the variable cannot contain single quotes - never trust your input), for example:

.. code:: php

    $sql = 'SELECT *
        FROM ' . SOME_TABLE . "
        WHERE username = '" . $db->sql_escape($username) . "'";

sql_query_limit()
^^^^^^^^^^^^^^^^^

We do not add limit statements to the sql query, but instead use ``$db->sql_query_limit()``. You basically pass the query, the total number of lines to retrieve and the offset.

Note: Since Oracle handles limits differently and because of how we implemented this handling you need to take special care if you use ``sql_query_limit`` with an sql query retrieving data from more than one table.

Make sure when using something like "SELECT x.\*, y.jars" that there is not a column named jars in x; make sure that there is no overlap between an implicit column and the explicit columns.

sql_build_array()
^^^^^^^^^^^^^^^^^

If you need to UPDATE or INSERT data, make use of the ``$db->sql_build_array()`` function. This function already escapes strings and checks other types, so there is no need to do this here. The data to be inserted should go into an array - ``$sql_ary`` - or directly within the statement if one or two variables needs to be inserted/updated. An example of an insert statement would be:

.. code:: php

    $sql_ary = [
        'somedata'		=> $my_string,
        'otherdata'		=> $an_int,
        'moredata'		=> $another_int,
    ];

    $db->sql_query('INSERT INTO ' . SOME_TABLE . ' ' . $db->sql_build_array('INSERT', $sql_ary));

To complete the example, this is how an update statement would look like:

.. code:: php

    $sql_ary = [
        'somedata'		=> $my_string,
        'otherdata'		=> $an_int,
        'moredata'		=> $another_int,
    ];

    $sql = 'UPDATE ' . SOME_TABLE . '
        SET ' . $db->sql_build_array('UPDATE', $sql_ary) . '
        WHERE user_id = ' . (int) $user_id;
    $db->sql_query($sql);

The ``$db->sql_build_array()`` function supports the following modes: ``INSERT`` (example above), ``INSERT_SELECT`` (building query for ``INSERT INTO table (...) SELECT value, column ...`` statements), ``UPDATE`` (example above) and ``SELECT`` (for building WHERE statement [AND logic]).

sql_multi_insert()
^^^^^^^^^^^^^^^^^^

If you want to insert multiple statements at once, please use the separate ``sql_multi_insert()`` method. An example:

.. code:: php

    $sql_ary = [];

    $sql_ary[] = [
        'somedata'		=> $my_string_1,
        'otherdata'		=> $an_int_1,
        'moredata'		=> $another_int_1,
    ];

    $sql_ary[] = [
        'somedata'		=> $my_string_2,
        'otherdata'		=> $an_int_2,
        'moredata'		=> $another_int_2,
    ];

    $db->sql_multi_insert(SOME_TABLE, $sql_ary);

sql_in_set()
^^^^^^^^^^^^

The ``$db->sql_in_set()`` function should be used for building ``IN ()`` and ``NOT IN ()`` constructs. Since (specifically) MySQL tend to be faster if for one value to be compared the ``=`` and ``<>`` operator is used, we let the DBAL decide what to do. A typical example of doing a positive match against a number of values would be:

.. code:: php

    $sql = 'SELECT *
        FROM ' . FORUMS_TABLE . '
        WHERE ' . $db->sql_in_set('forum_id', $forum_ids);
    $db->sql_query($sql);

Based on the number of values in $forum_ids, the query can look differently.

**SQL Statement if $forum_ids = [1, 2, 3];**

.. code:: php

    SELECT FROM phpbb_forums WHERE forum_id IN (1, 2, 3)

**SQL Statement if $forum_ids = [1] or $forum_ids = 1**

.. code:: php

    SELECT FROM phpbb_forums WHERE forum_id = 1

Of course the same is possible for doing a negative match against a number of values:

.. code:: php

    $sql = 'SELECT *
        FROM ' . FORUMS_TABLE . '
        WHERE ' . $db->sql_in_set('forum_id', $forum_ids, true);
    $db->sql_query($sql);

Based on the number of values in $forum_ids, the query can look differently here too.

**SQL Statement if $forum_ids = [1, 2, 3];**

.. code:: php

    SELECT FROM phpbb_forums WHERE forum_id NOT IN (1, 2, 3)

**SQL Statement if $forum_ids = [1] or $forum_ids = 1**

.. code:: php

    SELECT FROM phpbb_forums WHERE forum_id <> 1

If the given array is empty, an error will be produced.

sql_build_query()
^^^^^^^^^^^^^^^^^

The ``$db->sql_build_query()`` function is responsible for building sql statements for SELECT and SELECT DISTINCT queries if you need to JOIN on more than one table or retrieve data from more than one table while doing a JOIN. This needs to be used to make sure the resulting statement is working on all supported db's. Instead of explaining every possible combination, I will give a short example:

.. code:: php

    $sql_array = [
        'SELECT'	=> 'f.*, ft.mark_time',

        'FROM'		=> [
            FORUMS_WATCH_TABLE	=> 'fw',
            FORUMS_TABLE		=> 'f',
        ],

        'LEFT_JOIN'	=> [
            [
                'FROM'	=> [FORUMS_TRACK_TABLE => 'ft'],
                'ON'	=> 'ft.user_id = ' . $user->data['user_id'] . ' AND ft.forum_id = f.forum_id',
            ],
        ],

        'WHERE'		=> 'fw.user_id = ' . $user->data['user_id'] . '
            AND f.forum_id = fw.forum_id',

        'ORDER_BY'	=> 'left_id',
    ];

    $sql = $db->sql_build_query('SELECT', $sql_array);

The possible first parameter for sql_build_query() is SELECT or SELECT_DISTINCT. As you can see, the logic is pretty self-explaining. For the LEFT_JOIN key, just add another array if you want to join on to tables for example. The added benefit of using this construct is that you are able to easily build the query statement based on conditions - for example the above LEFT_JOIN is only necessary if server side topic tracking is enabled; a slight adjustement would be:

.. code:: php

    $sql_array = [
        'SELECT'	=> 'f.*',

        'FROM'		=> [
            FORUMS_WATCH_TABLE	=> 'fw',
            FORUMS_TABLE		=> 'f',
        ],

        'WHERE'		=> 'fw.user_id = ' . $user->data['user_id'] . '
            AND f.forum_id = fw.forum_id',

        'ORDER_BY'	=> 'left_id',
    ];

    if ($config['load_db_lastread'])
    {
        $sql_array['LEFT_JOIN'] = [
            [
                'FROM'	=> [FORUMS_TRACK_TABLE => 'ft'],
                'ON'	=> 'ft.user_id = ' . $user->data['user_id'] . ' AND ft.forum_id = f.forum_id',
            ],
        ];

        $sql_array['SELECT'] .= ', ft.mark_time ';
    }
    else
    {
        // Here we read the cookie data
    }

    $sql = $db->sql_build_query('SELECT', $sql_array);

3.iv. Optimizations
-------------------

Operations in loop definition:
++++++++++++++++++++++++++++++

Always try to optimize your loops if operations are going on at the comparing part, since this part is executed every time the loop is parsed through. For assignments a descriptive name should be chosen. Example:

**On every iteration the count function is called:**

.. code:: php

    for ($i = 0; $i < count($post_data); $i++)
    {
        do_something();
    }

**You are able to assign the (not changing) result within the loop itself:**

.. code:: php

    for ($i = 0, $size = count($post_data); $i < $size; $i++)
    {
        do_something();
    }

Use of in_array()
^^^^^^^^^^^^^^^^^

Try to avoid using ``in_array()`` on huge arrays, and try to not place them into loops if the array to check consist of more than 20 entries. ``in_array()`` can be very time consuming and uses a lot of cpu processing time. For little checks it is not noticeable, but if checked against a huge array within a loop those checks alone can take several seconds. If you need this functionality, try using ``isset()`` on the arrays keys instead, actually shifting the values into keys and vice versa. A call to ``isset($array[$var])`` is a lot faster than ``in_array($var, array_keys($array))`` for example.

3.v. General Guidelines
-----------------------

General things
++++++++++++++

Never trust user input (this also applies to server variables as well as cookies).

Try to sanitize values returned from a function.

Try to sanitize given function variables within your function.

The auth class should be used for all authorisation checking.

No attempt should be made to remove any copyright information (either contained within the source or displayed interactively when the source is run/compiled), neither should the copyright information be altered in any way (it may be added to).

Variables
+++++++++

Make use of the ``\phpbb\request\request`` class for everything.

The $request->variable() method determines the type to set from the second parameter (which determines the default value too). If you need to get a scalar variable type, you need to tell this the variable() method explicitly. Examples:

**Old method, do not use it:**

.. code:: php

    $start = (isset($HTTP_GET_VARS['start'])) ? intval($HTTP_GET_VARS['start']) : intval($HTTP_POST_VARS['start']);
    $submit = (isset($HTTP_POST_VARS['submit'])) ? true : false;

**Use request var and define a default variable (use the correct type):**

.. code:: php

    $start = $request->variable('start', 0);
    $submit = $request->is_set_post('submit');

**$start is an int, the following use of $request->variable() therefore is not allowed:**

.. code:: php

    $start = $request->variable('start', '0');

**Getting an array, keys are integers, value defaults to 0:**

.. code:: php

    $mark_array = $request->variable('mark', [0]);

**Getting an array, keys are strings, value defaults to 0:**

.. code:: php

    $action_ary = $request->variable('action', ['' => 0]);

Login checks/redirection
++++++++++++++++++++++++

To show a forum login box use ``login_forum_box($forum_data)``, else use the ``login_box()`` function.

``$forum_data`` should contain at least the ``forum_id`` and ``forum_password`` fields. If the field ``forum_name`` is available, then it is displayed on the forum login page.

The ``login_box()`` function can have a redirect as the first parameter. As a thumb of rule, specify an empty string if you want to redirect to the users current location, else do not add the ``$SID`` to the redirect string (for example within the ucp/login we redirect to the board index because else the user would be redirected to the login screen).

Sensitive Operations
++++++++++++++++++++

For sensitive operations always let the user confirm the action. For the confirmation screens, make use of the ``confirm_box()`` function.

Altering Operations
+++++++++++++++++++

For operations altering the state of the database, for instance posting, always verify the form token, unless you are already using ``confirm_box()``. To do so, make use of the ``add_form_key()`` and ``check_form_key()`` functions.

.. code:: php

	add_form_key('my_form');

	if ($submit)
	{
		if (!check_form_key('my_form'))
		{
			trigger_error('FORM_INVALID');
		}
	}

The string passed to ``add_form_key()`` needs to match the string passed to ``check_form_key()``. Another requirement for this to work correctly is that all forms include the ``{S_FORM_TOKEN}`` template variable.

Sessions
++++++++

Sessions should be initiated on each page, as near the top as possible using the following code:

.. code:: php

    $user->session_begin();
    $auth->acl($user->data);
    $user->setup();

The ``$user->setup()`` call can be used to pass on additional language definition and a custom style (used in viewforum).

Errors and messages
+++++++++++++++++++

All messages/errors should be outputted by calling ``trigger_error()`` using the appropriate message type and language string. Example:

.. code:: php

    trigger_error('NO_FORUM');

.. code:: php

    trigger_error($user->lang['NO_FORUM']);

.. code:: php

    trigger_error('NO_MODE', E_USER_ERROR);

Url formatting
++++++++++++++

All urls pointing to internal files need to be prepended by the ``$phpbb_root_path`` variable.
Within the administration control panel all urls pointing to internal files need to be prepended by the ``$phpbb_admin_path variable``.
This makes sure the path is always correct and users being able to just rename the admin folder and the acp still
working as intended (though some links will fail and the code need to be slightly adjusted).

The ``append_sid()`` function from 2.0.x is available too, though it does not handle url alterations automatically. Please have a look at the code documentation if you want to get more details on how to use append_sid(). A sample call to append_sid() can look like this:

.. code:: php

    append_sid("{$phpbb_root_path}memberlist.$phpEx", 'mode=group&amp;g=' . $row['group_id'])

General function usage
++++++++++++++++++++++

Some of these functions are only chosen over others because of personal preference and have no benefit other than maintaining consistency throughout the code.

Use ``strpos`` instead of ``strstr``

Use ``else if`` instead of ``elseif``

Use ``false`` (lowercase) instead of ``FALSE``

Use ``true`` (lowercase) instead of ``TRUE``

Exiting
+++++++

Your page should either call ``page_footer()`` in the end to trigger output through the template engine and terminate the script, or alternatively at least call the ``exit_handler()``. That call is necessary because it provides a method for external applications embedding phpBB to be called at the end of the script.

3.vi. Restrictions on the Use of PHP
------------------------------------

Dynamic code execution
++++++++++++++++++++++

Never execute dynamic PHP code (generated or in a constant string) using any of the following PHP functions:

- eval
- create_function
- preg_replace with the **e** modifier in the pattern

If absolutely necessary a file should be created, and a mechanism for creating this file prior to running phpBB should be provided as a setup process.

The e modifier in **preg_replace** can be replaced by **preg_replace_callback** and objects to encapsulate state that is needed in the callback code.

Other functions, operators, statements and keywords:
The following PHP statements should also not be used in phpBB:

- goto
