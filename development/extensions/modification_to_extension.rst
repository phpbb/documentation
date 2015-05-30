==========================================================
Updating a phpBB 3.0 modification to a phpBB 3.1 extension
==========================================================

Extension Structure
===================

The most obvious change should be the location the MODs / Extensions are stored
in 3.1. In phpBB 3.0 all files were put into the core's root folder. In phpBB
3.1 a special directory for Extensions has been created. It's called ``ext/``.

Directory
---------

Each extension has its own directory. However, you can (and should) also use an
additional vendor directory (with your author name or author-group name). In
case of my newspage the files will be in

.. code-block:: php

    phpBB/ext/nickvergessen/newspage/

There should not be a need to have files located outside of that directory. No
matter which files, may it be styles, language or ACP module files. All of them
will be moved into your extension's directory:

+--------------------+------------------------------+
| new directory      | current directory            |
+====================+==============================+
| acp/\*_module.php  | phpBB/includes/acp/          |
+--------------------+------------------------------+
| acp/\*_info.php    | phpBB/includes/acp/info/     |
+--------------------+------------------------------+
| adm/style/         | phpBB/adm/style/             |
+--------------------+------------------------------+
| config/            | ---                          |
+--------------------+------------------------------+
| controller/        | \*.php                       |
+--------------------+------------------------------+
| event/             | ---                          |
+--------------------+------------------------------+
| language/          | phpBB/language/              |
+--------------------+------------------------------+
| migrations/        | ---                          |
+--------------------+------------------------------+
| styles/            | phpBB/styles/                |
+--------------------+------------------------------+


Newly added, additional directories have already been listed. Their use will be
explained in the following paragraphs.

Important new files
-------------------

There is a new file, your extension needs, in order to be recognized by the
system. It's called ``composer.json``:
it specifies the requirements of your extension aswell as some author
information. The layout is a simple json array, the keys should really explain
enough.

**Note:** you must not change the ``type`` element.
In the ``require`` section you can also specify other extensions which are
required in order to install this one. (*Validation for this is not yet
implemented, but will be in 3.1.0*)


.. code-block:: json

    {
        "name": "nickvergessen/newspage",
        "type": "phpbb-extension",
        "description": "Adds a extra-page to the board where a switchable number of news are displayed. The text can be shorten to a certain number of chars. Also the Icons can be switched of (post icons, user icons)",
        "homepage": "https://github.com/nickvergessen/phpbb3-mod-newspage",
        "version": "1.1.0",
        "time": "2013-03-16",
        "license": "GPL-2.0",
        "authors": [
            {
                "name": "Joas Schilling",
                "email": "nickvergessen@gmx.de",
                "homepage": "http://www.flying-bits.org",
                "role": "Lead Developer"
            }
        ],
        "require": {
            "php": ">=5.3.3"
        },
        "extra": {
            "display-name": "phpBB 3.1 NV Newspage Extension",
            "soft-require": {
                "phpbb/phpbb": ">=3.1.0-RC2,<3.2.*@dev"
            }
        }
     }

The second new file is called ``ext.php``. It can be used to extend the
functionality while install/uninstalling your extension:

.. code-block:: php

     <?php

     // this file is not really needed, when empty it can be ommitted
     // however you can override the default methods and add custom
     // installation logic

     namespace nickvergessen\newspage;

     class ext extends \phpbb\extension\base
     {
     }


Front-facing files, routes and services
---------------------------------------

While in 3.0 you just created a new file in the root directory of phpBB, you
might want to use the new controller system of 3.1 in future. Your links change
from something like ``phpBB/newspage.php`` to ``phpBB/app.php/newspage`` in
first place, but with a little htaccess rule this can be rewritten to
``phpBB/newspage``.

In order to link a specific routing rule to your extension, you need to define
the route in your extension's ``config/routing.yml``.

For the easy start of the newspage, 2 rules are enough. The first rule is for
the basic page currently ``newspage.php``, the second one is for the pagination,
like ``newspage.php?start=5``. The first rule sets a default page (1), while the
second rule requires a second part of the url to be an integer.

