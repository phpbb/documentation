=======================
Tutorial: Notifications
=======================

.. contents:: This tutorial explains:
   :depth: 1
   :local:

Introduction
============
The notification system was introduced with the release of phpBB :guilabel:`3.1`.
Since then it has seen further developments and enhancements for users and extension developers.
In :guilabel:`3.2` the notification system was heavily refactored making it faster and more efficient.

phpBB users have complete control over their personal notification interactions.
They can set their own preferences for notification methods or disable them all together.
Mark notifications as read when necessary, even though in a lot of cases this is done automatically.

In phpBB there are two default notification methods: email-based and board-based notifications.
The email method is only available when the ''board-wide emails'' setting has been enabled by the board administrator in the ACP.
Extensions, however, can create and add their own notification methods.

This tutorial will document how and extension can leverage the notification system by creating a notification
based on some sort of triggering event (such as replying to a post),
sending the notification via either the board, email or some other custom methods, and managing its
notifications.

File Structure
--------------
This is an overview of the file structure needed for a notification to function within an extension.
In total there are 7 files that will be covered in this tutorial, to create and send notifications.
These files will be referenced throughout this tutorial.


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

Creating a Notification Type
============================
The first thing is to determine a name for the type of notification we will create.
For the purposes of this tutorial we will name it ''sample''. All extensions should always
use their vendor and name as prefixes, so the notification type name we'll be using is: ``vendor.extension.notification.type.sample``.

Registering as a Symfony Service
--------------------------------
Now our notification type must be registered as a Symfony service in our extension's :class:`services.yml`.
As with any service declaration, it will need a service identifier and the class argument (we will discuss what
goes into our :class:`sample` class a little later).
However, notification types also require three additional parameters: ``parent``, ``shared`` and ``tags`` parameters.

The ``parent`` parameter will declare the parent service of our notification. In other words, our notification will be a child class
and it will inherit from a core phpBB notification service, in this case phpBB's base notification class/service.

The ``shared`` parameter should be set to ``flase`` which will make sure that each time this notification type is requested, a new instance is created.
This will prevent any data from one notification instance being inadvertently mixed up with another.

Finally ``tags`` is used to tag our service as a notification type. This is how phpBB will know this is part of its notification system.

.. code-block:: yaml
   :caption: :class:`vendor/extension/config/services.yml`

   services:
       vendor.extension.notification.type.sample:
           class: vendor\extension\notification\type\sample
           parent: notification.type.base
           shared: false
           tags: [{ name: notification.type }]

However, for the purposes of this tutorial, we are going to need two additional services in our notification type.
We will be using the Controller helper object (:class:`\\phpbb\\controller\\helper`) to create a route (see get_url_)
and the User loader object (:class:`\\phpbb\\user_loader`) to display a user's details (see get_title_ and get_avatar_).
But because we are defining a ``parent``, we can not also use the ``arguments`` parameter.
We either have to define all ``arguments``, including the ones from the parent,
or we can use the ``calls`` parameter to call functions when our notification is instantiated that will load these additional
object functions, as shown below.
You can read more about this in `Additional services`_.

The first argument in the call is the name of the ``set_`` function we are going to call and create in our :class:`sample` class.
The second argument is an array with service definitions that our ``set_`` functions will be adding to our :class:`sample` class.

.. code-block:: yaml
   :caption: :class:`vendor/extension/config/services.yml`
   :name: services file

   services:
       vendor.extension.notification.type.sample:
           class: vendor\extension\notification\type\sample
           parent: notification.type.base
           shared: false
           tags: [{ name: notification.type }]
           calls:
               - ['set_helper', ['@controller.helper']]
               - ['set_user_loader', ['@user_loader']]

Altering an Extension's State
-----------------------------
The next thing that we need to do, is a bit of house-keeping that is required for every extension that is
creating its own notifications, the enabling, disabling and purging of our notification type when our extension's state changes.
In other words, when an extension is enabled/disabled, the notification type must also enabled/disabled.
Or when the extension's data is deleted, the notification type's data is purged from the database as well.
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
        * @param mixed  $old_state  State returned by previous call of this method
        * @return mixed             Returns false after last step, otherwise temporary state
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
        * @param mixed  $old_state  State returned by previous call of this method
        * @return mixed             Returns false after last step, otherwise temporary state
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
        * @param mixed  $old_state  State returned by previous call of this method
        * @return mixed             Returns false after last step, otherwise temporary state
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

