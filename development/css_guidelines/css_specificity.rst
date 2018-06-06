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
