======================
Tutorial: Parsing text
======================

Database fields
===============
phpBB uses the following database fields where BBCode is allowed (forum description, forum rules, post content, ...):

- **foo** - Text itself
- **foo_bbcode_uid** - a randomly generated unique identifier to mark the BBCodes and used for quicker parsing
- **foo_bbcode_bitfield** - a `bit field <https://en.wikipedia.org/wiki/Bit_field>`_ containing the information which bbcode is used in the text so only the relevant ones need to be loaded from the database.
- **foo_options** - a bit field containing the information whether bbcode, smilies and magic urls are enabled (OPTION_FLAG_BBCODE, OPTION_FLAG_SMILIES and OPTION_FLAG_LINKS). Sometimes you will find this separated into enable_bbcode, enable_smilies and enable_magic_url

Column names will vary, replace ``foo`` with the respective column name (e.g. ``text``, ``text_bbcode_uid``, ...).

Parsing text with BBCodes & smilies
===================================

Inserting text into DB
----------------------

.. code-block:: php

    $text = $this->request->variable('text', '', true);
    $uid = $bitfield = $options = ''; // will be modified by generate_text_for_storage
    $allow_bbcode = $allow_urls = $allow_smilies = true;
    generate_text_for_storage($text, $uid, $bitfield, $options, $allow_bbcode, $allow_urls, $allow_smilies);

    $sql_ary = array(
        'text'              => $text,
        'bbcode_uid'        => $uid,
        'bbcode_bitfield'   => $bitfield,
        'bbcode_options'    => $options,
    );

    $sql = 'INSERT INTO ' . YOUR_TABLE . ' ' . $this->db->sql_build_array('INSERT', $sql_ary);
    $this->db->sql_query($sql);

The above method uses the bbcode options database field which is used in many places instead of enable_smiles,
enable_bbcode and enable_magic_url. Here is how to insert it into the database using the enable_smilies, enable_bbcode
and enable_magic_url tables.

.. code-block:: php

    $text = $this->request->variable('text', '', true);
    $uid = $bitfield = $options = ''; // will be modified by generate_text_for_storage
    $allow_bbcode = $allow_urls = $allow_smilies = true;
    generate_text_for_storage($text, $uid, $bitfield, $options, $allow_bbcode, $allow_urls, $allow_smilies);

    $sql_ary = array(
        'text'              => $text,
        'bbcode_uid'        => $uid,
        'bbcode_bitfield'   => $bitfield,
        'enable_bbcode'     => $allow_bbcode,
        'enable_magic_url'  => $allow_urls,
        'enable_smilies'    => $allow_smilies,
    );

    $sql = 'INSERT INTO ' . YOUR_TABLE . ' ' . $this->db->sql_build_array('INSERT', $sql_ary);
    $this->db->sql_query($sql);

Displaying text from DB
-----------------------

This example uses the bbcode_options field which is used in forums and groups description parsing:

.. code-block:: php

    $sql = 'SELECT text, bbcode_uid, bbcode_bitfield, bbcode_options
        FROM ' . YOUR_TABLE;
    $result = $this->db->sql_query($sql);
    $row = $this->db->sql_fetchrow($result);
    $this->db->sql_freeresult($result);

    $text = generate_text_for_display($row['text'], $row['bbcode_uid'], $row['bbcode_bitfield'], $row['bbcode_options']);

    $this->template->assign_vars([
        'TEXT'  => $text,
    ]);

The next one uses the enable_bbcode, enable_smilies and enable_magic_url flags which can be used instead of the above method and is used in parsing posts:

.. code-block:: php

    $sql = 'SELECT text, bbcode_uid, bbcode_bitfield, enable_bbcode, enable_smilies, enable_magic_url
        FROM ' . YOUR_TABLE;
    $result = $this->db->sql_query($sql);
    $row = $this->db->sql_fetchrow($result);
    $this->db->sql_freeresult($result);

    $row['bbcode_options'] = (($row['enable_bbcode']) ? OPTION_FLAG_BBCODE : 0) +
        (($row['enable_smilies']) ? OPTION_FLAG_SMILIES : 0) +
        (($row['enable_magic_url']) ? OPTION_FLAG_LINKS : 0);
    $text = generate_text_for_display($row['text'], $row['bbcode_uid'], $row['bbcode_bitfield'], $row['bbcode_options']);

    $this->template->assign_vars([
        'TEXT'  => $text,
    ]);

Generating text for editing
---------------------------

.. code-block:: php

    $sql = 'SELECT text, bbcode_uid, bbcode_options
        FROM ' . YOUR_TABLE;
    $result = $this->db->sql_query_limit($sql, 1);
    $row = $this->db->sql_fetchrow($result);
    $this->db->sql_freeresult($result);

    $post_data = generate_text_for_edit($row['text'], $row['bbcode_uid'], $row['bbcode_options']);

    $this->template->assign_vars([
        'POST_TEXT'         => $post_data['text'],
        'S_ALLOW_BBCODES'   => $post_data['allow_bbcode'],
        'S_ALLOW_SMILIES'   => $post_data['allow_smilies'],
        'S_ALLOW_URLS'      => $post_data['allow_urls'],
    ]);

Database fields for BBCode
--------------------------

The following column definitions are expected for BBCodes:

.. code-block::

    "text": [
        "MTEXT_UNI",
        "" // Default empty string
    ],
    "bbcode_uid": [
        "VCHAR:8",
        "" // Default empty string
    ],
    "bbcode_bitfield": [
        "VCHAR:255",
        "" // Default empty string
    ],
    "bbcode_options": [
        "UINT:11",
        7 // Default all enabled
    ],