Defining Language Strings
-------------------------
Next we can start defining some language strings that will be used by the notification.
This specific language file contains all possible language strings that can be used in a notification.
You can remove any strings that you will not need.

.. tip::
   This language file will be included during a user's setup later on in this tutorial, meaning that they will be globally available.
   However, there are a few strings that are only needed in the :abbr:`UCP (User Control Panel)`.
   Ideally these strings should be defined in a separate file, namely :class:`info_ucp_extension.php`.
   Using this naming convention (:class:`info_ucp_*.php`) will automatically include it only in the UCP.
   But for the sake of this tutorial, they are all being defined in this one language file.

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

Now lets create the sample Email template file, which is also located in the language directory.
The variables used in this file are defined in get_email_template_variables_.
The first line of the file should begin with ``Subject:``, followed by the actual email subject and an empty line.
It is possible to use variables in the subject line as well.

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

The Notification Type Class
---------------------------
The following example shows what is needed as the bare minimum for a notification type class.
`All the functions <Notification Type Class Functions_>`_ will be discussed later on.

We have defined the :class:`base` notification type class as a ``parent`` when we were `Registering as a Symfony Service`_.
Therefore it is important that our notification type class extends the :class:`base` class.

.. code-block:: php
   :caption: :class:`/vendor/extension/notification/type/sample.php`

   <?php

   namespace vendor\extension\notification\type;

   class sample extends \phpbb\notification\type\base
   {
       // All the functions
   }

.. tip::

   It is also possible to extend other notification types, rather than the :class:`base` class.
   |br| For example, if you want to extend the :class:`post` notification type instead:
   |br| you will have to register that as the service's parent: ``parent: notification.type.post``
   |br| and extend that class instead: ``class sample extends \phpbb\notification\type\post``

Notification Type Class Functions
=================================
Now it is time to dive into the wonderful world of our notification type class.
We will try to cover all the functions that are possible for you to use.
We will also mention whether each function is required or optional to use.

Base Services
-------------
The base notification type class (:class:`\\phpbb\\notification\\type\\base`) already has a few available services which can be used in our class's functions.

.. csv-table::
    :header: Object, Class
    :delim: |

    ``$auth`` | :class:`\\phpbb\\auth\\auth`
    ``$db`` | :class:`\\phpbb\\db\\driver\\driver_interface`
    ``$language`` | :class:`\\phpbb\\language\\language`
    ``$user`` | :class:`\\phpbb\\user`
    ``$phpbb_root_path`` | :class:`string` phpBB root path
    ``$php_ext`` | :class:`string` php File extension
    ``$user_notifications_table`` | :class:`string` User notifications table

Additional Services
-------------------
As mentioned earlier in `Registering as a Symfony Service`_, we want to use two additional services.
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
    * @param \phpbb\controller\helper  $helper  Controller helper object
    * @return void
    */
   public function set_helper(\phpbb\controller\helper $helper)
   {
       $this->helper = $helper;
   }

   /**
    * Set user loader.
    *
    * @param \phpbb\user_loader  $user_loader  User loader object
    * @return void
    */
   public function set_user_loader(\phpbb\user_loader $user_loader)
   {
       $this->user_loader = $user_loader;
   }

Required Class Functions
------------------------

The following functions must be implemented in every notification type class.

get_type
--------
This should return the service identifier as defined in `Registering as a Symfony Service`_.

.. code-block:: php

   /**
    * Get notification type name.
    *
    * @return string  The notification name as defined in services.yml
    */
   public function get_type()
   {
       return 'vendor.extension.notification.type.sample';
   }

notification_option
-------------------
This variable array defines two language strings from our notification that will appear in the :abbr:`UCP (User Control Panel)`.
|br| The ``group`` is for the category under which the the notification type will show up.
|br| The ``lang`` is for the actual notification type.

It is also possible to define an ``id`` in these options.
Usually this isn't needed for most extensions.
The ``id`` variable is used to concatenate multiple notification types into one.
So if you have multiple notification types that should show up as a single type in the user's preferences,
you can set the same ``id`` on all those types.

