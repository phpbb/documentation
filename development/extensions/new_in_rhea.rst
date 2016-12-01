========================
What's New for phpBB 3.2
========================

Introduction
============

phpBB 3.2 (Rhea) introduces many new and updated components that extensions can take advantage of. Some of these changes may require extensions to make updates to maintain compatibility with phpBB 3.2 (some changes provide a layer of backwards compatibility with 3.1). Extension authors should review the changes documented below to see how their extensions may be affected.

This documentation explains:

 * `New Language Object`_
 * `New BBCode Engine`_
 * `New Text Reparser`_
 * `New File Uploader`_
 * `New Font Awesome Icons`_
 * `Updated Notifications`_
 * `Updated Twig Syntax`_
 * `Updated Symfony Services`_
 * `Updated INCLUDECSS`_
 * `Additional Helpers`_

New Language Object
===================

.. warning::
    The following applies to phpBB 3.2 and later versions. If you must maintain backwards compatibility with phpBB 3.1, continue using the deprecated language methods from the User object.

A new Language object has been introduced that decouples language functions from the User object. That is to say, the following language functions now belong to the ``\phpbb\language\language`` class:

.. csv-table::
   :header: "Function", "Description"
   :delim: |

   ``lang`` | "Advanced language substitution."
   ``add_lang`` | "Add Language Items."
   ``get_plural_form`` | "Determine which plural form we should use."
   ``set_user_language`` | "Function to set user's language to display."
   ``set_default_language`` | "Function to set the board's default language to display."

The Language object is available as a service from the DI container, and can be added to an extension's services as an argument:

.. code-block:: yaml

    arguments:
        - '@language'

Language keys can be translated by calling the ``lang()`` method from the Language object:

.. code-block:: php

    $language->lang('SOME_LANGUAGE_KEY');

Language files can be added by calling the ``add_lang()`` method from the Language object:

.. code-block:: php

    // Load a core language file
    $language->add_lang('posting');
    
Extension developers should note that the ``add_lang()`` method now supports adding language files from extensions, replacing the deprecated ``add_lang_ext()`` method from the User object:

.. code-block:: php

    // Load an extension's language file
    $language->add_lang('demo', 'acme/demo');

.. note::
    Note the argument order of the ``add_lang()`` method. It takes as its first argument the name of the language file, and the optional second argument is the packaged name of an extension. This is the reverse order of arguments that the deprecated ``add_lang_ext()`` from the User object used.

New BBCode Engine
=================

.. warning::
    The following applies to phpBB 3.2 and later versions. It is not backwards compatible with phpBB 3.1.

As of phpBB 3.2, a new and more powerful BBCode formatting engine has been integrated. The new engine is the third-party `s9e/TextFormatter <https://github.com/s9e/TextFormatter/>`_ library. Its integration classes can be found in ``phpBB/phpbb/textformatter``.

The new engine has already been equipped with many PHP events making it even easier than before for extensions to configure BBCodes and BBCode formatted text. The following are the new PHP events:

.. csv-table::
   :header: "Event", "Description"
   :delim: |

   ``core.text_formatter_s9e_configure_before`` | "Modify the s9e\TextFormatter configurator before the default settings are set."
   ``core.text_formatter_s9e_configure_after`` | "Modify the s9e\TextFormatter configurator after the default settings are set."
   ``core.text_formatter_s9e_parser_setup`` | "Configure the parser service, Can be used to: toggle features or BBCodes, register variables or custom parsers in the s9e\TextFormatter parser, configure the s9e\TextFormatter parser's runtime settings."
   ``core.text_formatter_s9e_parse_before`` | "Modify a text before it is parsed."
   ``core.text_formatter_s9e_parse_after`` | "Modify a parsed text in its XML form."
   ``core.text_formatter_s9e_renderer_setup`` | "Configure the renderer service."
   ``core.text_formatter_s9e_render_before`` | "Modify a parsed text before it is rendered."
   ``core.text_formatter_s9e_render_after`` | "Modify a rendered text."

Fortunately, the integration is pretty seamless and most existing extensions that handle messages processed by the BBCode engine should continue to work without needing any changes. For example, the following phpBB functions will continue to work as they did in phpBB 3.1:

  * ``decode_message()``
  * ``generate_text_for_display()``
  * ``generate_text_for_edit()``
  * ``generate_text_for_storage()``
  * ``strip_bbcode()``
  * ``smiley_text()``

Some simple examples of what can be done with the new library include:

.. code-block:: php

    // Lets get the parser from the container in this example
    $parser = $container->get('text_formatter.parser')
        ->get_parser();
    
    // Disable or enable a BBCode
    $parser->disable_bbcode($name);
    $parser->enable_bbcode($name);

    // Disable or enable BBCodes in general
    $parser->disable_bbcodes();
    $parser->enable_bbcodes();

    // Lets get the text formatter utils from the container in this example
    $text_formatter_utils = $container->get('text_formatter.utils');
    
    // Remove a BBCode and its content from a message      
    $text_formatter_utils->remove_bbcode($message, $bbcode)

    // Un-parse text back to its original form
    $text_formatter_utils->unparse($message)

A major change introduced by the new engine is how text (in posts, PMs, signatures, etc.) is stored. In phpBB 3.1, text is stored as HTML, with BBCodes and some other features being replaced at rendering time. As of phpBB 3.2, text is stored as XML and transformed into HTML at rendering time. phpBB 3.2 has a `New Text Reparser`_ class which will convert all posts, PMs, signatures, etc. to the new format shortly after updating to 3.2 (this is handled mostly by incremental cron jobs).

.. note::
    Messages stored in the old HTML format will still display as normal, even before being converted to the new XML format. This ensures a seamless experience for a board's users.

Extensions that are storing their own messages with BBCodes and smilies should consider adding a TextReparser class to ensure their messages are updated to the new XML format. See `New Text Reparser`_ for more information.

.. seealso::
    The s9e/TextFormatter library `documentation and cookbook <http://s9etextformatter.readthedocs.io>`_.

New Text Reparser
=================

.. warning::
    The following applies to phpBB 3.2 and later versions. It is not backwards compatible with phpBB 3.1.

phpBB 3.2 introduces the ``\phpbb\textreparser`` class to reparse stored text in the database. By reparsing, it will rebuild BBCodes, smilies and other text formatting in posts, private messages, signatures and anywhere else BBCodes are used.

The class was conceived to provide a means to reparse BBCodes into the new XML storage format introduced by the `New BBCode engine`_. When a board is updated from 3.1 to 3.2, the reparser is called into service in two ways. First, migrations are used to reparse some of the smaller database items (forum descriptions, for example). Second, cron tasks are used to incrementally reparse the larger database items (posts & PMs).

Extensions that store their own text with BBCodes, smilies, etc. should consider using the text reparser to ensure they are also updated to the new XML format. Extensions can extend the text reparser. The minimum that is required is the ``get_columns()`` method which returns an array mapping the column names of the table storing text to be reparsed, for example:

.. code-block:: php

    <?php

    namespace acme\demo\textreparser\plugins;

    class demo_text extends \phpbb\textreparser\row_based_plugin
    {
        public function get_columns()
        {
            return array(
                'id'            => 'demo_id',
                'text'          => 'demo_message',
                'bbcode_uid'    => 'demo_message_bbcode_uid',
                'options'       => 'demo_message_bbcode_options',
            );
        }
    }

Notice that the table name has not been identified yet. The table name is actually defined as an argument in the service definition of the extension's reparser class:

.. code-block:: yaml

    text_reparser.acme_demo_text:
        class: acme\demo\textreparser\plugins\demo_text
        arguments:
            - '@dbal.conn'
            - '%acme.demo.tables.demo_messages%'
        tags:
            - { name: text_reparser.plugin }

The next step is to add our reparser to phpBB's cron jobs queue. To do so, we simply define a cron task service for our reparser in the following way:

.. code-block:: yaml

    cron.task.text_reparser.acme_demo_text:
        class: phpbb\cron\task\text_reparser\reparser
        arguments:
            - '@config'
            - '@config_text'
            - '@text_reparser.lock'
            - '@text_reparser.manager'
            - '@text_reparser_collection'
        calls:
            - [set_name, [cron.task.text_reparser.acme_demo_text]]
            - [set_reparser, [text_reparser.acme_demo_text]]
        tags:
            - { name: cron.task }

Notice that the service is using phpBB's reparser cron task class, then uses the ``calls`` option to include our reparser. Be sure to set the calls options to your cron and reparser services we just defined.

Finally, to complete setting up the cron jobs, we must add two new configs to the config table using a migration:

.. code-block:: php

    public function update_data()
	{
		return array(
			array('config.add', array('text_reparser.acme_demo_text_cron_interval', 10)),
			array('config.add', array('text_reparser.acme_demo_text_last_cron', 0)),
		);
	}

Note that these configs are the name of the our cron.task ``text_reparser.acme_demo_text`` plus ``_cron_interval`` and ``_last_cron``. The ``cron_interval`` should be a value in seconds to wait between jobs, in this case "10", and the ``last_cron`` should always be set to "0".

