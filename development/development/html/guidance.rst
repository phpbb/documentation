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
-  Don’t include a trailing slash in self-closing elements.

Example:

.. code:: html
   <div class="tweet">
       <a href="path/to/somewhere">
           <img src="path/to/image.png" alt="">
       </a>
       <p>[tweet text]</p>
       <button disabled>Reply</button>
   </div>

4. Attribute order
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
               <a data-id="1234"
                data-analytics-category="[value]"
                data-analytics-action="[value]"
                href="[url]">[text]</a>
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
