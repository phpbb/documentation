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
migration, this makes any database schema changes you need when installing the
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
                $this->table_prefix . 'profile_fields'    => array(
                    'field_show_on_pm'        => array('BOOL', 0),
                ),
                $this->table_prefix . 'styles'        => array(
                    'style_path'            => array('VCHAR:100', ''),
                    'bbcode_bitfield'        => array('VCHAR:255', 'kNg='),
                    'style_parent_id'        => array('UINT:4', 0),
                    'style_parent_tree'        => array('TEXT', ''),
                ),
                $this->table_prefix . 'reports'        => array(
                    'reported_post_text'        => array('MTEXT_UNI', ''),
                    'reported_post_uid'            => array('VCHAR:8', ''),
                    'reported_post_bitfield'    => array('VCHAR:255', ''),
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
                $this->table_prefix . 'profile_fields'    => array(
                    'field_show_on_pm',
                ),
                $this->table_prefix . 'styles'        => array(
                    'style_path',
                    'bbcode_bitfield',
                    'style_parent_id',
                    'style_parent_tree',
                ),
                $this->table_prefix . 'reports'        => array(
                    'reported_post_text',
                    'reported_post_uid',
                    'reported_post_bitfield',
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
                $this->table_prefix . 'styles_template',
                $this->table_prefix . 'styles_template_data',
                $this->table_prefix . 'styles_theme',
            ),
        );
    }

    public function revert_schema()
    {
        return array(
            'add_columns'    => array(
                $this->table_prefix . 'styles'        => array(
                    'imageset_id'    => array('UINT', 0),
                    'template_id'    => array('UINT', 0),
                    'theme_id'        => array('UINT', 0),
                ),
            ),

            'add_tables'    => array(
                $this->table_prefix . 'styles_imageset'        => array(
                    'COLUMNS'        => array(
                        'imageset_id'                => array('UINT', NULL, 'auto_increment'),
                        'imageset_name'                => array('VCHAR_UNI:255', ''),
                        'imageset_copyright'        => array('VCHAR_UNI', ''),
                        'imageset_path'                => array('VCHAR:100', ''),
                    ),
                    'PRIMARY_KEY'        => 'imageset_id',
                    'KEYS'                => array(
                        'imgset_nm'            => array('UNIQUE', 'imageset_name'),
                    ),
                ),
                $this->table_prefix . 'styles_imageset_data'    => array(
                    'COLUMNS'        => array(
                        'image_id'                => array('UINT', NULL, 'auto_increment'),
                        'image_name'            => array('VCHAR:200', ''),
                        'image_filename'        => array('VCHAR:200', ''),
                        'image_lang'            => array('VCHAR:30', ''),
                        'image_height'            => array('USINT', 0),
                        'image_width'            => array('USINT', 0),
                        'imageset_id'            => array('UINT', 0),
                    ),
                    'PRIMARY_KEY'        => 'image_id',
                    'KEYS'                => array(
                        'i_d'            => array('INDEX', 'imageset_id'),
                    ),
                ),
                $this->table_prefix . 'styles_template'        => array(
                    'COLUMNS'        => array(
                        'template_id'            => array('UINT', NULL, 'auto_increment'),
                        'template_name'            => array('VCHAR_UNI:255', ''),
                        'template_copyright'    => array('VCHAR_UNI', ''),
                        'template_path'            => array('VCHAR:100', ''),
                        'bbcode_bitfield'        => array('VCHAR:255', 'kNg='),
                        'template_storedb'        => array('BOOL', 0),
                        'template_inherits_id'        => array('UINT:4', 0),
                        'template_inherit_path'        => array('VCHAR', ''),
                    ),
                    'PRIMARY_KEY'    => 'template_id',
                    'KEYS'            => array(
                        'tmplte_nm'                => array('UNIQUE', 'template_name'),
                    ),
                ),
                $this->table_prefix . 'styles_template_data'    => array(
                    'COLUMNS'        => array(
                        'template_id'            => array('UINT', 0),
                        'template_filename'        => array('VCHAR:100', ''),
                        'template_included'        => array('TEXT', ''),
                        'template_mtime'        => array('TIMESTAMP', 0),
                        'template_data'            => array('MTEXT_UNI', ''),
                    ),
                    'KEYS'            => array(
                        'tid'                    => array('INDEX', 'template_id'),
                        'tfn'                    => array('INDEX', 'template_filename'),
                    ),
                ),
                $this->table_prefix . 'styles_theme'            => array(
                    'COLUMNS'        => array(
                        'theme_id'                => array('UINT', NULL, 'auto_increment'),
                        'theme_name'            => array('VCHAR_UNI:255', ''),
                        'theme_copyright'        => array('VCHAR_UNI', ''),
                        'theme_path'            => array('VCHAR:100', ''),
                        'theme_storedb'            => array('BOOL', 0),
                        'theme_mtime'            => array('TIMESTAMP', 0),
                        'theme_data'            => array('MTEXT_UNI', ''),
                    ),
                    'PRIMARY_KEY'    => 'theme_id',
                    'KEYS'            => array(
                        'theme_name'        => array('UNIQUE', 'theme_name'),
                    ),
                ),
            ),
        );
    }
