======================
Tutorial: Key Concepts
======================

Introduction
============

Before we can jump into making our extension do great things, we need to cover some key concepts and
practices used in phpBB.

This tutorial explains:

 * `Dependency injection`_
 * `PHP files`_
 * `Template files`_
 * `Language files`_
 * `Javascript and CSS files`_

.. _dependency-injection:

Dependency injection
====================

A large portion of the phpBB codebase since 3.1 is based on a fundamental mechanism, namely dependency injection. The
goal is to not have to worry about managing the different dependencies of the components you want to use (e.g. the
database layer, the cache system or the current user object). It's also a means to cease using globally scoped
variables.

Since phpBB 3.1 this has been implemented using the Symfony DependencyInjection Component. All services provided by
phpBB are defined in a YAML format file in ``/config/services.yml``. Extensions can use the services defined by phpBB as
well as define their own services for their PHP classes in their own ``config/services.yml``.

To provide a simple example of dependency injection in action, let's look at the constructor method for Acme Demo's
controller class ``main.php``:

.. code-block:: php

    public function __construct(\phpbb\config\config $config, \phpbb\controller\helper $helper, \phpbb\template\template $template, \phpbb\user $user)
    {
        $this->config = $config;
        $this->helper = $helper;
        $this->template = $template;
        $this->user = $user;
    }

As you can see, it requires the ``$config``, ``$helper``, ``$template``, and ``$user`` objects
(a.k.a. services). To have these services automatically resolved by dependency injection, The Acme Demo extension must
define its controller class as a service in its ``config/services.yml``:

.. code-block:: yaml

    services:
        acme.demo.controller:
            class: acme\demo\controller\main
            arguments:
                - '@config'
                - '@controller.helper'
                - '@template'
                - '@user'

Note that ``acme.demo.controller`` is the unique service name for the class. Extensions 
must prefix them with the vendor and extension name (in this case,
``acme.demo``) to prevent potential conflicts with other extensions or core services.

The ``class`` is simply the name-spaced path to the class.

The ``arguments`` are the service dependencies required by the class. It is important that the
order of arguments must match the order of parameters in the ``__construct()`` method definition.
Any arguments beginning with ``@`` or ``%`` symbols should be wrapped in single quotes (this will be required 
starting from phpBB 3.2).

Most PHP files in an extension should use the dependency injection model with service definitions, particularly
controllers and event listeners. The exceptions to this are any ACP/MCP/UCP files, language files and migration files
(which do not currently use the service container).

.. seealso::

    * `Symfony: The DependencyInjection Component <https://symfony.com/doc/2.8/components/dependency_injection.html>`_


PHP files
=========

As part of phpBB's shift towards widespread use of object orientation, it is advisable for developers to make use of
classes to organise data where appropriate. Extensions are encouraged to store related functions in classes, and
classes in their own files.

The naming of classes is important for consistency. All classes should be name-spaced and have a direct class to path
name mapping; in other words the name-space and class name must be inclusive of the directory structure. For example:

.. code-block:: php

    <?php

    namespace acme\demo\controller;

    class main
    {
        // do something
    }

The above name-spaced code would be for a class file and path structure such as ``acme/demo/controller/main.php``.

Properly name-spaced classes are auto-loaded by phpBB, meaning
that accessor functions do not need to be made for them to be accessible to other classes.

.. note::

    The phpBB 3.1 `Coding Guidelines <https://area51.phpbb.com/docs/31x/coding-guidelines.html>`_ state that
    the closing ``?>`` is not required in PHP files, and all files should contain one extra blank line at the end.

IN_PHPBB Security
-----------------

PHP files that contain only classes are not required to use the ``IN_PHPBB`` security test. However,
if your PHP files contain any executable code not encapsulated within a class structure, such
as exposed functions, ``define()``, ``include()`` or ``require()`` statements, or other artifacts,
then the ``IN_PHPBB`` test is required prior to any executable code:

