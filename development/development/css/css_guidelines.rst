Introduction
------------

CSS is not a pretty language. While it is simple to learn and get started with, it soon becomes problematic at any reasonable scale. There isn’t much we can do to change how CSS works, but we can make changes to the way we author and structure it.

There are a variety of techniques we must employ in order to satisfy these goals, and CSS Guidelines is a document of recommendations and approaches that will help us to do so.

The first part of this will deal with syntax, formatting, and CSS anatomy. The second part will deal with approach, mindframe, and attitude toward writing/architecting CSS.

Syntax and Formatting
---------------------

One of the simplest forms of a styleguide is a set of rules regarding syntax and formatting. Having a standard way of writing (literally writing) CSS means that code will always look and feel familiar to all members of the team.

Further, code that looks clean feels clean. It is a much nicer environment to work in, and prompts other team members to maintain the standard of cleanliness that they found. Ugly code sets a bad precedent.

The chosen code format must ensure that code is: easy to read, easy to clearly comment, minimizes the chance of accidentally introducing errors, and results in useful diffs and blames.

At a very high-level, we want

-  Tab (4 space width) indents
-  80 character wide columns
-  multi-line CSS
-  a meaningful use of comments & whitespace

Anatomy of a Ruleset
~~~~~~~~~~~~~~~~~~~~

Before we discuss how we write out our rulesets, let’s first familiarize ourselves with the relevant terminology:

The following is a ``[ruleset]``

.. code-block::

    [selector],
    [selector] {
        [property]: [value]; |
        [property]: [value]; | <- [declaration-block]
        [property]: [value]; |
        [<--declaration--->]
    }

Formating
~~~~~~~~~

