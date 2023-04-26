=====================
Tutorial: Permissions
=====================

Introduction
============

The permission system in phpBB is used to control access to different parts of the software. It works by allowing administrators to assign certain permissions to user groups or individual users, which determine what actions they are able to perform.

  1. `Create permissions`_ with a migration.
  2. `Define permissions`_ with language keys.
  3. `Wire up permissions`_ with events.
  4. `Checking permissions`_ with PHP.
  5. `Understanding Permissions`_ in phpBB.

Create permissions
==================

There are four permission types:

  - ``a_*`` Administrator
  - ``m_*`` Moderator
  - ``u_*`` User
  - ``f_*`` Forum

You can create new permissions for each of these types and assign them
to user groups or permission roles. You can also define new roles to
assign your permissions to if desired.

Permissions must first be created in a migration using the :doc:`../migrations/tools/permission`.
It helps with adding, removing, setting, and unsetting permissions and adding
or removing permission roles. For example, to create a new User permission
``u_foo_bar`` and set it to ``YES`` for the Registered Users group and
the Standard User Role:

.. code-block:: php

    return [
        ['permission.add', ['u_foo_bar']],
        ['permission.permission_set', ['REGISTERED', 'u_foo_bar', 'group']],
        ['permission.permission_set', ['ROLE_USER_STANDARD', 'u_foo_bar']],
    ];

Define permissions
==================

Permissions must have a corresponding language key definition. All language
keys for permissions should be placed in a language file that starts with
``permissions_`` and the keys will be automatically loaded into the ACP
language array. For example, the language file ``permissions_foobar.php``:

.. code-block:: php

    $lang = array_merge($lang, [
        'ACL_U_FOOBAR' => 'Can post foobars',
    ]);

Wire up permissions
===================

Wiring up permissions simply refers to making phpBB aware of your new
permissions by adding them to the permission data array. The array uses
the permission name as its key and an array value defining the permission's
language key and the category it should belong to.

This is done in an event listener using the ``core.permissions`` event to
add your new permissions to phpBB's permission data array:

.. code-block:: php

    $event->update_subarray('permissions', 'u_foo_bar', ['lang' => 'ACL_U_FOOBAR', 'cat' => 'post']);

.. warning::

    In order to support phpBB 3.2.1 or earlier versions, you can not use the ``update_subarray()`` method, and must instead use the following older style of code:

    .. code-block:: php

        # Wiring permissions the correct way for phpBB 3.1.0 - 3.2.1
        $permissions = $event['permissions'];
        $permissions['u_foo_bar'] = ['lang' => 'ACL_U_FOOBAR', 'cat' => 'post'];
        $event['permissions'] = $permissions;

        # Notice that the above permissions $event variable must first be copied by assigning it to a
        # local variable, then modified, and then copied back. This is because the event variables are
        # overloaded, which is a limitation in PHP. For example, this shortcut will not work:
        $event['permissions']['u_foo_bar'] = ['lang' => 'ACL_U_FOOBAR', 'cat' => 'post'];

Checking permissions
====================

A user's permission can be checked by calling ``$auth->acl_get()``:

.. code-block:: php

    // Check a user's permissions
    $auth->acl_get('u_foo_bar');

If it is specific to a forum (i.e local) then pass it the forum ID as a second argument:

.. code-block:: php

    // Check a user's permission in the forum with ID 3
    $auth->acl_get('u_foo_bar', 3);

For forums one can use the forum specific call ``$auth->acl_getf()``:

.. code-block:: php

    // Check a forum's permissions
    $auth->acl_getf('f_your_permission');

It is also possible to check for more than one option with ``acl_gets()``:

.. code-block:: php

    $auth->acl_gets('permission1'[, 'permission2', ..., 'permissionNth'], $forumId);

.. note::

    When checking permissions, it's also important to keep in mind whether the global or local permissions should be checked.
    If ``acl_get`` is called without a forum id, the global permissions will be used. Instead, passing a forum id will also
    check the local permissions which can then potentially override a ``NO`` with a ``YES``.
    After checking all user, group, forum, and global permissions, the return permission is always either ``YES`` or ``NO``,
    ``NEVER`` is only used to enforce a ``NO``.

Understanding Permissions
=========================

Permissions in phpBB control what actions users are allowed to perform on the forum, such as creating a new topic, replying to a post, or editing a user’s profile. Each permission is assigned a value of ``YES``, ``NO``, or ``NEVER``.

- ``YES`` means that the user or group is allowed to perform the action.
- ``NO`` means that the user or group is not allowed to perform the action, but it can be overruled by a ``YES`` from a group or role they are assigned to.
- ``NEVER`` means that the user or group is not allowed to perform the action and cannot be overruled by a ``YES`` from a group or role they are assigned to.

When a user requests to perform an action, phpBB combines all the permissions assigned to the user through their groups, roles, and direct permission assignments. If any permission is set to ``NEVER``, it overrides all other permissions and denies the user access to that action. If a permission is set to ``NO``, it can be overridden by a ``YES`` permission from another group or role.

Permission Types
----------------

There are four types of permissions in phpBB:

- ``a_*`` Administrator: These permissions are applied to users who are assigned administrator roles.
- ``f_*`` Forum: These permissions are applied to individual forums and can be set for each user group or individual user.
- ``m_*`` Moderator: These permissions are applied to users who are assigned moderator roles for specific forums.
- ``u_*`` User: These permissions are applied to individual users and override the permissions set for their user group.

Local and Global Permissions
----------------------------

Permissions can be set to apply locally or globally. Local permissions are specific to a single forum, while global permissions apply to the entire board. By default, forum permissions are set to local. Administrator and User permissions are typically set to global.

Permission options can also be set to apply both locally and globally, which is typical for Moderator permissions. This allows some users to be granted the permission on a single forum, while others might be granted the permission board-wide.

Roles
-----

Roles are a predefined set of permission options that can be applied to users or groups. When the permission options of a role are changed, the users or groups assigned that role are automatically updated.

The effective permission for any option is determined by a combination of the user's group membership, assigned roles, and direct permission assignments. In some cases, opposing permissions may exist, which can lead to unexpected results. It's important to carefully consider the permission settings to ensure that users are granted the appropriate level of access on the forum.
