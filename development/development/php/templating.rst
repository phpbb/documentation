4. Templating
=============

4.i. General Templating
-----------------------

File naming
+++++++++++

Templates **SHALL** use the suffix ``.html`` and **MAY** use the ``.twig`` suffix for non-HTML files interpreted by twig or twig macros. Other suffixes like ``.tpl`` or ``.html5`` **SHALL NOT** be used.

Variables
+++++++++

All template variables **SHALL** be named appropriately using underscores for spaces (`snake_case`).

Previous versions of phpBB used prefixes for special handling of variables, e.g. ``L_`` for language variables, ``S_`` for system variables, etc. This has been deprecated in phpBB 4.0 and will be dropped in a later version of phpBB.
``UA_`` and ``LA`` prefixes resulted in special inside JavaScript.

Appropriate escaping needs to be done in template files using the provided escape functions. Variables can be escaped inside JavaScript using the standard ``e('js')`` twig function:

.. code-block:: js

    {{ username|e('js') }}

This will escape the variable for JavaScript usage. A helper function for language variables inside JavaScript without the need for ``e('js')`` has been introduced:

.. code-block:: js

    {{ lang_js('USERNAME') }}

The ``L_`` prefix or ``LA`` prefix is not needed anymore. The function will automatically escape the variable for JavaScript usage.

.. warning::

    Support for the ``L_`` prefix and ``LA`` prefix have been deprecated in phpBB 4.0 will be removed in a later version of phpBB. Please use the new functions instead.

.. seealso::

    - `escape - Filters - Documentation <https://twig.symfony.com/doc/3.x/filters/escape.html>`_
    - `Twig for Template Designers - Variables <https://twig.symfony.com/doc/3.x/templates.html#variables>`_

Blocks/Loops
++++++++++++

The basic block level loop **SHALL** use the twig syntax as follows:

.. code-block:: html

    {% for item in loopname %}
        markup, {{ item.X_YYYYY }}, etc.
    {% endfor %}

Further instructions on how to use loops will follow in section `Extended syntax for Blocks/Loops`_.

.. warning::

    The old style of loops using ``<!-- BEGIN loopname -->`` and ``<!-- END loopname -->`` is deprecated in phpBB 4.0 and will be removed in a later version of phpBB. Please use the new twig syntax instead.

    .. code:: html

        <!-- BEGIN loopname -->
            markup, {loopname.X_YYYYY}, etc.
        <!-- END loopname -->

.. seealso::

    - `for - Tags - Twig Documentation <https://twig.symfony.com/doc/3.x/tags/for.html>`_

Including files
+++++++++++++++

In phpBB 3.1 and later, template inclusion **SHALL** be handled using Twig syntax. To include another template file, use the following Twig statement:

.. code-block:: twig

    {% include 'filename' %}

For example, to include the overall header or a custom menu bar:

.. code-block:: twig

    {% include 'overall_header.html' %}
    {% include 'simple_header.html' %}

You can also include a template file using a variable:

.. code-block:: twig

    {% include FILE_VAR %}

Template-defined variables can be used as well:

.. code-block:: twig

    {% set SOME_VAR = 'my_file.html' %}
    {% include SOME_VAR %}

.. seealso::

    - `Twig for Template Designers - Including other templates <https://twig.symfony.com/doc/3.x/templates.html#including-other-templates>`_

Conditionals/Control structures
+++++++++++++++++++++++++++++++

Starting with phpBB 3.1, the template engine uses Twig for control structures and conditionals. This allows for a more powerful and flexible way to handle logic in templates compared to the previous phpBB template syntax.
All conditionals **SHALL** use the Twig syntax starting with phpBB 4.0.

.. warning::

    The old style of conditionals using ``<!-- IF expr -->`` and ``<!-- ENDIF -->`` is deprecated in phpBB 4.0 and will be removed in a later version of phpBB. Please use the new Twig syntax instead.

    .. code:: html

        <!-- IF expr -->
            markup
        <!-- ENDIF -->

