Coding Guidelines
=================

phpBB's coding guidelines are maintained in its
`source code repository <https://github.com/phpbb/phpbb>`_. You can find the
latest versions on area51:

* Rules for `Olympus (3.0.x) code <http://area51.phpbb.com/docs/30x/coding-guidelines.html>`_
* Rules for `Ascraeus (3.1.x) code <http://area51.phpbb.com/docs/31x/coding-guidelines.html>`_
* Rules for `Rhea (3.2.x) code <http://area51.phpbb.com/docs/32x/coding-guidelines.html>`_

These documents are automatically updated when changes are made to them.

JavaScript Linting
------------------

We use JSHint and JSCS for checking the quality of the JavaScript—JSHint for
linting, and JSCS for ensuring consistent code. There is a .jshintrc and a
.jscs file in the root of the project, and your editor probably has a plugin
available which will show you when you violate these standards.
