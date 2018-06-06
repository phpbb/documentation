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

.. code:: css

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

CSS allows for the use of several different unit types. As such it can get confusing when using more than one type of unit throughout, it's for that reason its beneficial to stick to a strict set of rules for what unit types are to be used for certain selectors.

Furthermore there are certain reasons to use or avoid using specific units in certain places.

EM
^^

The ‘em’ unit. This is a very problematic unit which wreaks havoc on countless projects due to the way its calculated. As such this unit type must be avoid except for very very minimal use cases. We prevent the use of ``em`` except for ``letter-spacing`` & ``word-spacing``. It is also used for icon sizing but that is an edge case.

Line-heights
^^^^^^^^^^^^

All line-heights are to be specified as ``unitless`` in order to prevent improper inheritance. By nature when using units with line-heights the children inherit by default. This can lead to unwanted effects and bloated code. A ``sass`` function called ``unitless`` is provided which will convert px values for convenience, but for clarity the math is simply

.. code:: scss

    line-height: (desired px value) / (current elements font-size)

Font-size
^^^^^^^^^

All ``font-size`` should be specified either in ``px`` or ``%`` in small cases. All px values will be converted to ``rem`` during the build process as ``rem`` provide for control in responsive situations.

Margins & Paddings
^^^^^^^^^^^^^^^^^^

All ``margin`` & ``padding`` should be specified in ``px`` values or ``%``. All ``px`` values will be converted to ``rem`` during the build process as ``rem`` provide for control in responsive situations.

PX
^^

All ``px`` will be whole numbers. Browsers do not render ``px`` in fractional values despite what your browser may say it is. Only calculated values will display as fractional ``px``. For clarification a calculated value would be units like ``rem``, ``em``, ``%``, & even ``unitless`` as is the case with line-heights.

Dimensions
^^^^^^^^^^

All dimensional values ``width``, ``min-width``, ``height``, & ``min-height`` should be specified in ``px`` or ``%``. A case can be made for ``vw`` & ``vh``, but they are still on the fringe of browser acceptance, as such fallbacks in ``px`` or ``%`` are required. These values will remain as px if specified. This is done as ``height`` is more effectively and appropriately controlled via the ``line-height`` property, and ``width`` is better specified using the objects box-model via ``padding`` unless its fluid in which ``100%`` can be specified or you can also use ``left: 0; right: 0;``

Indenting Sass
^^^^^^^^^^^^^^

Sass provides nesting functionality. That is to say, by writing this:

.. code:: css

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

Enforcing standardization
~~~~~~~~~~~~~~~~~~~~~~~~~

Our project makes use of several tools to lint and to keep us to the standards.

1. `stylelint.io`_
^^^^^^^^^^^^^^^^^^

.. note::

This is used to provide detailed linting for our standards via the ``.stylelintrc`` file in the root of the project.

2. `postcss-sorting`_
^^^^^^^^^^^^^^^^^^^^^

.. note::

This is used to provide automatic sorting to our declaration order via the ``.postcss-sorting.json`` file in the root of the project.

3. `postcss-pxtorem`_
^^^^^^^^^^^^^^^^^^^^^

.. note::

This is used to ensure the proper units are consistently used throughout the project during the build process via ``gulp`` as well as on save in your editor.

4. `stylefmt`_
^^^^^^^^^^^^^^

.. note::

This is used to help automatically re-format your code to the standards on the fly during the build process via ``gulp`` as well as on save in your editor.

.. note::

As a **NOTE** our editors of choice are `PhpStorm`_ & `ATOM`_ which provides usefull plugins to make use of these tools. Checkout the `Editor Setup`_ section of the docs for more information

.. _stylelint.io: http://www.stylelint.io
.. _postcss-sorting: https://github.com/hudochenkov/postcss-sorting
.. _postcss-pxtorem: https://github.com/cuth/postcss-pxtorem
.. _stylefmt: https://github.com/morishitter/stylefmt
.. _PhpStorm: https://www.jetbrains.com/phpstorm/
.. _ATOM: http://www.atom.io
.. _Editor Setup: /editor-setup


Naming Conventions
------------------

Naming conventions in CSS are hugely useful in making your code more strict, more transparent, and more informative.

A good naming convention will tell you and your team

-  what type of thing a class does
-  where a class can be used
-  what (else) a class might be related to

The naming convention we follow are as follows

