=======================
Tutorial: Notifications
=======================

.. contents:: This tutorial explains:
   :depth: 1
   :local:

Introduction
============
Notifications have been a part of phpBB ever since :guilabel:`3.0`.
Since then they have been further developed, extended and enhanced.
In :guilabel:`3.2` the notification system has been completely refactored, so it worked faster and more efficiently.
This change also reduced the posting time to be almost instantaneous.

A user has full power over their personal notifications.
They can set their own preferences for notification methods or disable them all together.
Mark notifications as read when necessary, even though in a lot of cases this is done automatically.
The user has a centralised place for all notifications, which is easily accessible.

By default there are two methods of notification.
Namely per email or per board notification.
The email method is only available when the ''board-wide emails'' setting has been enabled.
Extensions can also create and add their own notification methods.

File structure
--------------
This is an overview of the file structure needed for a notification to function within an extension.
In total there are 7 files that will be covered in this tutorial, to create and send notifications.
These files will be mentioned throughout this tutorial.


| |fa-user| vendor
| └─ |fa-ext| extension
|  |nbsp| ├─ |fa-folder| config
|  |nbsp| │ |nbsp| └─ |fa-file| services.yml
|  |nbsp| ├─ |fa-folder| event
|  |nbsp| │ |nbsp| └─ |fa-file| listener.php
|  |nbsp| ├─ |fa-folder| language
|  |nbsp| │ |nbsp| |nbsp| └─ |fa-folder| en
|  |nbsp| │ |nbsp| |nbsp| |nbsp| |nbsp| |nbsp| |nbsp| └─ |fa-folder| email
|  |nbsp| │ |nbsp| |nbsp| |nbsp| |nbsp| |nbsp| |nbsp| │ |nbsp| |nbsp| └─ |fa-folder| short
|  |nbsp| │ |nbsp| |nbsp| |nbsp| |nbsp| |nbsp| |nbsp| │ |nbsp| |nbsp| │ |nbsp| |nbsp| └─ |fa-file| sample.txt
|  |nbsp| │ |nbsp| |nbsp| |nbsp| |nbsp| |nbsp| |nbsp| │ |nbsp| |nbsp| └─ |fa-file| sample.txt
|  |nbsp| │ |nbsp| |nbsp| |nbsp| |nbsp| |nbsp| |nbsp| └─ |fa-file| extension_common.php
|  |nbsp| ├─ |fa-folder| notification
|  |nbsp| │ |nbsp| |nbsp| └─ |fa-folder| type
|  |nbsp| │ |nbsp| |nbsp| |nbsp| |nbsp| |nbsp| |nbsp| └─ |fa-file| sample.php
|  |nbsp| └─ |fa-file| ext.php
|

Creating a notification type
============================
The notification type that will be used in this tutorial is: ``vendor.extension.notification.type.sample``.

Registering as a Symfony service
--------------------------------
Firstly the notification type has to be registered as a Symfony service.
As with any service declaration, it will need a service identifier and the class argument.
However, notifications types also need three additional parameters. The parent, shared and tags parameters.
The parent parameter will indicate from which service this notification type will inherit.
And the shared parameter will make sure that each time this notification type is requested, a new instance is created.
This will prevent that any data will be transferred over.
Lastly, the service needs to be tagged as a notification type, so it will be correctly listed in all places.

.. code-block:: yaml
   :caption: :class:`vendor/config/services.yml`

   services:
       vendor.extension.notification.type.sample:
           class: vendor\extension\notification\type\sample
           parent: notification.type.base
           shared: false
           tags: [{ name: notification.type }]

However, we want to use two additional services in our notification type.
We want to also use the Controller helper object (:class:`\\phpbb\\controller\\helper`)
and the User loader object (:class:`\\phpbb\\user_loader`).
But because we are defining a ``parent``, we can not also use the ``arguments`` parameter.
We either have to define all ``arguments``, including the ones from the parent,
or we can use a different setup and use the ``calls`` parameter as shown below.
You can read more about this in `Additional services`_.
The first argument is the function's name and the second parameter is an array of service definitions.

