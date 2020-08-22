===========
Module Tool
===========

The module tool allows you to add or remove modules in the ucp, mcp, or acp.

Add Module
==========

Add a new module

.. code-block:: php

    ['module.add', [ mixed $class [, mixed $parent [, array $data [, mixed $include_path ]]] ]]

.. csv-table::
   :header: "Parameter", "Required/Default", "Usage"
   :delim: |

   class | Required | The module class: acp, mcp, or ucp
   parent | default 0 | The parent module_id or module_langname (0 for no parent)
   data | default [] | An array of the data on the new module. This can be setup in two different ways. (see below)
   include_path | default false | Optionally specify a custom include path (only works when using the automatic module add method)

Manually specifying module info
-------------------------------

The "manual" way for inserting a category or one module at a time. It will be
merged with the base array shown a bit below, but at the very least requires
``module_langname`` to be sent, and, if you want to create a module (instead of
just a category) you must send ``module_basename`` and ``module_mode``.

.. code-block:: php

    $data = [
        'module_enabled'    => 1,
        'module_display'    => 1,
        'module_basename'   => '',
        'module_class'      => $class,
        'parent_id'         => (int) $parent,
        'module_langname'   => '',
        'module_mode'       => '',
        'module_auth'       => '',
    ];

Automatically determining module info
-------------------------------------

The "automatic" way. For inserting multiple modules at a time based on the specs
in the ``_info`` file for the module(s). For this to work the modules must be
correctly setup in the ``_info`` file. An example follows (this would insert the
settings, log, and flag modes from the ``includes/acp/info/acp_asacp.php``
file):

.. code-block:: php

    $data = [
        'module_basename'   => 'acp_asacp',
        'modes'             => ['settings', 'log', 'flag'],
    ];

Optionally you may omit 'modes' and it will insert all of the modules in that
info file.

Example
-------

.. code-block:: php

    public function update_data()
    {
        return [
            // Add a new category named ACP_CAT_TEST_MOD to ACP_CAT_DOT_MODS
            ['module.add', [
                'acp',
                'ACP_CAT_DOT_MODS',
                'ACP_CAT_TEST_MOD'
           ]],

            // Add the settings and features modes from the acp_board module to the ACP_CAT_TEST_MOD category using the "automatic" method.
            ['module.add', [
                'acp',
                'ACP_CAT_TEST_MOD',
                [
                    'module_basename'       => 'acp_board',
                    'modes'                 => ['settings', 'features'],
                ],
            ]],

            // Add the avatar mode from acp_board to the ACP_CAT_TEST_MOD category using the "manual" method.
            ['module.add', [
                'acp',
                'ACP_CAT_TEST_MOD',
                [
                    'module_basename'   => 'acp_board',
                    'module_langname'   => 'ACP_AVATAR_SETTINGS',
                    'module_mode'       => 'avatar',
                    'module_auth'       => 'acl_a_board && ext_vendor/name',
                ],
            ]],
        ];
    }

Remove Module
=============

.. code-block:: php

    ['module.remove', [ mixed $class [, mixed $parent [, array $data [, mixed $include_path ]]] ]]

Parameters
----------

.. csv-table::
   :header: "Parameter", "Required/Default", "Usage"
   :delim: |

   class | Required | The module class: acp, mcp, or ucp
   parent | default 0 | The parent module_id or module_langname (0 for no parent)
   module | default '' | The module_id or module_langname of the module to remove (more information below)
   include_path | default false | Optionally specify a custom include path (only works when using the automatic module add method)

Manually specifying module info
-------------------------------

The "manual" way. When removing the module using the manual method you may
specify a string (module_langname) or an integer (module_id)

Automatically determining module info
-------------------------------------

The "automatic" way. When removing the module using the automatic method you
may use the same information sent through the $data array when using the
automatic method of the module_add function. Just as with the automatic add
method, this will automatically find the modules listed according to the given
module_basename and modes from the _info file.

Example
-------

.. code-block:: php

    public function update_data()
    {
        return [
            // Remove the avatar mode from acp_board to the ACP_CAT_TEST_MOD category using the "manual" method.
            ['module.remove', [
                'acp',
                'ACP_CAT_TEST_MOD',
                [
                    'module_basename'   => 'acp_board',
                    'module_langname'   => 'ACP_AVATAR_SETTINGS',
                    'module_mode'       => 'avatar',
                    'module_auth'       => 'acl_a_board && ext_vendor/name',
                ],
            ]],

            // Remove the settings and features modes from the acp_board module to the ACP_CAT_TEST_MOD category using the "automatic" method.
            ['module.remove', [
                'acp',
                'ACP_CAT_TEST_MOD',
                [
                    'module_basename'       => 'acp_board',
                    'modes'                 => ['settings', 'features'],
                ],
            ]],

            // Remove a new category named ACP_CAT_TEST_MOD to ACP_CAT_DOT_MODS
            ['module.remove', [
                'acp',
                'ACP_CAT_DOT_MODS',
                'ACP_CAT_TEST_MOD'
            ]],
        ];
    }