-  Hyphen (``-``) delimited strings
-  Layer namespacing
-  A variation on BEM-like naming for action modifiers

It’s worth noting that not all the naming conventions are normally useful in the CSS side of development; they really come into their own when viewed in HTML.

Hyphen Delimited
~~~~~~~~~~~~~~~~

All strings in classes are delimited with a hyphen (``-``), like so:

.. code:: css

    .page-head { }

    .sub-content { }

Camel case and underscores are not used for regular classes; the following are incorrect:

.. code:: css

    .pageHead { }

    .sub_content { }

Modified BEM-like Naming
~~~~~~~~~~~~~~~~~~~~~~~~

For larger, more interrelated pieces of UI that require a number of classes, we use a modified BEM-like naming convention.

BEM, meaning Block, Element, Modifier, is a front-end methodology coined by developers working at Yandex. Whilst BEM is a complete methodology, here we are only concerned with its naming convention. Further, the naming convention here only is BEM-like; the principles are exactly the same, but the actual syntax differs.

BEM splits components’ classes into three groups:

-  Block: The sole root of the component.
-  Element: A component part of the Block.
-  Modifier: A variant or extension of the Block.

To take an analogy (note, not an example):

.. code:: css

    .dropdown { }
    .dropdown-item { }
    .dropdown--active { }

Elements are delimited with one (1) hyphen (``-``), and Modifiers are delimited by two (2) hyphens (``--``).

Here we can see that ``.dropdown {}`` is the Block; it is the sole root of a discrete entity. ``.dropdown-item {}`` is an Element; it is a smaller part of the ``.dropdown {}`` Block. Finally, ``.dropdown--active {}`` is a Modifier; it is a specific variant of the ``.dropdown {}`` Block.

Starting Context
^^^^^^^^^^^^^^^^

Your Block context starts at the most logical, self-contained, discrete location. To continue with our dropdown-based analogy, we’d not have a class like ``.header-dropdown {}``, as the header is another, much higher context. We’d probably have separate Blocks, like so:

.. code:: css

    .header { }

    .header-nav { }


    .dropdown { }

    .dropdown-item { }

If we did want to denote a ``.dropdown {}`` inside a ``.header {}``, it is more correct to use a selector like ``.header .dropdown {}`` which bridges two Blocks than it is to increase the scope of existing Blocks and Elements.

A more realistic example of properly scoped blocks might look something like this, where each chunk of code represents its own Block:

.. code:: css

    .page { }


    .content { }


    .footer { }

    .footer-copyright { }

Incorrect notation for this would be:

.. code:: css

    .page { }

    .page-content { }

    .page-footer { }

    .page-copyright { }

It is important to know when BEM scope starts and stops. As a rule, BEM applies to self-contained, discrete parts of the UI.

More Layers
^^^^^^^^^^^

If we were to add another Element—called, let’s say, ``.dropdown-link {}``—to this ``.dropdown {}`` component, we would not need to step through every layer of the DOM. That is to say, the correct notation would be ``.dropdown-link {}``, and not ``.dropdown-item-link {}``. Your classes do not reflect the full paper-trail of the DOM.

Layer Namespacing
~~~~~~~~~~~~~~~~~

There are a number of common problems when working with CSS at scale, but the major two that namespacing aims to solve are clarity and confidence:

-  **Clarity:** How much information can we glean from the smallest possible source? Is our code self-documenting? Can we make safe assumptions from a single context? How much do we have to rely on external or supplementary information in order to learn about a system?
-  **Confidence:** Do we have enough knowledge about a system to be able to safely interface with it? Do we know enough about our code to be able to confidently make changes? Do we have a way of knowing the potential side effects of making a change? Do we have a way of knowing what we might be able to remove?

This gets further complicated when dealing with `ITCSS`_. Knowing what layer a class is coming from is not always apparent. To combat this and provide complete transparency we use layer based namespacing.

In no particular order, here are the individual namespaces and a brief description. We’ll look at each in more detail in a moment, but the following list should acquaint you.