-  Use one discrete selector per line in multi-selector rulesets
-  The opening brace (``{``) should be on the same line as our last selector
-  Include a single space before the opening brace (``{``)
-  Include properties and values on the same line
-  Include one declaration per line in a declaration block
-  Use one level of indentation for each declaration
-  Include a single space after the colon (``:``) of a declaration
-  Use lowercase hex values, e.g. #abc123
-  Use quotes consistently. **Preference double quotes**, e.g. ``content: ""``
-  Always quote attribute values in selectors, e.g. ``input[type="checkbox"]``
-  Avoid specifying units for zero-values, e.g. ``margin: 0``
-  Always use leading zeros, e.g. ``font-size: 0.875rem``
-  Include a space after each comma (``,``) in comma-separated property or function values
-  Include a semi-colon (``;``) at the end of every declaration including the last in a declaration block
-  Place the closing brace (``}``) of a ruleset in the same column as the first character of the ruleset, on its own line
-  Separate each ruleset by a blank line

Example:

.. code:: scss

    .selector-1,
    .selector-2,
    .selector-3[type="text"] {
        -webkit-box-sizing: border-box;
        -moz-box-sizing: border-box;
        box-sizing: border-box;
        display: block;
        padding: 0;
        font-family: helvetica, arial, sans-serif;
        color: #333333;
        background: #ffffff;
        background: linear-gradient(#ffffff, rgba(0, 0, 0, 0.8));
    }

    .selector-a,
    .selector-b {
        padding: 10px;
    }

This format seems to be the largely universal standard (except for variations in indentation).

As such, the following would be incorrect:

.. code:: scss

    .foo, .foo-bar, .baz
    {
      display:block;
      background-color:green;
      color:red }

Problems here include

-  2 spaces instead of tabs (4 space width)
-  selectors on the same line
-  the opening brace (``{``) on its own line
-  the closing brace (``}``) does not sit on its own line
-  the last semi-colon (``;``) is missing
-  no spaces after colons (``:``)

Multi-line CSS
~~~~~~~~~~~~~~

CSS should be written across multiple lines, except in very specific circumstances. There are a number of benefits to this:

-  A reduced chance of merge conflicts, because each piece of functionality exists on its own line.
-  More ‘truthful’ and reliable ``diffs``, because one line only ever carries one change.

Exceptions to this rule should be fairly apparent, such as similar rulesets that only carry one declaration each, for example:

.. code:: css

    .icon {
        display: inline-block;
        width: 16px;
        height: 16px;
        background-image: url(/img/sprite.svg);
    }

    .icon-home     { background-position: 0 0; }
    .icon-person   { background-position: -16px 0; }
    .icon-files    { background-position: 0 -16px; }
    .icon-settings { background-position: -16px -16px; }

These types of ruleset benefit from being single-lined because

-  they still conform to the one-reason-to-change-per-line rule
-  they share enough similarities that they don’t need to be read as thoroughly as other rulesets - there is more benefit in being able to scan their selectors, which are of more interest to us in these cases

Declaration order
~~~~~~~~~~~~~~~~~

declarations are to be consistently ordered by related property declarations following the order

#. Typographic
#. Visual
#. Positioning
#. Box model
#. Misc

Example:

.. code:: scss

    .declaration-order {
        /* Typography */
        font: normal 13px "Helvetica Neue", sans-serif;
        line-height: 1.5;
        text-align: center;

        /* Visual */
        background-color: #f5f5f5;
        border: 1px solid #e5e5e5;
        border-radius: 3px;
        color: #333333;

        /* Positioning */
        position: absolute;
        z-index: 100;
        top: 0;
        right: 0;
        bottom: 0;
        left: 0;

        /* Box-model */
        display: block;
        float: right;
        width: 100px;
        height: 100px;
        margin: 0;
        padding: 8px;

        /* Misc */
        content: "-";
    }

Proper use of units
~~~~~~~~~~~~~~~~~~~

Because CSS allows for the use of several different unit types, it can get confusing when using more than one type of unit throughout. For that reason it's beneficial to stick to a strict set of rules for what unit types are to be used for certain selectors.

Furthermore there are certain reasons to use or avoid using specific units in certain places.

EM
^^

The ‘em’ unit. This is a very problematic unit which wreaks havoc on countless projects due to the way it's calculated. As such, this unit type must be avoid except for very very minimal use cases. We prevent the use of ``em`` except for ``letter-spacing`` & ``word-spacing``. It is also used for icon sizing, but that is an edge case.

Line-heights
^^^^^^^^^^^^

All line-heights are to be specified as ``unitless`` in order to prevent improper inheritance. By nature when using units with line-heights, the children inherit by default. This can lead to unwanted effects and bloated code. A ``sass`` function called ``unitless`` is provided which will convert px values for convenience, but for clarity the math is simply

.. code:: scss

    line-height: (desired px value) / (current elements font-size)

Font-size
^^^^^^^^^

All ``font-size`` should be specified either in ``px`` or ``%`` in small cases. All px values will be converted to ``rem`` during the build process as ``rem`` provides for control in responsive situations.

Margins & Paddings
^^^^^^^^^^^^^^^^^^

All ``margin`` & ``padding`` should be specified in ``px`` values or ``%``. All ``px`` values will be converted to ``rem`` during the build process as ``rem`` provides for control in responsive situations.

PX
^^

All ``px`` will be whole numbers. Browsers do not render ``px`` in fractional values despite what your browser may say it is. Only calculated values will display as fractional ``px``. For clarification a calculated value would be units like ``rem``, ``em``, ``%``, & even ``unitless`` as is the case with line-heights.

Dimensions
^^^^^^^^^^

All dimensional values ``width``, ``min-width``, ``height``, & ``min-height`` should be specified in ``px`` or ``%``. A case can be made for ``vw`` & ``vh``, but they are still on the fringe of browser acceptance, as such fallbacks in ``px`` or ``%`` are required. These values will remain as px if specified. This is done as ``height`` is more effectively and appropriately controlled via the ``line-height`` property, and ``width`` is better specified using the objects box-model via ``padding`` unless its fluid in which ``100%`` can be specified or you can also use ``left: 0; right: 0;``

Indenting Sass
^^^^^^^^^^^^^^

Sass provides nesting functionality. That is to say, by writing this:

.. code::

    .foo {
        color: red;

        .bar {
            color: blue;
        }
    }

… we will be left with this compiled CSS:

.. code:: css

    .foo { color: red; }
    .foo .bar { color: blue; }

When indenting Sass, we stick to the same four space tab indentation, and we also leave a blank line before and after the nested ruleset.

**N.B.** Nesting in Sass should be avoided in most cases. See the Specificity section for more data

CSS Variables
~~~~~~~~~~~~~

CSS Variables allow you to store and reuse values throughout your stylesheets. This promotes maintainability and reduces the risk of inconsistencies.

Here are some guidelines for using CSS variables effectively in phpBB styles:

- Store project-wide values:

    Use variables to define core UI aspects like colors, spacing, and fonts. Prefix these variables with `--phpbb-` in the phpBB core to avoid naming conflicts.
    For example:

    .. code:: css

        :root {
          --phpbb-primary-color: #1abc9c;
          --phpbb-secondary-color: #34495e;
          --phpbb-text-color: #ecf0f1;
          --phpbb-font-size: 16px;
          --phpbb-line-height: 1.5;
        }

- Create style-specific variables:
    If styles differ or might differ between phpBB styles (e.g. prosilver), use the style's name as a prefix (e.g. --prosilver-) for style-specific variables.
    This allows for customization without affecting other styles. For instance:

    .. code:: css

        :root {
          --prosilver-background-color: #f5f5f5;
          --prosilver-border-color: #ddd;
        }

        .content {
          background-color: var(--prosilver-background-color);
          border: 1px solid var(--prosilver-border-color);
        }

    In this example, `--phpbb-primary-color` defines the primary color used throughout the project, while `--prosilver-background-color` sets the background color specifically for the prosilver style.

By following these recommendations, you can leverage the power of CSS variables to create a more maintainable and efficient codebase for your phpBB styles.

Benefits of Using CSS Variables:

- Improved Maintainability: Makes it easier to update core styles or style-specific customizations by changing the variable value in one place.
- Reduced Repetition: Eliminates the need to repeat the same value throughout your stylesheets.
- Flexibility: Provides greater control over styles and the ability to create themes with unique appearances.

For a detailed explanation of CSS Variables, refer to the `MDN Web Docs: Using CSS custom properties (variables) <https://developer.mozilla.org/en-US/docs/Web/CSS/Using_CSS_custom_properties>`_.


Enforcing standardization
~~~~~~~~~~~~~~~~~~~~~~~~~

Our project makes use of several tools to lint and keep code up to standards.

1. `stylelint.io`_
^^^^^^^^^^^^^^^^^^

.. note:: This is used to provide detailed linting for our standards via the ``.stylelintrc`` file in the root of the project.

2. `postcss-sorting`_
^^^^^^^^^^^^^^^^^^^^^

.. note:: This is used to provide automatic sorting to our declaration order via the ``.postcss-sorting.json`` file in the root of the project.

3. `postcss-pxtorem`_
^^^^^^^^^^^^^^^^^^^^^

.. note:: This is used to ensure that proper units are consistently used throughout the project during the build process via ``gulp`` as well as on save in your editor.

4. `stylefmt`_
^^^^^^^^^^^^^^

.. note:: This is used to help automatically re-format your code on-the-fly to meet standards during the build process via ``gulp`` as well as on save in your editor.

.. note:: Our editors of choice are `PhpStorm`_ & `ATOM`_ which provide useful plugins to make use of these tools. Check out the `Editor Setup`_ section of the docs for more information

.. _stylelint.io: http://www.stylelint.io
.. _postcss-sorting: https://github.com/hudochenkov/postcss-sorting
.. _postcss-pxtorem: https://github.com/cuth/postcss-pxtorem
.. _stylefmt: https://github.com/morishitter/stylefmt
.. _PhpStorm: https://www.jetbrains.com/phpstorm/
.. _ATOM: http://www.atom.io
.. _Editor Setup: /editor-setup