.. code-block:: yaml
   :caption: :class:`vendor/config/services.yml`

   services:
       vendor.extension.notification.type.sample:
           class: vendor\extension\notification\type\sample
           parent: notification.type.base
           shared: false
           tags: [{ name: notification.type }]
           calls:
               - ['set_helper', ['@controller.helper']]
               - ['set_user_loader', ['@user_loader']]

Altering an extension's state
-----------------------------
The second thing that needs to be done, is enabling, disabling and purging the notification type when the extension's state changes.
Meaning that when an extension is enabled/disabled, the notification type is enabled/disabled.
Or when the extension's data is deleted, the notification type's data is purged from the database.
If this is not done or set up correctly, it will throw uncaught exceptions, making the board inaccessible.

In order to achieve this, three functions have to be added to the :class:`ext.php`.
Each function will retrieve the notification manager from the service container and perform their respective action.

.. code-block:: php
   :caption: :class:`vendor/extension/ext.php`

   <?php

   namespace vendor\extension;

   class ext extends \phpbb\extension\base
   {
       /**
        * Enable notifications for the extension.
        *
        * @param mixed		$old_state		State returned by previous call of this method
        * @return mixed				Returns false after last step, otherwise temporary state
        * @access public
        */
       public function enable_step($old_state)
       {
           if ($old_state === false)
           {
               /** @var \phpbb\notification\manager $notification_manager */
               $notification_manager = $this->container->get('notification_manager');

               $notification_manager->enable_notifications('vendor.extension.notification.type.sample');
               return 'notification';
           }

           return parent::enable_step($old_state);
       }

       /**
        * Disable notifications for the extension.
        *
        * @param mixed		$old_state		State returned by previous call of this method
        * @return mixed				Returns false after last step, otherwise temporary state
        * @access public
        */
       public function disable_step($old_state)
       {
           if ($old_state === false)
           {
               /** @var \phpbb\notification\manager $notification_manager */
               $notification_manager = $this->container->get('notification_manager');

               $notification_manager->disable_notifications('vendor.extension.notification.type.sample');

               return 'notification';
           }

           return parent::disable_step($old_state);
       }

       /**
        * Purge notifications for the extension.
        *
        * @param mixed		$old_state		State returned by previous call of this method
        * @return mixed				Returns false after last step, otherwise temporary state
        * @access public
        */
       public function purge_step($old_state)
       {
           if ($old_state === false)
           {
               /** @var \phpbb\notification\manager $notification_manager */
               $notification_manager = $this->container->get('notification_manager');

               $notification_manager->purge_notifications('vendor.extension.notification.type.sample');

               return 'notification';
           }

           return parent::purge_step($old_state);
       }
   }

Defining the language strings
-----------------------------
Next we can start defining some language strings that will be used by the notification type.
This specific language file contains all possible language strings that can be used in a notification.
You can remove any strings that you will not need.

.. tip::
   This language file will be included during a user's setup later on in this tutorial, meaning that they will be globally available.
   However, there are a few strings that are only needed in the :abbr:`UCP (User Control Panel)`.
   Ideally these strings should be defined in a separate file, namely :class:`info_ucp_extension.php`.
   Using this naming convention (:class:`info_ucp_*.php`) will automatically include it only in the UCP.
   But for the sake of this tutorial, they all are defined in this one language file.

