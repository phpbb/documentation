=================
Permission system
=================

Introduction
============
The permission system is the system that allows board administrator decide what users are allowed do on the board.
Information on how to you use permission system can be found on :doc:`Tutorial: Permissions <tutorial_permissions>`.

An administrator with the correct permissions has access to the administration control panel (ACP) which contains the
administrative side of the permissions system. The administrator then setups the permissions to allow users to have the
rights to do certain things, tasks or see certain features. At the end of the day each permission is what is called
a permission option and users obtain the rights to these options either directly, from a group or from a role that is
assigned to them or a group they are in.

Permission options
==================
Permission options are the individual options that allow or deny you access to features. Examples are ``f_post``, ``m_delete``,
``a_ban`` and ``u_sendpm``. Permission options are group into permissions of the same type.

Examples of that are the ``f_``, ``m_``, ``a_`` and ``u_`` prefixes:

- ``f_`` - Forum permissions
- ``m_`` - Moderator permissions
- ``a_`` - Administrator permissions
- ``u_`` - User permissions

User permissions
================
Individual user permissions are stored in the phpbb_users table in the ``user_permissions`` column.
In addition to that, users that have the ``a_switchperm`` permission may assume the permissions of another user.
When this is done, the user id of the user one is assuming the permissions of are stored in the column ``user_perm_form``.

Permission options
==================
Permission options are stored in the table phpbb_acl_options. The fields of this table are defined as follows:

- ``auth_option_id`` - Unique ID of option ``auth_option``
- ``auth_option`` - Name of permission option
- ``is_global`` - Set to 1 if a global option else set to 0
- ``is_local`` - Set to 1 if a local option else set to 0
- ``founder_only`` - Set to 1 if a founder only option else set to 0

A local permission option is a option that can be granted to a user on a forum by forum basis.
This allows one to grant users options to perform a task in one forum but not another. They are also called
forum based permissions. In contrast to that, a global permission option is an option that is valid board wide.

Permission options can also be both global and local. An example is 'm_edit', the moderator permission to edit a topic.
Some users can be granted this permission on a single forum while other users might be granted this permission board wide.
In order to support this, the option is set to both local and global.

Founders
========
A founder is a special type of user. It should only be granted to the most trusted of administrators.
Founders can access the permission system to correct their permissions even if another administrator has removed their permissions.
Only a founder can remove the founder status of another founder. Therefore, a founder only permission is a type of
permission that is limited to this special type of user. By default, no permission is set to founder only.

Roles
=====
Roles are a predefined setup of permission options that can be applied to users or groups.
If the permission options of a role are changed, the users or groups assigned that role get updated automatically.

Roles are stored in the ``phpbb_acl_roles`` table which is comprised of the following columns:

- ``role_id`` - Unique ID of role
- ``role_name`` - Role name normally as a lang key
- ``role_description`` - Role description normally as a lang key
- ``role_type`` - ``a_``, ``u_``, ``m_`` or ``f_`` depending on what type of role it is
- ``role_order`` - Number indicating display order in the ACP

The permission options for a role are stored in the ``phpbb_acl_roles_data`` table which is comprised of the
following columns:

- ``role_id`` - Role id from phpbb_acl_roles
- ``auth_option_id`` - Option id from ``phpbb_acl_options``
- ``auth_setting`` - Stores either ``ACL_YES`` (1), ``ACL_NO`` (-1) or ``ACL_NEVER`` (0)

Your effective permission for any option is built up from a combination of details such as which groups you are
a member of, which role you have assigned and whether you have been assigned directly that permission.
As such you might have opposing permissions.

The ``YES``, ``NO`` and ``NEVER`` system works to allow phpBB to combine these different "answers" for an option and
give you the effective permission.
If at any point one gets a ``NEVER``, that will be the effective permission for that option since a ``NEVER`` can not be
overridden by a ``YES``. It will force the permission to be ``NO`` in the end, no matter what other roles, groups permissions,
etc. might say ``YES``. A ``NO`` will however be overridden by a ``YES``.

When checking permissions, it's also important to keep in mind whether the global or local permissions should be checked.
If ``acl_get`` is called without a forum id, the global permissions will be used. Instead, passing a forum id will also
check the local permissions which can then potentially override a ``NO`` with a ``YES``.
After checking all user, group, forum, and global permissions, the return permission is always either ``YES`` or ``NO``,
``NEVER`` is only used to enforce a ``NO``.

Roles specific to users are stored in the ``phpbb_acl_users`` table:

- ``user_id`` - User id from ``phpbb_users``
- ``forum_id`` - Forum id from ``phpbb_forums`` if a local option, else 0
- ``auth_option_id`` - Option id from ``phpbb_acl_options``
- ``auth_role_id`` - Role id from ``phpbb_acl_roles`` if obtained from a role, else 0
- ``auth_setting`` - Stores either ``ACL_YES`` (1), ``ACL_NO`` (-1) or ``ACL_NEVER`` (0)

Roles specific to groups are stored in the ``phpbb_acl_groups`` table:

- ``group_id`` - Group id from ``phpbb_groups``
- ``forum_id`` - Forum id from ``phpbb_forums`` if a local option, else 0
- ``auth_option_id`` - Option id from ``phpbb_acl_options``
- ``auth_role_id`` - Role id from ``phpbb_acl_roles`` if obtained from a role, else 0
- ``auth_setting`` - Stores either ``ACL_YES`` (1), ``ACL_NO`` (-1) or ``ACL_NEVER`` (0)

Checking permissions
====================

A user's permission can be checked by calling ``$auth->acl_get('u_garage_browse');``. The argument is the option
you want to check for. If it is specific to a forum (i.e local) then you call it as ``$auth->acl_get('u_garage_browse', 3);``
where ``3`` is the forum id.

For forums one can use the forum specific call ``$auth->acl_getf('f_your_permission');``.

It is also possible to check for more than one option:

.. code-block:: php

    $auth->acl_gets(option1[, option2, ..., optionN, $forumId]);
