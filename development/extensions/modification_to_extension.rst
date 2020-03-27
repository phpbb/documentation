=================================================
Updating a phpBB 3.0 modification to an extension
=================================================

Extension Structure
===================

The most obvious change should be the location where the MODs / Extensions are
stored. In phpBB 3.0 all files were put into the core's root folder. In phpBB 
3.1 a special directory for extensions has been created. It's called ``ext/``.

Directory
---------

Each extension has its own directory. However, you must also use an
additional vendor directory (with your author name or author-group name). In
the case of my Newspage, the files will be in

.. code-block:: php

    phpBB/ext/nickvergessen/newspage/

There should not be a need to have files located outside of that directory. No
matter which files, may it be styles, language or ACP module files. All of them
should be moved into your extension's directory:

.. csv-table::
   :header: "new directory", "current directory"
   :delim: |

   ``acp/*_module.php`` | ``phpBB/includes/acp/``
   ``acp/*_info.php`` | ``phpBB/includes/acp/info/``
   ``adm/style/`` | ``phpBB/adm/style/``
   ``config/`` | ---
   ``controller/`` | ``*.php``
   ``event/`` | ---
   ``language/`` | ``phpBB/language/``
   ``migrations/`` | ---
   ``styles/`` | ``phpBB/styles/``

Newly added, additional directories have already been listed. Their use will be
explained in the following paragraphs.

Important new files
-------------------

There is a new file your extension needs in order to be recognised by the
system. It's called ``composer.json``:
it specifies the requirements of your extension as well as some author
information. The layout is a simple json array, the keys should really explain
enough.

.. note::

    You must not change the ``type`` element.

In the ``require`` section you can also specify other extensions which are
required in order to install this one. (*Validation for this is not yet
implemented, but should be in 3.3.0*)

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
     // ext/nickvergessen/newspage/ext.php

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
must use the new controller system in 3.1 for extensions. Your links will change
from something like ``phpBB/newspage.php`` to ``phpBB/app.php/newspage``. If the
board has enabled url rewriting, your links will look a little nicer like
``phpBB/newspage``.

In order to link a specific routing rule to your extension, you need to define
the route in your extension's ``config/routing.yml``.

For an easy start to the Newspage, two rules are enough. The first rule is for
the basic page, currently ``newspage.php``. The second one is for the pagination,
like ``newspage.php?start=5``. The first rule sets a default page (1), while the
second rule requires a second part of the url to be an integer.

.. code-block:: yaml

     # ext/nickvergessen/newspage/config/routing.yml
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
definition of the Newspage controller service would be something similar to:

.. code-block:: yaml

     # ext/nickvergessen/newspage/config/services.yml
     services:
         nickvergessen.newspage.controller:
             class: nickvergessen\newspage\controller\main
             arguments:
                 - '@auth'
                 - '@cache'
                 - '@config'
                 - '@dbal.conn'
                 - '@request'
                 - '@template'
                 - '@user'
                 - '@controller.helper'
                 - '%core.root_path%'
                 - '%core.php_ext%'

Any service that is previously defined in your file, or in the file of the phpBB
core ``phpBB/config/services.yml``, can also be used as an argument, as well as
some predefined strings (like ``core.root_path`` here).

.. note::

    The classes from ``phpBB/ext/`` are automatically loaded by their namespace
    and class names, whereby backslash ( ``\`` ) represent directories. In this
    case the class ``nickvergessen\newspage\controller\main`` would be located
    in ``phpBB/ext/nickvergessen/newspage/controller/main.php``

For more explanations about
`Routing <https://area51.phpbb.com/docs/dev/master/extensions/tutorial_controllers.html#routing>`_ and
`Services <https://area51.phpbb.com/docs/dev/master/extensions/tutorial_controllers.html#dependencies>`_ see our documentation.

In this example my **controller/main.php** would look like the following:

.. code-block:: php

     <?php
     // ext/nickvergessen/newspage/controller/main.php

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
         * @param \phpbb\config            $config    Config object
         * @param \phpbb\template          $template  Template object
         * @param \phpbb\user              $user      User object
         * @param \phpbb\controller\helper $helper    Controller helper object
         * @param string                   $root_path phpBB root path
         * @param string                   $php_ext   phpEx
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
            * @param    int            Status code of the page (200 - OK [ default ], 403 - Unauthorised, 404 - Page not found, etc.)
            */
            return $this->helper->render('newspage_body.html');
        }
     }

