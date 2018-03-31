In working on large, long running projects with dozens of developers, it is important that we all work in a unified way in order to, among other things:

-  Keep code maintainable
-  Keep code transparent and readable
-  Keep code scalable

There are a variety of techniques we must employ in order to satisfy these goals.

The Importance of a Styleguide
------------------------------

A coding styleguide (note, not a visual styleguide) is a valuable tool for teams who

-  build and maintain products for a reasonable length of time
-  have developers of differing abilities and specialisms
-  have a number of different developers working on a product at any given time
-  on-board new staff regularly
-  have a number of codebases that developers dip in and out of

Whilst styleguides are typically more suited to production teams—large codebases on long-lived and evolving projects, with multiple developers contributing over prolonged periods of time—all developers should strive for a degree of standardization in their code.

A good styleguide, when well followed, will

-  set the standard for code quality across a codebase
-  promote consistency across codebases
-  give developers a feeling of familiarity across codebases
-  increase productivity

Disclaimers
~~~~~~~~~~~

These Guidelines are a styleguide; they may not be the styleguide. They contain methodologies, techniques, and tips that we firmly recommend to teams

They are opinionated, but have been repeatedly tried, tested, stressed, refined, broken, reworked, and revisited over a number of years on projects of all sizes.

They should be learned, understood, and implemented at all times on this project, any deviation must be fully justified.

Some General principles
-----------------------

    “Part of being a good steward to a successful project is realizing
    that writing code for yourself is a Bad Idea™. If thousands of
    people are using your code, then write your code for maximum
    clarity, not your personal preference of how to get clever within
    the spec.” - Idan Gazit

-  Don’t try to prematurely optimize your code; keep it readable and understandable
-  All code should look like a single person typed it, even when many people are contributing to it
-  We use a strictly enforced agreed-upon style based on existing common patterns

Meaningful Whitespace
---------------------

Only one style should exist across the entire source of all your code-base. Always be consistent in your use of whitespace. Use whitespace to improve readability.

-  Never mix spaces and tabs for indentation. Stick to your choice without fail (**Preference: tabs**)
-  Choose the number of preferred characters used per indentation level (**Preference: 4 spaces**)

.. warning::

configure your editor to “show invisibles” or to automatically remove end-of-line whitespace. The use of an `EditorConfig`_ file is being used to help maintain the basic whitespace conventions.

As well as indentation, we can provide a lot of information through liberal and judicious use of whitespace between rulesets. We use:

-  One (1) empty line between closely related rulesets
-  Two (2) empty lines between loosely related rulesets

For example:

.. code:: scss

    //------------------------------------------------------------------------------
    // #FOO
    //------------------------------------------------------------------------------

    .foo { }

        .foo__bar { }


    .foo--baz { }

There should never be a scenario in which two rulesets do not have an empty line between them. This would be incorrect:

.. code:: scss

    .foo { }
        .foo__bar { }
    .foo--baz { }

Multiple Files
~~~~~~~~~~~~~~

With the meteoric rise of preprocessors of late, more often is the case that developers are splitting CSS across multiple files.

Even if not using a preprocessor, it is a good idea to split discrete chunks of code into their own files, which are concatenated during a build step.

We follow the ITCSS principles for the organization of our code and as such everything is broken up into partials. All partials are to be named to reflect the contained component/module and lead by an underscore(\ ``_``) to prevent self rendering.

Commenting
----------

**CSS needs more comments.**

The cognitive overhead of working with CSS is huge. With so much to be aware of, and so many project-specific nuances to remember, the worst situation most developers find themselves in is being the-person-who-didn’t-write-this-code. Remembering your own classes, rules, objects, and helpers is manageable to an extent, but anyone inheriting CSS barely stands a chance.

This is why well commented code is extremely important. Take time to describe components, how they work, their limitations, and the way they are constructed. Don’t leave others in the project guessing as to the purpose of uncommon or non-obvious code.

Comment style should be simple and consistent within the code base.

-  Place comments on a new line above their subject
-  Keep line-length to a sensible maximum, e.g., 80 columns
-  Make liberal use of comments to break CSS code into discrete sections
-  Use “sentence case” comments and consistent text indentation

As CSS is something of a declarative language that doesn’t really leave much of a paper-trail, it is often hard to discern—from looking at the CSS alone

-  whether some CSS relies on other code elsewhere
-  what effect changing some code will have elsewhere
-  where else some CSS might be used
-  what styles something might inherit (intentionally or otherwise)
-  what styles something might pass on (intentionally or otherwise)
-  where the author intended a piece of CSS to be used

This doesn’t even take into account some of CSS’ many quirks—such as various sates of ``overflow`` triggering block formatting context, or certain transform properties triggering hardware acceleration—that make it even more baffling to developers inheriting projects.

As a result of CSS not telling its own story very well, it is a language that really does benefit from being heavily commented. As a rule, you should comment anything that isn’t immediately obvious from the code alone. That is to say, there is no need to tell someone that ``color: red;`` will make something red, but if you’re using ``overflow: hidden;`` to clear floats—as opposed to clipping an element’s overflow—this is probably something worth documenting.

.. warning::

Tip: you can configure your editor to provide you with shortcuts to output agreed-upon comment patterns.

Comment Example:

.. code:: scss

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
~~~~~~~~~

Oftentimes we want to comment on specific declarations (i.e. lines) in a ruleset. To do this we use a kind of reverse footnote. Here is a more complex comment detailing the larger site headers mentioned above:

.. code:: scss

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
    // 9. Prevent default browser outline halo
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

These types of comment allow us to keep all of our documentation in one place whilst referring to the parts of the ruleset to which they belong.

Titling
~~~~~~~

Begin every new major section of a CSS project with a title:

.. code:: scss

    //------------------------------------------------------------------------------
    // #SECTION-TITLE
    //------------------------------------------------------------------------------

    .selector { }

The title of the section is prefixed with a hash (``#``) symbol to allow us to perform more targeted searches (e.g. ``grep``, etc.): instead of searching for just ``SECTION-TITLE``—which may yield many results—a more scoped search of ``#SECTION-TITLE`` should return only the section in question.

Leave a carriage return between this title and the next line of code (be that a comment, some Sass, or some CSS).

Preprocessor Comments
~~~~~~~~~~~~~~~~~~~~~

With most—if not all—preprocessors, we have the option to write comments that will not get compiled out into our resulting CSS file. As a rule, use these comments to speed up and prevent errors in the minification step.

.. _EditorConfig: http://editorconfig.org/
