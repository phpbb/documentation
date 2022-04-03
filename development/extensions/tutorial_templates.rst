.. _tutorial-template-syntax:

=========================
Tutorial: Template syntax
=========================

Introduction
============

Starting with version 3.1, phpBB is using the twig template engine that also provides extensive documentation:
`Twig Documentation <https://twig.symfony.com/doc/2.x/>`_

This tutorial will cover some of the details on the implementation of phpBB's own syntax as used before phpBB 3.2,
as well as some specific phpBB specific implementations for using the template engine.

Assigning data
==============

Variables
---------

Assign a single variable:

.. code-block:: php

    $template->assign_var('FOO', $foo);

Assigning multiple variables:

.. code-block:: php

    $template->assign_vars([
        'FOO' => $foo,
        'BAR' => $bar,
        'BAZ' => $baz
    ]);

Default Template Variables
--------------------------

There are some variables set in phpBB's page_header function that are common to all templates and which may be useful to a style or extension author.

.. list-table::
    :widths: 20 60 20
    :header-rows: 1

    * - Template variable
      - Description
      - Sample output
    * - ``T_ASSETS_PATH``
      - The path to assets files (``assets`` path in root of phpBB installation)
      - ``./assets``
    * - ``T_THEME_PATH``
      - The path to the currently selected style's theme folder (where all the css files are stored)
      - ``./styles/prosilver/theme``
    * - ``T_TEMPLATE_PATH``
      - The path to the currently selected style's template folder
      - ``./styles/prosilver/template``
    * - ``T_IMAGES_PATH``
      - The path to phpBB's image folder
      - ``./images``
    * - ``T_SMILIES_PATH``
      - The path to the smiley folder
      - ``./images/similies``
    * - ``T_AVATAR_PATH``
      - The path to the avatar upload folder
      - ``./images/avatars/upload``
    * - ``T_AVATAR_GALLERY_PATH``
      - The path to the avatar gallery folder
      - ``./images/avatars/gallery``
    * - ``T_ICONS_PATH``
      - The path to topic icons folder
      - ``./images/icons``
    * - ``T_RANKS_PATH``
      - The path to the rank images
      - ``./images/ranks``
    * - ``T_UPLOAD_PATH``
      - The path to phpBB's upload folder (shouldn't be used directly).
      - ``./files``

Blocks
------

Blocks are used to assign any number of items of the same type, e.g. topics or posts ("foreach loop").

.. code-block:: php

    while ($row = $db->sql_fetchrow($result))
    {
        $template->assign_block_vars('loopname', [
            'FOO' => $row['foo'],
            'BAR' => $row['bar']
        ]);
    }

Nested loops:

.. code-block:: php

    while ($topic = $db->sql_fetchrow($result))
    {
        $template->assign_block_vars('topic', [
            'TOPIC_ID' => $topic['topic_id']
        ]);

        while ($post = $db->sql_fetchrow($result))
        {
            $template->assign_block_vars('topic.post', [
                'POST_ID' => $post['post_id']
            ]);
        }
    }

The blocks and nested loops can then be used accordingly in HTML files (see `Syntax elements`_).

Syntax elements
===============

This section will highlight phpBB specific syntax elements in the template engine.
The phpBB specific syntax will be deprecated in a later version of phpBB. It is therefore recommended to use
the twig syntax instead:

- `Twig Documentation <https://twig.symfony.com/doc/2.x/>`_

Comments
--------

To make comments inside the template you can use:

.. code-block:: html

    <!-- IF 0 -->
    Your comments can go here, because "0" is always false.
    <!-- ENDIF -->

Variables
---------

Variables take the form ``{X_YYYYY}`` with the data being assigned from the source. Most language strings are not
assigned from the source. When a language variable is found ``{L_YYYYYY}`` phpBB first looks if an assigned variable
exists with that name. If it does, it uses that. If not it looks if an existing string defined in the language file
exists.

Blocks
------

The basic block level loop remains and takes the form:

.. code-block:: html

    <!-- BEGIN loopname -->
    markup, {loopname.X_YYYYY}, etc.
    <!-- END loopname -->

However this has now been extended with the following additions. Firstly you can set the start and end points of the loop.
For example:

.. code-block:: html

    <!-- BEGIN loopname(2) -->
    markup
    <!-- END loopname -->

Will start the loop on the third entry (note that indexes start at *zero*). Extensions of this are:

- ``loopname(2,4)``: Starts loop on third values, ends on fourth
- ``loopname(-4)``: Starts loop fourth from last value
- ``loopname(2,-4)``: Starts loop on third value, ends four from end

A further extension to begin is BEGINELSE:

.. code-block:: html

    <!-- BEGIN loop -->
    markup
    <!-- BEGINELSE -->
    markup
    <!-- END loop -->

This will cause the markup between ``BEGINELSE`` and ``END`` to be output if the loop contains no values.
This is useful for forums with no topics (for example) ... in some ways it replaces "bits of" the existing
"switch" type control (the rest being replaced by conditionals, see below).

You can also check if your loop has any content similar to using ``count()`` in PHP:

.. code-block:: html

    <!-- IF .loopname -->
    <!-- BEGIN loopname -->
    markup, {loopname.X_YYYYY}, etc.
    <!-- END loopname -->
    <!-- ENDIF -->

``.loopname`` will basically output the size of the block array. This makes sense if you want to prevent for example
an empty <select> tag, which would not be XHTML valid.

Including files
---------------

phpBB has the ability to include other HTML files:

.. code-block:: html

    <!-- INCLUDE filename.html -->

You will note in the phpBB templates the major sources start with ``<!-- INCLUDE overall_header.html -->`` or
``<!-- INCLUDE simple_header.html -->``. That way template designers can specify directly reuse other parts like headers
or footers.

