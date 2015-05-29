=========================
Using the Language System
=========================

phpBB uses a language system to guarantee easy localisation. All strings
presented to the user are first looked up in an internal dictionary. Thus it is
also a requirement for Extensions to use said system for all output presented to
the user. This chapter will show you how to use the language system and how to
add your custom entries.


Using the Language System in php
================================

The object holding the language dictionary for the current user is - hardly
surprising - the ``$user`` object. We generally refer to the name of the word in
the dictionary as **language key**, to the returned value as **language string**
or **language value**. Both together are a **language entry**. By convention,
the language key should always be all-uppercase. Language entries are collected
in language files.

To lookup a language entry inside of phpBB, query the ``$user`` object like
this: ``$user->lang('LANG_KEY')``, which will return the language string
assigned to the key ``LANG_KEY`` in the current user's language. Note that many
functions in phpBB automatically translate their arguments; passing the language
key as an argument is usually enough.

The dictionary is not loaded into memory all at once, but is split up in several
files, which have to be manually loaded on demand. The files are stored inside
the language directory, named after its
`language tag <https://area51.phpbb.com/docs/30x/coding-guidelines.html#translation>`_,
where one subdirectory is used for each installed language. The default language
files are in the root of that subdirectory, while ACP language files go into the
``/acp`` subdirectory; email templates are placed in the ``/email``
subdirectory. Files for extensions should be placed in the extension's
``/language`` directory.

Additional language files can be loaded during user setup via the call to the
``$user->setup()`` method at the top of each accessible file. To do so, pass the
name with the subdirectory but without extension as argument of setup. For
instance ``$user->setup('search')`` or ``$user->setup('mylangfile')`` or
``$user->setup(array('mylangfile', 'search'))``. If you need to add a language
file at a later stage, use add_lang, e.g.
``$user->add_lang(array('mylangfile', 'search'))``.

A sightly more difficult situation arises when the displayed text should contain
links etc. phpBB uses a ``lang()``-method for that, for instance:

.. code-block:: php

    $message .= '<br /><br />' . $user->lang('MY_TRICKY_LANGUAGE_KEY', '<a href="' . append_sid("{$phpbb_root_path}mypage.$phpEx") . '">', '</a>');
    trigger_error($message);

Using the Language System in template files
===========================================

Language entries in
`Using the Template System <https://wiki.phpbb.com/Using_the_phpBB3.0_Template_System>`_
are a major improvement since phpBB 3.0. There is no longer a need to manually
assign these in the php file; loaded language files will be automatically used.
To use the language entry with the key ``MY_KEY`` in a template file, just write
``{L_MY_KEY}`` in the template - it's as simple as that.

Add new entries
===============

New language files should always be placed in their own files in the extensions
directory. There are however a few exceptions, notably log entries and module
names. Those need to be placed in their appropriate common.php language file,
either in the language's directory or the acp subdirectory.

**Note:** When writing or editing a language file, make sure to save it using
utf-8 encoding **without BOM**
(`Byte Order Mark <http://en.wikipedia.org/wiki/Byte_Order_Mark>`_). Otherwise
the forum will not function properly. Some editors call that mode "utf8 cookie".

.. code-block:: php

    <?php
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
        $lang = array();
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

    $lang = array_merge($lang, array(
        'MY_LANGUAGE_KEY'		=> 'A language entry',
        'MY_OTHER_LANGUAGE_KEY'	=> 'Another language entry',
        'MY_TRICKY_LANGUAGE_KEY'	=> 'This is a %slink%s',
    ));
