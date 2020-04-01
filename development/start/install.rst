============
Installation
============

1. Quick install
================

If you have basic knowledge of using FTP and are sure your hosting service or server will run phpBB3 you can use these steps to quickly get started. For a more detailed explanation you should skip this and go to `2. Requirements`_ below.

Decompress the phpBB3 archive to a local directory on your system.
Upload all the files contained in this archive (retaining the directory structure) to a web accessible directory on your server or hosting account.
Change the permissions on config.php to be writable by all (``666`` or ``-rw-rw-rw-`` within your FTP Client)
Change the permissions on the following directories to be writable by all (``777`` or ``-rwxrwxrwx`` within your FTP Client):
``store/``, ``cache/``, ``files/`` and ``images/avatars/upload/``.
Point your web browser to the location where you uploaded the phpBB3 files with the addition of ``install/app.php`` or simply ``install/``, e.g. ``http://www.example.com/phpBB3/install/app.php``, ``http://www.example.com/forum/install/``.
Click the **INSTALL** tab, follow the steps and fill out all the requested information.
Change the permissions on config.php to be writable only by yourself (``644`` or ``-rw-r--r--`` within your FTP Client)
phpBB3 should now be available, please **MAKE SURE** you read at least `6. Conversion from phpBB 2.0.x to phpBB 3.2.x`_ below for important, security related post-installation instructions, and also take note of `7. Important (security related) post-Install tasks for all installation methods`_ regarding anti-spam measures.
If you experienced problems or do not know how to proceed with any of the steps above please read the rest of this document.

2. Requirements
===============

phpBB 3.2.x has a few requirements which must be met before you are able to install and use it.

A webserver or web hosting account running on any major Operating System with support for PHP
A SQL database system, **one of**:
MySQL 3.23 or above (MySQLi supported)
MariaDB 5.1 or above
PostgreSQL 8.3+
SQLite 3.6.15+
MS SQL Server 2000 or above (via ODBC or the native adapter)
Oracle
PHP **7.1.0+** but less than PHP **7.3** with support for the database you intend to use.
The following PHP modules are required:
json
getimagesize() function must be enabled.
Presence of the following modules within PHP will provide access to additional features, but they are not required:
zlib Compression support
Remote FTP support
XML support
GD Support
If your server or hosting account does not meet the requirements above then you will be unable to install phpBB 3.2.x.

3. New installation
================

Installation of phpBB will vary according to your server and database. If you have shell access to your account (via telnet or ssh for example) you may want to upload the entire phpBB archive (in binary mode!) to a directory on your host and unarchive it there.

If you do not have shell access or do not wish to use it, you will need to decompress the phpBB archive to a local directory on your system using your favourite compression program, e.g. winzip, rar, zip, etc. From there you must FTP **ALL** the files it contains (being sure to retain the directory structure and filenames) to your host. Please ensure that the cases of filenames are retained, do **NOT** force filenames to all lower or upper case as doing so will cause errors later.

All .php, .sql, .cfg, .css, .js, .html, .htaccess and .txt files should be uploaded in **ASCII** mode, while all graphics should be uploaded in **BINARY** mode. If you are unfamiliar with what this means please refer to your FTP client documentation. In most cases this is all handled transparantly by your ftp client, but if you encounter problems later you should be sure the files were uploaded correctly as described here.

phpBB comes supplied with British English as its standard language. However, a number of separate packs for different languages are available. If you are not a native English speaker you may wish to install one or more of these packages before continuing. The installation process below will allow you to select a default language from those available (you can, of course, change this default at a later stage). For more details on language packs, where to obtain them and how to install them please see `2.i. Languages (Internationalisation - i18n)`_.

Once all the files have been uploaded to your site, you should point your browser at this location with the addition of ``/install/``. For example, if your domain name is ``www.example.com`` and you placed the phpBB files in the directory ``/phpBB3`` off your web root you would enter ``http://www.example.com/phpBB3/install/`` or (alternatively) ``http://www.example.com/phpBB3/install/app.php`` into your browser. When you have done this, you should see the **phpBB Introduction** screen appear.

