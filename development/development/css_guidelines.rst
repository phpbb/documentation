Introduction
============

CSS is not a pretty language. While it is simple to learn and get started with,
it soon becomes problematic at any reasonable scale. There isn’t much we can do
to change how CSS works, but we can make changes to the way we author and
structure it.

There are a variety of techniques we must employ in order to satisfy these
goals, and CSS Guidelines is a document of recommendations and approaches that
will help us to do so.

The first part of this will deal with syntax, formatting and CSS anatomy, the
second part will deal with approach, mind frame and attitude toward writing and
architecting CSS.


Meaningful Whitespace
=====================

Only one style should exist across the entire source of all your code-base.
Always be consistent in your use of whitespace. Use whitespace to improve
readability.

- Never mix spaces and tabs for indentation. Stick to your choice without fail. (**Preference: tabs**)
- Choose the number of preferred characters used per indentation level. (**Preference: 4 spaces**)

.. warning::

configure your editor to "show invisibles" or to automatically remove end-of-line whitespace. The use of an `EditorConfig <http://editorconfig.org/>`_ file is being used to help maintain the basic whitespace conventions.


As well as indentation, we can provide a lot of information through liberal and
judicious use of whitespace between rulesets. We use:

- One (1) empty line between closely related rulesets.
- Two (2) empty lines between loosely related rulesets.

For example:

.. code-block:: scss

  //------------------------------------------------------------------------------
  // #FOO
  //------------------------------------------------------------------------------

  .foo { }

      .foo__bar { }


  .foo--baz { }


There should never be a scenario in which two rulesets do not have an empty line
between them. This would be incorrect:

.. code-block:: scss

  .foo { }
      .foo__bar { }
  .foo--baz { }



Multiple Files
==============

With the meteoric rise of preprocessors of late, more often is the case that
developers are splitting CSS across multiple files.

Even if not using a preprocessor, it is a good idea to split discrete chunks of
code into their own files, which are concatenated during a build step.

We follow the ITCSS principles for the organization of our code and as such
everything is broken up into partials. All partials are to be named to reflect
the contained component/module and lead by an underscore(`_`) to prevent self
rendering.


Commenting
==========

**CSS needs more comments.**

The cognitive overhead of working with CSS is huge. With so much to be aware of,
and so many project-specific nuances to remember, the worst situation most
developers find themselves in is being the-person-who-didn’t-write-this-code.
Remembering your own classes, rules, objects, and helpers is manageable to an
extent, but anyone inheriting CSS barely stands a chance.

This is why well commented code is extremely important. Take time to describe
components, how they work, their limitations, and the way they are constructed.
Don't leave others in the project guessing as to the purpose of uncommon or
non-obvious code.

Comment style should be simple and consistent within the code base.

- Place comments on a new line above their subject.
- Keep line-length to a sensible maximum, e.g., 80 columns.
- Make liberal use of comments to break CSS code into discrete sections.
- Use "sentence case" comments and consistent text indentation.

As CSS is something of a declarative language that doesn’t really leave much of
a paper-trail, it is often hard to discern—from looking at the CSS alone—

- whether some CSS relies on other code elsewhere;
- what effect changing some code will have elsewhere;
- where else some CSS might be used;
- what styles something might inherit (intentionally or otherwise);
- what styles something might pass on (intentionally or otherwise);
- where the author intended a piece of CSS to be used.

This doesn’t even take into account some of CSS’ many quirks—such as various
sates of `overflow` triggering block formatting context, or certain transform
properties triggering hardware acceleration—that make it even more baffling to
developers inheriting projects.

As a result of CSS not telling its own story very well, it is a language that
really does benefit from being heavily commented.

As a rule, you should comment anything that isn’t immediately obvious from the
code alone. That is to say, there is no need to tell someone that `color: red;`
will make something red, but if you’re using `overflow: hidden;` to clear
floats—as opposed to clipping an element’s overflow—this is probably something
worth documenting.

.. warning::

Tip: you can configure your editor to provide you with shortcuts to output agreed-upon comment patterns.

Comment Example:

.. code-block:: scss

  //------------------------------------------------------------------------------
  // #[LAYER]: PARTIAL NAME
  //------------------------------------------------------------------------------
  // #description
  //
  // This is a description of the PARTIAL
  //
  //------------------------------------------------------------------------------

  //
  // #settings

  // Layout Variables
  $variable: [value]

  // Theme Variables
  $variable: [value]

  //
  // #scss

  //
  // 1. inline comment
  // 2. inline comment
  // 3. inline comment
  //

  [selector] {
      [property]: [value];
      [property]: [value]; // [1]
      [property]: [value]; // [1]
      [property]: [value]; // [2]
      [property]: [value];
      [property]: [value]; // [3]
  }

  //
  // Section Block Comment
  //------------------------------------------------------------------------------
  //
  // 1. inline comment
  // 2. inline comment
  // 3. inline comment
  //
  [selector] {
      [property]: [value];
      [property]: [value]; // [1]
      [property]: [value]; // [1]
      [property]: [value]; // [2]
      [property]: [value];
      [property]: [value]; // [3]
  }