-  ``o-``: Signify that something is an Object, and that it may be used in any number of unrelated contexts to the one you can currently see it in. Making modifications to these types of class could potentially have knock-on effects in a lot of other unrelated places. Tread carefully.
-  ``c-``: Signify that something is a Component. This is a concrete, implementation-specific piece of UI. All of the changes you make to its styles should be detectable in the context you’re currently looking at. Modifying these styles should be safe and have no side effects.
-  ``u-``: Signify that this class is a Utility class. It has a very specific role (often providing only one declaration) and should not be bound onto or changed. It can be reused and is not tied to any specific piece of UI. You will probably recognize this namespace from libraries and methodologies like `SUITcss`_.
-  ``t-``: Signify that a class is responsible for adding a Theme to a view. It lets us know that UI Components’ current cosmetic appearance may be due to the presence of a theme. Vastly improves templating for large projects
-  ``s-``: Signify that a class creates a new styling context or Scope. Similar to a Theme, but not necessarily cosmetic, these should be used sparingly—they can be open to abuse and lead to poor CSS if not used wisely.
-  ``is-``, ``has-``: Signify that the piece of UI in question is currently styled a certain way because of a state or condition. This stateful namespace is gorgeous, and comes from `SMACSS`_. It tells us that the DOM currently has a temporary, optional, or short-lived style applied to it due to a certain state being invoked.
-  ``_``: Signify that this class is the worst of the worst—a hack! Sometimes, although incredibly rarely, we need to add a class in our markup in order to force something to work. If we do this, we need to let others know that this class is less than ideal, and hopefully temporary (i.e. do not bind onto this).
-  ``js``-: Signify that this piece of the DOM has some behavior acting upon it, and that JavaScript binds onto it to provide that behavior. If you’re not a developer working with JavaScript, leave these well alone.

Even from this short list alone, we can see just how much more information we can communicate to developers simply by placing a character or two at the front of our existing classes.

