========================
What's New for phpBB 3.3
========================

Introduction
============

phpBB 3.3 (Rhea) is only a minor version update to 3.2. There are, however, a few changes extension developers need to be aware of. The biggest changes to come in 3.3 are updates to many of phpBB's underlying dependencies, bringing Symfony, Twig, jQuery and PHP up to date.

This documentation explains:

 * `PHP 7`_
 * `Symfony 3.4`_
 * `Twig 2`_
 * `jQuery 3`_
 * `Extension Installation Error Messages`_

PHP 7
=====

PHP 7.1 is the minimum version required by phpBB 3.3. It is unlikely that this should cause any problems for extensions. If your PHP code worked in phpBB 3.1 or 3.2, it should work in phpBB 3.3 as well.

If you intend to start using some of the new language constructs introduced in PHP 7, you must make your extension's minimum PHP requirement known to your users. This can include setting the minimum PHP version in your extension's ``composer.json`` file as well as designating phpBB 3.3 as a minimum requirement. You can also use the ``ext.php`` file to check that the minimum PHP and phpBB version requirements are satisfied in the ``is_enableable()`` method, which will prevent users who do not meet the requirements from accidentally installing your extension. Examples of this can be found `here <tutorial_advanced.html#using-installation-commands-in-ext-php>`_.

Symfony 3.4
===========

Symfony has been updated to 3.4 (from 2.8). The following changes are due to deprecations introduced in Symfony 2 that have been removed from Symfony 3. The following changes are **required** for phpBB 3.3 and later.

.. note::
    Although the following changes are required for phpBB 3.3, they are backwards compatible and therefore, will still work with phpBB 3.2 and 3.1.

Deprecated special characters at the beginning of unquoted strings
------------------------------------------------------------------

According to Yaml specification, unquoted strings cannot start with ``@``, ``%``, `````, ``|`` or ``>``. You must wrap these strings with single or double quotes:

.. code-block:: yaml

    vendor.package.class:
       class: vendor\package\classname
       arguments:
          - '@dbal.conn'
          - '%custom.tables%'
       calls:
          - [set_controller_helper, ['@controller.helper']]

Deprecated Route Pattern
------------------------

Older versions of Symfony and phpBB allowed routes to be defined using the keyword ``pattern``:

.. code-block:: yaml

    vendor.package.route:
       pattern: /{value}

For phpBB 3.3, route paths must instead be defined using the keyword ``path``:

.. code-block:: yaml

    vendor.package.route:
       path: /{value}

Twig 2
======

Twig has been updated from version 1 to version 2. This change should not affect any Twig template syntax you may be using in your extensions.

jQuery 3
========

phpBB 3.3 ships with jQuery 3.4.1, updated from the much older version 1.12.4 that shipped with phpBB 3.2.

The developers of jQuery are very good about maintaining backwards compatibility, which means that most of your jQuery code should continue to work. The biggest changes introduced by jQuery versions 2 and 3 are dropping support for legacy browsers, in particular, Internet Explorer.

While it's not always easy to check if an extension's jQuery code is functioning fine, jQuery provides a Migration PlugIn on their web site. You can add the un-compressed version of this PlugIn to your phpBB development board, which will output to your browser's error console any problems it finds in your jQuery code.

The majority of any issues you may see reported by the Migration PlugIn will be warnings related to using deprecated jQuery functions (usually shortcuts or aliases such as ``click()`` or ``focus()`` which should instead be changed to the ``on()`` delegation event handler). Even if you are using deprecated functions, they will still most likely work just fine, although it is best to make any recommended updates in the event that jQuery does eventually remove deprecated functions.

Extension Installation Error Messages
=====================================

One often requested feature by extension authors finally makes its debut in phpBB 3.3: Displaying error messages to users when an extension can not be enabled!

Typically extension authors use their extension's ``ext.php`` file to set conditional tests to check and see if a phpBB board meets the basic requirements of their extension. If it fails, the extension is not be enabled. However users are only met with an error message that they failed to meet the extension's requirements.

Now extension authors can finally explain what the specific requirements are that caused the extension to fail to install.

This can be done in the same ``ext.php`` file and the same ``is_enableable()`` method as before. Except now, instead of only being able to return either a true or false boolean, the method allows you to return an array of error messages for each reason why an extension can not be enabled/installed; such as in this following example:

.. note::

    To be backwards compatible with phpBB 3.2 and 3.1, check for phpBB 3.3 or newer before using the new message system. Otherwise for older phpBB boards you must use the original method of returning a simple true/false boolean.

.. code-block:: php

    /**
     * Check if extension can be enabled
     *
     * @return bool|array True if enableable, false (or an array of error messages) if not.
     */
    public function is_enableable()
    {
        // Only install extension if PHP ZipArchive is present
        $enableable = class_exists('ZipArchive');

        // If the test failed and phpBB 3.3 is detected, return error message explaining why
        if (!$enableable && phpbb_version_compare(PHPBB_VERSION, '3.3.0', '>='))
        {
            // Import my extension's language file
            $language = $this->container->get('language');
            $language->add_lang('my_install_lang_file', 'myvendor/myextension');

            // Return message 'PHP ZipArchive is required to enable and use this extension.'
            return array($language->lang('INSTALL_FAILED_MESSAGE'));
        }

        // Return the boolean result of the test, either true (or false for phpBB 3.2 and 3.1)
        return $enableable;
    }
