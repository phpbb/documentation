===============================
Language Pack Validation Policy
===============================

Submission guidelines
=====================

Description
-----------

Contribution description in the `Customisation Database`_
should be translated into English in addition of your local language, as some
administrators might want to download your translation without speak your
language.

Screenshot
----------

Contribution screenshot in the `Customisation Database`_ should only be the
flag of the country whose the language is spoken. For example, the flag of
France for the French language.

Demo-Link
---------

The Demo URL in the Customisation Database must be empty, unless you want to
put a link to an international community (
`officially <https://www.phpbb.com/support/intl/>`_ listed or not) related to
the language of the contribution. For example, http://www.phpbbarabia.com/ as
Demo URL concerning the
`Arabic language <https://www.phpbb.com/customise/db/translation/arabic/>`_ is
allowed.

Package
-------

* The submitted ``<languagename>_<version>.zip`` must contain a
  ``<languagename>_<version>`` folder. The files from above should be placed in
  this folder.
* Revision name in the `Customisation Database`_ should be left blank, contain
  the phpBB package version and/or package release name (e.g. ``3.0.12`` /
  ``Richard 'D¡cky' Foote`` for 3.0.12) for more understanding.

Package Validation
==================

* Language packages must include all files that are included in the folders for
  the English language. This includes the following folders:

    + ``ext/phpbb/viglink/language/en/``
    + ``language/en/``
    + ``styles/prosilver/theme/en/``

* Language packages must contain 1 additional files:

    + ``language/{iso}/LICENSE``

* Language packages may contain 4 more additional files:

    + ``language/{iso}/AUTHORS.md``
    + ``language/{iso}/CHANGELOG.md``
    + ``language/{iso}/README.md``
    + ``language/{iso}/VERSION.md``

* No other additional files are allowed!
* All folders within the language-directories must contain an ``index.htm`` file (e.g. ``language/en/acp/index.htm``, ``language/en/index.htm``, ``styles/prosilver/theme/de/index.htm``, see the `Language Pack Submission Policy`_ for a complete list.).
* An exception from this rule are the the directories for the viglink-translation and the directories which belong the phpBB package (e.g. ``language/``, ``styles/``).

File Validation
===============

* All files must be stored using ``LF`` (LineFeed / UNIX) line endings.
* All ``.php`` files must have a check for the ``IN_PHPBB`` constant:

    .. code-block:: php

        if (!defined('IN_PHPBB'))
        {
            exit;
        }

* All files containing non-english language (``.php``, ``.txt``, as well as all
  additional files from `Package Validation`_) must be saved as *UTF8 without
  BOM*.
* ``.php`` files must **not** produce any output. There should be no characters
  before ``<?php``. ``.php`` files must **not** contain the closing tag ``?>``,
  but just end with a new line

language/{iso}/iso.txt
----------------------

* The file must contain exactly 3 lines:

    #. English language name
    #. Language name in the spoken language
    #. Author(-group) information (Plaintext only, no links allowed)

\*/index.htm
------------

The ``index.htm`` files in all folders must either be completly empty, or
contains the default html body:

.. code-block:: html

    <html>
    <head>
    <title></title>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    </head>

    <body bgcolor="#FFFFFF" text="#000000">

    </body>
    </html>

language/{iso}/help/*.php
-------------------------

* The file must must only contain 1 array named `$lang`. No other variables are allowed.
* The array must only contain arrays with the following structure:

    .. code-block:: php

        array(
            0 => 'TextA',
            1 => 'TextB',
        ),

    + If TextA is ``--`` the entry is a headline.
    + If both, TextA and TextB, are ``--`` the entry causes a column switch for
      the 2 column page layout. A ``help/*.php`` file must contain exactly one
      of these entries.

* For TextA and TextB normal `Key Validation`_ applies.

language/{iso}/email/\*.txt and language/{iso}/email/short/\*.txt
-----------------------------------------------------------------
* Emails must only contain the subject-line, when the english email template
  also contains it::

    Subject: {Translated subject here}

* Emails must only contain the ``{EMAIL_SIG}``, when the english email template
  also contains it. Additional the ``{EMAIL_SIG}`` must always be on it's own
  line, must be the last line of text and is followed by an empty new line.
* Emails should use all variables that are provided in the english email
  template, in order to provide the same information to the user.
* Emails may only contain ``{U_BOARD}``, ``{EMAIL_SIG}`` and ``{SITENAME}`` as
  additional variables. No other variables are available.
* Emails must not use HTML content.
* There must be an empty new line at the end of the file.

language/{iso}/\*.php and language/{iso}/acp/\*.php
---------------------------------------------------
* The file must must only contain 1 array named ``$lang``. No other variables
  are allowed.
* Language files must contain all keys, which are included in the english
  language file.
* Language files must only contain keys, which are also included in the english
  language file.
* For all entries the `Key Validation`_ applies.

Key Validation
==============

Type
----

* Entries must be of the same type as in the english language. If the entry is
  of type ``string``, your translation must be of type ``string``. If the
  english language is of type ``array`` (e.g. using plurals), your translation
  must be of type ``array`` aswell.
* If the entry is an array, your translation must contain the same keys as the
  english array. Exceptions are plural forms.

String And Integer Replacements
-------------------------------

* If the english string contains replacements, such as ``%s``, ``%1$s``, ``%d``
  and ``%1$d``, your string should contain the same number of replacements.
  Exceptions are integer replacements in plural forms. This allows you to use::

    No posts

  rather then::

    0 posts

HTML
----

* Strings should only contain HTML that is also included in the english
  strings.
* Additional ``<a href="">``, ``<strong>``, ``<em>``, ``<u>`` and ``<br />``
  are allowed.
* ``<b>`` should not be used, use ``<strong>`` instead.
* ``<i>`` should not be used, use ``<em>`` instead.
* Strings should only close HTML which it has opened itself and should close
  all HTML it has opened. Exceptions here are:

    + ``language/{iso}/install.php``
        * ``INSTALL_INTRO_BODY``
        * ``SUPPORT_BODY``
        * ``UPDATE_INSTALLATION_EXPLAIN``
    + ``language/{iso}/ucp.php``
        * ``TERMS_OF_USE_CONTENT``
        * ``PRIVACY_POLICY``

  which are always inside of a ``<p>`` tag and are allowed to close it, if they
  reopen it later on.

Arrays
------

* Arrays must have the same structure and elements as the english version.
  Exceptions are plural forms, which may have more or less keys, depending on
  the plural rule.

Copyright & License
===================

Copyright
---------

The translation is mostly your work and you have a right to hold a copyright
and names to it. Therefor a maximum of 3 links can be included as an author
credit in the footer, customisable via the ``TRANSLATION_INFO`` key in
``common.php``.

.. note::

    The Translations Manager has complete discretion on what is acceptable as
    an author credit link.

License
-------

* All translations must be released under
  `GNU General Public License 2.0 <http://www.opensource.org/licenses/gpl-2.0.php>`_
.. _Customisation Database: https://www.phpbb.com/go/customise/language-packs/3.2
.. _Language Pack Submission Policy: https://area51.phpbb.com/docs/dev/3.2.x/language/guidelines.html#language-pack-submission-policy