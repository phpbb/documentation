===============
Permission Tool
===============

The permission tool helps adding and removing permissions, setting and
unsetting permissions, and adding and removing permission roles.

Add Permission
==============

Add a new permission

.. code-block:: php

    array('permission.add', array(permission name, global (default: true) , copy from (default: false) )),

Example
-------

.. code-block:: php

    public function update_data()
    {
        return array(
             array('permission.add', array('a_new')), // New global admin permission a_new
             array('permission.add', array('m_new')), // New global moderator permission m_new
             array('permission.add', array('m_new', false)), // New local moderator permission m_new
             array('permission.add', array('u_new')), // New global user permission u_new
             array('permission.add', array('u_new', false)), // New local user permission u_new

             array('permission.add', array('a_copy', true, 'a_existing')), // New global admin permission a_copy, copies permission settings from a_existing
        );
    }

Delete Permission
=================

Delete a permission

.. code-block:: php

    array('permission.remove', array(permission name, global (default: true) )),

Example
-------

.. code-block:: php

    public function update_data()
    {
        return array(
             array('permission.remove', array('a_new')), // Remove global admin permission a_new
             array('permission.remove', array('m_new')), // Remove global moderator permission m_new
             array('permission.remove', array('m_new', false)), // Remove local moderator permission m_new
             array('permission.remove', array('u_new')), // Remove global user permission u_new
             array('permission.remove', array('u_new', false)), // Remove local user permission u_new
        );
    }

Add Role
========
Add a new permission role

.. code-block:: php

    array('permission.role_add', array(role name, role type (u_, m_, a_), role description )),

Example
-------

.. code-block:: php

    public function update_data()
    {
        return array(
             array('permission.role_add', array('new admin role', 'a_', 'a new role for admins')), // New role "new admin role"
             array('permission.role_add', array('new moderator role', 'm_', 'a new role for moderators')), // New role "new moderator role"
             array('permission.role_add', array('new user role', 'u_', 'a new role for users')), // New role "new user role"
        );
    }

Update Permission Role
======================

Update a permission role

.. code-block:: php

    array('permission.role_update', array(old role name, new role name )),

Example
-------

.. code-block:: php

    public function update_data()
    {
        return array(
             array('permission.role_update', array('new admin role', 'new name for admin role')), // Rename "new admin role" to "new name for admin role"
        );
    }

Remove Role
===========

Remove a permission role

.. code-block:: php

    array('permission.role_remove', array(role name)),

Example
-------

.. code-block:: php

    public function update_data()
    {
        return array(
             array('permission.role_remove', array('new admin role')), // Remove role "new admin role"
             array('permission.role_remove', array('new moderator role')), // Remove role "new moderator role"
             array('permission.role_remove', array('new user role')), // Remove role "new user role"
        );
    }

Permission Set
==============

Set a permission (to Yes or Never)

.. code-block:: php

    array('permission.permission_set', array(role/group name, permission name(s), type ('role', 'group', default: role), has permission (default: true) )),

Example
-------

.. code-block:: php

    public function update_data()
    {
        return array(
             array('permission.permission_set', array('ROLE_ADMIN_FULL', 'a_new')), // Give ROLE_ADMIN_FULL a_new permission
             array('permission.permission_set', array('ROLE_ADMIN_FULL', 'a_new2', 'role', false)), // Set a_new2 to never for ROLE_ADMIN_FULL
             array('permission.permission_set', array('REGISTERED', 'u_new', 'group')), // Give REGISTERED users u_new permission
        );
    }


Permission Unset
================

Remove a permission (set to No)

.. code-block:: php

    array('permission.permission_unset', array(role/group name, permission name(s), type ('role', 'group', default: role) )),

Example
-------

.. code-block:: php

    public function update_data()
    {
        return array(
             array('permission.permission_unset', array('ROLE_ADMIN_FULL', 'a_new')), // Remove a_new permission from role ROLE_ADMIN_FULL
             array('permission.permission_unset', array('REGISTERED', 'u_new', 'group')), // Remove u_new permission from group REGISTERED
        );
    }