.. code-block:: php

    <?php

    if (!defined('IN_PHPBB'))
    {
       exit;
    }

    include('somefile.php');

    function do_something ()
    {
       // do something
    }

.. seealso::

    * The phpBB 3.1 `Coding Guidelines <https://area51.phpbb.com/docs/31x/coding-guidelines.html>`_.
    * The phpBB Customisation Database `PHP Validation Policy <https://www.phpbb.com/extensions/rules-and-policies/validation-policy/#php>`_.


Template files
==============

Templating for extensions is no different than templating for phpBB3 in general. phpBB 3.1 has switched to the
Twig template engine but retains phpBB’s original templating syntax. Therefore, either phpBB or Twig template syntax
is permissible in an extension. If you are not familiar with Twig, you may use phpBB’s syntax.

An extension can contain two types of template files: custom templates and :ref:`template-events-label`.
An extension's custom template files should have unique names, preferably prefixed with the vendor and extension
names, to prevent conflicts with other extension or phpBB template files. In addition to template
files, an extension can contain theme files (CSS scripts and images), Javascript files and other assets.

Template files in an extension should be organised in a fashion similar to phpBB’s template
file structure. The ``styles/`` directory should contain directories for each style you have written template files for.
For example, prosilver and subsilver2. Any style that inherits from prosilver, will inherit from your extension’s
prosilver directory as well.

A special ``all/`` directory can be used to contain template files that can be used
with any and all styles (a common JS file, for example).

Template files for the ACP should be stored in the ``adm/style/``
location, similar to phpBB’s structure.

An example directory structure for an extension with universal (all) files and theme specific files:

::

    styles
    ├── all
    │   ├── template
    │   │   └── event
    │   │       └── overall_header_head_append.html
    │   └── theme
    │       ├── css
    │       │   └── acme_demo_main.css
    │       └── images
    │           └── acme_demo_image.png
    ├── prosilver
    │   └── template
    │       ├── acme_demo_body.html
    │       └── event
    │           └── overall_header_navigation_append.html
    └── subsilver2
        └── template
            ├── acme_demo_body.html
            └── event
                └── overall_header_navigation_append.html


.. warning::

    If a standard phpBB template filename is used for an extension template, then it will override the template
    file from phpBB. Therefore it is important to be mindful of this when naming template files. Overriding template
    files is not advisable for publicly released extensions as it could conflict with other extensions.

.. seealso::

    * `Twig Template Syntax <https://twig.symfony.com/>`_ at Symfony.
    * :ref:`Tutorial: Template Syntax <tutorial-template-syntax>`.
    * The phpBB Customisation Database `Template Validation Policy <https://www.phpbb.com/extensions/rules-and-policies/validation-policy/#templates>`_.

Language files
==============

Language files in an extension should be organised in a fashion similar to phpBB’s Language
file structure. The ``language/`` directory should contain directories for each language you have a translation for.
Note that the ``en`` English language is required for all extensions as it is the default language in phpBB.

The Acme Demo extension's language file looks like:

.. code-block:: php

    <?php

    if (!defined('IN_PHPBB'))
    {
        exit;
    }

    if (empty($lang) || !is_array($lang))
    {
        $lang = [];
    }

    $lang = array_merge($lang, [
        'DEMO_PAGE'              => 'Demo',
        'DEMO_HELLO'             => 'Hello %s!',
        'DEMO_GOODBYE'           => 'Goodbye %s!',
        'ACP_DEMO_TITLE'         => 'Demo Module',
        'ACP_DEMO'               => 'Settings',
        'ACP_DEMO_GOODBYE'       => 'Should say goodbye?',
        'ACP_DEMO_SETTING_SAVED' => 'Settings have been saved successfully!',
    ]);

Loading language files in an extension is simple enough using the
``add_lang()`` method of the ``$language`` object. It takes two arguments, the first being the name of the language file (or an array of language file names)
and the second being the extension vendor/package.

