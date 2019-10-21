JavaScript Guidelines
=====================

We use `XO.js <https://github.com/xojs/xo>`_ for checking the quality, linting, and ensuring consistent JS code standards. Its installed via npm as a module and is configured via the ``package.json`` file in the root. Your editor probably has a plugin available which will show you when you violate these standards. ``XO.js`` is an `ESLint <https://eslint.org/>`_ wrapper. Its essentially a custom `config <https://github.com/xojs/eslint-config-xo/blob/master/index.js>`_ for ESlint, but simplifies the use as we do not have to maintain/update the standards. This means we do not need to manage an ``eslintrc`` file.

.. note:: Our editors of choice are `PhpStorm`_ & `ATOM`_ which provide useful plugins to make use of these tools. Check out the `Editor Setup`_ section of the docs for more information

.. _PhpStorm: https://www.jetbrains.com/phpstorm/
.. _ATOM: https://atom.io
.. _Editor Setup: /editor-setup

.. toctree::
   :maxdepth: 2

   test
