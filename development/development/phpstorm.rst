=========================
Using PhpStorm With phpBB
=========================

PhpStorm is an IDE (Integrated Development Environment) and is the preferred development platform of the phpBB development team.

This guide explains how to setup PhpStorm for development with phpBB.

Create a New Project
====================

First you will need to get a copy of phpBB's development repository from GitHub.

1. Visit the `phpBB repository <https://github.com/phpbb/phpbb>`_ and fork it to your GitHub account.

2. Clone your new phpBB fork to your computer.

3. Open PhpStorm

4. Choose "Create New Project from Existing Files" and follow the Wizard's steps.

.. note:: Depending on your local environment, typically the best choise is "Source files are in a local directory, no web server is yet configured". You can always set up the web server later.

5. Select the phpBB project folder you cloned from GitHub and click "Project Root". Then click "Finish".

Code Style
==========

Setting up PhpStorm to honor phpBB's coding style guide will ensure you are always writing code that meets phpBB's requirements. These settings are configured in PhpStorm's Settings/Preferences, under **Editor > Code Style**.

.. note:: Before changing settings, it's a good idea to create a phpBB "Scheme" in the Code Style settings pane. This phpBB scheme can be applied to any phpBB project you create in PhpStorm.

.. seealso:: For your convenience we have provided an XML export of the following code style settings for phpBB (see `phpBB Code Style Scheme`_). You can import these settings into your project and all the following styling settings will be configured for you.

PHP
###

Tabs & Indents
**************

Tabs should be used (not spaces). All tab and indent sizes should be set to 4 spaces. Also be sure "Keep indents on empty lines" is NOT checked.

Spaces
******

There are many settings for handling spaces, and the defaults should work for the most part. The general rule is single-spaces should surround all operators and parentheses (except for function declarations/calls).

Wrapping and Braces
*******************

The general rule here is that braces always go on new lines.

CSS, JavaScript, HTML, Twig
###########################

Tabs should be used (not spaces). All tab and indent sizes should be set to 4 spaces. 
Also be sure "Keep indents on empty lines" is NOT checked.

JSON & YAML
###########

Json and Yaml files uses 4 spaces over tabs, so tab character should be disabled and 4 spaces the indent size.

Inspections
===========

One of the most powerful features of an IDE like PhpStorm is its ability to inspect your code and provide, in real time, errors and warnings. An IDE is fully aware of how phpBB's codebase is designed to work, and how all of its classes and functions interact with each other. Inspections can instantly show you, for example, if you are using a function incorrectly, calling non-existent methods, missing arguments, etc.

The default inspection settings should work just fine. However there are a couple adjustments that might be desired:

* If PhpStorm is not connected to your database server, you may want to turn off **SQL > SQL Dialect Detection** and **SQL > No data sources configured** warnings.
* phpBB uses fully qualified namespaces, so you can turn off this inspection warning **PHP > Code Style > Unnecessary fully qualified name**.
* You may enable additional JavaScript inspections. Under **JavaScript > Code quality tools**, you can enable JSCS, JSHint, JSlint and/or ESLint. phpBB comes with configuration files for JSHint and JSCS. With these inspections enabled, you can use the configuration files provided by phpBB instead of PhpStorm's default settings. To do so, point PhpStorm to the custom configuration files under **Language & Frameworks > JavaScript > Code Quality Tools**. Point JSHint to `.jshintrc` and point JSCS to `.jscsrc`.

.. warning:: Stylelint is not bundled with PhpStorm. The Stylelint tool is run through NodeJS. To use Stylelint, make sure the NodeJS framework is downloaded and installed on your computer. Then you can follow these `Instructions <https://www.jetbrains.com/help/phpstorm/2016.3/using-stylelint-code-quality-tool.html>`_.

.. warning:: JSCS is not bundled with PhpStorm. The JSCS tool is run through NodeJS. To use JSCS, make sure the NodeJS framework is downloaded and installed on your computer. Then you can install JSCS via the npm package manager and configure the JSCS options in PhpStorm to use the JSCS package. For more information review `PhpStorm's documentation <https://www.jetbrains.com/help/phpstorm/10.0/using-javascript-code-quality-tools.html#JSCS>`_.