.. code-block:: yaml

     newspage_base_controller:
         pattern: /newspage
         defaults: { _controller: nickvergessen.newspage.controller:base, page: 1 }

     newspage_page_controller:
         pattern: /newspage/{page}
         defaults: { _controller: nickvergessen.newspage.controller:base }
         requirements:
             page:  \d+

The string we define for ``_controller`` defines a service
(``nickvergessen.newspage.controller``) and a method (``base``) of the class
which is then called. Services are defined in your extensions
``config/services.yml``. Services are instances of classes. Services are used,
so there is only one instance of the class which is used all the time. You can
also define the arguments for the constructor of your class. The example
definition of the newspage controller service would be something similar to:

.. code-block:: yaml

     services:
         nickvergessen.newspage.controller:
             class: nickvergessen\newspage\controller\main
             arguments:
                 - @auth
                 - @cache
                 - @config
                 - @dbal.conn
                 - @request
                 - @template
                 - @user
                 - @controller.helper
                 - %core.root_path%
                 - %core.php_ext%

Any service that is previously defined in your file, or in the file of the phpBB
core ``phpBB/config/services.yml``, can also be used as an argument, aswell as
some predefined string (like ``core.root_path`` here).


.. note::

    The classes from ``phpBB/ext/`` are automatically loaded by their namespace
    and class names, whereby backslash ( ``\`` ) represent directories. In this
    case the class ``nickvergessen\newspage\controller\main`` would be located
    in ``phpBB/ext/nickvergessen/newspage/controller/main.php``

For more explanations about
`Routing <http://symfony.com/doc/2.3/book/routing.html>`_ and
`Services <http://symfony.com/doc/2.3/book/service_container.html>`_ see the
Symfony 2.3 Documentation.

In this example my **controller/main.php** would look like the following:

.. code-block:: php

     <?php

     /**
      *
      * @package NV Newspage Extension
      * @copyright (c) 2013 nickvergessen
      * @license http://opensource.org/licenses/gpl-2.0.php GNU General Public License v2
      *
      */

     namespace nickvergessen\newspage\controller;

     class main
     {
        /**
         * Constructor
         * NOTE: The parameters of this method must match in order and type with
         * the dependencies defined in the services.yml file for this service.
         *
         * @param \phpbb\config    $config        Config object
         * @param \phpbb\template    $template    Template object
         * @param \phpbb\user    $user        User object
         * @param \phpbb\controller\helper        $helper                Controller helper object
         * @param string            $root_path    phpBB root path
         * @param string            $php_ext    phpEx
         */
        public function __construct(\phpbb\config\config $config, \phpbb\template\template $template, \phpbb\user $user, \phpbb\controller\helper $helper, $root_path, $php_ext)
        {
            $this->config = $config;
            $this->template = $template;
            $this->user = $user;
            $this->helper = $helper;
            $this->root_path = $root_path;
            $this->php_ext = $php_ext;
        }

        /**
         * Base controller to be accessed with the URL /newspage/{page}
         * (where {page} is the placeholder for a value)
         *
         * @param int    $page    Page number taken from the URL
         * @return Symfony\Component\HttpFoundation\Response A Symfony Response object
         */
        public function base($page = 1)
        {
            /*
            * Do some magic here,
            * load your data and send it to the template.
            */

            /*
            * The render method takes up to three other arguments
            * @param    string        Name of the template file to display
            *                        Template files are searched for two places:
            *                        - phpBB/styles/<style_name>/template/
            *                        - phpBB/ext/<all_active_extensions>/styles/<style_name>/template/
            * @param    string        Page title
            * @param    int            Status code of the page (200 - OK [ default ], 403 - Unauthorized, 404 - Page not found, etc.)
            */
            return $this->helper->render('newspage_body.html');
        }
     }

.. note::

    The consecution of arguments in services.yml should match the consecution of
    arguments passed to the class constructor ``public function __construct()``.
    Otherwise, error will be thrown and the board will be broken if you try to
    enable the extension.