.. note:: You can introduce new templates (i.e. other than those in the default set) using this system and include them
    as you wish ... perhaps useful for a common "menu" bar or similar.

PHP
---

.. warning:: The ``PHP`` and ``INCLUDEPHP`` syntax elements are deprecated in phpBB 3.3 and will be removed in phpBB 4.0.

It is possible to directly include PHP within pages. This is achieved by enclosing the PHP within relevant tags:

.. code-block:: html

    <!-- PHP -->
    echo "hello!";
    <!-- ENDPHP -->

You may also include PHP from an external file using:

.. code-block:: html

    <!-- INCLUDEPHP somefile.php -->

It will be included and executed inline.

Please be aware that the path-information of the PHP-file to include, refers to your phpBB-installation's root-path and
**NOT** to the path where your template-file lies in!

.. warning:: It is very much discouraged to include PHP files in templates. The ability to include raw PHP was introduced
    primarily to allow end users to include banner code, etc. without modifying multiple files. It was not intended for
    general use. By default templates will have PHP disabled (the admin will need to specifically activate PHP for a template).

Conditionals/Control structures
-------------------------------

Conditionals and control structures can be used similar to twig. A simple example of this is:

.. code-block:: html

    <!-- IF expr -->
    markup
    <!-- ENDIF -->

The expression can take many forms:

.. code-block:: html

    <!-- IF loop.S_ROW_COUNT is even -->
    markup
    <!-- ENDIF -->

This will output the markup if the S_ROW_COUNT variable in the current iteration of loop is an even value (i.e. the expr is TRUE).
You can use various comparison methods (standard as well as equivalent textual versions noted in square brackets) including:

- ``==`` [``eq``]
- ``!=`` [``neq``, ``ne``]
- ``<>`` (same as ``!=``)
- ``!==`` (not equivalent in value and type)
- ``===`` (equivalent in value and type)
- ``>`` [``gt``]
- ``<`` [``lt``]
- ``>=`` [``gte``]
- ``<=`` [``lte``]
- ``&&`` [``and``]
- ``||`` [``or``]
- ``%`` [``mod``]
- ``!`` [``not``]
- ``+``
- ``-``
- ``*``
- ``/``
- ``<<`` (bitwise shift left)
- ``>>`` (bitwise shift right)
- ``|`` (bitwise or)
- ``^`` (bitwise xor)
- ``&`` (bitwise and)
- ``~`` (bitwise not)
- ``is`` (can be used to join comparison operations)

Basic parenthesis can also be used to enforce good old BODMAS rules. Additionally some basic comparison types are defined:

- ``even``
- ``odd``
- ``div``

Beyond the simple use of IF you can also do a sequence of comparisons using the following:

.. code-block:: html

    <!-- IF expr1 -->
    markup
    <!-- ELSEIF expr2 -->
    markup
    .
    .
    .
    <!-- ELSEIF exprN -->
    markup
    <!-- ELSE -->
    markup
    <!-- ENDIF -->

Each statement will be tested in turn and the relevant output generated when a match (if a match) is found.
It is not necessary to always use ``ELSEIF``, ``ELSE`` can be used alone to match "everything else".

This can also be used to for example assign different stylesheets on even row count than on uneven ones:

.. code-block:: html

    <table>
    <!-- IF loop.S_ROW_COUNT is even -->
    <tr class="row1">
    <!-- ELSE -->
    <tr class="row2">
    <!-- ENDIF -->
    <td>HELLO!</td>
    </tr>
    </table>

Other elements can also be added:

.. code-block:: html

    <table>
    <!-- IF loop.S_ROW_COUNT > 10 -->
    <tr bgcolor="#FF0000">
    <!-- ELSEIF loop.S_ROW_COUNT > 5 -->
    <tr bgcolor="#00FF00">
    <!-- ELSEIF loop.S_ROW_COUNT > 2 -->
    <tr bgcolor="#0000FF">
    <!-- ELSE -->
    <tr bgcolor="#FF00FF">
    <!-- ENDIF -->
    <td>hello!</td>
    </tr>
    </table>

This will output the row cell in purple for the first two rows, blue for rows 2 to 5, green for rows 5 to 10 and red
for remainder. So, you could produce a "nice" gradient effect, for example.

You could use ``IF`` to do common checks on for example the login state of a user:

.. code-block:: html

    <!-- IF S_USER_LOGGED_IN -->
    markup
    <!-- ENDIF -->

User variables
--------------

You can also define simple (boolean, integer or double) variables from inside the template. This is for example useful
if you dont want to copy & paste complex ``IF`` expressions over and over again:

.. code-block:: html

    <!-- IF expr1 -->
    <!-- DEFINE $COLSPAN = 3 -->
    <!-- ELSEIF expr2 -->
    <!-- DEFINE $COLSPAN = 4 -->
    <!-- ELSE -->
    <!-- DEFINE $COLSPAN = 1 -->
    <!-- ENDIF -->

    ...

    <tr><td colspan="{$COLSPAN}">...</td></tr>
    <tr><rd colspan="{$COLSPAN}">...</td></tr>

The ``DEFINE`` keyword does have some restrictions on its use:

- There **MUST** be exactly one space before and after the ``=``
- You **MUST** use single quotes

An example of this:

.. code-block:: html

    <!-- DEFINE $COLSPAN = 3 -->  //GOOD
    <!-- DEFINE $COLSPAN=3 -->         //BAD
    <!-- DEFINE $COLSPAN  =  3 -->     //BAD


    <!-- DEFINE $CLASS = 'class1' -->  //GOOD
    <!-- DEFINE $CLASS = "class1" -->  //BAD

User variables can be cleared (unset) using:

.. code-block:: html

    <!-- UNDEFINE $COLSPAN -->