.. code-block:: php
   :caption: :class:`vendor/extension/language/en/extension_common.php`
   :name: language file

   <?php

   if (!defined('IN_PHPBB'))
   {
       exit;
   }

   if (empty($lang) || !is_array($lang))
   {
       $lang = [];
   }

   // Some characters you may want to copy&paste: ’ » “ ” …
   $lang = array_merge($lang, [
       'VENDOR_EXTENSION_NOTIFICATION_REASON'		=> 'This is a sample reason',
       'VENDOR_EXTENSION_NOTIFICATION_TITLE'		=> '<strong>Received a sample notification</strong> from %s',

       // These strings should ideally be defined in a info_ucp_*.php language file
       'VENDOR_EXTENSION_NOTIFICATIONS'		=> 'Sample notifications category',
       'VENDOR_EXTENSION_NOTIFICATION_SAMPLE'		=> 'Someone sends you a sample notification',
   ]);

Now lets create the sample email template file, which is located in the language directory.
The variables used in this file are defined in get_email_template_variables_.
The first line of the file should begin with ``Subject:``, followed by the actual email subject and an empty line.
It is possible to use variables in the subject line aswell.

.. code-block:: text
   :caption: :class:`vendor/extension/language/en/email/sample.txt`
   :name: email template

   Subject: New sample private message has arrived

   Hello {USERNAME},

   You have received a new sample private message from "{AUTHOR}" to your account on "{SITENAME}" with the following subject:
   {SUBJECT}

   You can view your new message by clicking on the following link:
   {U_REGULAR}

   You have requested that you be notified on this event, remember that you can always choose not to be notified of new messages by changing the appropriate setting in your profile.
   {U_NOTIFICATION_SETTINGS}

   {EMAIL_SIG}

.. tip::

   It is a good practise to always use the following layout:

.. code-block:: text

   Subject: The email subject

   Hello {USERNAME},

   The content for this email.

   {EMAIL_SIG}

Setting up the notification type class
--------------------------------------
This is the bare bones of notification type class.
`All the functions <Functions of a notification type_>`_ will be discussed later on.

We have defined the :class:`base` notification type class as a ``parent`` when we were `Registering as a Symfony service`_.
Therefore it is important, that our notification type class extends the :class:`base` class.

.. code-block:: php
   :caption: :class:`/vendor/extension/notification/type/sample.php`

   <?php

   namespace vendor\extension\notification\type;

   class sample extends \phpbb\notification\type\base
   {
       // All the functions
   }

.. tip::

   It is also possible to extend any other notification type, rather than the :class:`base` class.
   |br| For example, if you want to extend the :class:`post` notification type instead:
   |br| you will have to register that as the service's parent: ``parent: notification.type.post``
   |br| and extend that class instead: ``class sample extends \phpbb\notification\type\post``

Functions of a notification type
================================
Now it is time to dive into the wonderful world of a notification type file.
We will try to cover all functions that are possible for you to use, top to bottom.
Per function we will mention if it is a required function or optional.

Base services
-------------
The base notification type class (:class:`\\phpbb\\notification\\type\\base`) already has a few services injected which can be used in these functions.

.. csv-table::
    :header: "Object", "Class"
    :delim: |

    ``$auth`` | :class:`\\phpbb\\auth\\auth`
    ``$db`` | :class:`\\phpbb\\db\\driver\\driver_interface`
    ``$language`` | :class:`\\phpbb\\language\\language`
    ``$user`` | :class:`\\phpbb\\user`
    ``$phpbb_root_path`` | :class:`string` phpBB root path
    ``$php_ext`` | :class:`string` php File extension
    ``$user_notifications_table`` | :class:`string` User notifications table

Additional services
-------------------
As mentioned earlier in `Registering as a Symfony service`_, we want to use two additional services.
And because we are using the ``calls`` construct, rather than overriding the parent's ``__construct()``,
we have to define the functions that are being called.
You can use this construct for any registered Symfony service that you may need to inject.