.. note:: phpBB uses jQuery. The Javascript inspections need to be made aware of jQuery to avoid any false warnings/errors. To do this, simply go to **Languages & Frameworks > JavaScript > Libraries** and enable jQuery. If jQuery is not in the list, you can use the "Download" button to download a copy of jQuery to PhpStorm.

.. seealso:: For your convenience we have provided an XML export of the above code inspection settings for phpBB (see `phpBB Inspection Profile`_). You can import these settings into your project and all the above inspection settings will be configured for you.

Plugins
=======

Adding plugins to PhpStorm can bring even more features, tools, inspectors and code quality analysis to your IDE.

EditorConfig
############

phpBB uses an EditorConfig profile. Install the EditorConfig plug-in to take advantage of it. This nifty plug-in will automatically make sure your PHP, CSS, JS, HTML, YML and MD files will always correctly use tabs or spaces as required by the file type, trim trailing whitespaces, and ensure all files have a new empty line at the end.

Languages & Frameworks
======================

PHP inspections are dependent upon the PHP language level (i.e. PHP 5.3, 5.4, 7.0, etc.). You should set the **PHP language level** to the minimum version phpBB supports. This is to ensure you don't accidentally write code that may be valid in PHP 5.6, but incompatible with PHP 5.4 (which phpBB supports). The **PHP interpreter** should be set to whatever PHP binary is available in the drop down menu. If no interpreter is found, you need to direct it to your PHP executable on your system (e.g.: /usr/bin/php).

PHPUnit Testing
===============

While it's possible to run PHPUnit tests in PhpStorm directly from the Terminal window, PHPUnit testing is also built into PhpStorm as a Run/Debug action. The benefit of this, is testing can more easily be paused or aborted. Failed tests can be re-run without having to run the entire test suite. Best of all the failed test reporting has hyperlinks to the failing code points, making it much easier to jump to the problem tests and phpBB code and debug them.

.. note:: This assumes you already have PHPUnit testing configured and working from the command line interface. Read the :doc:`../testing/index` documentation for more information.

To set up PHPunit within PhpStorm, go to:

* **Run > Edit Configurations**

* Hit the **+** to create a new PHPUnit configuration and give it a name, like 'phpBB tests'.

* Set **Test Runner** to **Defined in configuration file**.

* Check **Use alternative configuration file** and point it to the **phpunit.xml.dist** file in the phpBB project root.

* Set **Command Line > Custom working directory** to the phpBB project root.

* Now you can choose **Run > phpBB tests** and the unit tests should run within PhpStorm.

.. note:: If you are writing extensions for phpBB, you can set up PHPUnit test configurations for each extension as well. Just change each configuration to use the extension's configuration file instead of phpBB's.

PhpStorm Setting Exports for phpBB
==================================

Copy and save these code blocks as XML files, and they can be imported into PhpStorm's settings to automatically set up most of the configuration recommendations mentioned in this documentation for phpBB.

phpBB Code Style Scheme
#######################