You can also have multiple different methods in one controller aswell as having
multiple controllers, in order to organize your code a bit better.

If we now add the entry for our extension into the phpbb_ext table, and go to
``example.tld/app.php/newspage/`` you can see your template file.

**Congratulations!** You just finished the "Hello World" example for phpBB
Extensions. ;)

ACP Modules
-----------

This section also applies to MCP and UCP modules.

As mentioned before these files are also moved into your extensions directory.
The info-file, currently located in
``phpBB/includes/acp/info/acp_newspage.php``, is going to be
``ext/nickvergessen/newspage/acp/main_info.php`` and the module itself is moved
from ``phpBB/includes/acp/acp_newspage.php`` to
``ext/nickvergessen/newspage/acp/main_module.php``. In order to be able to
automatically load the files by their class names we need to make some little
adjustments to the classes themselves.

As for the ``main_info.php`` I need to adjust the class name from
``acp_newspage_info`` to ``main_info`` and also change the value of
``'filename'`` in the returned array.

.. code-block:: php

     <?php

     /**
      *
      * @package NV Newspage Extension
      * @copyright (c) 2013 nickvergessen
      * @license http://opensource.org/licenses/gpl-2.0.php GNU General Public License v2
      *
      */

     /**
     * @ignore
     */
     if (!defined('IN_PHPBB'))
     {
        exit;
     }

     namespace nickvergessen\newspage\acp;

     class main_info
     {
        function module()
        {
            return array(
                'filename'    => '\nickvergessen\newspage\acp\main_module',
                'title'        => 'ACP_NEWSPAGE_TITLE',
                'version'    => '1.0.1',
                'modes'        => array(
                    'config_newspage'    => array('title' => 'ACP_NEWSPAGE_CONFIG', 'auth' => 'acl_a_board', 'cat' => array('ACP_NEWSPAGE_TITLE')),
                ),
            );
        }
     }

In case of the module, I just adjust the class name:

.. code-block:: php

     <?php

     /**
      *
      * @package NV Newspage Extension
      * @copyright (c) 2013 nickvergessen
      * @license http://opensource.org/licenses/gpl-2.0.php GNU General Public License v2
      *
      */

     /**
      * @ignore
      */
     if (!defined('IN_PHPBB'))
     {
        exit;
     }

     namespace nickvergessen\newspage\acp;

     class main_module
     {
        var $u_action;

        function main($id, $mode)
        {
            // Your magic stuff here
        }
     }

And there you go. Your Extensions ACP module can now be added through the ACP
and you just finished another step of successfully converting a MOD into an
Extension.

Database Changes, UMIL replaced by Migrations
=============================================

`Wiki/Migrations <https://wiki.phpbb.com/Migrations>`_

Basically migrations to the same as your 3.0 UMIL files. It performs the
database changes of your MOD/Extension. The biggest difference between
migrations and UMIL hereby is, that while you had one file with one array in
UMIL for all your changes, you have one file per version in Migrations. But
let's have a look at the newspage again.

.. code-block:: php

     $versions = array(
        '1.0.0'    => array(
            'config_add' => array(
                array('news_number', 5),
                array('news_forums', '0'),
                array('news_char_limit', 500),
                array('news_user_info', 1),
                array('news_post_buttons', 1),
            ),
            'module_add' => array(
                array('acp', 'ACP_CAT_DOT_MODS', 'NEWS'),

                array('acp', 'NEWS', array(
                        'module_basename'    => 'newspage',
                        'module_langname'    => 'NEWS_CONFIG',
                        'module_mode'        => 'overview',
                        'module_auth'        => 'acl_a_board',
                    ),
                ),
            ),
        ),
        '1.0.1'    => array(
            'config_add' => array(
                array('news_pages', 1),
            ),
        ),
        '1.0.2'    => array(),
        '1.0.3' => array(
            'config_add' => array(
                array('news_attach_show', 1),
                array('news_cat_show', 1),
                array('news_archive_per_year', 1),
            ),
        ),
     );

