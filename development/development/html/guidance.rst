Idiomatic HTMLGuidelines
================================================

1. Whitespace
----------------

Only one style should exist across the entire source of your code-base.
Always be consistent in your use of whitespace. Use whitespace to
improve readability.

-  Never mix spaces and tabs for indentation.
-  Preference: ``Tabs``

.. tip: configure your editor to “show invisibles”. This will allow you to
eliminate end of line whitespace, eliminate unintended blank line
whitespace, and avoid polluting commits.

2. Format
------------

-  Always use lowercase tag and attribute names.
-  Write one discrete element per line.
-  Use one additional level of indentation for each nested element.
-  Use valueless boolean attributes (e.g. ``checked`` rather than
   ``checked="checked"``).
-  Always use double quotes to quote attribute values.
-  Omit the ``type`` attributes from ``link`` stylesheet, ``style`` and
   ``script`` elements.
-  Always include closing tags. ``<p>Some text</p>`` **NOT** ``<p>Some text``
-  Don’t include a trailing slash in self-closing elements. ``<img src="#" alt="something">`` **NOT** ``<img src="#" alt="something" />``

Example:

.. code:: html
   <div class="tweet">
       <a href="path/to/somewhere">
           <img src="path/to/image.png" alt="">
       </a>
       <p>[tweet text]</p>
       <button disabled>Reply</button>
   </div>

3. Attribute order
------------------

HTML attributes should be listed in an order that reflects the fact that
class names are the primary interface through which CSS and JavaScript
select elements.

1. ``class``
2. ``id``
3. ``data-*``
4. Everything else

Example:

.. code:: html
   <a class="[value]" id="[value]" data-name="[value]" href="[url]">[text]</a>

4. Line Breaks
--------------

We highly recommend using ``<p>`` **OR** ``<span>`` to wrap all blocks of text over using ``<br>`` to control line breaks. You are not able to stlye the ``<br>`` tag which limits the control of the content on a page.
Prefer the use of paragrphs or block level spans over breaks as you can not style a ``br`` tag. ``<p>Some text</p><p>Some More Text</p>`` **OR** ``<span class="something">Some text</span><span class="display-block-class">Some More Text</span>`` **NOT** ``Some text<br>Some More Text``

**Example with bad formated text:**

.. code:: html

    <div class="content">

        <h3>
            This is a Title<br>
            <small>This is a subtitle</small>
        </h3>

        <p>
            Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.<br>
            Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.<br>
            Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.<br>
            Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.<br>
        </p>

    </div>

**Example with good formated text:**

.. code:: css
    .subtitle {
        display: block;
    }

    .no-margin {
        padding: 0;
        margin: 0;
    }

.. code:: html

    <div class="content">

        <h3>
            This is a Title
            <small class="subtitle">This is a subtitle</small>
        </h3>

        <p class="no-margin">
            Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
        </p>
        <p class="no-margin">
            Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
        </p>
        <p class="no-margin">
            Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
        </p>
        <p class="no-margin">
            Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
        </p>

    </div>

5. Naming
---------

Naming is hard, but very important. It’s a crucial part of the process
of developing a maintainable code base, and ensuring that you have a
relatively scalable interface between your HTML and CSS/JS.

-  Use clear, thoughtful, and appropriate names for HTML classes. The
   names should be informative both within HTML and CSS files.
-  Avoid *systematic* use of abbreviated class names. Don’t make things
   difficult to understand.

**Example with bad names:**

.. code:: html
   <div class="cb s-scr"></div>

.. code:: css
   .s-scr {
     overflow: auto;
   }

   .cb {
     background: #000;
   }

**Example with better names:**

.. code:: html
   <div class="column-body is-scrollable"></div>

.. code:: css
   .is-scrollable {
       overflow: auto;
   }

   .column-body {
       background: #000;
   }

6. Practical example
--------------------

An example of various conventions.

.. code:: html

   <!DOCTYPE html>
   <html>
       <head>
           <meta charset="utf-8">
           <title>Document</title>
           <link rel="stylesheet" href="main.css">
           <script src="main.js"></script>
       </head>
       <body>
           <article class="post" id="1234">
               <time class="timestamp">March 15, 2012</time>
               <ul>
                   <li>
                       <a href="[url]">[text]</a>
                       <img src="[url]" alt="[text]">
                   </li>
                   <li>
                       <a href="[url]">[text]</a>
                   </li>
               </ul>

               <a class="link-complex" href="[url]">
                   <span class="link-complex__target">[text]</span>
                   [text]
               </a>

               <input value="text" readonly>
           </article>
       </body>
   </html>