.. code-block:: php

   /** @var \phpbb\controller\helper */
   protected $helper;

   /** @var \phpbb\user_loader */
   protected $user_loader;

   /**
    * Set controller helper.
    *
    * @param \phpbb\controller\helper	$helper		Controller helper object
    * @return void
    */
   public function set_helper(\phpbb\controller\helper $helper)
   {
       $this->helper = $helper;
   }

   /**
    * Set user loader.
    *
    * @param \phpbb\user_loader		$user_loader	User loader object
    * @return void
    */
   public function set_user_loader(\phpbb\user_loader $user_loader)
   {
       $this->user_loader = $user_loader;
   }

get_type
--------
This should return the service identifier as defined in `Registering as a Symfony service`_.

.. code-block:: php

   /**
    * Get notification type name.
    *
    * @return string				The notification name as defined in services.yml
    */
   public function get_type()
   {
       return 'vendor.extension.notification.type.sample';
   }

notification_option
-------------------
This variable defines 2 language strings for the notification to show up in the :abbr:`UCP (User Control Panel)`.
|br| The ``group`` is for the category under which the the notification type will show up.
|br| The ``lang`` is for the actual notification type.

It is also possible to define an ``id`` in these options.
Usually this isn't needed for most extensions.
This ``id`` variable is used to concatenate multiple notification types into one.
So if you have multiple notification types that should show up as a single type in the user's preferences,
you can set the same ``id`` on all those types.

If you do not wish to display this notification in the user's preferences, you can omit this variable.
In that case also make sure to set the is_available_ to ``false``.

.. code-block:: php

   /**
    * Notification option data (for outputting to the user).
    *
    * @var bool|array				False if the service should use it's default data
    * 						Array of data (including keys 'id', 'lang', and 'group')
    * @static
    */
   static public $notification_option = [
       'lang'	=> 'VENDOR_EXTENSION_NOTIFICATION_SAMPLE',
       'group'	=> 'VENDOR_EXTENSION_NOTIFICATIONS',
   ];

is_available
------------
This function determines if this notification type should show in the :abbr:`UCP (User Control Panel)`.
You can simply set it to ``true`` or check some configuration or authentication settings. Or anything else for that matter.
As shown below, where we check if the private messages are enabled and the user is authorised to read them.

If it is not set to ``false``, make sure the `notification_option`_ array is set.
If it is set to ``false``, the notification type will not show up in the UCP.
Meaning that a user can not change their preferences in regards to this notification type
and thus can not enable/disable any notification methods.

.. code-block:: php

   /**
    * Is this type available to the current user.
    *
    * Defines whether or not it will be shown in the UCP "Edit notification options".
    *
    * @return bool				Whether or not this is available to the user
    */
   public function is_available()
   {
       return $this->config['allow_privmsg'] && $this->auth->acl_get('u_readpm');
   }

get_item_id
-----------
This function should return the identifier for the item this notification belongs to.
Usually this refers to some sort of entity, like a forum, topic, post, etc..
If you do not have any specific "item", you can have a look at the `Custom item identifier`_.

Just to be clear, this identifier is not the actual notification identifier (``notification_id``).
However, it is used - in conjunction with the `parent identifier <get_item_parent_id_>`_ - to create an index.
For example, when a notification with an item/parent id is send to a user,
and that user still has not read a prior notification with the same item/parent id combination,
the new notification will not be send.
This is to prevent spamming the user with notifications about the same item over and over.

.. code-block:: php

   /**
    * Get the id of the item.
    *
    * @param array	$data			The notification type specific data
    * @return int				Identifier of the notification
    * @static
    */
   public static function get_item_id($data)
   {
       return $data['message_id'];
   }

get_item_parent_id
------------------
This function should return the identifier for the parent of the item this notification belongs to.
Usually this refers to some sort of parent entity for the `item identifier <get_item_id_>`_, like a forum, topic, post, etc..
When the item is a topic, the parent is the forum.
When the item is a post, the parent is the topic.
And so on, and so forth.
If there is no parent for the item, you can set this to zero: ``return 0;``.