Further Reading
'''''''''''''''

   -  `UI Selector Namspacing`_

JavaScript Hooks
~~~~~~~~~~~~~~~~

As a rule, it is unwise to bind your CSS and your JS onto the same class in your HTML. This is because doing so means you can’t have (or remove) one without (removing) the other. It is much cleaner, much more transparent, and much more maintainable to bind your JS onto specific classes. Typically, this is why you sometimes se classes that are prepended with ``js-``, for

example:

.. code:: html

    <input type="submit" class="btn js-btn" value="Follow" />

This means that we can have an element elsewhere which can carry the style of ``.btn {}``, but without the behavior of ``.js-btn``.

``data-*`` Attributes
^^^^^^^^^^^^^^^^^^^^^

A cleaner and preferred practice is to use ``data-*`` attributes as JS hooks.``data-*`` attributes, as per the spec, are typically used to store custom data private to the page or application’. however since you are already binding this attribute to your js, it makes since to use the same attribute as the js hook.

.. _ITCSS: https://www.youtube.com/watch?v=1OKZOV-iLj4
.. _SUITcss: https://suitcss.github.io/
.. _SMACSS: https://smacss.com/
.. _UI Selector Namspacing: https://csswizardry.com/2015/03/more-transparent-ui-code-with-namespaces/


CSS Selectors
-------------

Perhaps somewhat surprisingly, one of the most fundamental, critical aspects of writing maintainable and scalable CSS is selectors. Their specificity, their portability, and their reusability all have a direct impact on the mileage you will get out of the CSS, and the headaches it might bring you.

Selector Intent
~~~~~~~~~~~~~~~

It is important when writing CSS that you scope the selectors correctly, and that you're selecting the right things for the right reasons. Selector Intent is the process of deciding and defining what you want to style and how you will go about selecting it. For example, if you are wanting to style your website’s main navigation menu, a selector like this would be incredibly unwise:

.. code:: css

    header ul { }

This selector’s intent is to style any ``ul`` inside any ``header`` element, whereas your intent was to style the site’s main navigation. This is poor Selector Intent: you can have any number of ``header`` elements on a page, and they in turn can house any number of ``uls``, so a selector like this runs the risk of applying very specific styling to a very wide number of elements. This will result in having to write more CSS to undo the greedy nature of such a selector.

A better approach would be a selector like:

.. code:: css

    .site-nav { }

An unambiguous, explicit selector with good Selector Intent. Explicitly selecting the right thing for exactly the right reason.

Poor Selector Intent is one of the biggest reasons for headaches on CSS projects. Writing rules that are far too greedy, and apply very specific treatments via very far reaching selectors. This causes unexpected side effects and leads to very tangled stylesheets, with selectors overstepping their intentions and impacting and interfering with otherwise unrelated rulesets.

CSS cannot be encapsulated, it is inherently leaky, but you can mitigate some of these effects by not writing such globally operating selectors: **your selectors should be as explicit and well reasoned as your reason for wanting to select something.**

Reusability
~~~~~~~~~~~

With a move toward a more component based approach to constructing UIs, the idea of reusability is paramount. You want the option to be able to move, recycle, duplicate, and syndicate components across our projects.

To this end, make heavy use of classes. IDs, as well as being hugely over specific, cannot be used more than once on any given page. Classes can be reused an infinite amount of times. Everything you choose, from the type of selector to its name, should lend itself toward being reused.

Location Independence
~~~~~~~~~~~~~~~~~~~~~

Given the ever changing nature of most UI projects, and the move to more component based architectures, it is in your best interest not to style things based on where they are, but on what they are. That is to say, your components’ styling should not be reliant upon where its placed. They should remain entirely location independent.

Let’s take an example of a call-to-action button that has been styled via the following selector:

.. code:: css

    .promo a { }

Not only does this have poor Selector Intent, it will greedily style any and every link inside of a ``.promo`` to look like a button. It is also pretty wasteful as a result of being so locationally dependent: you can’t reuse that button with its correct styling outside of ``.promo`` because it is explicitly tied to that location. A far better selector would have been:

.. code:: css

    .btn { }

This single class can be reused anywhere outside of ``.promo`` and will always carry its correct styling. As a result of a better selector, this piece of UI is more portable, more recyclable, doesn’t have any dependencies, and has much better Selector Intent. **A component shouldn’t have to live in a certain place to look a certain way.**

Portability
~~~~~~~~~~~

Reducing or removing, location dependence means that you can move components around our markup more freely, but how about improving the ability to move classes around components? On a much lower level, there are changes you can make to your selectors that make the selectors themselves, as opposed to the components they create more portable. Take the following example:

.. code:: css

    input.btn { }

This is a *qualified* selector; the leading ``input`` ties this ruleset to only being able to work on ``input`` elements. By omitting this qualification, you allow the reuse of the ``.btn`` class on any element you choose, like an ``a``, for example, or a ``button``.

Qualified selectors do not lend themselves well to being reused, and every selector you write should be authored with reuse in mind.

Of course, there are times when you may want to legitimately qualify a selector, you might need to apply some very specific styling to a particular element when it carries a certain class, for example:

.. code:: css

    /**
     * Embolden and color any element with a class of `.error`.
     */
    .error {
        color: red;
        font-weight: bold;
    }

    /**
     * If the element is a `div`, also give it some box-like styling.
     */
    div.error {
        padding: 10px;
        border: 1px solid;
    }

This is one example where a qualified selector might be justifiable, but the recommend approach would be:

.. code:: css

    /**
     * Text-level errors.
     */
    .error-text {
        color: red;
        font-weight: bold;
    }

    /**
     * Elements that contain errors.
     */
    .error-box {
        padding: 10px;
        border: 1px solid;
    }

This means that you can apply ``.error-box`` to any element, and not just a ``div`` it is more reusable than a qualified selector.

Quasi-Qualified Selectors
^^^^^^^^^^^^^^^^^^^^^^^^^

One thing that qualified selectors can be useful for is signaling where a class might be expected or intended to be used, for example:

.. code:: css

    ul.nav { }

Here you can see that the ``.nav`` class is meant to be used on a ``ul`` element, and not on a ``nav``. By using *quasi-qualified selectors* you can still provide that information without actually qualifying the selector:

.. code:: css

    /*ul*/.nav { }

By commenting out the leading element, you can still leave it to be read, but avoid qualifying and increasing the specificity of the selector.

Naming
~~~~~~

As Phil Karlton once said

    ‘There are only two hard things in Computer Science: cache
    invalidation and naming things.’

Without commenting on the former claim here, but the latter has plagued people for years. Our advice with regard to naming things in CSS is to pick a name that is sensible, but somewhat ambiguous: aim for high reusability. For example, instead of a class like ``.site-nav``, choose something like ``.primary-nav``; rather than ``.footer-links``, favor a class like ``.sub-links``.

The differences in these names is that the first of each two examples is tied to a very specific use case: they can only be used as the site’s navigation or the footer’s links respectively. By using slightly more ambiguous names, you can increase the ability to reuse these components in different circumstances.

To quote Nicolas Gallagher:

    'Tying your class name semantics tightly to the nature of the content
    has already reduced the ability of your architecture to scale or be
    easily put to use by other developers.'

That is to say, you should use sensible names or classes. For example ``.border`` or ``.red`` are never advisable, avoid using classes which describe the exact nature of the content and/or its use cases. **Using a class name to describe content is redundant because content describes itself.**

The debate surrounding semantics has raged for years, but it is important that you adopt a more pragmatic, sensible approach to naming things in order to work more efficiently and effectively. Instead of focussing on ‘semantics’, look more closely at sensibility and longevity, choose names based on ease of maintenance, not for their perceived meaning.

Name things for people; they’re the only ones that actually read your classes (everything else merely matches them). Once again, it is better to strive for reusable, recyclable classes rather than writing for specific use cases. Let’s take an example:

.. code:: css

    /**
     * Runs the risk of becoming out of date; not very maintainable.
     */
    .blue { color: blue; }

    /**
     * Depends on location in order to be rendered properly.
     */
    .header span { color: blue; }

    /**
     * Too specific; limits the ability to reuse.
     */
    .header-color { color: blue; }

    /**
     * Nicely abstracted, very portable, doesn’t risk becoming out of date.
     */
    .highlight-color { color: blue; }

It is important to strike a balance between names that do not literally describe the style that the class brings, but also ones that do not explicitly describe specific use cases. Instead of ``.home-page-panel``, choose ``.masthead``; instead of ``.site-nav``, favor ``.primary-nav``; instead of ``.btn-login``, opt for ``.btn-primary``.

Selector Performance
~~~~~~~~~~~~~~~~~~~~

A topic which is with the quality of today’s browsers, more interesting than it is important, is selector performance. That is to say, how quickly a browser can match the selectors you write in CSS up with the nodes it finds in the DOM.

Generally speaking, the longer a selector is (i.e. the more component parts) the slower it is, for example:

.. code:: css

    body.home div.header ul { }

…is a far less efficient selector than:

.. code:: css

    .primary-nav { }

This is because browsers read CSS selectors right-to-left. A browser will read the first selector as

-  find all ``ul`` elements in the DOM
-  now check if they live anywhere inside an element with a class of ``.header``
-  next check that ``.header`` class exists on a ``div`` element
-  now check that that all lives anywhere inside any elements with a class of ``.home``
-  finally, check that ``.home`` exists on a ``body`` element

The second, in contrast, is simply a case of the browser reading, find all the elements with a class of ``.primary-nav``.

To further compound the problem, the example uses descendant selectors (e.g. ``.foo .bar {}``). The upshot of this is that a browser is required to start with the rightmost part of the selector (i.e. ``.bar``) and keep looking up the DOM indefinitely until it finds the next part (i.e. ``.foo``). This could mean stepping up the DOM dozens of times until a match is found.

This is just one reason why **nesting with preprocessors is often a false economy**; as well as making selectors unnecessarily more specific, and creating location dependency, it also creates more work for the browser.

By using a child selector (e.g. ``.foo > .bar {}``) you can make the process much more efficient, because this only requires the browser to look one level higher in the DOM, and it will stop regardless of whether or not it found a match.

The Key Selector
^^^^^^^^^^^^^^^^

Because browsers read selectors right-to-left, the rightmost selector is often critical in defining a selector’s performance: this is called the key selector.

The following selector might appear to be highly performant at first glance. It uses an ID which is nice and fast, and there can only ever be one on a page, so surely this will be a nice and speedy lookup, just find that one ID and then style everything inside of it:

.. code:: css

    #foo * { }

The problem with this selector is that the key selector (``*``) is very, very far reaching. What this selector actually does is find every single node in the DOM (even ``<title>``, ``<link>``, and ``<head>`` elements; everything) and then looks to see if it lives anywhere at any level within #foo. This is a very, very expensive selector, and should most likely be avoided or rewritten.

Thankfully, by writing selectors with good Selector Intent, you are probably avoiding inefficient selectors by default; you are very unlikely to have greedy key selectors if you’re targeting the right things for the right reason.

That said, however, CSS selector performance should be fairly low on your list of things to optimize; browsers are fast, and are only ever getting faster, and it is only on notable edge cases that inefficient selectors would be likely to pose a problem.

As well as their own specific issues, nesting, qualifying, and poor Selector Intent all contribute to less efficient selectors.

General Rules
~~~~~~~~~~~~~

Your selectors are fundamental to writing good CSS. To very briefly sum up the above sections:

-  **Select what you want explicitly**, rather than relying on circumstance or coincidence. Good Selector Intent will rein in the reach and leak of your styles.
-  **Write selectors for reusability**, so that you can work more efficiently and reduce waste and repetition.
-  **Do not nest selectors unnecessarily**, because this will increase specificity and affect where else you can use your styles.
-  **Do not qualify selectors unnecessarily**, as this will impact the number of different elements you can apply styles to.
-  **Keep selectors as short as possible**, in order to keep specificity down and performance up.

Focussing on these points will keep your selectors a lot more sane and easy to work with on changing and long running projects.

Further Reading
'''''''''''''''