If you do not wish to display this notification in the user's preferences, you can omit this variable
and also make sure to set the is_available_ function to return ``false``.

.. code-block:: php

   /**
    * Notification option data (for outputting to the user).
    *
    * @var bool|array  False if the service should use it's default data
    *                  Array of data (including keys 'id', 'lang', and 'group')
    * @static
    */
   static public $notification_option = [
       'lang'	=> 'VENDOR_EXTENSION_NOTIFICATION_SAMPLE',
       'group'	=> 'VENDOR_EXTENSION_NOTIFICATIONS',
   ];

is_available
------------
This function determines if this notification type should show in the :abbr:`UCP (User Control Panel)`.
You can simply set it to ``true`` or check some configuration or authentication settings,
or anything else for that matter, as long as it always returns either a ``true`` or ``false`` boolean.
In the example below we will make displaying the notification in the UCP dependent
on whether private messages are enabled and the user is authorised to read them.

If this function returns ``false``, the notification type will not appear in the UCP.
This simply means that a user can not change their preferences in regards to this notification type
and thus can not enable/disable it. Remember that if this function could return ``false``, make sure
the `notification_option`_ array is set.

.. code-block:: php

   /**
    * Is this type available to the current user.
    *
    * Defines whether or not it will be shown in the UCP "Edit notification options".
    *
    * @return bool  Whether or not this is available to the user
    */
   public function is_available()
   {
       return $this->config['allow_privmsg'] && $this->auth->acl_get('u_readpm');
   }

get_item_id
-----------
This function should return the identifier for the item this notification belongs to.
Usually this refers to some sort of entity, like a forum, topic, post, etc...
If you do not have any specific item, you can have a look at the `Custom Item Identifier`_.

Just to be clear, this identifier is not the actual notification identifier (``notification_id``).
However, it is used - in conjunction with the `parent identifier <get_item_parent_id_>`_ - to create an index.
For example, when a notification with an item/parent id is sent to a user,
and that user still has not read a prior notification with the same item/parent id combination,
the new notification will not be sent.
This is to prevent spamming the user with notifications about the same item over and over.

.. code-block:: php

   /**
    * Get the id of the item.
    *
    * @param array  $data  The notification type specific data
    * @return int          Identifier of the notification
    * @static
    */
   public static function get_item_id($data)
   {
       return $data['message_id'];
   }

get_item_parent_id
------------------
This function should return the identifier for the parent of the item this notification belongs to.
Usually this refers to some sort of parent entity for the `item identifier <get_item_id_>`_, like a forum, topic, post, etc...
For example, when the item is a topic, the parent is the forum. When the item is a post, the parent is the topic.
And so on, and so forth.
If there is no parent for the item, you can set this to return zero: ``return 0;``.

.. code-block:: php

   /**
    * Get the id of the parent.
    *
    * @param array  $data  The type notification specific data
    * @return int          Identifier of the parent
    * @static
    */
   public static function get_item_parent_id($data)
   {
       return 0;
   }

find_users_for_notification
---------------------------
This function is responsible for finding the users that need to be notified.
It should return an array with the user identifiers as keys and the notification methods as values.
There are various helper functions that help you achieve the desired outcome.

check_user_notification_options
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
You can send an array of user identifiers to this function.
It will then check the available notification methods for each user.
If the notification type is available in the :abbr:`UCP (User Control Panel)`, it will check the user's preferences.
Otherwise it will use the default notification methods; the board method and the email method (if *board-wide emails* is enabled).
The array that is returned by this function can be used as a return value for find_users_for_notification_.

get_authorised_recipients
^^^^^^^^^^^^^^^^^^^^^^^^^
If your notification is for an event within a specific forum, you might want to check the users' authentication.
This can be done using this function, which will check all users' ``f_read`` permission for the provided ``forum_id``.
The array that is returned by this function is already put through check_user_notification_options_.

.. code-block:: php

   /**
    * Find the users who want to receive notifications.
    *
    * @param array  $data     The type specific data
    * @param array  $options  Options for finding users for notification
    *                           ignore_users => array of users and user types that should not receive notifications from this type
    *                           because they've already been notified
    *                           e.g.: array(2 => array(''), 3 => array('', 'email'), ...)
    * @return array           Array of user identifiers with their notification method(s)
    */
   public function find_users_for_notification($data, $options = [])
   {
       return $this->check_user_notification_options([$data['user_id']], $options);
   }