.. note::

    The order of arguments in services.yml should match the order of
    arguments passed to the class constructor ``public function __construct()``.
    Otherwise, an error will be thrown and the board will be broken if you try to
    enable the extension.

You can also have multiple different methods in one controller as well as having
multiple controllers, in order to organise your code a bit better.

ACP Modules
-----------

This section also applies to MCP and UCP modules.

As mentioned before these files are also moved into your extensions directory.
The info-file, currently located in
``phpBB/includes/acp/info/acp_newspage.php``, is going to be
``ext/nickvergessen/newspage/acp/main_info.php`` and the module itself is moved
from ``phpBB/includes/acp/acp_newspage.php`` to
``ext/nickvergessen/newspage/acp/main_module.php``. In order to be able to
automatically load the files by their class names we need to make some
adjustments to the classes themselves.

As for the ``main_info.php`` we need to adjust the class name from
``acp_newspage_info`` to ``main_info`` and also change the value of
``'filename'`` in the returned array.

.. code-block:: php

     <?php
     // ext/nickvergessen/newspage/acp/main_info.php

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
            return [
                'filename' => '\nickvergessen\newspage\acp\main_module',
                'title'    => 'ACP_NEWSPAGE_TITLE',
                'modes'    => [
                    'config_newspage' => [
                        'title' => 'ACP_NEWSPAGE_CONFIG',
                        'auth'  => 'acl_a_board',
                        'cat'   => ['ACP_NEWSPAGE_TITLE']
                    ],
                ],
            ];
        }
     }

In case of the module, just adjust the class name:

.. code-block:: php

     <?php
     // ext/nickvergessen/newspage/acp/main_module.php

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

Database Changes, UMIL replaced by Migrations
=============================================

.. seealso::

   For more documentation about migrations, see the :doc:`../migrations/index` API and 
   :doc:`tutorial_migrations` documentation

Basically migrations do the same as your 3.0 UMIL files. It performs the
database changes of your MOD/Extension. The biggest difference between
migrations and UMIL is that while you had one file with one array in
UMIL for all your changes, you can have multiple files in Migrations. You usually
create a new migration file each time you need to introduce new database changes. But
let's have a look at the Newspage again.

.. code-block:: php

     $versions = [
        '1.0.0'    => [
            'config_add' => [
                ['news_number', 5],
                ['news_forums', '0'],
                ['news_char_limit', 500],
                ['news_user_info', 1],
                ['news_post_buttons', 1],
            ],
            'module_add' => [
                ['acp', 'ACP_CAT_DOT_MODS', 'NEWS'],

                ['acp', 'NEWS', [
                        'module_basename'    => 'newspage',
                        'module_langname'    => 'NEWS_CONFIG',
                        'module_mode'        => 'overview',
                        'module_auth'        => 'acl_a_board',
                    ],
                ],
            ],
        ],
        '1.0.1'    => [
            'config_add' => [
                ['news_pages', 1],
            ],
        ],
        '1.0.2'    => [],
        '1.0.3' => [
            'config_add' => [
                ['news_attach_show', 1],
                ['news_cat_show', 1],
                ['news_archive_per_year', 1],
            ],
        ],
     ];

Schema Changes
--------------

The Newspage does not have any database schema changes, so I will use the
:doc:`../migrations/schema_changes` example from the Documentation.
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
        return [
            'add_columns'        => [
                $this->table_prefix . 'groups'        => [
                    'group_teampage'    => ['UINT', 0, 'after' => 'group_legend'],
                ],
                $this->table_prefix . 'profile_fields'    => [
                    'field_show_on_pm'        => ['BOOL', 0],
                ],
            ],
            'change_columns'    => [
                $this->table_prefix . 'groups'        => [
                    'group_legend'        => ['UINT', 0],
                ],
            ],
        ];
     }

     public function revert_schema()
     {
        return [
            'drop_columns'        => [
                $this->table_prefix . 'groups'        => [
                    'group_teampage',
                ],
                $this->table_prefix . 'profile_fields'    => [
                    'field_show_on_pm',
                ],
            ],
            'change_columns'    => [
                $this->table_prefix . 'groups'        => [
                    'group_legend'        => ['BOOL', 0],
                ],
            ],
        ];
     }

The ``revert_schema()`` should thereby revert all changes made by the
``update_schema()``.