-  `Shoot to kill; CSS selector intent`_
-  `‘Scope’ in CSS`_
-  `Keep your CSS selectors short`_
-  `About HTML semantics and front-end architecture`_
-  `Naming UI components in OOCSS`_
-  `Writing efficient CSS selectors`_


.. _Shoot to kill; CSS selector intent: http://csswizardry.com/2012/07/shoot-to-kill-css-selector-intent/
.. _‘Scope’ in CSS: http://csswizardry.com/2013/05/scope-in-css/
.. _Keep your CSS selectors short: http://csswizardry.com/2012/05/keep-your-css-selectors-short/
.. _About HTML semantics and front-end architecture: http://nicolasgallagher.com/about-html-semantics-front-end-architecture/
.. _Naming UI components in OOCSS: http://csswizardry.com/2014/03/naming-ui-components-in-oocss/
.. _Writing efficient CSS selectors: http://csswizardry.com/2011/09/writing-efficient-css-selectors/


Specificity
-----------

As we’ve seen, CSS isn’t the most friendly of languages: globally operating, very leaky, dependent on location, hard to encapsulate, based on inheritance… But! None of that even comes close to the horrors of specificity.

No matter how well considered your naming, regardless of how perfect your source order and cascade are managed, and how well you’ve scoped your rulesets, just one overly-specific selector can undo everything. It is a gigantic curveball, and undermines CSS’ very nature of the cascade, inheritance, and source order.