3.i. Introduction
-------------------

The initial screen gives you a short introduction into phpBB. It allows you to read the license phpBB is released under (General Public License v2) and provides information about how you can receive support. To start the installation, use the **INSTALL** tab.

3.ii. Requirements
-------------------

The first page you will see after starting the installation is the Requirements list. phpBB automatically checks whether everything that it needs to run properly is installed on your server. You need to have at least the minimum PHP version installed, and at least one database available to continue the installation. Also important, is that all shown folders are available and have the correct permissions. Please see the description of each section to find out whether they are optional or required for phpBB to run. If everything is in order, you can continue the installation with Start Install.

3.iii. Database settings
-------------------

You now have to decide which database to use. See the `Requirements`_ section for information on which databases are supported. If you do not know your database settings, please contact your host and ask for them. You will not be able to continue without them. You need:

- The Database Type - the database you will be using.
- The Database server hostname or DSN - the address of the database server.
- The Database server port - the port of the database server (most of the time this is not needed).
- The Database name - the name of the database on the server.
- The Database username and Database password - the login data to access the database.

.. note:: if you are installing using SQLite, you should enter the full path to your database file in the DSN field and leave the username and password fields blank. For security reasons, you should make sure that the database file is not stored in a location accessible from the web.

You don't need to change the Prefix for tables in database setting, unless you plan on using multipe phpBB installations on one database. In this case, you can use a different prefix for each installation to make it work.

After you entered your details, you can continue with the Proceed to next step button. Now phpBB will check whether the data you entered will lead to a successful database connection and whether tables with the same prefix already exist.

A **Could not connect** to the database error means that you didn't enter the database data correctly and it is not possible for phpBB to connect. Make sure that everything you entered is in order and try again. Again, if you are unsure about your database settings, please contact your host.

If you installed another version of phpBB before on the same database with the same prefix, phpBB will inform you and you just need to enter a different database prefix.

If you see the **Successful Connection** message, you can continue to the next step.

3.iv Administrator details
-------------------

Now you have to create your administration user. This user will have full administration access and he/she will be the first user on your forum. All fields on this page are required. You can also set the default language of your forum on this page. In a vanilla phpBB installation, we only include British English. You can download further languages from https://www.phpbb.com/, and add them before installing or later.

3.v Configuration file
-------------------

In this step, phpBB will try to write the configuration file automatically. The forum needs the configuration file in order to operate. It contains all the database settings, so without it, phpBB will not be able to access the database.

Usually, writing the configuration file automatically works fine. If the file permissions are not set correctly, this process can fail. In this case, you need to upload the file manually. phpBB asks you to download the `config.php` file and tells you what to do with it. Please read the instructions carefully. After you have uploaded the file, use Done to get to the last step. If Done returns you to the same page as before, and does not return a success message, you did not upload the file correctly.

3.vi Advanced settings
-------------------

The Advanced settings allow you to set additional parameters of the board configuration. They are optional and you can always change them later. So, even if you are not sure what these settings mean, you can still proceed to the final step and finish the installation.

If the installation was successful, you can now use the **Login** button to visit the Administration Control Panel. Congratulations, you have installed phpBB successfully. But there is still work ahead!

If you are unable to get phpBB installed even after reading this guide, please look at the support section of the installer's introduction page to find out where you can ask for further assistance.

At this point if you are converting from phpBB 2.0.x, you should refer to `6. Conversion from phpBB 2.0.x to phpBB 3.2.x`_ for further information. If not, you should remove the install directory from your server as you will only be able to access the Administration Control Panel whilst it is present.

4. Updating from stable releases of phpBB 3.2.x
================================================