.. code-block:: php

   /**
    * Get the id of the parent.
    *
    * @param array	$data			The type notification specific data
    * @return int				Identifier of the parent
    * @static
    */
   public static function get_item_parent_id($data)
   {
       return 0;
   }

find_users_for_notification
---------------------------
This function is responsible for finding the users that need to be notified.
It should return an array with the user identifiers as keys and the notification methods as value.
There are various helper functions that help you achieve the desired outcome.

check_user_notification_options
+++++++++++++++++++++++++++++++
You can send an array of user identifiers to this function.
This function will then check the available notification methods for each user.
If the notification type is available in the :abbr:`UCP (User Control Panel)`, it will check the user's preferences.
Otherwise it will use the default notification methods; the board method and the email method (if *board-wide emails* is enabled).
The array that is returned by this function, can be used as a return value for find_users_for_notification_.

get_authorised_recipients
+++++++++++++++++++++++++
If your notification is for an event within a specific forum, you might want to check the users' authentication.
This can be done by using this function, which will check all users' ``f_read`` permission for the provided ``forum_id``.
The array that is returned by this function is already put through check_user_notification_options_.

.. code-block:: php

   /**
    * Find the users who want to receive notifications.
    *
    * @param array $data			The type specific data
    * @param array $options			Options for finding users for notification
    * 				 		ignore_users => array of users and user types that should not receive notifications from this type
    * 				 		because they've already been notified
    * 						  e.g.: array(2 => array(''), 3 => array('', 'email'), ...)
    * @return array				Array of user identifiers with their notification method(s)
    */
   public function find_users_for_notification($data, $options = [])
   {
       return $this->check_user_notification_options([$data['user_id']], $options);
   }

.. note::

    The ``forum_id`` variable below is not set in this Tutorial, just shown as an example.

.. code-block:: php

   public function_find_users_for_notification($data, $options = [])
   {
       return $this->get_authorised_recipients([$data['user_id']], $data['forum_id'], $options);
   }

users_to_query
--------------
This function should return an array of user identifiers.
Identifiers of users that need to be queried for this notification to be displayed to the user that is notified.
For example users whose username need to be displayed, or the user whose avatar will be shown next to the notification text.

.. code-block:: php

   /**
    * Users needed to query before this notification can be displayed.
    *
    * @return array				Array of user identifiers to query.
    */
   public function users_to_query()
   {
       return [$this->get_data('sender_id')];
   }

get_avatar
----------
The user identifiers returned by the users_to_query_ function are added to the User loader object.
Unfortunately, that object is not available by default in the `Base services`_.
However, we have added that in the `Additional services`_ section, so we can use it anyway!

So we use the convenient function, applicably named, ``get_avatar()`` that is available in the User loader.
And we supply three parameters. The first being the user identifier from whom we want to show the avatar.
The second is a boolean, indicating that the user does not have to be queried from the database, as that is already done.
And the third is also a boolean, indicating that the avatar image should be lazy loaded in the HTML.
Seeing it is in a dropdown and not visible immediately, lazy loading is more beneficial for a page's load time.

If you do not wish to display an avatar next to the notification text, you can omit this function all together.

.. code-block:: php

   /**
    * Get the user's avatar.
    *
    * @return string				The HTML formatted avatar
    */
   public function get_avatar()
   {
       return $this->user_loader->get_avatar($this->get_data('sender_id'), false, true);
   }

get_title
---------
This should return the main text for the notification.
Usually the action that was taken why this user received a notification.
Commonly the action is made bold and everything else is regular, as shown in the `language file`_.

.. code-block:: php

   /**
    * Get the title of this notification.
    *
    * @return string				The notification's title
    */
   public function get_title()
   {
       return $this->language->lang(
           'VENDOR_EXTENSION_NOTIFICATION_SAMPLE_TITLE',
           $this->user_loader->get_username($this->get_data('sender_id'), 'no_profile')
       );
   }

