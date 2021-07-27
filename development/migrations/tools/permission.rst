===============
Permission Tool
===============

The permission tool helps with adding and removing permissions, setting and
unsetting permissions, and adding and removing permission roles.

Add Permission
==============

Add a new permission

.. code-block:: php

    ['permission.add', [permission name, global (default: true) , copy from (default: false) ]],

Example
-------

.. code-block:: php

    public function update_data()
    {
        return [
             ['permission.add', ['a_new']], // New global admin permission a_new
             ['permission.add', ['m_new']], // New global moderator permission m_new
             ['permission.add', ['m_new', false]], // New local moderator permission m_new
             ['permission.add', ['u_new']], // New global user permission u_new
             ['permission.add', ['u_new', false]], // New local user permission u_new

             ['permission.add', ['a_copy', true, 'a_existing']], // New global admin permission a_copy, copies permission settings from a_existing
        ];
    }

Delete Permission
=================

Delete a permission

.. code-block:: php

    ['permission.remove', [permission name, global (default: true) ]],

Example
-------

.. code-block:: php

    public function update_data()
    {
        return [
             ['permission.remove', ['a_new']], // Remove global admin permission a_new
             ['permission.remove', ['m_new']], // Remove global moderator permission m_new
             ['permission.remove', ['m_new', false]], // Remove local moderator permission m_new
             ['permission.remove', ['u_new']], // Remove global user permission u_new
             ['permission.remove', ['u_new', false]], // Remove local user permission u_new
        ];
    }

Add Role
========
Add a new permission role

.. code-block:: php

    ['permission.role_add', [role name, role type (u_, m_, a_), role description]],

Example
-------

.. code-block:: php

    public function update_data()
    {
        return [
             ['permission.role_add', ['new admin role', 'a_', 'a new role for admins']], // New role "new admin role"
             ['permission.role_add', ['new moderator role', 'm_', 'a new role for moderators']], // New role "new moderator role"
             ['permission.role_add', ['new user role', 'u_', 'a new role for users']], // New role "new user role"
        ];
    }

Update Permission Role
======================

Update a permission role

.. code-block:: php

    ['permission.role_update', [old role name, new role name]],

Example
-------

.. code-block:: php

    public function update_data()
    {
        return [
             ['permission.role_update', ['new admin role', 'new name for admin role']], // Rename "new admin role" to "new name for admin role"
        ];
    }

Remove Role
===========

Remove a permission role

.. code-block:: php

    ['permission.role_remove', [role name]],

Example
-------

.. code-block:: php

    public function update_data()
    {
        return [
             ['permission.role_remove', ['new admin role']], // Remove role "new admin role"
             ['permission.role_remove', ['new moderator role']], // Remove role "new moderator role"
             ['permission.role_remove', ['new user role']], // Remove role "new user role"
        ];
    }

Permission Set
==============

Set a permission (to Yes or Never)

.. code-block:: php

    ['permission.permission_set', [role/group name, permission name(s), type ('role', 'group', default: role), has permission (default: true) ]],

Example
-------

.. code-block:: php

    public function update_data()
    {
        return [
             ['permission.permission_set', ['ROLE_ADMIN_FULL', 'a_new']], // Give ROLE_ADMIN_FULL a_new permission
             ['permission.permission_set', ['ROLE_ADMIN_FULL', 'a_new2', 'role', false]], // Set a_new2 to never for ROLE_ADMIN_FULL
             ['permission.permission_set', ['REGISTERED', 'u_new', 'group']], // Give REGISTERED users u_new permission
        ];
    }


Permission Unset
================

Remove a permission (set to No)

.. code-block:: php

    ['permission.permission_unset', [role/group name, permission name(s), type ('role', 'group', default: role) ]],

Example
-------

.. code-block:: php

    public function update_data()
    {
        return [
             ['permission.permission_unset', ['ROLE_ADMIN_FULL', 'a_new']], // Remove a_new permission from role ROLE_ADMIN_FULL
             ['permission.permission_unset', ['REGISTERED', 'u_new', 'group']], // Remove u_new permission from group REGISTERED
        ];
    }

Role Exists
===========
Check if a permission role exists before attempting to set/unset permissions on it

.. code-block:: php

    ['permission.role_exists', [role name]],

Example
-------

.. code-block:: php

    public function update_data()
    {
        return [
            ['if', [
                ['permission.role_exists', ['ROLE_ADMIN_FULL']], // Check if ROLE_ADMIN_FULL exists before updating it
                ['permission.permission_set', ['ROLE_ADMIN_FULL', 'a_new']], // Give ROLE_ADMIN_FULL a_new permission
            ]],

            ['if', [
                ['permission.role_exists', ['ROLE_MOD_FULL']], // Check if ROLE_MOD_FULL exists before updating it
                ['permission.permission_unset', ['ROLE_MOD_FULL', 'm_new']], // Remove m_new permission from role ROLE_MOD_FULL
            ]],
        ];
    }
