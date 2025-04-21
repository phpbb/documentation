.. _tutorial-template-syntax:

=========================
Tutorial: Template syntax
=========================

Introduction
============

Starting with version 3.1, phpBB is using the Twig template engine. This tutorial will cover some of the details on
the implementation of Twig's syntax in phpBB and its extensions, however more extensive documentation for Twig can
be found here: `Twig Documentation <https://twig.symfony.com/doc/2.x/>`_.



Assigning data in PHP
=====================

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

This section will highlight Twig syntax elements in the template engine.
The older phpBB specific syntax will be deprecated in a later version of phpBB. It is therefore recommended to use
the documented Twig syntax instead:

Comments
--------

To make comments inside the template you can use ``{# #}``:

.. code-block:: twig

    {# Your comments can go here. #}

Variables
---------

Variables in phpBB take the form of ``{{ X_YYYYY }}``, where the data is assigned from the source. However, most
language strings are not assigned from the source. When a language variable is found, denoted as ``{{ lang('YYYYYY') }}``,
phpBB first checks if an assigned variable with that name exists. If it does, it uses that. If not, it checks if an
existing string defined in the language file exists.

By using the language variable format, phpBB allows for more flexibility in the customization of language strings.
This allows for easy modifications of language strings in the language files without having to modify the source code
directly.

Blocks
------

The basic block level loop takes the form:

.. code-block:: twig

    {% for item in loops.loopname %}
        markup, {{ item.xyyyy }}, etc.
    {% endfor %}

A further extension to begin is to use ``else`` in a loop:

.. code-block:: twig

    {% for item in loops.loopname %}
        markup, {{ item.xyyyy }}, etc.
    {% else %}
        alternate markup
    {% endfor %}

This will cause the markup between ``else`` and ``endfor`` to be output if the loop contains no values.
This is useful for forums with no topics (for example) ... in some ways it replaces "bits of" the existing
"switch" type control (the rest being replaced by conditionals, see below).

You can also check if your loop has any content similar to using ``count()`` in PHP:

.. code-block:: twig

    {% if loops.loopname|length %}
        {% for item in loops.loopname %}
            {{ item.xyyyy }}
        {% endfor %}
    {% endif %}

``loops.loopname|length`` will output the size of the block array. This makes sense if you want to prevent, for example,
an empty ``<select>`` tag, which would not be HTML valid.

You can also access specific iterations of a loop using the following special variables:

.. list-table::
    :widths: 20 80

    * - ``loop.index``
      - The current iteration of the loop. (1 indexed)
    * - ``loop.index0``
      - The current iteration of the loop. (0 indexed)
    * - ``loop.revindex``
      - The number of iterations from the end of the loop (1 indexed)
    * - ``loop.revindex0``
      - The number of iterations from the end of the loop (0 indexed)
    * - ``loop.first``
      - True if first iteration
    * - ``loop.last``
      - True if last iteration
    * - ``loop.length``
      - The number of items in the sequence
    * - ``loop.parent``
      - The parent context

Including files
---------------

phpBB has the ability to include other HTML, Javascript and CSS files:

.. code-block:: twig

    {% INCLUDE 'filename.html' %}
    {% INCLUDEJS 'filename.js' %}
    {% INCLUDECSS 'filename.css' %}

.. note:: You can introduce new templates (i.e. other than those in the default set) using this system and include them
    as you wish ... perhaps useful for a common "menu" bar or similar.

Conditionals/Control structures
-------------------------------

Conditionals and control structures can be used similar to Twig. A simple example of this is:

.. code-block:: twig

    {% if expr %}
        markup
    {% endif %}

The expression can take many forms:

.. code-block:: twig

    {% if loop.index is even %}
        markup
    {% endif %}

This will output the markup if the current iteration of a loop is an even value.
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

.. code-block:: twig

    {% if expr1 %}
        markup
    {% elseif expr2 %}
        markup
        .
        .
        .
    {% elseif exprN %}
        markup
    {% else %}
        markup
    {% endif %}

Each statement will be tested in turn and the relevant output generated when a match (if a match) is found.
It is not necessary to always use ``elseif``, ``else`` can be used alone to match "everything else".

This can also be used to for example assign different stylesheets on even row count than on uneven ones:

.. code-block:: twig

    <table>
    {% if loop.index is even %}
        <tr class="row1">
    {% else %}
        <tr class="row2">
    {% endif %}
            <td>HELLO!</td>
        </tr>
    </table>

Other elements can also be added:

.. code-block:: twig

    <table>
    {% if loop.index > 10 %}
        <tr bgcolor="#FF0000">
    {% elseif loop.index > 5 %}
        <tr bgcolor="#00FF00">
    {% elseif loop.index > 2 %}
        <tr bgcolor="#0000FF">
    {% else %}
        <tr bgcolor="#FF00FF">
    {% endif %}
            <td>hello!</td>
        </tr>
    </table>

This will output the row cell in purple for the first two rows, blue for rows 2 to 5, green for rows 5 to 10 and red
for remainder. So, you could produce a "nice" gradient effect, for example.

You could use ``if`` to do common checks on for example the login state of a user:

.. code-block:: twig

    {% if S_USER_LOGGED_IN %}
        markup
    {% endif %}

User variables
--------------

You can also define simple (boolean, integer or double) variables from inside the template. This is for example useful
if you dont want to copy & paste complex ``if`` expressions over and over again:

.. code-block:: twig
    :force:

    {% if expr1 %}
        {% DEFINE $COLSPAN = 3 %}
    {% elseif expr2 %}
        {% DEFINE $COLSPAN = 4 %}
    {% else %}
        {% DEFINE $COLSPAN = 1 %}
    {% endif %}

    <tr><td colspan="{{ $COLSPAN }}">...</td></tr>
    <tr><td colspan="{{ $COLSPAN }}">...</td></tr>

The ``DEFINE`` keyword does have some restrictions on its use:

- There **MUST** be exactly one space before and after the ``=``
- You **MUST** use single quotes

An example of this:

.. code-block:: twig

    {% DEFINE $COLSPAN = 3 %}   //GOOD
    {% DEFINE $COLSPAN=3 %}     //BAD
    {% DEFINE $COLSPAN  =  3 %} //BAD


    {% DEFINE $CLASS = 'class1' %}  //GOOD
    {% DEFINE $CLASS = "class1" %}  //BAD

User variables can be cleared (unset) using:

.. code-block:: twig

    {% UNDEFINE $COLSPAN %}

Language variables
------------------

You can use and interact with language variables in multiple ways. phpBB extends the standard twig syntax with the
following functions to be able to use language variables within twig based template code:

- ``lang``
    Get output for a language variable similar to using ``{{ L_FOO }}``.
    The following two lines output the same result:

    .. code-block:: twig
        :force:

        {{ lang('FOO') }}
        {{ L_FOO }}

    It supports the same parameter syntax as ``$language->lang()``:

    .. code-block:: twig

        {{ lang('SOME_VAR', param1, param2) }}

    For language variables in Javascript, please use ``lang_js``.

- ``lang_js``
    Get output for language variable in JS code. This should be used instead of the previously used ``LA_`` prefix.
    The following two lines output the same result:

    .. code-block:: twig
        :force:

        {{ lang_js('FOO') }}
        {{ LA_FOO }}

    It supports the same parameter syntax as ``$language->lang()``:

    .. code-block:: twig

        {{ lang_js('SOME_VAR', param1, param2) }}

    Essentially this is the equivalent of:

    .. code-block:: twig

        {{ lang('SOME_VAR', param1, param2) | escape('js') }}

- ``lang_defined``
    Checks whether a language variable is defined. Can be used to check for existence of a language variable before
    calling ``lang`` or ``lang_js``.

    .. code-block:: twig

        {% if lang_defined('MY_LANG_VAR') %}
            <span>{{ lang('MY_LANG_VAR') }}</span>
        {% endif %}

- ``lang_raw``
    Outputs the raw value of a language variable, e.g. a string or array. It can be used to access entries of a language
    array in the template code.

    .. code-block:: twig

        {% for step in lang_raw('EXTENSION_UPDATING_EXPLAIN') %}
            <li>{{ step }}</li>
        {% endfor %}