Data Changes
------------

The data changes, like adding modules, permissions and configs, are provided
with the ``update_data()`` function.

This function returns an array as well. The example for the 1.0.0 version update
from the Newspage would look like the following:

.. code-block:: php

     public function update_data()
     {
        return [
            ['config.add', ['news_number', 5]],
            ['config.add', ['news_forums', '0']],
            ['config.add', ['news_char_limit', 500]],
            ['config.add', ['news_user_info', 1]],
            ['config.add', ['news_post_buttons', 1]],

            ['module.add', [
                'acp',
                'ACP_CAT_DOT_MODS',
                'ACP_NEWSPAGE_TITLE'
            ]],
            ['module.add', [
                'acp',
                'ACP_NEWSPAGE_TITLE',
                [
                    'module_basename'    => '\nickvergessen\newspage\acp\main_module',
                    'modes'                => ['config_newspage'],
                ],
            ]],

            ['config.add', ['newspage_mod_version', '1.0.0']],
        ];
     }

More information about these data update tools can be found in
:doc:`../migrations/tools/index`.

Dependencies and finishing up migrations
----------------------------------------

Now there are only two things your migration file still needs. The first thing
is a check, which allows phpBB to see whether the migration is already
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
migration I will only require phpBB's ``3.1.0-a1`` migration:

.. code-block:: php

     static public function depends_on()
     {
        return ['\phpbb\db\migration\data\v310\alpha1'];
     }

All further Newspage migrations can now require Newspage's first migration file,
and thus all will be also dependent on phpBB's 3.1.0-a1 migration.

A complete file could look like this:

.. code-block:: php

     <?php
     // ext/nickvergessen/newspage/migrations/v10x/release_1_0_0.php
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
            return ['phpbb_db_migration_data_310_dev'];
        }

        public function update_data()
        {
            return [
                ['config.add', ['news_number', 5]],
                ['config.add', ['news_forums', '0']],
                ['config.add', ['news_char_limit', 500]],
                ['config.add', ['news_user_info', 1]],
                ['config.add', ['news_post_buttons', 1]],

                ['module.add', [
                    'acp',
                    'ACP_CAT_DOT_MODS',
                    'ACP_NEWSPAGE_TITLE'
                ]],
                ['module.add', [
                    'acp',
                    'ACP_NEWSPAGE_TITLE',
                    [
                        'module_basename'    => '\nickvergessen\newspage\acp\main_module',
                        'modes'                => ['config_newspage'],
                    ],
                ]],

                ['config.add', ['newspage_mod_version', '1.0.0']],
            ];
        }
     }


Include extension's language files
==================================

As the language files in your extension are not detected by
``$user->add_lang()`` any more, you need to use the ``$user->add_lang_ext()``
method. This method takes two arguments, the first one is the fullname of the
extension (including the vendor) and the second one is the file name or array of
file names. So in order to load the Newspage language file we call:

.. code-block:: php

     $user->add_lang_ext('nickvergessen/newspage', 'newspage');

to load the language file
``phpBB/ext/nickvergessen/newspage/language/en/newspage.php``

File edits - Don't edit! Use Events and Listeners!
==================================================

As for the Newspage Modification, the only thing that is now missing from
completion is the link in the header section, so you can start browsing the
Newspage.

In order to do this, the template variable used to be defined in the
``page_header()`` function of phpBB along with an edit in the ``overall_header.html`` template.
But this is not phpBB 3.0, so we don't use file edits anymore and instead employ **events**
instead. With events you can hook into several places and execute your code,
without editing them.

php Events
----------

So instead of adding

.. code-block:: php

     $template->assign_vars([
        'U_NEWSPAGE'    => append_sid($phpbb_root_path . 'app.' . $phpEx, 'controller=newspage/'),
     ]);

to the ``page_header()``, we put that into an event listener, which is then
called everytime ``page_header()`` itself is called.

So we add the **event/main_listener.php** file to our extension, which
implements a Symfony class:

.. code-block:: php

     <?php
     // ext/nickvergessen/newspage/event/main_listener.php

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

In the ``getSubscribedEvents()`` method we tell the system which events we
want to subscribe our new custom functions to.
In our case we want to subscribe to two events: the ``core.page_header`` event 
and the ``core.user_setup`` event (a full list
of events can be found `here <https://wiki.phpbb.com/Event_List>`_):