get_forum
---------
If you want to provide the name of the forum the action occurred that triggered this notification,
that is possible through this notification. For example when a new topic is posted.
Can be omitted if no forum name is required or available.
It will be prefixed by the *Forum:* string:

    *Forum:* The forum name

.. note::

    The ``forum_name`` variable below is not set in this Tutorial, just shown as an example.

.. code-block:: php

   /**
    * Get the forum name for this notification.
    *
    * @return string
    */
   public function get_forum()
   {
       return $this->language->lang(
           'NOTIFICATION_FORUM',
           $this->get_data('forum_name')
       );
   }

get_reason
----------
If you want to provide a literal reason for this notification, that is possible through this function.
For example the reason provided when creating or closing a report, or for editing or deleting a post.
Can be omitted if no additional reason is required.
It will be prefixed by the *Reason:* string:

    *Reason:* This is a sample reason

.. code-block:: php

   /**
    * Get the reason for this notification.
    *
    * @return string				The notification's reason
    */
   public function get_reason()
   {
       return $this->language->lang(
           'NOTIFICATION_REASON',
           $this->language->lang('VENDOR_EXTENSION_NOTIFICATION_SAMPLE_REASON'))
       );
   }

get_reference
-------------
If you want to provide an additional reference for this notification, that is possible through this notification.
For example the subject of a private message, post or topic.
Can be omitted if no additional reference is required.
It will be encapsulated in double quotes:

    "The message subject"

.. code-block:: php

   /**
    * Get the reference for this notification.
    *
    * @return string				The notification's reference
    */
   public function get_reference()
   {
       return $this->language->lang(
           'NOTIFICATION_REFERENCE',
           censor_text($this->get_data('message_subject'))
       );
   }

get_style_class
---------------
It is also possible to add a custom CSS class to the notification row.
This can be useful if you want to do some additional or different styling.
For example when the notification is about a report or a disapproval.
Providing a string here, will add it as classes to the notification.
Can be omitted if no additional CSS class is required.

.. code-block:: php

   /**
    * Get the CSS style class for this notification.
    *
    * @return string                The notification's CSS class
    */
   public function get_style_class()
   {
       return 'sample-notification-class and-another-class';
   }

get_url
-------
This should return the url the user is send to when clicking on the notification.
It is required to have this function in your notification type, even if there is no url to send the user to.
In such a case, return an empty string: ``return '';``.

There are - usually - two ways to create the required url.
Either through ``append_sid()`` or using the *Controller helper object*.
The first one is commonly used when sending a user to a page within the phpBB core, such as viewforum, viewtopic or the ucp.
The second one is commonly used when sending a user to a page within an extension, which are often routes.

.. code-block:: php
   :caption: Returning a url with the ``append_sid`` option

   /**
    * Get the url to this item.
    *
    * @return string				The notification's url
    */
   public function get_url()
   {
       return append_sid("{$this->phpbb_root_path}ucp.{$this->php_ext}", [
           'mode' => 'view',
           'i'    => 'pm'
           'p'    => $this->get_data('message_id'),
       ]);
   }

.. note::

    We have added the *Controller helper object* in the `Additional services`_ section.

.. code-block:: php
   :caption: Returning a url with the Controller helper object

   public function get_url()
   {
       return $this->helper->route('vendor_extension_route', [
           'subject'	=> $this->get_data('message_subject'),
       ]);
   }

get_redirect_url
----------------
This function can return a different url than get_url_.
The url returned by this function, will be used to ``redirect()`` the user to when they mark the notification as read.
Most commonly this url is the same as the url returned by get_url_, it even defaults to that.
So if you do not want to provide a different *"mark read"*-url, you can omit this function.

For example, the :class:`post` notification uses this to send the user to first unread post in a topic.

