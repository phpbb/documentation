1. Defaults
===========

1.i. Editor Settings
--------------------

Tabs vs Spaces
+++++++++++++++

In order to make this as simple as possible, we will be using tabs, not spaces. We enforce 4 (four) spaces for one tab - therefore you need to set your tab width within your editor to 4 spaces. Make sure that when you **save** the file, it's saving tabs and not spaces. This way, we can each have the code be displayed the way we like it, without breaking the layout of the actual files.

Tabs in front of lines are no problem, but having them within the text can be a problem if you do not set it to the amount of spaces every one of us uses. Here is a short example of how it should look like:

.. code:: php

    {TAB}$mode{TAB}{TAB}= $request->variable('mode', '');
    {TAB}$search_id{TAB}= $request->variable('search_id', '');

If entered with tabs (replace the {TAB}) both equal signs need to be on the same column.

Linefeeds
++++++++++

Ensure that your editor is saving files in the UNIX (LF) line ending format. This means that lines are terminated with a newline, not with Windows Line endings (CR/LF combo) as they are on Win32 or Classic Mac (CR) Line endings. Any decent editor should be able to do this, but it might not always be the default setting. Know your editor. If you want advice for an editor for your Operating System, just ask one of the developers. Some of them do their editing on Win32.

1.ii. File Layout
-----------------

Standard header for new files:
This template of the header must be included at the start of all phpBB files:

.. code:: php

    /**
    *
    * This file is part of the phpBB Forum Software package.
    *
    * @copyright (c) phpBB Limited <https://www.phpbb.com>
    * @license GNU General Public License, version 2 (GPL-2.0)
    *
    * For full copyright and license information, please see
    * the docs/CREDITS.txt file.
    *
    */

Please see the `1.iii. File Locations`_ section for the correct package name.

PHP closing tags
++++++++++++++++

A file containg only PHP code should not end with the optional PHP closing tag ``?>`` to avoid issues with whitespace following it.

Newline at end of file
++++++++++++++++++++++

All files should end in a newline so the last line does not appear as modified in diffs, when a line is appended to the file.

Files containing inline code
++++++++++++++++++++++++++++

For those files you have to put an empty comment directly after the header to prevent the documentor assigning the header to the first code element found.

.. code:: php

    /**
    * {HEADER}
    */

    /**
    */
    {CODE}

Files containing only functions
+++++++++++++++++++++++++++++++

Do not forget to comment the functions (especially the first function following the header). Each function should have
at least a comment of what this function does. For more complex functions it is recommended to document the parameters too.

Files containing only classes
+++++++++++++++++++++++++++++

Do not forget to comment the class. Classes need a separate @package definition, it is the same as the header package
name. Apart from this special case the above statement for files containing only functions needs to be applied to
classes and it's methods too.

Code following the header but only functions/classes file
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++

If this case is true, the best method to avoid documentation confusions is adding an ignore command, for example:

.. code:: php

    /**
    * {HEADER}
    */

    /**
    * @ignore
    */
    Small code snipped, mostly one or two defines or an if statement

    /**
    * {DOCUMENTATION}
    */
    class ...

1.iii. File Locations
---------------------

Functions used by more than one page should be placed in functions.php, functions specific to one page should be placed on that page (at the bottom) or within the relevant sections functions file. Some files in /includes are holding functions responsible for special sections, for example uploading files, displaying "things", user related functions and so forth.

The following packages are defined, and related new features/functions should be placed within the mentioned files/locations, as well as specifying the correct package name. The package names are bold within this list:

**phpBB3**
Core files and all files not assigned to a separate package
**acm**
``/phpbb/cache``
Cache System
**acp**
``/adm``, ``/includes/acp``, ``/includes/functions_admin.php``
Administration Control Panel
**dbal**
``/phpbb/db``, ``/includes/db``
Database Abstraction Layer.
``/phpbb/db/driver/``
Database Abstraction Layer classes
``/phpbb/db/migration/``
Migrations are used for updating the database from one release to another
**diff**
``/includes/diff``
Diff Engine
**images**
``/images``
All global images not connected to styles
**install**
``/install``
Installation System
**language**
``/language``
All language files
**login**
``/phpbb/auth``
Login Authentication Plugins
**VC**
``/includes/captcha``
CAPTCHA
**mcp**
``mcp.php``, ``/includes/mcp``, ``report.php``
Moderator Control Panel
**ucp**
``ucp.php``, ``/includes/ucp``
User Control Panel
**utf**
``/includes/utf``
UTF8-related functions/classes
**search**
``/phpbb/search``, ``search.php``
Search System
**styles**
``/styles``
phpBB Styles/Templates/Themes

1.iv. Special Constants
-----------------------

There are some special constants application developers are able to utilize to bend some of phpBB's internal functionality to suit their needs.

.. code:: php

    PHPBB_MSG_HANDLER          (overwrite message handler)
    PHPBB_DB_NEW_LINK          (overwrite new_link parameter for sql_connect)
    PHPBB_ROOT_PATH            (overwrite $phpbb_root_path)
    PHPBB_ADMIN_PATH           (overwrite $phpbb_admin_path)
    PHPBB_USE_BOARD_URL_PATH   (use generate_board_url() for image paths instead of $phpbb_root_path)
    PHPBB_DISABLE_ACP_EDITOR   (disable ACP style editor for templates)
    PHPBB_DISABLE_CONFIG_CHECK (disable ACP config.php writeable check)

    PHPBB_ACM_MEMCACHE_PORT     (overwrite memcached port, default is 11211)
    PHPBB_ACM_MEMCACHE_COMPRESS (overwrite memcached compress setting, default is disabled)
    PHPBB_ACM_MEMCACHE_HOST     (overwrite memcached host name, default is localhost)

    PHPBB_ACM_REDIS_HOST        (overwrite redis host name, default is localhost)
    PHPBB_ACM_REDIS_PORT        (overwrite redis port, default is 6379)
    PHPBB_ACM_REDIS_PASSWORD    (overwrite redis password, default is empty)
    PHPBB_ACM_REDIS_DB          (overwrite redis default database)

    PHPBB_QA                   (Set board to QA-Mode, which means the updater also checks for RC-releases)

PHPBB_USE_BOARD_URL_PATH
++++++++++++++++++++++++

If the ``PHPBB_USE_BOARD_URL_PATH`` constant is set to true, phpBB uses generate_board_url() (this will return the boards url with the script path included) on all instances where web-accessible images are loaded. The exact locations are:

- /phpbb/user.php - \phpbb\user::img()
- /includes/functions_content.php - smiley_text()

Path locations for the following template variables are affected by this too:

- {T_ASSETS_PATH} - assets (non-style specific, static resources)
- {T_THEME_PATH} - styles/xxx/theme
- {T_TEMPLATE_PATH} - styles/xxx/template
- {T_SUPER_TEMPLATE_PATH} - styles/xxx/template
- {T_IMAGES_PATH} - images/
- {T_SMILIES_PATH} - $config['smilies_path']/
- {T_AVATAR_GALLERY_PATH} - $config['avatar_gallery_path']/
- {T_ICONS_PATH} - $config['icons_path']/
- {T_RANKS_PATH} - $config['ranks_path']/
- {T_UPLOAD_PATH} - $config['upload_path']/
- {T_STYLESHEET_LINK} - styles/xxx/theme/stylesheet.css
- New template variable {BOARD_URL} for the board url + script path.