.. code-block:: php

        static public function getSubscribedEvents()
        {
            return [
                'core.user_setup'    => 'load_language_on_setup',
                'core.page_header'   => 'add_page_header_link',
            ];
        }

Now we add the two functions which are called with each event:

.. code-block:: php

        public function load_language_on_setup($event)
        {
            $lang_set_ext = $event['lang_set_ext'];
            $lang_set_ext[] = [
                'ext_name' => 'nickvergessen/newspage',
                'lang_set' => 'newspage',
            ];
            $event['lang_set_ext'] = $lang_set_ext;
        }

        public function add_page_header_link($event)
        {
            // I use a second language file here, so I only load the strings global which are required globally.
            // This includes the name of the link, aswell as the ACP module names.
            $this->user->add_lang_ext('nickvergessen/newspage', 'newspage_global');

            $this->template->assign_vars([
                'U_NEWSPAGE'    => $this->helper->route('newspage_base_controller'),
            ]);
        }

As a last step we need to register the event listener to the system.
This is done using the ``event.listener`` tag in the ``config/service.yml``:

.. code-block:: yaml

    # ext/nickvergessen/newspage/config/service.yml
    nickvergessen.newspage.listener:
        class: nickvergessen\newspage\event\main_listener
        arguments:
            - '@controller.helper'
            - '@template'
            - '@user'
        tags:
            - { name: event.listener }

After this is added, your listener gets called and we are done with the
php-editing.

Again like with the controllers, you can have multiple listeners in the 
``event/`` directory, as well as subscribe to multiple events with one listener.

Template Event
--------------

Now the only thing left is adding the code to the html output. For templates
you need one file per template event.

The filename includes the event name. In order to add the Newspage link
next to the FAQ link, we need to use the
``'overall_header_navigation_prepend'`` event (a full list of events can be
found `here <https://wiki.phpbb.com/Event_List>`_).

So we add the
``styles/prosilver/template/event/overall_header_navigation_prepend_listener.html``
to our extensions directory and add our html code into it.

.. code-block:: html

     <li class="icon-newspage"><a href="{U_NEWSPAGE}">{L_NEWSPAGE}</a></li>

And that's it. No file edits required for the template files as well.

Adding Events
-------------

There are already numerous events available. However, if your extension needs to
make use of an event which is not yet in the phpBB code, you can request the
event be added to the core by creating a ticket in the
`phpBB Bug Tracker <https://tracker.phpbb.com/projects/PHPBB3>`_ and we will
endeavour to include it in the next release.

Basics finished!
----------------

And that's it, the 3.0 Modification was successfully converted into a 3.1
Extension.

Compatibility
=============

In some cases the compatibility of functions and classes could not be kept,
while increasing their power for 3.1. You can see a list of these in the Wiki-Article
about `PhpBB3.1 <https://wiki.phpbb.com/PhpBB3.1>`_

Pagination
----------

When you use your old 3.0 code you will receive an error like the following::

    Fatal error: Call to undefined function generate_pagination() in .../phpBB3/ext/nickvergessen/newspage/controller/main.php on line 534

The problem is that the pagination is no longer returned by the function,
but instead automatically put into the template. Also, the function
name was updated with a phpbb-prefix.

The old pagination code was similar to:

.. code-block:: php

        $pagination = generate_pagination(append_sid("{$phpbb_root_path}app.$phpEx", 'controller=newspage/'), $total_paginated, $config['news_number'], $start);

        $this->template->assign_vars([
            'PAGINATION'        => $pagination,
            'PAGE_NUMBER'        => on_page($total_paginated, $config['news_number'], $start),
            'TOTAL_NEWS'        => $this->user->lang('VIEW_TOPIC_POSTS', $total_paginated),
        ]);

The new code should look like:

.. code-block:: php

        $pagination = $phpbb_container->get('pagination');
        $pagination->generate_template_pagination(
            [
                'routes' => [
                    'newspage_base_controller',
                    'newspage_page_controller',
                ],
                'params' => [],
            ], 'pagination', 'page', $total_paginated, $this->config['news_number'], $start);

        $this->template->assign_vars([
            'PAGE_NUMBER'        => $pagination->on_page($total_paginated, $this->config['news_number'], $start),
            'TOTAL_NEWS'        => $this->user->lang('VIEW_TOPIC_POSTS', $total_paginated),
        ]);