If you are currently using a stable release of phpBB, updating to this version is straightforward. You would have downloaded one of four packages and your choice determines what you need to do.
.. note:: Before updating, we heavily recommend you do a full backup of your database and existing phpBB files! If you are unsure how to achieve this please ask your hosting provider for advice.

**Please make sure you update your phpBB source files too, even if you just run the database updater.** If you have shell access to your server, you may wish to update via the command line interface. From your board's root, execute the following command: ``php bin/phpbbcli.php --safe-mode db:migrate``.

4.i. Full package
-----------------

Updating using the full package is the recommended update method for boards without modifications to core phpBB files.

First, you should make a copy of your existing ``config.php`` file; keep it in a safe place! Next, delete all the existing phpBB files, you should leave your ``files/``, ``images/`` and ``ext/`` directories in place, otherwise you will lose your file attachments, uploaded images and get errors due to missing extension files. You can leave alternative styles in place too. With this complete, you can upload the new phpBB files (see `3. New installation`_ for details if necessary). Once complete, copy back your saved ``config.php``, replacing the new one. Another method is to just **replace** the existing files with the files from the full package - though make sure you do **not** overwrite your ``config.php`` file.

You should now got to ``/install/app.php/update`` which will display a warning: **No valid update directory was found, please make sure you uploaded the relevant files.** Beneath that warning you will see a radio button **Update database only**, just click **Submit**. Depending on your previous version this will make a number of database changes. You may receive **FAILURES** during this procedure. They should not be a cause for concern unless you see an actual **ERROR**, in which case the script will stop (in this case you should seek help via our forums or bug tracker). If you have shell access to your server, you may wish to update via the command line interface. From your board's root, execute the following command: ``php bin/phpbbcli.php --safe-mode db:migrate``.

Once ``/install/app.php/update`` has completed, it displays the success message: **The database update was successful.** You may proceed to the Administration Control Panel and then remove the install directory as advised.

4.ii. Changed files
-------------------

This package is meant for those wanting to only replace the files that were changed between a previous version and the latest version.

This package contains a number of archives, each contains the files changed from a given release to the latest version. You should select the appropriate archive for your current version, e.g. if you currently have **3.2.0** you should select the appropriate ``phpBB-3.2.1-files.zip/tar.bz2`` file.

The directory structure has been preserved, enabling you (if you wish) to simply upload the uncompressed contents of the archive to the appropriate location on your server, i.e. simply overwrite the existing files with the new versions. Do not forget that if you have installed any modifications (MODs) these files will overwrite the originals, possibly destroying them in the process. You will need to re-add MODs to any affected file before uploading.

As for the other update procedures, you should go to ``/install/app.php/update``, select "Update database only" and submit the page after you have finished updating the files. This will update your database schema and increment the version number. If you have shell access to your server, you may wish to update via the command line interface. From your board's root, execute the following command: ``php bin/phpbbcli.php --safe-mode db:migrate``.

4.iii. Patch file
-----------------

The patch file package is for those wanting to update through the patch application, and should only be used by those who are comfortable with it.

The patch file is one solution for those with changes in to the phpBB core files and do not want to re-add them back to all the changed files. To use this you will need command line access to a standard UNIX type **patch application**. If you do not have access to such an application, but still want to use this update approach, we strongly recommend the `4.iv. Automatic update package`_ explained below. It is also the recommended update method.

A number of patch files are provided to allow you to update from previous stable releases. Select the correct patch, e.g. if your current version is **3.2.0**, you need the ``phpBB-3.2.1-patch.zip/tar.bz2`` file. Place the correct patch in the parent directory containing the phpBB core files (i.e. index.php, viewforum.php, etc.). With this done you should run the following command: ``patch -cl -d [PHPBB DIRECTORY] -p1 < [PATCH NAME]`` (where PHPBB DIRECTORY is the directory name your phpBB Installation resides in, for example phpBB, and where PATCH NAME is the relevant filename of the selected patch file). This should complete quickly, hopefully without any HUNK FAILED comments.

