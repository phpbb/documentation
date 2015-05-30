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
        return array();
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
        return array();
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
        return array(
            'add_columns'        => array(
                $this->table_prefix . 'groups'        => array(
                    'group_teampage'    => array('UINT', 0, 'after' => 'group_legend'),
                ),
                $this->table_prefix . 'styles'        => array(
                    'style_path'             => array('VCHAR:100', ''),
                    'bbcode_bitfield'        => array('VCHAR:255', 'kNg='),
                    'style_parent_id'        => array('UINT:4', 0),
                    'style_parent_tree'      => array('TEXT', ''),
                ),
            ),
            'change_columns'    => array(
                $this->table_prefix . 'groups'        => array(
                    'group_legend'        => array('UINT', 0),
                ),
            ),
        );
    }

    public function revert_schema()
    {
        return array(
            'drop_columns'        => array(
                $this->table_prefix . 'groups'        => array(
                    'group_teampage',
                ),
                $this->table_prefix . 'styles'        => array(
                    'style_path',
                    'bbcode_bitfield',
                    'style_parent_id',
                    'style_parent_tree',
                ),
            ),
        );
    }

**From style_update_p2:**

.. code-block:: php

    public function update_schema()
    {
        return array(
            'drop_columns'    => array(
                $this->table_prefix . 'styles'        => array(
                    'imageset_id',
                    'template_id',
                    'theme_id',
                ),
            ),

            'drop_tables'    => array(
                $this->table_prefix . 'styles_imageset',
                $this->table_prefix . 'styles_imageset_data',
            ),
        );
    }

    public function revert_schema()
    {
        return array(
            'add_columns'    => array(
                $this->table_prefix . 'styles' => array(
                    'imageset_id'    => array('UINT', 0),
                    'template_id'    => array('UINT', 0),
                    'theme_id'       => array('UINT', 0),
                ),
            ),

            'add_tables'    => array(
                $this->table_prefix . 'styles_imageset' => array(
                    'COLUMNS' => array(
                        'imageset_id'                => array('UINT', NULL, 'auto_increment'),
                        'imageset_name'              => array('VCHAR_UNI:255', ''),
                        'imageset_copyright'         => array('VCHAR_UNI', ''),
                        'imageset_path'              => array('VCHAR:100', ''),
                    ),
                    'PRIMARY_KEY' => 'imageset_id',
                    'KEYS' => array(
                        'imgset_nm'            => array('UNIQUE', 'imageset_name'),
                    ),
                ),
                $this->table_prefix . 'styles_imageset_data' => array(
                    'COLUMNS' => array(
                        'image_id'              => array('UINT', NULL, 'auto_increment'),
                        'image_name'            => array('VCHAR:200', ''),
                        'image_filename'        => array('VCHAR:200', ''),
                        'image_lang'            => array('VCHAR:30', ''),
                        'image_height'          => array('USINT', 0),
                        'image_width'           => array('USINT', 0),
                        'imageset_id'           => array('UINT', 0),
                    ),
                    'PRIMARY_KEY' => 'image_id',
                    'KEYS' => array(
                        'i_d'            => array('INDEX', 'imageset_id'),
                    ),
                ),
            ),
        );
    }