.. code-block:: php

   /**
    * Get the url to redirect to after the item has been marked as read.
    *
    * @return string				The notification's "mark read"-url
    */
   public function get_redirect_url()
   {
       return append_sid("{$this->phpbb_root_path}viewtopic.{$this->php_ext}", "t={$this->item_parent_id}&amp;view=unread#unread");
   }

get_email_template
------------------
If you do not want to make use of the email notification method, you can return ``false``.
This will make it so users can not select the email method in their notification preferences.

However, if you do want to make use of the email notification method, you can supply the email *template* file here.
It is not a template file like you may be used to, as it is not located in the :class:`styles/all/template` directory.
Rather, it is located in the language's :class:`email` directory, as shown in the `File structure`.

You can, or rather should, use the ``@vendor_extension/`` prefix to indicate your extension's path.
The *default* directory, as mentioned, is the :class:`email` directory and in our case, the filename is :class:`sample`.
So the file name should be appended to the prefix, so that will result in ``@vendor_extension/sample``.
If your email template is located in a subdirectory of the :class:`email` directory,
you will have to indicate that in the path: ``@vendor_extension/subdirectory/sample``.

.. code-block:: php

   /**
    * Get email template.
    *
    * @return string|false			This notification's template file or false if there is none
    */
   public function get_email_template()
   {
       return '@vendor_extension/sample';
   }

There is also a third notification method, Jabber, which uses the :class:`email/short` directory for its template files.
This notification method is closely tied to the email method, so it is important to also supply that template file,
even though the content might be identical to the email template.

.. warning::

   Make sure to have both :class:`language/en/email/sample.txt` and :class:`language/en/email/short/sample.txt`
   in your extension's language directory to prevent errors.

get_email_template_variables
----------------------------
If you are not making use of the email notification method, you can omit this function.
Meaning that if get_email_template_ returns ``false``, you can leave this function out completely.

But if you do use the email method, then here you can define the variables that you need within your `email template`_.
However, the phpBB core already defines a few *default* variables for you:

.. csv-table::
    :header: "Variable", "Description", "Defined in"
    :delim: #

    ``USERNAME`` # The recipient's username # :class:`\\phpbb\\notification\\method\\messenger_base` ``notify_using_messenger()``
    ``U_NOTIFICATION_SETTINGS`` # The recipient's notification preferences url # :class:`\\phpbb\\notification\\method\\messenger_base` ``notify_using_messenger()``
    ``EMAIL_SIG`` # The board's email signature # :class:`includes/functions_messenger.php` ``send()``
    ``SITENAME`` # The board's site name # :class:`includes/functions_messenger.php` ``send()``
    ``U_BOARD`` # The board's url # :class:`includes/functions_messenger.php` ``send()``

When specifying additional template variables, which are urls, you need to make sure they are absolute urls.
Meaning that they have to include the *full* url: ``https://www.example.com/forum/ucp.php`` rather than just ``./ucp.php``.
The example below will show you how to achieve this for both regular urls and urls generated from Symfony routes.

