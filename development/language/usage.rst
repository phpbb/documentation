=========================
Using the Language System
=========================

phpBB uses a language system to guarantee easy localisation. All strings
presented to the user are first looked up in an internal dictionary. Thus it is
also a requirement for Extensions to use said system for all output presented to
the user. This chapter will show you how to use the language system and how to
add your custom entries.

We generally refer to the name of the word in the dictionary as
**language key** or **language variable**, to the returned value as
**language value** or **language string**. Both together are a
**language entry**. Language entries are collected in language files.

.. note::

    By convention, the language key should always be all-uppercase, using
    underscores to separate words.

Using the Language System in php
================================

The object holding the language dictionary for the current user is the ``$language``
object (``phpbb\language\language`` class). To get the translation of a language
entry inside of php code, call the ``phpbb\language\language::lang()`` method:

.. code-block:: php

    $language->lang('LANG_KEY');

You can also insert values into translated string. Use ``%s`` as placeholders
for string in the language string and ``%d`` for integers:

.. code-block:: php

    // Language string: "My translation has a %s"
    echo $language->lang('LANG_KEY', 'parameter');
    // Output: "My translation has a parameter"

    // Language string: "My translation has %d parameter"
    echo $language->lang('LANG_KEY', 1);
    // Output: "My translation has 1 parameter"

.. warning::

    When using ``%d`` for plurals make sure to allow translators to use plurals
    according to their language. For more information see: :doc:`plurals`

.. note::

    Many functions in phpBB automatically translate their arguments; passing the
    language key as an argument is usually enough.

The dictionary is not loaded into memory all at once, but is split up in several
files, which have to be manually loaded on demand. The files are stored inside
the language directory, named after its
`language tag <https://area51.phpbb.com/docs/master/coding-guidelines.html#translation>`_,
where one subdirectory is used for each installed language. The default language
files are in the root of that subdirectory, while ACP language files go into the
``/acp`` subdirectory; email templates are placed in the ``/email``
subdirectory.

.. note::

    Files for extensions should be placed in the extension's ``/language``
    directory.

Loading language files
======================

Loading from phpBB core
-----------------------

Additional language files can be loaded during user setup via the call to the
``phpbb\user::setup()`` method at the top of each accessible file. To do so,
pass the name with the subdirectory but without extension as argument of setup.

.. code-block:: php

    $user->setup('search');
    // or
    $user->setup(['ucp', 'search']);

Since ``phpbb\user::setup()`` must only be called once,
``phpbb\language\language::add_lang()`` has to be used, to load additional
language files, after ``phpbb\user::setup()`` has already been called.

.. code-block:: php

    $language->add_lang('search');
    // or
    $language->add_lang(['ucp', 'search']);

Loading from an extension
-------------------------

To load a file from an extension
you need to use ``phpbb\language\language::add_lang()`` which takes
the array of language files as a first argument and the vendor + extension name as
a second argument.

.. code-block:: php

    $language->add_lang('demo', 'acme/demo');
    // or
    $language->add_lang(['demo', 'demo2'], 'acme/demo');

Using the Language System in template files
===========================================

Language entries in
:ref:`Template Syntax <tutorial-template-syntax>`
are a major improvement since phpBB 3.0. There is no longer a need to manually
assign these in the PHP file; language entries of loaded language files can be
used automatically.

To use the language entry with the key ``MY_KEY`` in a template file, just write
``{L_MY_KEY}`` in the template (phpBB syntax) or ``{{ lang('MY_KEY') }}`` (new
twig syntax).

Javascript
----------

If the language entry is going to be used inside of JavaScript, it must be properly
escaped. This is easy to achieve by using ``{LA_MY_KEY}`` in the template (phpBB 
syntax) or ``{{ lang('MY_KEY')|e('js') }}`` (new twig syntax).

.. note::

    When using language entries in the JavaScript context with the new twig syntax,
    the following methods are possible:

    * ``{{ lang('MY_KEY')|escape('js') }}`` Twig's native JavaScript context escape filter.
    * ``{{ lang('MY_KEY')|e('js') }}`` Short-hand version for calling ``escape`` using ``e``.
    * ``{{ lang('MY_KEY')|escape('addslashes') }}`` phpBB's legacy addslashes escape filter.
    * ``{{ lang('MY_KEY')|e('addslashes') }}`` Short-hand version for calling ``escape`` using ``e``.

Add new entries
===============

New language files should always be placed in their own files in the extensions
directory.

.. note::

    When defining log entries and module names, make sure to load the language
    file, when the entries are being used.

.. note::

    When writing or editing a language file, make sure to save it using
    utf-8 encoding **without BOM**
    (`Byte Order Mark <https://en.wikipedia.org/wiki/Byte_Order_Mark>`_).
    Otherwise the forum will not function properly. Some editors call that mode
    "utf8 cookie".

.. code-block:: php

    <?php
    // language/en/sample.php
    /**
     *
     * This file is part of the phpBB Forum Software package.
     *
     * @copyright (c) phpBB Limited <https://www.phpbb.com>
     * @license GNU General Public License, version 2 (GPL-2.0)
     *
     * For full copyright and license information, please see
     * the docs/CREDITS.txt file.
     *
     */

    /**
     * DO NOT CHANGE
     */
    if (empty($lang) || !is_array($lang))
    {
        $lang = [];
    }

    // DEVELOPERS PLEASE NOTE
    //
    // All language files should use UTF-8 as their encoding and the files must not contain a BOM.
    //
    // Placeholders can now contain order information, e.g. instead of
    // 'Page %s of %s' you can (and should) write 'Page %1$s of %2$s', this allows
    // translators to re-order the output of data while ensuring it remains correct
    //
    // You do not need this where single placeholders are used, e.g. 'Message %d' is fine
    // equally where a string contains only two placeholders which are used to wrap text
    // in a url you again do not need to specify an order e.g., 'Click %sHERE%s' is fine

    $lang = array_merge($lang, [
        'MY_LANGUAGE_KEY'         => 'A language entry',
        'MY_OTHER_LANGUAGE_KEY'   => 'Another language entry',
        'MY_TRICKY_LANGUAGE_KEY'  => 'This is a %slink%s',
    ]);