Schema Changes
--------------

The newspage does not have any database schema changes, so I will use the
Example from the `Wiki <https://wiki.phpbb.com/Migrations/Schema_Changes>`_.
Basically you need to have two methods in your migration class file:


.. code-block:: php

     public function update_schema()

and


.. code-block:: php

     public function revert_schema()

whereby both methods return an array with the changes:

.. code-block:: php

     public function update_schema()
     {
        return array(
            'add_columns'        => array(
                $this->table_prefix . 'groups'        => array(
                    'group_teampage'    => array('UINT', 0, 'after' => 'group_legend'),
                ),
                $this->table_prefix . 'profile_fields'    => array(
                    'field_show_on_pm'        => array('BOOL', 0),
                ),
            ),
            'change_columns'    => array(
                $this->table_prefix . 'groups'        => array(
                    'group_legend'        => array('UINT', 0),
                ),
            ),
        );
     }

     public function revert_schema()
     {
        return array(
            'drop_columns'        => array(
                $this->table_prefix . 'groups'        => array(
                    'group_teampage',
                ),
                $this->table_prefix . 'profile_fields'    => array(
                    'field_show_on_pm',
                ),
            ),
            'change_columns'    => array(
                $this->table_prefix . 'groups'        => array(
                    'group_legend'        => array('BOOL', 0),
                ),
            ),
        );
     }

The ``revert_schema()`` should thereby revert all changes made by the
``update_schema()``.

Data Changes
------------

The data changes, like adding modules, permissions and configs, are provided
with the ``update_data()`` function.

This function returns an array as well. The example for the 1.0.0 version update
from the newspage would look like the following:

.. code-block:: php

     public function update_data()
     {
        return array(
            array('config.add', array('news_number', 5)),
            array('config.add', array('news_forums', '0')),
            array('config.add', array('news_char_limit', 500)),
            array('config.add', array('news_user_info', 1)),
            array('config.add', array('news_post_buttons', 1)),

            array('module.add', array(
                'acp',
                'ACP_CAT_DOT_MODS',
                'ACP_NEWSPAGE_TITLE'
            )),
            array('module.add', array(
                'acp',
                'ACP_NEWSPAGE_TITLE',
                array(
                    'module_basename'    => '\nickvergessen\newspage\acp\main_module',
                    'modes'                => array('config_newspage'),
                ),
            )),

            array('config.add', array('newspage_mod_version', '1.0.0')),
        );
     }

More information about these data update tools can be found in
:doc:`migration/tools/index`.

Dependencies and finishing up migrations
----------------------------------------

Now there are only two things left, your migration file needs. The first thing
is a check, which allows phpbb to see whether the migration is already
installed, although it did not run yet (f.e. when updating from a 3.0 MOD to a
3.1 Extension).

The easiest way for this to check, could be the version of the MOD, but when you
add columns to tables, you can also check whether they exist:

.. code-block:: php

     public function effectively_installed()
     {
        return isset($this->config['newspage_mod_version']) && version_compare($this->config['newspage_mod_version'], '1.0.0', '>=');
     }

As the migration files can have almost any name, phpBB might be unable to sort
your migration files correctly. To avoid this problem, you can define a set of
dependencies which must be installed before your migration can be installed.
phpBB will try to install them, before installing your migration. If they can
not be found or installed, your installation will fail as well. For the 1.0.0
migration I will only require the ``3.1.0-a1`` Migration:

.. code-block:: php

     static public function depends_on()
     {
        return array('\phpbb\db\migration\data\v310\alpha1');
     }

All further updates can now require this Migration and so also require the
3.1.0-a1 Migration.

A complete file could look like this:

.. code-block:: php

     <?php
     /**
      *
      * @package migration
      * @copyright (c) 2013 phpBB Group
      * @license http://opensource.org/licenses/gpl-license.php GNU Public License v2
      *
      */

     namespace nickvergessen\newspage\migrations\v10x;

     class release_1_0_0 extends \phpbb\db\migration\migration
     {
        public function effectively_installed()
        {
            return isset($this->config['newspage_mod_version']) && version_compare($this->config['newspage_mod_version'], '1.0.0', '>=');
        }

        static public function depends_on()
        {
            return array('phpbb_db_migration_data_310_dev');
        }

        public function update_data()
        {
            return array(
                array('config.add', array('news_number', 5)),
                array('config.add', array('news_forums', '0')),
                array('config.add', array('news_char_limit', 500)),
                array('config.add', array('news_user_info', 1)),
                array('config.add', array('news_post_buttons', 1)),

                array('module.add', array(
                    'acp',
                    'ACP_CAT_DOT_MODS',
                    'ACP_NEWSPAGE_TITLE'
                )),
                array('module.add', array(
                    'acp',
                    'ACP_NEWSPAGE_TITLE',
                    array(
                        'module_basename'    => '\nickvergessen\newspage\acp\main_module',
                        'modes'                => array('config_newspage'),
                    ),
                )),

                array('config.add', array('newspage_mod_version', '1.0.0')),
            );
        }
     }


Include extension's language files
==================================

As the language files in your extension are not detected by the
``$user->add_lang()`` any more, you need to use the ``$user->add_lang_ext()``
method. This method takes two arguments, the first one is the fullname of the
extension (including the vendor) and the second one is the file name or array of
file names. so in order to load my newspage language file I now call:

.. code-block:: php

     $user->add_lang_ext('nickvergessen/newspage', 'newspage');

to load my language from
``phpBB/ext/nickvergessen/newspage/language/en/newspage.php``

File edits - Better don't edit anything, just use Events and Listeners
======================================================================

As for the newspage Modification, the only thing that is now missing from
completion is the link in the header section, so you can start browsing the
newspage.

In order to do this, I used to define the template variable in the
``page_header()``-function of phpBB and then edit the ``overall_header.html``.
But this is 3.1 so we don't like file edits anymore and added **events**
instead. With events you can hook into several places and execute your code,
without editing them.

php Events
----------

So instead of adding

.. code-block:: php

     $template->assign_vars(array(
        'U_NEWSPAGE'    => append_sid($phpbb_root_path . 'app.' . $phpEx, 'controller=newspage/'),
     ));

to the ``page_header()``, we put that into an event listener, which is then
called, everytime ``page_header()`` itself is called.

So we add the **event/main_listener.php** file to our extension, which
implements some Symfony class:

.. code-block:: php

     <?php

     /**
      *
      * @package NV Newspage Extension
      * @copyright (c) 2013 nickvergessen
      * @license http://opensource.org/licenses/gpl-2.0.php GNU General Public License v2
      *
      */

     /**
      * @ignore
      */

     if (!defined('IN_PHPBB'))
     {
        exit;
     }

     namespace nickvergessen\newspage\event;

     /**
      * Event listener
      */
     use Symfony\Component\EventDispatcher\EventSubscriberInterface;

     class main_listener implements EventSubscriberInterface
     {
        /**
         * Instead of using "global $user;" in the function, we use dependencies again.
         */
        public function __construct(\phpbb\controller\helper $helper, \phpbb\template\template $template, \phpbb\user $user)
        {
            $this->helper = $helper;
            $this->template = $template;
            $this->user = $user;
        }
     }

In the ``getSubscribedEvents()`` method we tell the system for which events we
want to get notified and which function should be executed in case it's called.
In our case we want to subscribe to the ``core.page_header``-Event (a full list
of events can be found `here <https://wiki.phpbb.com/Event_List>`_):

.. code-block:: php

        static public function getSubscribedEvents()
        {
            return array(
                'core.user_setup'                => 'load_language_on_setup',
                'core.page_header'                => 'add_page_header_link',
            );
        }

Now we add the function which is then called:

.. code-block:: php

        public function load_language_on_setup($event)
        {
            $lang_set_ext = $event['lang_set_ext'];
            $lang_set_ext[] = array(
                'ext_name' => 'nickvergessen/newspage',
                'lang_set' => 'newspage',
            );
            $event['lang_set_ext'] = $lang_set_ext;
        }

        public function add_page_header_link($event)
        {
            // I use a second language file here, so I only load the strings global which are required globally.
            // This includes the name of the link, aswell as the ACP module names.
            $this->user->add_lang_ext('nickvergessen/newspage', 'newspage_global');

            $this->template->assign_vars(array(
                'U_NEWSPAGE'    => $this->helper->route('newspage_base_controller'),
            ));
        }

As a last step we need to register the event listener to the system.
This is done using the ``event.listener`` tag in the service.yml:

.. code-block:: yaml

    nickvergessen.newspage.listener:
        class: nickvergessen\newspage\event\main_listener
        arguments:
            - @controller.helper
            - @template
            - @user
        tags:
            - { name: event.listener }

After this is added, your listener gets called and we are done with the
php-editing.

Your users will not get conflicts on searching for files blocks and other things
because another MOD already edited the code. Again like with the controllers,
you can have multiple listeners in the event/ directory, aswell as subscribe to
multiple events with one listener.

Template Event
--------------

Now the only thing left is, adding the code to the html output. For templates
you need one file per event.

The filename thereby includes the event name. In order to add the newspage link
next to the FAQ link, we need to use the
``'overall_header_navigation_prepend'``-event (a full list of events can be
found `here <https://wiki.phpbb.com/Event_List>`_).

So we add the
``styles/prosilver/template/event/overall_header_navigation_prepend_listener.html``
to our extensions directory and add the html code into it.

.. code-block:: html

     <li class="icon-newspage"><a href="{U_NEWSPAGE}">{L_NEWSPAGE}</a></li>

And that's it. No file edits required for the template files aswell.

Adding Events
-------------

You can also add events to your extensions php and template code. If you miss an
event from the core, please post a topic into the
`[3.x] Event Requests <https://area51.phpbb.com/phpBB/viewforum.php?f=111>`_-Forum
and we will include it for the next release. We try to include a huge bunch of
events by default, but surely we can not cover every place your MODs need to be
covered.

Basics finished!
----------------

And that's it, the 3.0 Modification was successfully converted into a 3.1
Extension.

Compatibility
=============

In some cases the compatibility of functions and classes count not be kept,
while increasing their power. You can see a list of things in the Wiki-Article
about `PhpBB3.1 <https://wiki.phpbb.com/PhpBB3.1>`_

Pagination
----------

When you use your old 3.0 code you will receive an error like the following::

    Fatal error: Call to undefined function generate_pagination() in .../phpBB3/ext/nickvergessen/newspage/controller/main.php on line 534

The problem is, that the pagination is now not returned by the function anymore,
but instead automatically put into the template. In the same step, the function
name was updated with a phpbb-prefix.

The old pagination code was similar to:

.. code-block:: php

        $pagination = generate_pagination(append_sid("{$phpbb_root_path}app.$phpEx", 'controller=newspage/'), $total_paginated, $config['news_number'], $start);

        $this->template->assign_vars(array(
            'PAGINATION'        => $pagination,
            'PAGE_NUMBER'        => on_page($total_paginated, $config['news_number'], $start),
            'TOTAL_NEWS'        => $this->user->lang('VIEW_TOPIC_POSTS', $total_paginated),
        ));

The new code should look like:

.. code-block:: php

        $pagination = $phpbb_container->get('pagination');
        $pagination->generate_template_pagination(
            array(
                'routes' => array(
                    'newspage_base_controller',
                    'newspage_page_controller',
                ),
                'params' => array(),
            ), 'pagination', 'page', $total_paginated, $this->config['news_number'], $start);

        $this->template->assign_vars(array(
            'PAGE_NUMBER'        => $pagination->on_page($total_paginated, $this->config['news_number'], $start),
            'TOTAL_NEWS'        => $this->user->lang('VIEW_TOPIC_POSTS', $total_paginated),
        ));
