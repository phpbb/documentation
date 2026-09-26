================
Maintenance Page
================

Overview
========

The maintenance page in phpBB 4.0 is designed to be a "zero-dependency" interceptor page. It resides in ``includes/startup.php`` and triggers before the autoloader, database, session, or language systems are initialized.

This architecture ensures that even if the database is offline or core files are being overwritten during an update, the user is served a professional, localized maintenance page rather than a PHP error.

Functional Flow
---------------

1. **Detection**: The system checks for the existence of ``store/UPDATE_LOCK.php``.
2. **Execution**: If the file exists, ``send_maintenance_screen()`` is called.
3. **Data Loading**: The function ``include``'s the lock file to retrieve metadata.
4. **Rendering**: A static HTML/CSS page is output with the necessary data added as a JSON payload for client-side logic.
5. **Polling**: The page includes a ``<meta http-equiv="refresh" content="30">`` tag to refresh the page every 30 seconds and automatically reconnect the user once the lock file is removed.

The Update Lock File
====================

The ``store/UPDATE_LOCK.php`` is an auto-generated PHP array-export. It acts as the "source of truth" for the maintenance screen.

Data Schema
-----------

The file must return an associative array with the following structure:

initiated
    *(int)* Unix timestamp of the start of maintenance. Used by the frontend to calculate "Started on" strings.

config
    *(array)* Global metadata.

    * ``default_lang``: Fallback ISO language code, should be the default board language and fitting language strings **MUST** be provided for this language in the ``lang`` array.
    * ``sitename``: The name of the board to be used in titles and messaging, same as the site name stored in the board config.

lang
    *(array)* A collection of language-specific blocks. Each block is keyed by the language ISO code and contains the following keys:

    * ``BOARD_MAINTENANCE``: The main body text for the board maintenance message.
    * ``BOARD_MAINTENANCE_START``: The localized "Started on" label (supports ``%1$s`` for the date).
    * ``BOARD_MAINTENANCE_TITLE``: The HTML title tag template (supports ``%1$s`` for the sitename).

links
    *(array)* A list of external community links. Each entry is an array with ``title`` and ``url``.

Example Implementation
----------------------

.. code-block:: php

    <?php
    /**
     * phpBB Update Lock File
     * This file is auto-generated. Do not edit manually.
     */

    if (!defined('IN_PHPBB'))
    {
        exit;
    }

    return [
        'initiated' => 1738200000,
        'config' => [
           'default_lang' => 'en',
           'sitename' => 'yourdomain.com',
        ],
        'lang' => [
           'en' => [
              'BOARD_MAINTENANCE'        => 'The board is currently down for maintenance.',
              'BOARD_MAINTENANCE_START'  => 'Started on %1$s',
              'BOARD_MAINTENANCE_TITLE'  => 'Board maintenance - %1$s',
           ]
        ],
        'links' => [
           ['title' => 'Discord', 'url' => 'https://discord.gg/example'],
           ['title' => 'Status Page', 'url' => 'https://status.example.com'],
        ],
    ];

Best Practices for Developers
=============================

1. **Atomic Writes**: When creating the lock file, always write to a temporary file (e.g., ``UPDATE_LOCK.php.tmp``) and use ``rename()`` to move it to its final destination. This prevents the interceptor from including a half-written file.
2. **Minimalism**: Do not include heavy logic in the lock file. It is intended only for data storage.
3. **Localization**: Always provide at least the key corresponding to your default language in the ``lang`` array to satisfy the ``default_lang`` fallback.