If you do get failures, you should look at using the `4.ii. Changed files` package to replace the files which failed to patch. Please note that you will need to manually re-add any MODs to these particular files. Alternatively, if you know how, you can examine the ``.rej`` files to determine what failed where and make manual adjustments to the relevant source.

You should, of course, delete the patch file (or files) after use. As for the other update procedures, you should navigate to ``/install/app.php/update``, select "Update database only" and submit the page after you have finished updating the files. This will update your database schema and data (if appropriate) and increment the version number. If you have shell access to your server, you may wish to update via the command line interface. From your board's root, execute the following command: ``php bin/phpbbcli.php --safe-mode db:migrate``.

4.iv. Automatic update package
------------------------------

This update method is only recommended for installations with modifications to core phpBB files. This package detects changed files automatically and merges in changes if needed.

The automatic update package will update the board from a given version to the latest version. A number of automatic update files are available, and you should choose the one that corresponds to the version of the board that you are currently running. For example, if your current version is **3.2.0**, you need the ``phpBB-3.2.0_to_3.2.1.zip/tar.bz2`` file.

To perform the update, either follow the instructions from the **Administration Control Panel->System** Tab - this should point out that you are running an outdated version and will guide you through the update - or follow the instructions listed below.

- Go to the `downloads page <https://www.phpbb.com/downloads/>`_ and download the latest update package listed there, matching your current version.
- Upload the uncompressed archive contents to your phpBB installation - only the ``install/`` and ``vendor/`` folders are required. Upload these folders in their entirety, retaining the file structure.
- After the install folder is present, phpBB will go offline automatically.
- Point your browser to the install directory, for example ``http://www.example.com/phpBB3/install/``
- Choose the "Update" Tab and follow the instructions


4.v. All package types
----------------------

If you have non-English language packs installed, you may want to see if a new version has been made available. A number of missing strings may have been added which, though not essential, may be beneficial to users. Please note that at this time not all language packs have been updated so you should be prepared to periodically check for updates.

These update methods will only update the standard style ``prosilver``, any other styles you have installed for your board will usually also need to be updated.

5. Updating from phpBB 3.0.x/3.1x to phpBB 3.2.x
==================================================

Updating from phpBB 3.0.x or 3.1.x to 3.2.x is just the same as `4. Updating from stable releases of phpBB 3.2.x`_

However you can also start with a new set of phpBB 3.2.x files.