Low-level
---------

Oftentimes we want to comment on specific declarations (i.e. lines) in a
ruleset. To do this we use a kind of reverse footnote. Here is a more complex
comment detailing the larger site headers mentioned above:

.. code-block:: scss

  //
  // 1. Allow us to style box model properties.
  // 2. Line different sized buttons up a little nicer.
  // 3. Make buttons inherit font styles (often necessary when styling `input`s as
  //    buttons).
  // 4. Reset/normalize some styles.
  // 5. Force all button-styled elements to appear clickable.
  // 6. Fixes odd inner spacing in IE7.
  // 7. Subtract the border size from the padding value so that buttons do not
  //    grow larger as we add borders.
  // 8. Prevent button text from being selectable.
  // 9. Prevent deafult browser outline halo
  //
  .o-btn {
      @include type(button);
      @include shadow(2);
      line-height: unitless($btn-height, map-get(map-get($type-styles, button), font-size));
      text-align: center; // [4]
      vertical-align: middle; // [2]
      white-space: nowrap;
      text-decoration: none; // [4]
      background-color: $btn-background-color;
      border: none;
      border-radius: $btn-border-radius;
      outline: none; // [9]
      color: $btn-text-color;
      position: relative;
      display: inline-block; // [1]
      overflow: hidden; // [6]
      min-width: $btn-min-width;
      margin: 0; // [4]
      padding: 0 $btn-spacing; // [7]
      cursor: pointer;
      user-select: none; // [8]
      transition:
          box-shadow 0.2s $animation-curve-fast-out-linear-in,
          background-color 0.2s $default-animation-curve,
          color 0.2s $default-animation-curve;
      will-change: box-shadow;
  }


These types of comment allow us to keep all of our documentation in one place
whilst referring to the parts of the ruleset to which they belong.


Titling
-------

Begin every new major section of a CSS project with a title:

.. code-block:: scss

  //------------------------------------------------------------------------------
  // #SECTION-TITLE
  //------------------------------------------------------------------------------

  .selector { }


The title of the section is prefixed with a hash (`#`) symbol to allow us to
perform more targeted searches (e.g. `grep`, etc.): instead of searching for
just `SECTION-TITLE`—which may yield many results—a more scoped search of
`#SECTION-TITLE` should return only the section in question.

Leave a carriage return between this title and the next line of code (be that a
comment, some Sass, or some CSS).


Preprocessor Comments
---------------------

With most—if not all—preprocessors, we have the option to write comments that
will not get compiled out into our resulting CSS file. As a rule, use these
comments to speed up and prevent errors in the minification step.


Syntax and Formatting
=====================

One of the simplest forms of a styleguide is a set of rules regarding syntax and
formatting. Having a standard way of writing (literally writing) CSS means that
code will always look and feel familiar to all members of the team.

Further, code that looks clean feels clean. It is a much nicer environment to
work in, and prompts other team members to maintain the standard of cleanliness
that they found. Ugly code sets a bad precedent.

The chosen code format must ensure that code is: easy to read; easy to clearly
comment; minimizes the chance of accidentally introducing errors; and results in
useful diffs and blames.

At a very high-level, we want

- Tab (4 space width) indents;
- 80 character wide columns;
- multi-line CSS;
- a meaningful use of comments & whitespace.


Anatomy of a Ruleset
--------------------

Before we discuss how we write out our rulesets, let’s first familiarize ourselves with the relevant terminology:

The following is a ``[ruleset]``

.. code-block:: text

  [selector],
  [selector] {
    [property]: [value]; |
    [property]: [value]; | <- [declaration-block]
    [property]: [value]; |
    [<--declaration--->]
  }



Formatting
---------