.. tip::
    In some cases you may want to run your reparser from a migration. For example, you need your stored text reparsed immediately during the extension update and do not want to wait for it to go through the cron task queue.

    If the volume of rows that need to be reparsed is high, it must reparse incrementally, in chunks, to minimise the risk of a PHP timeout or database corruption. The following is an example of a custom function in a migration acting in incremental chunks, processing 50 rows at a time:

    .. code-block:: php

        /**
         * Run the Acme Demo text reparser
         *
         * @param int $current A message id
         *
         * @return bool|int A message id or true if finished
         */
        public function reparse($current = 0)
        {
            // Get our reparser
            $reparser = new \acme\demo\textreparser\plugins\demo_text(
                $this->db,
                $this->container->getParameter('core.table_prefix') . 'demo_messages'
            );

            // If $current id is empty, get the highest id from the db
            if (empty($current))
            {
                $current = $reparser->get_max_id();
            }

            $limit = 50; // Reparse in chunks of 50 rows at a time
            $start = max(1, $current + 1 - $limit);
            $end   = max(1, $current);

            // Run the reparser
            $reparser->reparse_range($start, $end);

            // Update the $current id
            $current = $start - 1;

            // Return the $current id, or true when finished
            return ($current === 0) ? true : $current;
        }

New File Uploader
=================

.. warning::
    The following is a **required** change for phpBB 3.2 and later versions. It is not backwards compatible with phpBB 3.1. Extensions making this change must release a new major version dropping support for 3.1.

phpBB 3.2 introduces two new classes for uploading files: ``filespec`` and ``upload``. These have been refactored and are based on the previously available ``filespec`` and ``fileupload`` classes.

For information about the new classes, read :doc:`../files/overview` documentation.

To update an extension to use the new class, read the `Converting uses of fileupload class <../files/upload.html#converting-uses-of-fileupload-class>`_ documentation.

New Font Awesome Icons
======================

.. warning::
    The following applies to phpBB 3.2 and later versions. It is not backwards compatible with phpBB 3.1.

phpBB 3.2 includes the Font Awesome toolkit. It is used by the default style Prosilver, and has replaced almost every gif/png icon with a font icon.

The result of this is significant template changes to Prosilver, including some new CSS classes. Extensions written for phpBB 3.1 that make use of any of Prosilver's icons may need to be adjusted to be compatible with phpBB 3.2.

The benefit of the new `Font Awesome icons <http://fontawesome.io/icons/>`_ is they make it easy to improve GUI elements of your extension. For example, if an extension has a "Delete" link or button, you can easily add a nice little Trash Can icon to the link or button:

.. code-block:: html

    <a href="#">
        <i class="icon fa-trash fa-fw"></i><span>Delete</span>
    </a>

Updated Notifications
=====================

.. warning::
    The following is a **required** change for phpBB 3.2 and later versions. It is not backwards compatible with phpBB 3.1. Extensions making this change must release a new major version dropping support for 3.1.

Extensions that make use of the phpBB's built-in notification system must make the following updates to their notification classes, if necessary. The notable changes have been made to the ``find_users_for_notification()`` and ``create_insert_array()`` methods.

find_users_for_notification()
-----------------------------

This method must return an array of users who can see the notification. While it is the extension authors responsibility to determine how to build this array of users, an example usage in phpBB 3.1 may look like:

.. code-block:: php

    public function find_users_for_notification($data, $options = array())
    {
        // run code to query a group of users from the database...
        
        while ($row = $this->db->sql_fetchrow($result))
        {
            $users[$row['user_id']] = array('');
        }

        // do any additional processing...

        return $users;
    }

As of phpBB 3.2 a new helper to get the list of methods enabled by default is available from the manager class, to assign as the array values in the user array:

.. code-block:: php

    public function find_users_for_notification($data, $options = array())
    {
        // run code to query a group of users from the database...
        
        while ($row = $this->db->sql_fetchrow($result))
        {
            $users[$row['user_id']] = $this->notification_manager->get_default_methods();
        }

        // do any additional processing...

        return $users;
    }

.. note::
    Notice that we simply replaced the empty ``array('')`` value assigned to each user with the new ``$this->notification_manager->get_default_methods()`` method call.

create_insert_array()
---------------------

In phpBB 3.1, this method returned an array of data ready to be inserted into the database from the parent class:

.. code-block:: php

    public function create_insert_array($data, $pre_create_data = array())
    {
        // prepare some data...

        return parent::create_insert_array($data, $pre_create_data);
    } 

In phpBB 3.2, the data is now added the the class data property, so it is no longer necessary to use a ``return``, just call the method from the parent class at the end:

.. code-block:: php

    public function create_insert_array($data, $pre_create_data = array())
    {
        // prepare some data...

        parent::create_insert_array($data, $pre_create_data);
    } 