.. note::

    The ``forum_id`` variable below is not set in this tutorial, just shown as an example.

.. code-block:: php

   public function find_users_for_notification($data, $options = [])
   {
       return $this->get_authorised_recipients([$data['user_id']], $data['forum_id'], $options);
   }

users_to_query
--------------
This function should return an array of user identifiers for the users whose username need to be displayed,
or for users whose avatar will be shown next to the notification text.
Behind the scenes, the Notification manager object (:class:`\\phpbb\\notification\\manager`) will retrieve
all identifiers from all the notifications that need to be displayed.
It will then use a single SQL query to retrieve all the data for these users,
rather than each notification having to query a user's data separately.

.. tip::

   As a rule of thumb, all the user ids that will be used in the ``$user_loader`` should be returned here.

.. code-block:: php

   /**
    * Users needed to query before this notification can be displayed.
    *
    * @return array  Array of user identifiers to query.
    */
   public function users_to_query()
   {
       return [$this->get_data('sender_id')];
   }

get_title
---------
This should return the main text for the notification.
Usually the action that was taken that resulted in this notification.
Commonly the action is made bold and everything else is regular, as shown in the `language file`_.

Note that our language string has a string placeholder ``%s`` which is why we also send the sender's username as the second argument.
The username can be easily retrieved by the ``$user_loader`` object.
All the data for this user has already been queried, as we provided the user identifier in the users_to_query_ function.
So no additional SQL queries will be run.

.. code-block:: php

   /**
    * Get the title of this notification.
    *
    * @return string  The notification's title
    */
   public function get_title()
   {
       return $this->language->lang(
           'VENDOR_EXTENSION_NOTIFICATION_SAMPLE_TITLE',
           $this->user_loader->get_username($this->get_data('sender_id'), 'no_profile')
       );
   }

get_url
-------
This should return the URL the user is sent to when clicking on the notification.
This function is required in your notification type, even if there is no URL to send the user to,
in which case it should return an empty string: ``return '';``.

There are usually two ways to create the required URL.
Either through ``append_sid()`` or using the *Controller helper object*.
The first one is commonly used when sending a user to a page within the phpBB core, such as viewforum, viewtopic or the ucp.
The second one is commonly used when sending a user to a page within an extension, which often use routes.

.. code-block:: php
   :caption: Returning a URL with the ``append_sid`` option

   /**
    * Get the URL to this item.
    *
    * @return string  The notification's URL
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

    We have added the *Controller helper object* in the `Additional Services`_ section.

.. code-block:: php
   :caption: Returning a URL with the Controller helper object

   public function get_url()
   {
       return $this->helper->route('vendor_extension_route', [
           'subject'	=> $this->get_data('message_subject'),
       ]);
   }

get_email_template
------------------
If you do not want to make use of the email notification method, this should return ``false``
and users will not be able to select the email method in their notification preferences.

However, if you do want to make use of the email notification method, you should return the email *template* file here.
It is not a template file like you may be used to, as it is not located in the :class:`styles/all/template` directory.
Rather, it is located in the language's :class:`email` directory, as shown in the `File Structure`.

You can, or rather should, use the ``@vendor_extension/`` prefix to indicate your extension's path.
The *default* directory, as mentioned, is the :class:`email` directory and in our case, the filename is :class:`sample`.
So the file name should be appended to the prefix, so that will result in ``@vendor_extension/sample``.
If your email template is located in a subdirectory of the :class:`email` directory,
you will have to indicate that in the path, e.g.: ``@vendor_extension/subdirectory/sample``.

.. code-block:: php

   /**
    * Get email template.
    *
    * @return string|false  This notification's template file or false if there is none
    */
   public function get_email_template()
   {
       return '@vendor_extension/sample';
   }

.. note::

    The previously existing Jabber notification method has been removed in phpBB 4.0. A separate :class:`email/short` directory
    for this notification method is no longer used and therefore you no longer need to create a separate template file for it.

get_email_template_variables
----------------------------
If you are not making use of the email notification method, this should return an empty ``array()``.
But if you are using the email method, then you should use this function to define the variables that are used in your `email template`_.
However, note that the phpBB core already defines some *default* variables for you:

.. csv-table::
    :header: Variable, Description, Defined in
    :delim: #

    ``USERNAME`` # The recipient's username # :class:`\\phpbb\\notification\\method\\messenger_base` ``notify_using_messenger()``
    ``U_NOTIFICATION_SETTINGS`` # The recipient's notification preferences URL # :class:`\\phpbb\\notification\\method\\messenger_base` ``notify_using_messenger()``
    ``EMAIL_SIG`` # The board's email signature # :class:`includes/functions_messenger.php` ``send()``
    ``SITENAME`` # The board's site name # :class:`includes/functions_messenger.php` ``send()``
    ``U_BOARD`` # The board's URL # :class:`includes/functions_messenger.php` ``send()``

When specifying additional template variables such as URLs, you must make sure they are absolute URLs.
They have to include the *full* URL: ``https://www.example.com/forum/ucp.php`` rather than just ``./ucp.php``.
The example below will show you how to achieve this for both regular URLs and URLs generated from Symfony routes.

.. code-block:: php

   /**
    * Get email template variables.
    *
    * @return array  Array of variables that can be used in the email template
    */
   public function get_email_template_variables()
   {
       return [
           'AUTHOR'	=> htmlspecialchars_decode($this->user_loader->get_username($this->get_data('sender_id'), 'username')),
           'SUBJECT'	=> htmlspecialchars_decode(censor_text($this->get_data('message_subject')),

           // Absolute URL: regular
           'U_REGULAR'     => generate_board_url() . '/ucp.' . $this->php_ext . '?i=pm&mode=view&p=' . $this->get_data('message_id'),

           // Absolute URL: route
           'U_ROUTE'       => generate_board_url(false) . $this->helper->route('vendor_extension_route'),
       ];
   }

Optional Class Functions
------------------------

The following functions are optional and can be omitted if your notification does not need to use them.

get_avatar
----------
The user identifiers returned by the users_to_query_ function are added to the User loader object.
Unfortunately, that object is not available by default in the `Base Services`_.
This was why we added it in the `Additional Services`_ section.

So we use the convenient function, applicably named, ``get_avatar()`` that is available from the User loader.
And we supply three parameters. The first being the user identifier from whom we want to show the avatar.
The second is a boolean, indicating that the user does not have to be queried from the database, as that is already done.
And the third is also a boolean, indicating that the avatar image should be lazy loaded in the HTML.
As the notification GUI is a dropdown and not visible immediately, lazy loading is more beneficial for a page's load time.

If you do not wish to display an avatar next to the notification text, you can omit this function all together.

.. code-block:: php

   /**
    * Get the user's avatar.
    *
    * @return string  The HTML formatted avatar
    */
   public function get_avatar()
   {
       return $this->user_loader->get_avatar($this->get_data('sender_id'), false, true);
   }

get_forum
---------
If you want to provide the name of the forum that triggered this notification,
that is possible through this function. For example, when a new topic is posted in a forum.
This function can be omitted if no forum name is required or available.
It will be prefixed by the *Forum:* string:

    *Forum:* The forum name

.. note::

    The ``forum_name`` variable below is not set in this tutorial, just shown as an example.

.. code-block:: php

   /**
    * Get the forum name for this notification.
    *
    * @return string  The notification's forum name
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
For example, the reason provided when creating or closing a report, or for editing or deleting a post.
This function can be omitted if no reason is required.
It will be prefixed by the *Reason:* string:

    *Reason:* This is a sample reason

.. code-block:: php

   /**
    * Get the reason for this notification.
    *
    * @return string  The notification's reason
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
For example, the subject of a private message, post or topic.
This function can be omitted if no reference is required.
It will be encapsulated in double quotes:

    "The message subject"

.. code-block:: php

   /**
    * Get the reference for this notification.
    *
    * @return string  The notification's reference
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
This can be useful if you want to change the default styling of the notification text.
For example, when the notification is about a report or a disapproval.
Providing a string of classes here will add them to the notification.
This function can be omitted if no additional CSS class is required.

.. code-block:: php

   /**
    * Get the CSS style class for this notification.
    *
    * @return string  The notification's CSS class
    */
   public function get_style_class()
   {
       return 'sample-notification-class and-another-class';
   }

get_redirect_url
----------------
This function can return a different URL than get_url_.
The URL returned by this function will be used to ``redirect()`` the user after they mark the notification as read.
By default this URL is the same as the URL returned by get_url_.
So if you do not need to provide a different *"mark read"*-URL, you can omit this function.

For example, the :class:`post` notification uses this to send the user to first unread post in a topic.

.. code-block:: php

   /**
    * Get the URL to redirect to after the item has been marked as read.
    *
    * @return string  The notification's "mark read"-URL
    */
   public function get_redirect_url()
   {
       return append_sid("{$this->phpbb_root_path}viewtopic.{$this->php_ext}", "t={$this->item_parent_id}&amp;view=unread#unread");
   }

get_data
--------
This is a helper function, commonly used within functions that are called when displaying this notification type.
These *display functions* often need to access some data specific to a certain notification, such as a ``message_id``.
To retrieve those data variables, you can use this function, with the variable name as an argument: ``$this->get_data('key')``.

.. important::

    All data that you have to retrieve, must be inserted upon creation of the notification.
    |br| This is done through the create_insert_array_ function.

.. code-block:: php

   $this->get_data('sender_id');
   $this->get_data('message_id');
   $this->get_data('message_subject');

create_insert_array
-------------------
This function is responsible for inserting data specific to this notification type.
This data will be stored in the database and used when displaying the notification.

The ``$data`` parameter will contain the array that is being sent when `Sending a Notification`_.
So, all data that is needed for creating and displaying the notification has to be included.

However, only the data that is needed for displaying the notification must be inserted.
If you've paid close attention, you will have noticed that we use four data variables.
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
    * @param array  $data             The type specific data
    * @param array  $pre_create_data  Data from pre_create_insert_array()
    * @return void
    */
   public function create_insert_array($data, $pre_create_data = [])
   {
       $this->set_data('sender_id', $data['sender_id']);
       $this->set_data('message_id', $data['message_id']);
       $this->set_data('message_subject', $data['message_subject']);

       parent::create_insert_array($data, $pre_create_data);
   }

Sending a Notification
======================
Now that we've set up our notification type class, it's time to start sending the notification.
We know what data we need, so we can collect that when the event is triggered.

Sending a notification is done with the Notification manager object (:class:`\\phpbb\\notification\\manager`).
This service can be injected with the ``- '@notification_manager'`` service declaration.

Then you can use the notification manager to send the notification.
This is done with the ``add_notifications`` function.
The notification type (:class:`vendor.extension.notification.type.sample`) should be provided as the first argument,
and all the ``$data`` that we need in our notification type as the second argument.

Below you'll find a simple example on how to send the notification.
It's possible to send a notification from anywhere.
This example uses an event listener, but it is also possible to send it from a controller.

.. code-block:: php
   :caption: :class:`\\vendor\\extension\\event\\listener`

   <?php

   namespace vendor\extension\event;

   class listener implements \Symfony\Component\EventDispatcher\EventSubscriberInterface
   {
       static public function getSubscribedEvents()
       {
           return ['core.submit_pm_after' => 'send_sample_notification'];
       }

       /** @var \phpbb\notification\manager */
       protected $notification_manager;

       public function __construct(\phpbb\notification\manager $notication_manager)
       {
           $this->notification_manager   = $notification_manager;
       }

       public function send_sample_notification(\phpbb\event\data $event)
       {
           // For the sake of this tutorial, we assume that the PM is send to a single user
           $this->notification_manager->add_notifications('vendor.extension.notification.type.sample', [
               'user_id'         => array_key_first($event['pm_data']['recipients']),
               'sender_id'       => $event['data']['from_user_id'],
               'message_id'      => $event['data']['msg_id'],
               'message_subject' => $event['subject'],
           ]);
       }
   }

Updating a Notification
=======================
Updating a notification is done with the Notification manager object (:class:`\\phpbb\\notification\\manager`).
This service can be injected with the ``- '@notification_manager'`` service declaration.

Then you can use the notification manager to update the notification.
This is done with the ``update_notifications`` function.
The notification type (:class:`vendor.extension.notification.type.sample`) should be provided as the first argument,
and all the ``$data`` that we need in our notification type as the second argument.
Optionally you can send a third argument, ``$options``, to specify which notification should be updated.
The options that can be defined are listed below:

.. csv-table::
    :header: Object, Class
    :delim: #

    ``item_id``        # The item identifier for the notification. |br| Defaults to get_item_id_
    ``item_parent_id`` # The item's parent identifier for the notification. |br| Optional
    ``user_id``        # The user identifier for who received the notification. |br| Optional
    ``read``           # A boolean indicating whether the notification has been read. |br| Optional

.. code-block:: php

   // For the sake of this tutorial, we assume that the PM is send to a single user
   $user_id = array_key_first($event['pm_data']['recipients']);

   $data = [
       'user_id'         => $user_id,
       'sender_id'       => $event['data']['from_user_id'],
       'message_id'      => $event['data']['msg_id'],
       'message_subject' => $event['data']['subject'],
   ];

   // Just the item identifier is sufficient to update this notification as it is unique
   // But lets include some options to demonstrate how that can be done as well.
   $options = [
       'user_id'  => $user_id,
       'item_id'  => $event['data']['msg_id'],
       'read'     => false, // Only update when user has not read it yet
   ];

   $this->notification_manager->update_notifications('vendor.extension.notification.type.sample', $data, $options);

Now let's step through how the above example works.
The notification type will be created as if it was being sent.
Then, rather than inserting the notification, it will retrieve the data created by the create_insert_array_ function.
That data is turned into an SQL :class:`UPDATE` statement ``$db->sql_create_array('UPDATE', $data)``.
And the ``$options`` provided are turned into an SQL :class:`WHERE` statement.

.. note::

   The data retrieved from create_insert_array_ are not database columns.
   |br| The data is put through ``serialize()`` and and stored in the :class:`notification_data` column.

The data is retrieved by the ``create_update_array`` function in the notification type :class:`base` class.
First it creates the insert array and then unsets a few variables that should not be updated:
``user_id``, ``notification_id``, ``notification_time`` and ``notification_read``
*(which is the indicator for whether or not the notification has already been read)*.
If you want to update any of these variables as well, you will have to override the :class:`base` ``create_update_array`` function.

It is also possible to handle the update process for your notification type completely yourself.
This is done by creating an ``update_notifications`` function in your notification type class.
Have a look at the :class:`quote` type to see an example.

Deleting a Notification
=======================
Sometimes it is necessary to delete a notification.
For example when a private message is deleted before it is read,
or a topic with unapproved post notifications is deleted. In each
of these cases the cause for the notification has been deleted,
making the notification irrelevant.

Deleting a notification is handled using the ``delete_notifications``
function located in the notification manager object (:class:`\\phpbb\\notification\\manager`).
Typically you would use an appropriate event listener to call ``delete_notifications``,
such as when an action occurs that would make your notification irrelevant.

This function is very simple to use, and requires only a few basic parameters:

delete_notifications
--------------------

Parameters
^^^^^^^^^^

.. csv-table::
   :header: Parameter, Description
   :delim: #

   **notification_type** # The notification service identifier. |br| Can be a single string or an array of service identifiers. |br| In this example: ``vendor.extension.notification.type.sample``.
   **item_id**           # The item identifier(s). |br| The item id for which you want to delete notifications. |br| Can be a single integer or an array of integers. Only item identifiers for the provided |br| notification type(s) will be deleted.
   **parent_id**         # The parent identifier(s). |br| The parent id for which you want to delete notifications. |br| Can be a single integer or an array of integers. Use this argument to delete the |br| notifications that only belong to the given parent identifier(s). Default is |br| false to ignore parent identifiers.
   **user_id**           # The user identifier(s). |br| The user id for whom you want to delete notifications. |br| Can be a single integer or an array of integers. Use this argument to delete the |br| notifications for a given user or collection of users. Default is false to ignore |br| specific users.

.. code-block:: php

   // Let's take a look at a PM that was deleted.
   // Say the item ID(s) for our notification come from the deleted PM's message IDs.
   $item_ids = $event['data']['msg_ids'];

   // Just the item identifier is sufficient to delete this notification as it is unique
   // But you could include user_id or parent_id's if they were relevant as well.
   $this->notification_manager->delete_notifications('vendor.extension.notification.type.sample', $item_ids);

Marking a Notification
======================
Notifications are automatically marked as read when they are clicked in the notifications dropdown.
Or when marking forums or topics as read, their respective notifications are marked as well.
However, sometimes it may preferable to manually mark a notification as read or unread.

There are three methods available for marking a notification,
all of these are located in the Notification Manager object (:class:`\\phpbb\\notification\\manager`).
The distinct difference between these methods is how they determine which notifications should be marked.
Either through their item id, parent id or the actual notification id.
When marking notifications by their item id or parent id, it will automatically mark them for all available notification methods.
But when marking notifications by their actual id, you will have to provide the specific notification method yourself.

.. admonition:: Deprecated
   :class: error

   This following functions are deprecated since phpBB :guilabel:`3.2.0`:
   |br| ``mark_notifications_read``
   |br| ``mark_notifications_read_by_parent``

The following is a quick summary of the three methods available for marking notifications and their arguments.

mark_notifications
------------------

Parameters
^^^^^^^^^^

.. csv-table::
   :header: Parameter, Description
   :delim: #

   **notification_type** # Can be a single string or an array of service identifiers. |br| In this example: ``vendor.extension.notification.type.sample``.
   **item_id**           # The item identifier(s). |br| The item id(s) for notifications you want to mark read. |br| Can be a single integer or an array of integers. Alternatively, it is also possible to pass |br| false to mark read for all item ids.
   **user_id**           # The user identifier(s). |br| The user id(s) for whom you want to mark notifications read. |br| Can be a single integer or an array of integers. Alternatively, it is also possible to pass |br| false to mark read for all user ids.
   **time**              # UNIX timestamp to use as a cut off. |br| Mark notifications sent before this time as read. All notifications created after this |br| time will not be marked read. The default value is false, which will mark all as read.
   **mark_read**         # Whether to mark the notification as *read* or *unread*. |br| Defaults to *read*.

mark_notifications_by_parent
----------------------------

Parameters
^^^^^^^^^^

.. csv-table::
   :header: Parameter, Description
   :delim: #

   **notification_type** # Can be a single string or an array of service identifiers. |br| In this example: ``vendor.extension.notification.type.sample``.
   **parent_id**         # The parent identifier(s). |br| The item parent id(s) for notifications you want to mark read. |br| Can be a single integer or an array of integers. Alternatively, it is also possible to pass |br| false to mark read for all item parent ids.
   **user_id**           # The user identifier(s). |br| The user id(s) for whom you want to mark notifications read. |br| Can be a single integer or an array of integers. Alternatively, it is also possible to pass |br| false to mark read for all user ids.
   **time**              # UNIX timestamp to use as a cut off. |br| Mark notifications sent before this time as read. All notifications created after this |br| time will not be marked read. The default value is false, which will mark all as read.
   **mark_read**         # Whether to mark the notification as *read* or *unread*. |br| Defaults to *read*.

mark_notifications_by_id
------------------------
Thus far we haven't had to work with the actual identifier of the notification itself, instead using the notification's item and parent ids.
This is usually because in the core of phpBB's execution, we may never know or have access to the notification's actual id,
as most of the notification handling is done through the distinct item and/or parent ids.
However, there can be times where it is more convenient or accurate to work directly with the notification's unique id.
For example, when the notifications are listed in the :abbr:`UCP (User Control Panel)` and a user can select specific notifications to be marked as read.

Parameters
^^^^^^^^^^

.. csv-table::
   :header: Parameter, Description
   :delim: #

   **method_name**       # The notification method service identifier |br| For example: ``notification.method.board``
   **notification_id**   # The notification identifier(s) |br| Can be an integer or array of integers.
   **time**              # UNIX timestamp to use as a cut off. |br| Mark notifications sent before this time as read. All notifications created after this |br| time will not be marked read. The default value is false, which will mark all as read.
   **mark_read**         # Whether to mark the notification as *read* or *unread*. |br| Defaults to *read*.

Advanced Lessons
================

Custom Item Identifier
----------------------
Sometimes you can not use a “normal” item identifier, such as a ``topic_id``, ``post_id`` or ``msg_id``.
In this case you will need to create a custom notification counter in your extension.
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
