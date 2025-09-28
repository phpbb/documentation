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
put a link to an international community (`officially`_ listed or not) related to
the language of the contribution. For example, https://www.phpbb.nl/ as Demo
URL concerning the `Dutch language`_ is allowed.

Package
-------

* The submitted ``<languagename>_<version>.zip`` must contain a
  ``<languagename>_<version>`` folder. The files from above should be placed in
  this folder.
* Revision name in the `Customisation Database`_ should be left blank, contain
  the phpBB package version and/or package release name (e.g. ``4.0.0`` /
  ``Bertie's translation`` for 4.0.0) for more understanding.

Package Validation
==================

* Language packages must include all files that are included in the folders for
  the English language. This includes the following directories:

    + ``ext/phpbb/viglink/language/en/``
    + ``language/en/``
    + ``styles/prosilver/theme/en/``

* Language packages must contain 1 additional file:

    + ``language/{iso}/LICENSE``

* Language packages may contain 2 more additional files:

    + ``language/{iso}/CHANGELOG.md``
    + ``language/{iso}/README.md``

* No other additional files are allowed!
* The following folders within the language-directories must contain an ``index.htm`` file: ``language/en/acp/index.htm``, ``language/en/index.htm``, ``styles/prosilver/theme/en/index.htm``.
* No ``index.htm`` is need in the directories for the viglink-translation and the directories which belong the phpBB package: ``language/``, ``styles/``)

File Validation
===============

* All files must be saved with ``LF`` (LineFeed / UNIX) line endings.
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
  but just end with an empty new line.

language/{iso}/composer.json
----------------------------
It is the main configuration file of your translation and language packages.

The ``composer.json`` from the default language `British English` looks like this:

.. code-block:: json

        {
            "name": "phpbb/phpbb-language-en",
            "description": "phpBB Forum Software default language",
            "type": "phpbb-language",
            "version": "4.0.0-RC1",
            "homepage": "https://www.phpbb.com",
            "license": "GPL-2.0-only",
            "authors": [
                {
                    "name": "phpBB Limited",
                    "email": "operations@phpbb.com",
                    "homepage": "https://www.phpbb.com/go/authors"
                }
            ],
            "support": {
                "issues": "https://tracker.phpbb.com",
                "forum": "https://www.phpbb.com/community/",
                "wiki": "https://wiki.phpbb.com",
                "irc": "irc://irc.freenode.org/phpbb"
            },
            "extra": {
                "language-iso": "en",
                "english-name": "British English",
                "local-name": "British English",
                "phpbb-version": "4.0.0-RC1",
                "direction": "ltr",
                "user-lang": "en-gb",
                "plural-rule": 1,
                "recaptcha-lang": "en-GB",
                "turnstile-lang": "en"
            }
        }

Main block
^^^^^^^^^^
The main block of a language's ``composer.json`` file requires these six fields of information:

* ``"name":`` Must start with ``phpbb/phpbb-language-`` and be followed by the language iso code e.g.: ``phpbb/phpbb-language-de``
* ``"description":`` Must contain a short description for your translation e.g.: ``phpBB Forum Software language package Dutch (Casual Honorifics)``. URLs are not allowed. 
* ``"type":`` Must be: ``"phpbb-language",``. Do not change this!
* ``"version":`` Should be the version number of the language package. This can be different than the phpBB-version it is made for.
* ``"homepage":`` You may include a URL to your website, or leave this field empty using empty quotes ``""``
* ``"license":`` Must be: ``"GPL-2.0-only",``. Do not change this!

Authors
^^^^^^^
Use this section to credit the authors and maintainers of this translation. You can add repeating blocks like this for each additional author.

.. code-block:: json

		{
			"name": "Person A",
			"email": "mail@example.org",
			"homepage": "https://www.example.org"
		}

Support
^^^^^^^
Use this section to provide links to your websites, email, chat channels, etc. where you provide support for this translation. You should have at least one contact URL, e.g. the support section in the Customisation Database on www.phpBB.com.

Extra
^^^^^
The Extra block contains information required for the translation to function correctly within a phpBB installation.
Please do not omit any of these lines, and fill them out carefully.

* ``"language-iso":`` This must be your ISO code. In British English it is ``en``. This is also the same as the directory name e.g. ``language/en/`` or ``language/de_x_sie/``. 
* ``"english-name":`` The English name of your language package e.g.: ``"German (Casual Honorifics)"``. (Formerly, this was the first line of ``language/{iso}/iso.txt``.)
* ``"local-name":`` The local name of your language package e.g.: ``"Deutsch (Du)"``. (Formerly, this was the  second line of ``language/{iso}/iso.txt``.)
* ``"phpbb-version":`` This must represent an existing phpBB release version e.g.: ``4.0.0``. Individual naming is not allowed here!
* ``"direction":`` Use ``"ltr""`` for "left-to-right" languages (e.g.: Italian, Dutch, German) and ``"rtl"`` for right-to-left language (e.g.: Arabic).
* ``"user-lang":`` Input the user language code, e.g.: "de". (Formerly defined in the ``language/{iso}/common.php`` e.g.: ``'USER_LANG'    => 'de',`` or ``'USER_LANG'    => 'de-x-sie',``.)
* ``"plural-rule":`` Input the plural rule number of your language. (Formerly defined in the ``language/{iso}/common.php`` e.g.: ``'PLURAL_RULE'	=> 1,``.) Check the `plurals`_ section for more details.
* ``"recaptcha-lang":`` Input the ReCaptcha-Language-Code here. (Formerly defined in the ``language/{iso}/captcha_recaptcha.php`` e.g.: ``'RECAPTCHA_LANG' => 'de',``.) Check `Google ReCaptcha`_ for further information which code to use.
* ``"turnstile-lang":`` Input the Turnstile-Language-Code here. Check `Cloudflare Turnstile`_ for further information which code to use.

.. note::

    The ``composer.json`` must be valid JSON code. You can validate it using ``composer.phar``, see: `composer.json validation`_.

\*/index.htm
------------

The ``index.htm`` files in all folders must be either completely empty or contain the default html body:

.. code-block:: html

    <html>
    <head>
    <title></title>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    </head>

    <body bgcolor="#FFFFFF" text="#000000">

    </body>
    </html>

language/{iso}/help/\*.php
--------------------------

* The file must must only contain 1 array named `$lang`. No other variables are allowed.
* The array must only contain arrays with the following structure:

    .. code-block:: php

        [
            0 => 'TextA',
            1 => 'TextB',
        ],

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
  `GNU General Public License 2.0 <https://opensource.org/license/gpl-2-0>`_

.. _Customisation Database: https://www.phpbb.com/go/customise/language-packs/4.0
.. _Language Pack Submission Policy: https://area51.phpbb.com/docs/dev/master/language/guidelines.html#language-pack-submission-policy
.. _officially: https://www.phpbb.com/support/intl/
.. _Dutch language: https://www.phpbb.com/customise/db/translation/dutch_casual_honorifics/
.. _Google ReCaptcha: https://developers.google.com/recaptcha/docs/language
.. _Cloudflare Turnstile: https://developers.cloudflare.com/turnstile/reference/supported-languages/
.. _plurals: https://area51.phpbb.com/docs/dev/master/language/plurals.html
.. _composer.json validation: https://getcomposer.org/doc/03-cli.md#validate