- Use one discrete selector per line in multi-selector rulesets.
- The opening brace (``{``) should be on the same line as our last selector.
- Include a single space before the opening brace (``{``).
- Include properties and values on the same line.
- Include one declaration per line in a declaration block.
- Use one level of indentation for each declaration.
- Include a single space after the colon (``:``) of a declaration.
- Use lowercase hex values, e.g., #abc123.
- Use quotes consistently. **Preference double quotes**, e.g., ``content: ""``.
- Always quote attribute values in selectors, e.g., ``input[type="checkbox"]``.
- Avoid specifying units for zero-values, e.g., ``margin: 0``.
- Always use leading zeros, e.g, ``font-size: 0.875rem``
- Include a space after each comma(``,``) in comma-separated property or function values.
- Include a semi-colon(``;``) at the end of every declaration including the last in a declaration block.
- Place the closing brace (``}``) of a ruleset in the same column as the first character of the ruleset, on its own line.
- Separate each ruleset by a blank line.

Example:

.. code-block:: scss

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


This format seems to be the largely universal standard (except for variations in
indentation).

As such, the following would be incorrect:

.. code-block:: scss

  .foo, .foo-bar, .baz
  {
    display:block;
    background-color:green;
    color:red }


Problems here include

- 2 spaces instead of tabs (4 space width).
- selectors on the same line.
- the opening brace (``{``) on its own line.
- the closing brace (``}``) does not sit on its own line.
- the last semi-colon (``;``) is missing.
- no spaces after colons (``:``).


Multi-line CSS
--------------

CSS should be written across multiple lines, except in very specific
circumstances. There are a number of benefits to this:

- A reduced chance of merge conflicts, because each piece of functionality exists on its own line.
- More ‘truthful’ and reliable ``diffs``, because one line only ever carries one change.

Exceptions to this rule should be fairly apparent, such as similar rulesets
that only carry one declaration each, for example:

.. code-block:: css

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

- they still conform to the one-reason-to-change-per-line rule;
- they share enough similarities that they don’t need to be read as thoroughly as other rulesets—there is more benefit in being able to scan their selectors, which are of more interest to us in these cases.


Declaration order
-----------------

declarations are to be consistently ordered by related property declarations
following the order

1. Typographic
2. Visual
3. Positioning
4. Box model
5. Misc

Example:

.. code-block:: scss

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



Proper Use of units
-------------------

CSS allows for the use of several different unit types. As such it can get
confusing when using more than one type of unit through out the project. For
that reason its beneficial to stick to a stick set of rules for what unit types
are to be used for certain selectors.

Furthermore there are certain reasons to use or avoid using specific units in
certain places.

EM
++
The 'em' unit. This is a very problematic unit which reeks havoc on countless
projects due to the way its calculated. As such this unit type must be avoid
except for very very minimal use cases. We prevent the use of ``em`` except for
``letter-spaceing`` & ``word-spacing``. It is also used for icon sizing but that is
an edge case.

Line-heights
++++++++++++

All line-heights are to be specified as unitless in order to prevent in proper
inheritance. By nature when using units with line-heights the children inherit
by default. This can lead to unwanted effects and bloated code. A ``sass``
function called ``unitless`` is provided which will convert px values for
convenience, but for clarity the math is simply

.. code-block:: scss

	line-height: (desired px value) / (current elements font-size)


Font-size
+++++++++

All ``font-size`` should be specified either in ``px`` or ``%`` in small cases. All px
values will be converted to ``rem`` during the build process as ``rem`` provide for
control in responsive situations.

Margins & Paddings

++++++++++++++++++
All ``margin`` & ``padding`` should be specified in ``px`` values or ``%``. All ``px`` All
px values will be converted to ``rem`` during the build process as `rem` provide
for control in responsive situations.

PX
++
All ``px`` will be whole numbers. Browsers do not render ``px`` in fractional values
despite what you browser may say it is. Only calculated values will display as
fractional ``px``. For clarification a calculated value would be units like ``rem``,
``em``, ``%``, & even ``unitless`` as is the case with line-heights.

Dimensions
++++++++++

All dimensional values ``width``, ``min-width``, ``height``, & ``min-height`` should be
specified in ``px`` or ``%``. A case can be made for ``vw`` & ``vh``, but they are still
on the fringe of browser acceptance, as such fallbacks in ``px`` or ``%`` are
required. These values will remain as px if specified. This is done as ``height``
is more effectively and appropriately controlled via the ``line-height`` property,
and ``width`` is better specified using the objects box-model via ``padding`` unless
its fluid in which ``100%`` can be specified or u can also use
``left: 0; right: 0;``



Indenting Sass
++++++++++++++

Sass provides nesting functionality. That is to say, by writing this:

.. code-block:: css

  .foo {
    color: red;

    .bar {
        color: blue;
    }
  }


…we will be left with this compiled CSS:

.. code-block:: css

  .foo { color: red; }
  .foo .bar { color: blue; }


When indenting Sass, we stick to the same two indentation, and we also leave a
blank line before and after the nested ruleset.


**N.B.** Nesting in Sass should be avoided in most cases. See `Specificity`_ for more details.


Enforcing standardization
-------------------------

Our project makes use of several tools to lint and to keep us to the standards.

1. `stylelint.io <http://www.stylelint.io>`_
++++++++++++++++++++++++++++++++++++++++++++
.. note::

This is used to provide detailed linting for our standards via the ``.stlyelintrc`` file in the root of the project.

2. `postcss-sorting <https://github.com/hudochenkov/postcss-sorting>`_
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
.. note::

This is used to provide automatic sorting to our declaration order via the ``.postcss-sorting.json`` file in the root of the project.

3. `postcss-pxtorem <https://github.com/cuth/postcss-pxtorem>`_
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
.. note::

This is used to ensure the proper units are consistently used throughout the project during the build process via the ``gulp`` as well as on save in your editor.

4. `stylefmt <https://github.com/morishitter/stylefmt>`_
++++++++++++++++++++++++++++++++++++++++++++++++++++++++
.. note::

This is used to help automatically re-format your code to the standards on the fly during the build process via ``gulp`` as well as on save in your editor.

.. warning::

As a **NOTE** our editor of choice is `ATOM <http://www.atom.io>`_ which provides useful plugins to make use of these tools. Checkout the `Editor Setup`_ section of the docs for more information
