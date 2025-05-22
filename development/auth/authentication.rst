Auth API
========

This is an explanation of how to use the phpBB auth/acl API.

.. contents::
   :local:
   :depth: 2

1. Introduction
---------------

What is it?
^^^^^^^^^^^

The ``auth`` class contains methods related to authorisation of users to access various board functions, e.g., posting, viewing, replying, logging in (and out), etc. If you need to check whether a user can carry out a task or handle user login/logouts, this class is required.

Initialisation
^^^^^^^^^^^^^^

To use any methods contained within the ``auth`` class, it first needs to be instantiated. This is best achieved early in the execution of the script in the following manner:

.. code-block:: php

    $auth = new phpbb\auth\auth();

Once an instance of the class has been created you are free to call the various methods it contains. Note: if you wish to use the ``auth_admin`` methods you will need to instantiate this separately in the same way.

2. Methods
----------

Following are the methods you are able to use.

2.i. acl
^^^^^^^^

The ``acl`` method is the initialisation routine for all the ACL functions. It must be called before any ACL method. It takes one parameter: an associative array containing user information.

.. code-block:: php

    $auth->acl($userdata);

Where ``$userdata`` includes at least: ``user_id``, ``user_permissions``, and ``user_type``.

2.ii. acl_get
^^^^^^^^^^^^^

This method determines if a user can perform an action either globally or in a specific forum.

.. code-block:: php

    $result = $auth->acl_get('option'[, forum]);

- ``option``: e.g., 'f_list', 'm_edit', 'a_adduser', etc. Use ``!option`` to negate.
- ``forum`` (optional): integer ``forum_id``.

Returns a positive integer if allowed, zero if denied.

2.iii. acl_gets
^^^^^^^^^^^^^^^

This method checks multiple permissions at once.

.. code-block:: php

    $result = $auth->acl_gets('option1'[, 'option2', ..., forum]);

Returns a positive integer if *any* of the permissions is granted.

2.iv. acl_getf
^^^^^^^^^^^^^^

This method checks in which forums a user has a certain permission.

.. code-block:: php

    $result = $auth->acl_getf('option'[, clean]);

- ``option``: permission string (negation with ``!`` allowed)
- ``clean``: boolean. If true, only forums where permission is granted are returned.

Returns an associative array:

.. code-block:: php

    array(forum_id1 => array(option => integer), forum_id2 => ...)

2.v. acl_getf_global
^^^^^^^^^^^^^^^^^^^^

Checks if a user has a permission globally or in at least one forum.

.. code-block:: php

    $result = $auth->acl_getf_global('option');

Returns a positive integer or zero.

2.vi. acl_cache
^^^^^^^^^^^^^^^

**Private method.** Automatically called when needed. Generates user_permissions data.

2.vii. acl_clear_prefetch
^^^^^^^^^^^^^^^^^^^^^^^^^

Clears the ``user_permissions`` column in the users table.

.. code-block:: php

    $user_id = 2;
    $auth->acl_clear_prefetch($user_id);

Use ``$user_id = 0`` to clear cache for all users. Returns null.

2.viii. acl_get_list
^^^^^^^^^^^^^^^^^^^^

Returns an array describing which users have which permissions in which forums.

.. code-block:: php

    $user_id = array(2, 53);
    $permissions = array('f_list', 'f_read');
    $forum_id = array(1, 2, 3);
    $result = $auth->acl_get_list($user_id, $permissions, $forum_id);

Parameter types:
- ``$user_id``: ``false``, int, or array of int
- ``$permissions``: ``false``, string, or array of string
- ``$forum_id``: ``false``, int, or array of int

2.ix. Miscellaneous
^^^^^^^^^^^^^^^^^^^

Additional methods for pulling raw permission data:

.. code-block:: php

    function acl_group_raw_data($group_id = false, $opts = false, $forum_id = false)
    function acl_user_raw_data($user_id = false, $opts = false, $forum_id = false)
    function acl_raw_data_single_user($user_id)
    function acl_raw_data($user_id = false, $opts = false, $forum_id = false)
    function acl_role_data($user_type, $role_type, $ug_id = false, $forum_id = false)

Use ``acl_raw_data`` for general queries; others are optimized for specific data.

3. Admin Related Functions
--------------------------

Additional methods are available within the ``auth_admin`` class for managing permissions, options, and user cache. It is found in:

::

    includes/acp/auth.php

Instantiate separately:

.. code-block:: php

    $auth_admin = new auth_admin();

This gives access to both ``auth_admin`` and ``auth`` methods.
