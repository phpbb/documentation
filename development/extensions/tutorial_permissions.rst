=====================
Tutorial: Permissions
=====================

Introduction
============

Adding new permissions in an extension is an easy three-step process:

  1. `Create permissions`_ with a migration.
  2. `Define permissions`_ with language keys.
  3. `Wire up permissions`_ with events.

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
``u_foo_bar`` and set it to "yes" for the Registered Users group and
the Standard User Role:

.. code-block:: php

    return array(
        array('permission.add', array('u_foo_bar')),
        array('permission.permission_set', array('REGISTERED', 'u_foo_bar', 'group')),
        array('permission.permission_set', array('ROLE_USER_STANDARD', 'u_foo_bar')),
    );

Define permissions
==================

Permissions must have a corresponding language key definition. All language
keys for permissions should be placed in a language file that starts with
``permissions_`` and the keys will be automatically loaded into the ACP
language array. For example, the language file ``permissions_foobar.php``:

.. code-block:: php

    $lang = array_merge($lang, array(
        'ACL_U_FOOBAR' => 'Can post foobars',
    ));

Wire up permissions
===================

Wiring up permissions simply refers to making phpBB aware of your new
permissions by adding them to the permission data array. The array uses
the permission name as its key and an array value defining the permission's
language key and the category it should belong to.

This is done in an event listener using the ``core.permissions`` event to
add your new permissions to phpBB's permission data array:

.. code-block:: php

    $permissions = $event['permissions'];
    $permissions['u_foo_bar'] = array('lang' => 'ACL_U_FOOBAR', 'cat' => 'post');
    $event['permissions'] = $permissions;

.. note::

    Note how the ``permissions`` event variable is first copied by assigning
    it to a local variable, then modified, and then copied back. This is because the event
    variables are overloaded, which is a limitation in PHP. For example, this shortcut
    will not work:

    .. code-block:: php

        $event['permissions']['u_foo_bar'] = array('lang' => 'ACL_U_FOOBAR', 'cat' => 'post');