The problem with specificity is that it sets precedents and trumps that cannot simply be undone. If we take the following example

.. code:: css

    #content table { }

Not only does this exhibit poor **Selector Intent**, we didn’t actually want every ``table`` in the ``#content`` area. We wanted a specific type of ``table`` that just happened to live there. This is a hugely over-specific selector. It becomes apparent, when we needed a second type of ``table``:

.. code:: css

    #content table { }

    /**
     * Uh oh! My styles get overwritten by `#content table {}`.
     */
    .my-new-table { }

The first selector was trumping the specificity of the one defined after it, working against CSS’ source-order based application of styles. In order to remedy this, we have two main options. we could

#. refactor the CSS and HTML to remove that ID;
#. write a more specific selector to override it.

Unfortunately, refactoring would take a long time in a mature product and the knock-on effects of removing this ID would be more substantial business cost than the second option: just write a more specific selector.

.. code:: css

    #content table { }

    #content .my-new-table { }

Now we have a selector that is even more specific still! And if we ever want to override this one, we will need another selector of at least the same specificity defined after it. We’ve started on a downward spiral.

Specificity can, among other things,

-  limit your ability to extend and manipulate a codebase
-  interrupt and undo CSS’ cascading, inheriting nature
-  cause avoidable verbosity in your project
-  prevent things from working as expected when moved into different environments
-  lead to serious developer frustration

All of these issues are greatly magnified when working on a larger project with a number of developers contributing code.

Keep It Low at All Times
~~~~~~~~~~~~~~~~~~~~~~~~

The problem with specificity isn’t necessarily that it’s high or low; it’s the fact it is so variant and that it cannot be opted out of: the only way to deal with it is to get progressively more specific—the notorious specificity wars we looked at above.

One of the single, simplest tips for an easier life when writing CSS, particularly at any reasonable scale—is to always try to keep specificity as low as possible at all times. Try to make sure there isn’t a lot of variance between selectors in the codebase, and that all selectors strive for as low a specificity as possible.

Doing so will instantly help us tame and manage the project, meaning that no overly-specific selectors are likely to impact or affect anything of a lower specificity elsewhere. It also means we’re less likely to need to fight our way out of specificity corners, and we’ll probably also be writing much smaller stylesheets.

Simple changes to the way we work include, but are not limited to,

-  not using IDs in your CSS
-  not nesting selectors
-  not qualifying classes
-  not chaining selectors

**Specificity can be wrangled and understood, but it is safer just to avoid it entirely.**