Twig offers a clear and flexible way to handle logic in templates. The basic form of a conditional in Twig is:

.. code-block:: twig

    {% if expr %}
        markup
    {% endif %}

The `expr` can take many forms. For example, to check if the current loop iteration is even:

.. code-block:: twig

    {% if loop.index is even %}
        markup
    {% endif %}

This will output the markup if the current loop index is even. Twig supports a wide range of comparison and logical operators, including:

.. code-block:: text

    ==, !=, ==, >, <, >=, <=, and, or, not, in, is, matches, starts with, ends with, contains, has some, has every

You can also use parentheses to group expressions and enforce operator precedence.

Twig provides special tests for common checks:

.. code-block:: text

    even, odd, divisible by, defined, iterable, empty, null, same as

For example:

.. code-block:: twig

    {% if loop.index is divisible by(3) %}
        markup
    {% endif %}

Twig also supports `if`/`elseif`/`else` chains:

.. code-block:: twig

    {% if expr1 %}
        markup
    {% elseif expr2 %}
        markup
    {% else %}
        markup
    {% endif %}

Each condition is checked in order, and the first matching block is rendered.

Here are some practical examples:

**Row coloration in a table:**

.. code-block:: twig

    <table>
        {% for row in rows %}
            {% if loop.index is even %}
                <tr class="row1">
            {% else %}
                <tr class="row2">
            {% endif %}
                <td>HELLO!</td>
            </tr>
        {% endfor %}
    </table>

This will use `row1` for even rows and `row2` for odd rows.

**Gradient effect based on row count:**

.. code-block:: twig

    <table>
        {% for row in rows %}
            {% if loop.index > 10 %}
                <tr style="background-color:#FF0000">
            {% elseif loop.index > 5 %}
                <tr style="background-color:#00FF00">
            {% elseif loop.index > 2 %}
                <tr style="background-color:#0000FF">
            {% else %}
                <tr style="background-color:#FF00FF">
            {% endif %}
                <td>hello!</td>
            </tr>
        {% endfor %}
    </table>

This will output different background colors depending on the row index.

**Checking user login state:**

.. code-block:: twig

    {% if S_USER_LOGGED_IN %}
        markup
    {% endif %}

.. seealso::

    - `Twig for Template Designers - Control Structures <https://twig.symfony.com/doc/3.x/templates.html#control-structure>`_
    - `Twig for Template Designers - Operators <https://twig.symfony.com/doc/3.x/templates.html#operators>`_

Extended syntax for Blocks/Loops
++++++++++++++++++++++++++++++++

Twig provides powerful features for working with loops, including setting start and end points, handling empty loops, and working with nested loops.

**Setting start and end points of a loop:**

You can use the `slice` filter to control which items are iterated over:

