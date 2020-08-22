==============
Schema changes
==============

Schema changes are done in Migrations by creating an array that will be parsed
by ``\phpbb\db\tools::perform_schema_changes()``.

Basics
======
When performing schema changes, your Migrations class should contain two
functions, ``update_schema`` and ``revert_schema``.

update_schema
-------------
``update_schema()`` will be called as the **first** step when installing a
migration. This makes any database schema changes you need when installing the
migration.

.. code-block:: php

    public function update_schema()
    {
        return [];
    }

revert_schema
-------------

``revert_schema()`` will be called when a Migration must be uninstalled (this
could happen if the user wants/needs to revert changes by the Migration, a
dependency is reverted, or the installation fails and the entire Migration is
removed).

The instructions in ``revert_schema()`` should effectively do the exact
opposite of what ``update_schema()`` does (e.g. if a table is dropped, revert
should add the table with exactly the same columns/keys as it had before it
was dropped)

.. code-block:: php

    public function revert_schema()
    {
        return [];
    }

What to return
==============
The array returned is passed directly, as is, to
``\phpbb\db\tools::perform_schema_changes();``

Examples
--------

**From 3_1_0_dev:**

.. code-block:: php

    public function update_schema()
    {
        return [
            'add_columns'        => [
                $this->table_prefix . 'groups'        => [
                    'group_teampage'    => ['UINT', 0, 'after' => 'group_legend'],
                ],
                $this->table_prefix . 'styles'        => [
                    'style_path'             => ['VCHAR:100', ''],
                    'bbcode_bitfield'        => ['VCHAR:255', 'kNg='],
                    'style_parent_id'        => ['UINT:4', 0],
                    'style_parent_tree'      => ['TEXT', ''],
                ],
            ],
            'change_columns'    => [
                $this->table_prefix . 'groups'        => [
                    'group_legend'        => ['UINT', 0],
                ],
            ],
        ];
    }

    public function revert_schema()
    {
        return [
            'drop_columns'        => [
                $this->table_prefix . 'groups'        => [
                    'group_teampage',
                ],
                $this->table_prefix . 'styles'        => [
                    'style_path',
                    'bbcode_bitfield',
                    'style_parent_id',
                    'style_parent_tree',
                ],
            ],
        ];
    }

**From style_update_p2:**

.. code-block:: php

    public function update_schema()
    {
        return [
            'drop_columns'    => [
                $this->table_prefix . 'styles'        => [
                    'imageset_id',
                    'template_id',
                    'theme_id',
                ],
            ],

            'drop_tables'    => [
                $this->table_prefix . 'styles_imageset',
                $this->table_prefix . 'styles_imageset_data',
            ],
        ];
    }

    public function revert_schema()
    {
        return [
            'add_columns'    => [
                $this->table_prefix . 'styles' => [
                    'imageset_id'    => ['UINT', 0],
                    'template_id'    => ['UINT', 0],
                    'theme_id'       => ['UINT', 0],
                ],
            ],

            'add_tables'    => [
                $this->table_prefix . 'styles_imageset' => [
                    'COLUMNS' => [
                        'imageset_id'                => ['UINT', NULL, 'auto_increment'],
                        'imageset_name'              => ['VCHAR_UNI:255', ''],
                        'imageset_copyright'         => ['VCHAR_UNI', ''],
                        'imageset_path'              => ['VCHAR:100', ''],
                    ],
                    'PRIMARY_KEY' => 'imageset_id',
                    'KEYS' => [
                        'imgset_nm'            => ['UNIQUE', 'imageset_name'],
                    ],
                ],
                $this->table_prefix . 'styles_imageset_data' => [
                    'COLUMNS' => [
                        'image_id'              => ['UINT', NULL, 'auto_increment'],
                        'image_name'            => ['VCHAR:200', ''],
                        'image_filename'        => ['VCHAR:200', ''],
                        'image_lang'            => ['VCHAR:30', ''],
                        'image_height'          => ['USINT', 0],
                        'image_width'           => ['USINT', 0],
                        'imageset_id'           => ['UINT', 0],
                    ],
                    'PRIMARY_KEY' => 'image_id',
                    'KEYS' => [
                        'i_d'            => ['INDEX', 'imageset_id'],
                    ],
                ],
            ],
        ];
    }