.. code-block:: xml

    <code_scheme name="phpBB">
      <option name="OTHER_INDENT_OPTIONS">
        <value>
          <option name="INDENT_SIZE" value="4" />
          <option name="CONTINUATION_INDENT_SIZE" value="8" />
          <option name="TAB_SIZE" value="4" />
          <option name="USE_TAB_CHARACTER" value="true" />
          <option name="SMART_TABS" value="false" />
          <option name="LABEL_INDENT_SIZE" value="0" />
          <option name="LABEL_INDENT_ABSOLUTE" value="false" />
          <option name="USE_RELATIVE_INDENTS" value="false" />
        </value>
      </option>
      <option name="HTML_TEXT_WRAP" value="0" />
      <CssCodeStyleSettings>
        <option name="KEEP_SINGLE_LINE_BLOCKS" value="true" />
      </CssCodeStyleSettings>
      <JSCodeStyleSettings>
        <option name="SPACE_BEFORE_FUNCTION_LEFT_PARENTH" value="false" />
      </JSCodeStyleSettings>
      <PHPCodeStyleSettings>
        <option name="ALIGN_KEY_VALUE_PAIRS" value="true" />
        <option name="ALIGN_PHPDOC_PARAM_NAMES" value="true" />
        <option name="ALIGN_PHPDOC_COMMENTS" value="true" />
        <option name="COMMA_AFTER_LAST_ARRAY_ELEMENT" value="true" />
        <option name="PHPDOC_BLANK_LINE_BEFORE_TAGS" value="true" />
        <option name="PHPDOC_WRAP_LONG_LINES" value="true" />
        <option name="LOWER_CASE_BOOLEAN_CONST" value="true" />
        <option name="LOWER_CASE_NULL_CONST" value="true" />
        <option name="PHPDOC_USE_FQCN" value="true" />
        <option name="MULTILINE_CHAINED_CALLS_SEMICOLON_ON_NEW_LINE" value="true" />
        <option name="NAMESPACE_BRACE_STYLE" value="2" />
      </PHPCodeStyleSettings>
      <XML>
        <option name="XML_LEGACY_SETTINGS_IMPORTED" value="true" />
      </XML>
      <codeStyleSettings language="CSS">
        <indentOptions>
          <option name="USE_TAB_CHARACTER" value="true" />
        </indentOptions>
      </codeStyleSettings>
      <codeStyleSettings language="HTML">
        <indentOptions>
          <option name="USE_TAB_CHARACTER" value="true" />
        </indentOptions>
      </codeStyleSettings>
      <codeStyleSettings language="JavaScript">
        <indentOptions>
          <option name="USE_TAB_CHARACTER" value="true" />
        </indentOptions>
      </codeStyleSettings>
      <codeStyleSettings language="PHP">
        <option name="BLANK_LINES_AFTER_PACKAGE" value="1" />
        <option name="BRACE_STYLE" value="2" />
        <option name="ELSE_ON_NEW_LINE" value="true" />
        <option name="CATCH_ON_NEW_LINE" value="true" />
        <option name="INDENT_BREAK_FROM_CASE" value="false" />
        <option name="ALIGN_MULTILINE_PARAMETERS" value="false" />
        <option name="ALIGN_MULTILINE_FOR" value="false" />
        <option name="ALIGN_MULTILINE_ARRAY_INITIALIZER_EXPRESSION" value="true" />
        <option name="SPACE_AFTER_TYPE_CAST" value="true" />
        <option name="METHOD_CALL_CHAIN_WRAP" value="5" />
        <indentOptions>
          <option name="USE_TAB_CHARACTER" value="true" />
        </indentOptions>
      </codeStyleSettings>
      <codeStyleSettings language="Twig">
        <indentOptions>
          <option name="USE_TAB_CHARACTER" value="true" />
        </indentOptions>
      </codeStyleSettings>
      <codeStyleSettings language="yaml">
        <indentOptions>
          <option name="INDENT_SIZE" value="4" />
        </indentOptions>
      </codeStyleSettings>
    </code_scheme>

phpBB Inspection Profile
########################

.. code-block:: xml

    <?xml version="1.0" encoding="UTF-8"?>
    <inspections version="1.0" is_locked="false">
      <option name="myName" value="phpBB" />
      <option name="myLocal" value="false" />
      <inspection_tool class="JSHint" enabled="true" level="ERROR" enabled_by_default="true" />
      <inspection_tool class="PhpUnnecessaryFullyQualifiedNameInspection" enabled="false" level="WEAK WARNING" enabled_by_default="false" />
      <inspection_tool class="SqlDialectInspection" enabled="false" level="WARNING" enabled_by_default="false" />
      <inspection_tool class="SqlNoDataSourceInspection" enabled="false" level="WARNING" enabled_by_default="false" />
    </inspections>