.. note::

    The Language object was introduced in 3.2 to provide a dedicated class of language methods,
    extracted from the User object. The previous method of using ``add_lang_ext()``
    from the User object has been deprecated in 3.2, and will eventually be removed in the future.

.. code-block:: php

    // Load a single language file from acme/demo/language/en/common.php
    $language->add_lang(‘common’, ‘acme/demo’);

    // Load multiple language files from
    // acme/demo/language/en/common.php
    // acme/demo/language/en/controller.php
    $language->add_lang([‘common’, ‘controller’], ‘acme/demo’);

For performance reasons, it is preferred to use the above method to load language files at any point in your extension’s code
execution where the language keys are needed. However, if it is absolutely necessary to load an extension's
language keys globally, so they are available at all times, the ``core.user_setup`` PHP event should be used.

.. note::

    Language files can be given any name. However, language files that start with ``permissions_`` or ``info_acp_``
    will be loaded automatically within the ACP for permission and ACP module language keys, respectively,
    and do not need to be loaded using the previously discussed functions or events.

Javascript and CSS files
========================

Javascript and CSS files can be stored anywhere inside your extension. However, the most common locations are
within your style folders. Adding these scripts to your extension's templates can be conveniently handled using
phpBB's ``{% INCLUDECSS %}`` and ``{% INCLUDEJS %}`` template syntax.

The format for these INCLUDE tags takes the following form:

.. code-block:: twig

    {% INCLUDECSS '@vendor_extname/scriptname.css' %}

    {% INCLUDEJS '@vendor_extname/scriptname.js' %}

The INCLUDECSS tag will look in the extension's style **theme** folder for the named file, based on the current style
of the user, or the all style folder if one exists. The INCLUDECSS tag will automatically generate a ``<link>``
tag for the supplied CSS file in the ``<head>`` section of the HTML document.

The INCLUDEJS tag will look in the extension's style **template** folder for the named file, based on the current style
of the user, or the all style folder if one exists. The INCLUDEJS tag will automatically generate a ``<script>`` tag
for the supplied JS file in the footer of the HTML document.

.. note::

    The INCLUDECSS and INCLUDEJS tags can be used in any template event or custom template file.

When including JavaScript/CSS libraries and frameworks such as jQuery-UI or Font Awesome, the potential
for resource overlap between extensions can be mitigated using a simple work-around endorsed by the phpBB
Extensions Team. Using the the ``{% DEFINE %}`` tag you should test if the script your extension wants to include
is already defined, and if not, then include your script and define the script. For example:

.. code-block:: twig

    {% if not $INCLUDED_JQUERYUIJS %}
        {% INCLUDEJS '@vendor_extname/jquery-ui.js' %}
        {% DEFINE $INCLUDED_JQUERYUIJS = true %}
    {% endif %}

Some example template variable definitions to use with common libraries (the common practice should be to name
the variable definition after the library filename, e.g. highslide.js becomes HIGHSLIDEJS):

* HighSlide JS: ``$INCLUDED_HIGHSLIDEJS``
* Font Awesome CSS: ``$INCLUDED_FONTAWESOMECSS``
* ColorBox JS: ``$INCLUDED_COLORBOXJS``
* ColPick JS: ``$INCLUDED_COLPICKJS``
* MoTools JS: ``$INCLUDED_MOTOOLSJS``
* Dojo JS: ``$INCLUDED_DOJOJS``
* Angular JS: ``$INCLUDED_ANGULARJS``

.. seealso::

    The phpBB Customisation Database `JavaScript and CSS Validation Policy <https://www.phpbb.com/extensions/rules-and-policies/validation-policy/#scripts>`_.


Now that we've covered how PHP, template, language and asset files work in phpBB, we're ready to continue on
to the next sections to learn how to build out our extension into something functional.
