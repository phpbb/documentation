5. Character Sets and Encodings
===============================

What are Unicode, UCS and UTF-8?
--------------------------------

The `Universal Character Set (UCS) <https://en.wikipedia.org/wiki/Universal_Character_Set>`_ described in ISO/IEC 10646 consists of a large amount of characters. Each of them has a unique name and a code point which is an integer number. `Unicode <https://en.wikipedia.org/wiki/Unicode>`_ - which is an industry standard - complements the Universal Character Set with further information about the characters' properties and alternative character encodings. More information on Unicode can be found on the `Unicode Consortium's website <https://home.unicode.org/>`_. One of the Unicode encodings is the `8-bit Unicode Transformation Format (UTF-8) <https://en.wikipedia.org/wiki/UTF-8>`_. It encodes characters with up to four bytes aiming for maximum compatibility with the `American Standard Code for Information Interchange <https://en.wikipedia.org/wiki/ASCII>`_ which is a 7-bit encoding of a relatively small subset of the UCS.

phpBB's use of Unicode
++++++++++++++++++++++

Unfortunately PHP does not facilitate the use of Unicode prior to version 6. Most functions simply treat strings as sequences of bytes assuming that each character takes up exactly one byte. This behaviour still allows for storing UTF-8 encoded text in PHP strings but many operations on strings have unexpected results. To circumvent this problem we have created some alternative functions to PHP's native string operations which use code points instead of bytes. These functions can be found in ``/includes/utf/utf_tools.php``. A lot of native PHP functions still work with UTF-8 as long as you stick to certain restrictions. For example ``explode`` still works as long as the first and the last character of the delimiter string are ASCII characters.

phpBB only uses the ASCII and the UTF-8 character encodings. Still all Strings are UTF-8 encoded because ASCII is a subset of UTF-8. The only exceptions to this rule are code sections which deal with external systems which use other encodings and character sets. Such external data should be converted to UTF-8 using the ``utf8_recode()`` function supplied with phpBB. It supports a variety of other character sets and encodings, a full list can be found below.

With ``$request->variable()`` you can either allow all UCS characters in user input or restrict user input to ASCII characters. This feature is controlled by the method's third parameter called ``$multibyte``. You should allow multibyte characters in posts, PMs, topic titles, forum names, etc. but it's not necessary for internal uses like a ``$mode`` variable which should only hold a predefined list of ASCII strings anyway.

.. code: php
    // an input string containing a multibyte character
    $_REQUEST['multibyte_string'] = 'Käse';

    // print request variable as a UTF-8 string allowing multibyte characters
    echo $request->variable('multibyte_string', '', true);
    // print request variable as ASCII string
    echo $request->variable('multibyte_string', '');

This code snippet will generate the following output:

.. code: text
    Käse
    K??se

Case Folding
++++++++++++

Case insensitive comparison of strings is no longer possible with ``strtolower`` or ``strtoupper`` as some characters have multiple lower case or multiple upper case forms depending on their position in a word. The ``utf8_strtolower`` and the ``utf8_strtoupper`` functions suffer from the same problem so they can only be used to display upper/lower case versions of a string but they cannot be used for case insensitive comparisons either. So instead you should use case folding which gives you a case insensitive version of the string which can be used for case insensitive comparisons. An NFC normalized string can be case folded using ``utf8_case_fold_nfc()``.

**Bad - The strings might be the same even if strtolower differs:**

.. code:: php

    if (strtolower($string1) == strtolower($string2))
    {
    	echo '$string1 and $string2 are equal or differ in case';
    }

**Good - Case folding is really case insensitive:**

.. code:: php

	if (utf8_case_fold_nfc($string1) == utf8_case_fold_nfc($string2))
	{
		echo '$string1 and $string2 are equal or differ in case';
	}

Confusables Detection
+++++++++++++++++++++

phpBB offers a special method ``utf8_clean_string`` which can be used to make sure string identifiers are unique.
This method uses Normalization Form Compatibility Composition (NFKC) instead of NFC and replaces similarly looking
characters with a particular representative of the equivalence class. This method is currently used for usernames and
group names to avoid confusion with similarly looking names.