IDs in CSS
~~~~~~~~~~

If we want to keep specificity low, which we do, we have one really quick-win, simple, easy-to-follow rule that we can employ to help us:

.. warning::

**NEVER USE IDs in CSS**

Not only are IDs inherently non-reusable, they are also vastly more specific than any other selector, and therefore become specificity anomalies. Where the rest of your selectors are relatively low specificity, your ID-based selectors are, comparatively, much, much higher.

In fact, to highlight the severity of this difference, see how one thousand chained classes cannot override the specificity of a single ID: `jsfiddle.net/0yb7rque`_.

.. warning::

(Please note that in Firefox you may see the text rendering in blue: this is a `known bug`_, and an ID will be overridden by 256 chained classes.)

.. note::

**N.B.** It is still perfectly okay to use IDs in HTML and JavaScript; it is only in CSS that they prove troublesome.

It is often suggested that developers who choose not to use IDs in CSS merely don’t understand how specificity works. This is as incorrect as it is offensive: no matter how experienced a developer you are, this behavior cannot be circumvented; no amount of knowledge will make an ID less specific.

Opting into this way of working only introduces the chance of problems occurring further down the line, and—particularly when working at scale—all efforts should be made to avoid the potential for problems to arise. In a sentence:

**It is just not worth introducing the risk.**

Nesting
~~~~~~~

We’ve already looked at how nesting can lead to location dependent and potentially inefficient code, but now it’s time to take a look at another of its pitfalls: it makes selectors more specific.

When we talk about nesting, we don’t necessarily mean preprocessor nesting, like so:

.. code:: scss

    .foo {

        .bar { }

    }


We’re actually talking about descendant or child selectors; selectors which rely on a thing within a thing. That could look like any one of the following:

.. code:: css

    /**
     * An element with a class of `.bar` anywhere inside an element with a class of
     * `.foo`.
     */
    .foo .bar { }


    /**
     * An element with a class of `.module-title` directly inside an element with a
     * class of `.module`.
     */
    .module > .module-title { }


    /**
     * Any `li` element anywhere inside a `ul` element anywhere inside a `nav`
     * element
     */
    nav ul li { }

Whether you arrive at this CSS via a preprocessor or not isn’t particularly important, but it is worth noting **that preprocessors tout this as a feature, where it is actually to be avoided wherever possible.**

Generally speaking, each part in a compound selector adds specificity. Ergo, the fewer parts to a compound selector then the lower its overall specificity, and we always want to keep specificity low. To quote Jonathan Snook:

    …whenever declaring your styles, **use the least number of selectors required to style an element.**

Let’s look at an example:

.. code:: css

    .widget {
        padding: 10px;
    }

    .widget > .widget-title {
        color: red;
    }

To style an element with a class of ``.widget-title``, we have a selector that is twice as specific as it needs to be. That means that if we want to make any modifications to ``.widget-title``, we’ll need another at-least-equally specific selector:

.. code:: css

    .widget { ... }

    .widget > .widget-title { ... }

    .widget > .widget-title-sub {
        color: blue;
    }

Not only is this entirely avoidable—we caused this problem ourselves—we have a selector that is literally double the specificity it needs to be. We used 200% of the specificity actually required. And not only that, but this also leads to needless verbosity in our code—more to send over the wire.

.. warning::

As a rule, **if a selector will work without it being nested then do not nest it.**

Scope
~~~~~

One possible advantage of nesting—which, unfortunately, does not outweigh the disadvantages of increased specificity—is that it provides us with a namespace of sorts. A selector like ``.widget .title`` scopes the styling of ``.title`` to an element that only exists inside of an element carrying a class of ``.widget``.

This goes some way to providing our CSS with scope and encapsulation, but does still mean that our selectors are twice as specific as they need to be. A better way of providing this scope would be via a namespace—which does not lead to an unnecessary increase in specificity.

Now we have better scoped CSS with minimal specificity—the best of both worlds.