Updated Twig Syntax
===================

.. warning::
    The following applies to phpBB 3.2 and later versions. If you must maintain backwards compatibility with phpBB 3.1, please disregard this section.

If you are already using Twig template syntax, and you have been using loop structures in your templates, you are probably familiar with the odd usage of the ``loops`` prefix required in phpBB 3.1:

.. code-block:: twig

    # phpBB 3.1 and 3.2 compatible
    {% for item in loops.items %}
       item.MY_VAR
    {% endfor %}

As of phpBB 3.2, this requirement has been removed, allowing you to use natural Twig syntax for looped structures (i.e. the ``loops`` prefix is no longer needed):

.. code-block:: twig

    # phpBB 3.2 or later only
    {% for item in items %}
       item.MY_VAR
    {% endfor %}

If you want to maintain backwards compatibility with phpBB 3.1, you must continue using the ``loops`` prefix.

Updated Symfony Services
========================

The following changes are due to deprecations introduced in Symfony 2.8 (which is used in phpBB 3.2). These deprecations are being removed from Symfony 3 (which is used in phpBB 3.3).

Deprecated usage of @ at the beginning of unquoted strings
----------------------------------------------------------

.. warning::
    The following is recommended for phpBB 3.1 and later versions. It will be required from phpBB 3.3 and later.

According to Yaml specification, unquoted strings cannot start with ``@``, so you must wrap these arguments with single or double quotes:

.. code-block:: yaml

    vendor.package.class:
       class: vendor\package\classname
       arguments:
          - '@dbal.conn'
          - '%custom.tables%'
       calls:
          - [set_controller_helper, ['@controller.helper']]

.. note::
    In phpBB, we have decided that to maintain consistency, we also quote strings that begin with ``%``. We also prefer using single quotes instead of double quotes.

Deprecating Scopes and Introducing Shared Services
--------------------------------------------------

.. warning::
    The following is a **required** change for phpBB 3.2 and later versions. It is not backwards compatible with phpBB 3.1.  Extensions making this change must release a new major version dropping support for 3.1.

By default, all services are shared services. This means a class is instantiated once, and used each time you ask for it from the service container.

In some cases, however, it is desired to *unshare* a class, where a new instance is created each time you ask for the service. An example of this is the Notifications classes.

In phpBB 3.1, this was defined in the ``services.yml`` by setting the ``scope`` option to ``prototype``:

.. code-block:: yaml

    vendor.package.class:
       class: vendor\package\classname
       scope: prototype

For phpBB 3.2, instead of ``scope``, service definitions must now configure a ``shared`` option and set it to ``false`` to get the same result as in the previous prototype scope:

.. code-block:: yaml

    vendor.package.class:
       class: vendor\package\classname
       shared: false

Updated INCLUDECSS
==================

.. warning::
    The following applies to phpBB 3.2 and later versions. If you must maintain backwards compatibility with phpBB 3.1, please disregard this section.

As of phpBB 3.2, the ``INCLUDECSS`` template tag can now be called from anywhere in a template, making it just as easy and flexible to implement from any template event or file as the ``INCLUDEJS`` tag.

Previously, in phpBB 3.1, extension's could only use this tag in the ``overall_header_head_append`` template event, or before including ``overall_header.html`` in a custom template file.

Additional Helpers
==================

New Group Helper
----------------

phpBB 3.2 adds a new helper to simplify the job of displaying user group names.

In phpBB 3.1, displaying a user group name required verbose code similar to:

.. code-block:: php

    // phpbb 3.1 and 3.2 compatible:
    ($row['group_type'] == GROUP_SPECIAL) ? $user->lang('G_' . $row['group_name']) : $row['group_name'];

This is simpler in phpBB 3.2 with the ``get_name()`` method of the ``\phpbb\group\helper\`` class:

.. code-block:: php

    // phpBB 3.2 only:
    $group_helper->get_name($row['group_name']);

BBCode FAQ Controller Route
---------------------------

phpBB 3.2 now has a built-in routing definition for the BBCode FAQ page. Linking to this page is common for extensions that have their own BBCode message editor.

In phpBB 3.1, linking to the BBCode FAQ looked like:

.. code-block:: php

    // phpBB 3.1 and 3.2 compatible:
    $u_bbcode_faq = append_sid("{$phpbb_root_path}faq.{$phpEx}", 'mode=bbcode');

In phpBB 3.2, linking to the BBCode FAQ can be handled using the routing system:

.. code-block:: php

    // phpBB 3.2 only:
    $u_bbcode_faq = $controller_helper->route('phpbb_help_bbcode_controller');