.. code-block:: php

   /**
    * Get email template variables.
    *
    * @return array				Array of variables that can be used in the email template
    */
   public function get_email_template_variables()
   {
       return [
           'AUTHOR'	=> htmlspecialchars_decode($this->user_loader->get_username($this->get_data('sender_id'), 'username')),
           'SUBJECT'	=> htmlspecialchars_decode(censor_text($this->get_data('message_subject')),

           // Absolute url: regular
           'U_REGULAR'     => generate_board_url() . '/ucp.' . $this->php_ext . '?i=pm&mode=view&p=' . $this->get_data('message_id'),

           // Absolute url: route
           'U_ROUTE'       => generate_board_url(false) . $this->helper->route('vendor_extension_route'),
       ];
   }

get_data
--------
This is a helper function, commonly used within functions that are called when displaying this notification type.
These *display functions* often need to access some data specific to a certain notification, such as a ``message_id``.
To retrieve those data variables, you can use this function, with the variable name as argument: ``$this->get_data('key')``.

.. important::

    All data that you have to retrieve, must be inserted upon creation of the notification.
    |br| This is done through create_insert_array_ function.

.. code-block:: php

   $this->get_data('sender_id');
   $this->get_data('message_id');
   $this->get_data('message_subject');

create_insert_array
-------------------
This function is responsible for inserting data specific to this notification type.
This data will be stored in the database and used when displaying the notification.

The ``$data`` parameter will contain the array that is being send when `Sending a notification`_.
So, all data that is needed for creating and displaying the notification has to be included.

However, only the data that is needed for displaying the notification, must be inserted.
If you've paid close attention, you will have noticed that we use 4 data variables.
Namely ``user_id``, ``sender_id``, ``message_id`` and ``message_subject``.
But the ``user_id`` is only required when creating the notification, and not needed when displaying it.
So this variable does not have to be stored in the database.
All other variables can be inserted using the ``set_data('key', 'value')`` helper function.

.. hint::

    As a rule of thumb, only the data you get through ``get_data()`` has to be set through ``set_data()``.

.. code-block:: php

   /**
    * Function for preparing the data for insertion in an SQL query.
    * (The service handles insertion)
    *
    * @param array	$data			The type specific data
    * @param array	$pre_create_data	Data from pre_create_insert_array()
    * @return void
    */
   public function create_insert_array($data, $pre_create_data = [])
   {
       $this->set_data('sender_id', $data['sender_id']);
       $this->set_data('message_id', $data['message_id']);
       $this->set_data('message_subject', $data['message_subject']);

       parent::create_insert_array($data, $pre_create_data);
   }

Sending a notification
======================

Deleting a notification
=======================

Updating a notification
=======================

Marking a notification
======================
Do not use X, as it is deprecated

Advanced lessons
================

Custom item identifier
----------------------
Sometimes you can not use a “normal” item identifier, such as a ``topic_id``, ``post_id`` or ``msg_id``.
Commonly you then create a custom notification counter in your extension.
You add it through a migration, where it is added to the config table.
For example with the following code: ``['config.add', ['vendor_extension_notification_id', 0]]``.

.. seealso::

  Read more about this in the `Add config setting <../migrations/tools/config.html#add-config-setting>`__ section.


Then when sending a notification, you will have to increment the identifier and use that as the item id.
You can use the Config object's (:class:`\\phpbb\\config\\config`) ``increment()`` function to achieve this.

.. code-block:: php

   // Increment the notification identifier by 1
   $this->config->increment('vendor_extension_notification_id', 1);

   $this->notification_manager->add_notification('vendor.extension.notification.type.sample', [
       'item_id'   => $this->config['vendor_extension_notification_id'],
   ]);

You can use this custom notification identifier in the get_item_id_ function.

.. code-block:: php

   public static function get_item_id($data)
   {
       return $data['item_id'];
   }

Building a users list
---------------------
It is also possible to build a users list in a notification's text.
This can be useful, for example, when you want to show which users have replied to a topic.

   **Reply** from **User 1**, **User 2**, **User 3** and 7 others in topic:
   |br| *The topic title*

// @todo
Easiest thing to do is extend the :class:`post` notification type and override the necessary functions.
Make sure to send the correct variables to comply with :class:`post`'s ``get_title`` and ``find_users_for_notification``.

.. |fa-ext| raw:: html

   <i class="fa fa-puzzle-piece fa-fw" aria-hidden="true"></i>

.. |fa-user| raw:: html

   <i class="fa fa-user fa-fw" aria-hidden="true"></i>

.. |fa-file| raw:: html

   <i class="fa fa-file-o fa-fw" aria-hidden="true"></i>

.. |fa-folder| raw:: html

   <i class="fa fa-folder fa-fw" aria-hidden="true"></i>

.. |nbsp| raw:: html

   &nbsp;

.. |br| raw:: html

    <br>