Further Reading
'''''''''''''''

-  `‘Scope’ in CSS`_

``!important``
~~~~~~~~~~~~~~

The word ``!important`` sends shivers down the spines of almost all front-end developers. ``!important`` is a direct manifestation of problems with specificity; it is a way of cheating your way out of specificity wars, but usually comes at a heavy price. It is often viewed as a last resort—a desperate, defeated stab at patching over the symptoms of a much bigger problem with your code.

The general rule is that ``!important`` is always a bad thing, but, to quote Jamie Mason:

    Rules are the children of principles.

That is to say, a single rule is a simple, black-and-white way of adhering to a much larger principle. When you’re starting out, the rule never use ``!important`` is a good one.

However, once you begin to grow and mature as a developer, you begin to understand that the principle behind that rule is simply about keeping specificity low. You’ll also learn when and where the rules can be bent…

``!important`` does have a place in CSS projects, but only if used sparingly and proactively.

Proactive use of ``!important`` is when it is used *before* you’ve encountered any specificity problems; when it is used as a guarantee rather than as a fix.

For example:

.. code:: css

    .one-half {
        width: 50% !important;
    }

    .hidden {
        display: none !important;
    }

These two helper, or *utility*, classes are very specific in their intentions: you would only use them if you wanted something to be rendered at 50% width or not rendered at all. If you didn’t want this behavior, you would not use these classes, therefore whenever you do use them you will definitely want them to win.

Here we proactively apply ``!important`` to ensure that these styles always win. This is the correct use of ``!important`` to guarantee that these trumps always work, and don’t accidentally get overridden by something else more specific.

Incorrect, reactive use of ``!important`` is when it is used to combat specificity problems after the fact: applying ``!important`` to declarations because of poorly architected CSS. For example, let’s imagine we have this HTML:

.. code:: html

    <div class="content">
        <h2 class="heading-sub">...</h2>
    </div>

…and this CSS:

.. code:: css

    .content h2 {
        font-size: 2rem;
    }

    .heading-sub {
        font-size: 1.5rem !important;
    }

Here we can see how we’ve used ``!important`` to force our ``.heading-sub {}`` styles to reactively override our ``.content h2 {}`` selector. This could have been circumvented by any number of things, including using better Selector Intent, or avoiding nesting.

In these situations, it is preferable that you investigate and refactor any offending rulesets to try and bring specificity down across the board, as opposed to introducing such specificity heavyweights.

.. warning::

**Only use** ``!important`` **proactively, not reactively.**

Hacking Specificity
~~~~~~~~~~~~~~~~~~~

With all that said on the topic of specificity, and keeping it low, it is inevitable that we will encounter problems. No matter how hard we try, and how conscientious we are, there will always be times that we need to hack and wrangle specificity.

When these situations do arise, it is important that we handle the hacks as safely and elegantly as possible.

In the event that you need to increase the specificity of a class selector, there are a number of options. We could nest the class inside something else to bring its specificity up. For example, we could use ``.header .site-nav {}`` to bring up the specificity of a simple ``.site-nav {}`` selector.

The problem with this, as we’ve discussed, is that it introduces location dependency: these styles will only work when the ``.site-nav`` component is in the ``.header`` component.

Instead, we can use a much safer hack that will not impact this component’s portability: we can chain that class with itself:

.. code:: css

    .site-nav.site-nav { }

This chaining doubles the specificity of the selector, but does not introduce any dependency on location.

In the event that we do, for whatever reason, have an ID in our markup that we cannot replace with a class, select it via an attribute selector as opposed to an ID selector. For example, let’s imagine we have embedded a third-party widget on our page. We can style the widget via the markup that it outputs, but we have no ability to edit that markup ourselves:

.. code:: html

    <div id="third-party-widget">
        ...
    </div>

Even though we know not to use IDs in CSS, what other option do we have? We want to style this HTML but have no access to it, and all it has on it is an ID.

We do this:

.. code:: css

    [id="third-party-widget"] { }

Here we are selecting based on an attribute rather than an ID, and attribute selectors have the same specificity as a class. This allows us to style based on an ID, but without introducing its specificity.

Do keep in mind that these are hacks, and should not be used unless you have no better alternative.

Further Reading
'''''''''''''''

-  `Hacks for dealing with specificity`_

.. _jsfiddle.net/0yb7rque: http://jsfiddle.net/csswizardry/0yb7rque/
.. _known bug: https://twitter.com/codepo8/status/505004085398224896
.. _‘Scope’ in CSS: http://csswizardry.com/2013/05/scope-in-css/
.. _Hacks for dealing with specificity: http://csswizardry.com/2014/07/hacks-for-dealing-with-specificity/


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

We follow the ITCSS principles for the organization of our code and as such everything is broken up into partials. All partials are to be named to reflect the contained component/module and lead by an underscore (``_``) to prevent self rendering.

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