Delete all files **EXCEPT** for the following:
The ``config.php`` file
The ``images/`` directory
The ``files/`` directory
The ``store/`` directory
(The ``ext/`` directory
Upload the contents of the 3.2.x Full Package into your forum's directory. Make sure the root level .htaccess file is included in the upload.
Browse to ``/install/app.php/`` update
Read the notice Update database only and press **Submit**
Delete the ``install/`` directory

6. Conversion from phpBB 2.0.x to phpBB 3.2.x
=============================================

This paragraph explains the steps necessary to convert your existing phpBB2 installation to phpBB3.

6.i. Requirements before converting
-----------------------------------

Before converting, we heavily recommend you do a **full backup of your database and files!** If you are unsure how to achieve this, please ask your hosting provider for advice. You basically need to follow the instructions given for `3. New installation`_. Please **do not** overwrite any old files - install phpBB3 at a different location.

Once you made a backup of everything and also have a brand new phpBB3 installation, you can now begin the conversion.

Note that the conversion requires ``CREATE`` and ``DROP`` privileges for the phpBB3 database user account.

6.ii. Converting
----------------

To begin the conversion, visit the ``install/`` folder of your phpBB3 installation (the same as you have done for installing). Now you will see a new tab **Convert**. Click this tab.

As with install, the conversion is automated. Your previous 2.0.x database tables will not be changed and the original 2.0.x files will remain unaltered. The conversion is actually only filling your phpBB3 database tables and copying additional data over to your phpBB3 installation. This has the benefit that if something goes wrong, you are able to either re-run the conversion or continue a conversion, while your old board is still accessible. We really recommend that you disable your old installation while converting, else you may have inconsistent data after the conversion.

Please note that this conversion process may take quite some time and depending on your hosting provider this may result in it failing (due to web server resource limits or other timeout issues). If this is the case, you should ask your provider if they are willing to allow the convert script to temporarily exceed their limits (be nice and they will probably be quite helpful). If your host is unwilling to increase the limits to run the convertor, please see this article for performing the conversion on your local machine: `Knowledge Base - Offline Conversions <https://www.phpbb.com/kb/article/offline-conversions/>`_

Once completed, your board should be immediately available. If you encountered errors, you should report the problems to our bug tracker or seek help via our forums (see `5. Reporting Bugs`_ for details).

6.iii. Things to do after conversion
------------------------------------

After a successful conversion, there may be a few items you need to do - apart from checking if the installation is accessible and everything displayed correctly.

The first thing you may want to do is to go to the administration control panel and check every configuration item within the general tab. Thereafter, you may want to adjust the forum descriptions/names if you entered HTML there. You also may want to access the other administrative sections, e.g. adjusting permissions, smilies, icons, ranks, etc.

During the conversion, the search index is not created or transferred. This means after conversion you are not able to find any matches if you want to search for something. We recommend you rebuild your search index within **Administration Control Panel -> Maintenance -> Database -> Search Index**.

After verifying the settings in the ACP, you can delete the install directory to enable the board. The board will stay disabled until you do so.

Once you are pleased with your new installation, you may want to give it the name of your old installation, changing the directory name. With phpBB3 this is possible without any problems, but you may still want to check your cookie settings within the administration panel; in case your cookie path needs to be adjusted prior to renaming.

6.iv. Common conversion problems
--------------------------------

**Broken non-latin characters** The conversion script assumes that the database encoding in the source phpBB2 matches the encoding defined in the ``lang_main.php`` file of the default language pack of the source installation. Edit that file to match the database's encoding and re-start the conversion procedure.

**http 500 / white pages** The conversion is a load-heavy procedure. Restrictions imposed by some server hosting providers can cause problems. The most common causes are: values too low for the PHP settings ``memory_limit`` and ``max_execution_time``. Limits on the allowed CPU time are also a frequent cause for such errors, as are limits on the number of database queries allowed. If you cannot change such settings, then contact your hosting provider or run the conversion procedure on a different computer. The phpBB.com forums are also an excellent location to ask for support.

**Password conversion** Due to the utf-8 based handling of passwords in phpBB3, it is not always possible to transfer all passwords. For passwords "lost in translation" the easiest workaround is to use the **I forgot my password** link on the login page.

**Path to your former board** The convertor expects the relative path to your old board's files. So, for instance, if the old board is located at ``http://www.yourdomain.com/forum`` and the phpBB3 installation is located at ``http://www.yourdomain.com/phpBB3``, then the correct value would be ``../forum``. Note that the webserver user must be able to access the source installation's files.

**Missing images** If your default board language's language pack does not include all images, then some images might be missing in your installation. Always use a complete language pack as default language.

**Smilies** During the conversion you might see warnings about image files where the copying failed. This can happen if the old board's smilies have the same file names as those on the new board. Copy those files manually after the conversion, if you want to continue using the old smilies.

7. Important (security related) post-Install tasks for all installation methods
===============================================================================

Once you have successfully installed phpBB you **MUST** ensure you remove the entire ``install/`` directory. Leaving the install directory in place is a very serious potential security issue which may lead to deletion or alteration of files, etc. Please note that until this directory is removed, phpBB will not operate and a warning message will be displayed. Beyond this **essential** deletion, you may also wish to delete the docs/ directory if you wish.

With these directories deleted, you should proceed to the administration panel. Depending on how the installation completed, you may have been directed there automatically. If not, login as the administrator you specified during install/conversion and click the **Administration Control Panel** link at the bottom of any page. Ensure that details specified on the **General** tab are correct!

7.i. Uploadable avatars
-----------------------

phpBB supports several methods for allowing users to select their own **avatar** (an avatar is a small image generally unique to a user and displayed just below their username in posts).

Two of these options allow users to upload an avatar from their machine or a remote location (via a URL). If you wish to enable this function you should first ensure the correct path for uploadable avatars is set in **Administration Control Panel -> General -> Board Configuration -> Avatar** settings. By default this is ``images/avatars/uploads``, but you can set it to whatever you like, just ensure the configuration setting is updated. You must also ensure this directory can be written to by the webserver. Usually this means you have to alter its permissions to allow anyone to read and write to it. Exactly how you should do this depends on your FTP client or server operating system.

On UNIX systems, for example, you set the directory to ``a+rwx`` (or ``ugo+rwx`` or even ``777``). This can be done from a command line on your server using chmod or via your FTP client (using the **Change Permissions**, ``chmod`` or other Permissions dialog box, see your FTP client's documentation for help). Most FTP clients list permissions in the form of User (Read, Write, Execute), Group (Read, Write, Execute) and Other (Read, Write, Execute). You need to tick all of these boxes to set correct permissions.

On Windows systems, you need to ensure the directory is not write-protected and that it has global write permissions (see your server's documentation or contact your hosting provider if you are unsure on how to achieve this).

Please be aware that setting a directory's permissions to global write access is a potential security issue. While it is unlikely that anything nasty will occur (such as all the avatars being deleted) there are always people out there to cause trouble. Therefore you should monitor this directory and if possible make regular backups.

7.ii. Webserver configuration
-----------------------------

Depending on your web server, you may have to configure your server to deny web access to the ``cache/``, ``files/``, ``includes``, ``phpbb``, ``store/``, and vendor directories. This is to prevent users from accessing sensitive files.

For **Apache** there are ``.htaccess`` files already in place to do this for the most sensitive files and folders. We do however recommend to completely deny all access to the aforementioned folders and their respective subfolders in your Apache configuration.
On **Apache 2.4**, denying access to the ``phpbb`` folder in a phpBB instance located at ``/var/www/html/`` would be accomplished by adding the following access rules to the Apache configuration file (typically ``apache.conf``):

.. code-block:: text
    <Directory /var/www/html/phpbb/*>
        Require all denied
    </Directory>
    <Directory /var/www/html/phpbb>
        Require all denied
    </Directory>

The same settings can be applied to the other mentioned directories by replacing ``phpbb`` by the respective directory name. Please note that there are differences in syntax between Apache version `2.2 <https://httpd.apache.org/docs/2.2/howto/access.html>`_ and `2.4 <https://httpd.apache.org/docs/2.4/howto/access.html>`_.

For **Windows** based servers using **IIS** there are ``web.config`` files already in place to do this for you. For other webservers, you will have to adjust the configuration yourself. Sample files for **nginx** and **lighttpd** to help you get started may be found in the ``docs/`` directory.

8. Anti-Spam Measures
=====================

Like any online site that allows user input, your board could be subject to unwanted posts; often referred to as `forum spam <http://en.wikipedia.org/wiki/Forum_spam>`_. The vast majority of these attacks will be from automated computer programs known as `spambots <http://en.wikipedia.org/wiki/Spambot>`_. The attacks, generally, are not personal as the spammers are just trying to find accessible targets. phpBB has a number of anti-spam measures built in, including a range of CAPTCHAs. However, administrators are strongly urged to read and follow the advice for `Preventing Spam in phpBB <https://www.phpbb.com/support/spam/>`_ as soon as possible after completing the installation of your board.