.. code-block:: twig

    {# Start loop on the third entry (index 2) #}
    {% for item in loopname|slice(2) %}
        {{ item }}
    {% endfor %}

    {# Start two entries from the end #}
    {% for item in loopname|slice(-2) %}
        {{ item }}
    {% endfor %}

    {# Start at index 3 and end at index 4 (2 items) #}
    {% for item in loopname|slice(3, 2) %}
        {{ item }}
    {% endfor %}

    {# Start at index 3 and end four from last #}
    {% for item in loopname|slice(3, loopname|length - 3 - 4) %}
        {{ item }}
    {% endfor %}

**Handling empty loops:**

Twig provides the `else` block for loops:

.. code-block:: twig

    {% for item in loop %}
        {{ item }}
    {% else %}
        No items found.
    {% endfor %}

**Checking if a loop contains values:**

You can use an `if` statement with the `length` filter:

.. code-block:: twig

    {% if loop|length > 0 %}
        {% for item in loop %}
            {{ item }}
        {% endfor %}
    {% else %}
        No items found.
    {% endif %}

Or simply use the `else` block as above.

**Checking the number of items in a loop:**

.. code-block:: twig

    {% if loop|length > 2 %}
        {% for item in loop %}
            {{ item }}
        {% endfor %}
    {% else %}
        Not enough items.
    {% endif %}

**Nesting loops:**

Twig supports nested loops naturally:

.. code-block:: html

    {% for first in firstloop %}
        {{ first.MY_VARIABLE_FROM_FIRSTLOOP }}

        {% for second in first.secondloop %}
            {{ second.MY_VARIABLE_FROM_SECONDLOOP }}
        {% endfor %}
    {% endfor %}

**Breaking out of nested loops and working with special variables:**

Twig does not support breaking out of multiple nested loops directly, and child loops will not be directly interpreted as child loop inside `for` statements.
It is possible to use the `loop` variable to access the current loop's properties, such as `loop.index`, `loop.length`, and `loop.first`. This will however only work for the current loop, not for parent loops.

.. code-block:: html

    {% for l_block1 in l_block1_list %}
        {% if l_block1.S_SELECTED %}
            <strong>{{ l_block1.L_TITLE }}</strong>
            {% if S_PRIVMSGS %}
                <ul class="nav">
                {% for folder in folders %}
                    {% if loop.first %}
                        <ul class="nav">
                    {% endif %}

                    <li><a href="{{ folder.U_FOLDER }}">{{ folder.FOLDER_NAME }}</a></li>

                    {% if loop.last %}
                        </ul>
                    {% endif %}
                {% endfor %}
                </ul>
            {% endif %}

            <ul class="nav">
            {% for l_block2 in l_block1.l_block2 %}
                <li>
                    {% if l_block2.S_SELECTED %}
                        <strong>{{ l_block2.L_TITLE }}</strong>
                    {% else %}
                        <a href="{{ l_block2.U_TITLE }}">{{ l_block2.L_TITLE }}</a>
                    {% endif %}
                </li>
            {% endfor %}
            </ul>
        {% else %}
            <a class="nav" href="{{ l_block1.U_TITLE }}">{{ l_block1.L_TITLE }}</a>
        {% endif %}
    {% endfor %}

**Checking for first and last iteration:**

Use `loop.first` and `loop.last`:

.. code-block:: html

    {% for folder in folders %}
        {% if loop.first %}
            <ul class="nav">
        {% endif %}

        <li><a href="{{ folder.U_FOLDER }}">{{ folder.FOLDER_NAME }}</a></li>

        {% if loop.last %}
            </ul>
        {% endif %}
    {% endfor %}

**Alternative: Only output markup for certain iterations:**

.. code-block:: html

    {% for folder in folders %}
        {% if loop.first %}
            <ul class="nav">
        {% elseif loop.last %}
            </ul>
        {% else %}
            <li><a href="{{ folder.U_FOLDER }}">{{ folder.FOLDER_NAME }}</a></li>
        {% endif %}
    {% endfor %}

Just always remember that processing is taking place from top to bottom.

Forms
+++++

If a form is used for a non-trivial operation (i.e. more than a jumpbox), then it **SHALL** include the ``{{ S_FORM_TOKEN }}`` template variable.

.. code:: html

	<form method="post" id="mcp" action="{{ U_POST_ACTION }}">

		<fieldset class="submit-buttons">
			<input type="reset" value="{{ lang('RESET') }}" name="reset" class="button2">
			<input type="submit" name="action[add_warning]" value="{{ lang('SUBMIT') }}" class="button1">
			{{ S_FORM_TOKEN }}
		</fieldset>
	</form>


4.ii. Styles Tree
-----------------

Style configuration ``composer.json`` files are derived from the standard `composer` file format, but with a few additional fields specific to phpBB styles.
An important part of the style is assigning a unique name both in the ``name`` field and in the ``display-name`` field in the ``extra`` section of the ``composer.json``:

.. code:: json

    {
        "name": "phpbb/phpbb-style-prosilver",
        "description": "phpBB Forum Software default style",
        "type": "phpbb-style",
        "version": "4.0.0-a1-dev",
        "homepage": "https://www.phpbb.com",
        "license": "GPL-2.0",
        "authors": [
            {
                "name": "phpBB Limited",
                "email": "operations@phpbb.com",
                "homepage": "https://www.phpbb.com/go/authors"
            }
        ],
        "support": {
            "issues": "https://tracker.phpbb.com",
            "forum": "https://www.phpbb.com/community/",
            "docs": "https://www.phpbb.com/support/docs/",
            "irc": "irc://irc.libera.chat/phpbb",
            "chat": "https://www.phpbb.com/support/chat/"
        },
        "extra": {
            "display-name": "prosilver",
            "phpbb-version": "4.0.0-a1-dev",
            "parent-style":  ""
        }
    }

When basing a new style on an existing one, it is not necessary to provide all the template files.
By declaring the base style name in the **parent** field in the **Style configuration file (composer.json)**, the style can be set to reuse template files from the parent style:

.. code:: json

    {
        "name": "acme-author/my-custom-style",
        "description": "My custom style based on prosilver",
        "type": "phpbb-style",
        "version": "1.0.0",
        "homepage": "https://www.some-site.com",
        "license": "GPL-2.0",
        "authors": [
            {
                "name": "ACME Author",
                "email": "acme@some-site.com",
                "homepage": "https://www.some-site.com"
            }
        ],
        "extra": {
            "display-name": "My Custom Style Acme Style",
            "phpbb-version": "4.0.0",
            "parent-style":  "prosilver"
        }
    }

The effect of doing so is that the template engine will use the template files in the new style where they exist, but fall back to files in the parent style otherwise.
In the above example, if the new style does not have a file named ``overall_header.html``, the template engine will use the one from the ``prosilver`` style.

We strongly encourage the use of parent styles for styles based on the bundled styles, as it will ease the update procedure.

.. note::

    The previously used ``style.cfg`` file has been replaced with ``composer.json`` in phpBB 4.0. The new format is more flexible and allows for better integration.

4.iii. Template Events
----------------------

Template events **SHALL** follow this format: ``{% EVENT event_name %}``.

Using the above example, files named ``event_name.html`` located within extensions will be injected into the location of the event.

.. note::

    The previously used ``<!-- EVENT event_name -->`` syntax has been deprecated in phpBB 4.0 and will be removed in a later version of phpBB. Please use the new Twig syntax instead.

Template event naming guidelines
++++++++++++++++++++++++++++++++

- An event name must be all lowercase, with each word separated by an underscore.
- An event name must briefly describe the location and purpose of the event.
- An event name must end with one of the following suffixes:
	- ``_prepend`` - This event adds an item to the beginning of a block of related items, or adds to the beginning of individual items in a block.
	- ``_append`` - This event adds an item to the end of a block of related items, or adds to the end of individual items in a block.
	- ``_before`` - This event adds content directly before the specified block
	- ``_after`` - This event adds content directly after the specified block

Template event documentation
++++++++++++++++++++++++++++

Events must be documented in ``phpBB/docs/events.md`` in alphabetical order based on the event name. The format is as follows:

- An event found in only one template file:

.. code:: php

	event_name
	===
	* Location: styles/<style_name>/template/filename.html
	* Purpose: A brief description of what this event should be used for.
	This may span multiple lines.
	* Since: Version since when the event was added

- An event found in multiple template files:

.. code:: php

	event_name
	===
	* Locations:
	    + first/file/path.html
	    + second/file/path.html
	* Purpose: Same as above.
	* Since: 3.2.0-b1

- An event that is found multiple times in a file should have the number of instances in parenthesis next to the filename.

.. code:: php

	event_name
	===
	* Locations:
	    + first/file/path.html (2)
	    + second/file/path.html
	* Purpose: Same as above.
	* Since: 3.2.0-b1

- An actual example event documentation:

.. code:: php

	forumlist_body_last_post_title_prepend
	====
	* Locations:
	    + styles/prosilver/template/forumlist_body.html
	    + styles/subsilver2/template/forumlist_body.html
	* Purpose: Add content before the post title of the latest post in a forum on the forum list.
	* Since: 3.2.0-a1
