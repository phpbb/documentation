
===============
Getting Started
===============

1. Installing
============================

Installation, update and conversion instructions can be found in the INSTALL document in this directory. If you are intending on converting from a phpBB 2.0.x or 3.0.x installation we highly recommend that you backup any existing data before proceeding!

Users of phpBB 3.0, 3.1 and 3.2 Beta versions cannot directly update.

Please note that we don't support the following installation types:

- Updates from phpBB Beta versions and lower to phpBB Release Candidates and higher
- Conversions from phpBB 2.0.x to phpBB 3.0 Beta, 3.1 Beta and 3.2 Beta versions
- phpBB 3.0 Beta, 3.1 Beta or 3.2 beta installations

We give support for the following installation types:

- Updates from phpBB 3.0 RC1, 3.1 RC1 and 3.2 RC1 to the latest version
- Note: if using the Automatic Update Package, updates are supported from phpBB 3.0.2 onward. To update a pre-3.0.2 installation, first - update to 3.0.2 and then update to the current version.
- Conversions from phpBB 2.0.x to the latest version
- New installations of phpBB 3.1.x - only the latest released version
- New installations of phpBB 3.2.x - only the latest released version

2. Running
============================

Once installed, phpBB is easily managed via the Administration and Moderator Control Panels. If you need help or advice with phpBB, please see Section 3 below.

2.i. Languages (Internationalisation - i18n)
--------------------------------------------

A number of language packs with included style localisations are available. You can find them listed in the `Language Packs`_ pages of our downloads section or from the `Language Packs`_ section of the `Customisation Database`_.

For more information about language packs, please see: https://www.phpbb.com/languages/

This is the official location for all supported language sets. If you download a package from a 3rd party site you do so with the understanding that we cannot offer support. Please do not ask for support if you download a language pack from a 3rd party site.

Installation of these packages is straightforward: simply download the required language pack, uncompress (unzip) it and via FTP transfer the included ``language`` and ``styles`` folders to the root of your board installation. The language can then be installed via the Administration Control Panel of your board: ``Customise tab -> Language management -> Language packs``. A more detailed description of the process is in the Knowledge Base article, `How to Install a Language Pack <https://www.phpbb.com/kb/article/how-to-install-a-language-pack/>`_.

If your language is not available, please visit our `[3.2.x] Translations <https://www.phpbb.com/community/viewforum.php?f=566>`_ forum where you will find topics on translations in progress. Should you wish to volunteer to translate a language not currently available or assist in maintaining an existing language pack, you can `Apply to become a translator <https://www.phpbb.com/languages/apply.php>`_.

2.ii. Styles
--------------------------------------------

Although we are rather proud of the included styles, we realise that they may not be to everyone's taste. Therefore, phpBB allows styles to be switched with relative ease. First, you need to locate and download a style you like. You can find them listed in the `Styles <https://www.phpbb.com/customise/db/styles-2/>`_ section of our `Customisation Database`_.

For more information about styles, please see: https://www.phpbb.com/styles/

**Please note** that 3rd party styles downloaded for versions of phpBB2 will **not** work in phpBB3. It is also important to ensure that the style is updated to match the current version of the phpBB software you are using.

Once you have downloaded a style, the usual next step is to unarchive (or upload the unarchived contents of) the package into your ``styles/`` directory. You then need to visit ``Administration Control Panel -> Customise tab -> Style management -> Install Styles`` where you should see the new style available. Click "Install style" to install the style.

**Please note** that to improve efficiency, the software caches certain data. For this reason, if you create your own style or modify existing ones, please remember to purge the board cache by clicking the ``Run now`` button next to the ``Purge the cache`` option in the index page of the Administration Control Panel. You may also need to reload the page you have changed in your web browser to overcome browser caching. If the cache is not purged, you will not see your changes taking effect.

2.iii. Extensions
--------------------------------------------

We are proud to have a thriving extensions community. These third party extensions to the standard phpBB software, extend its capabilities still further. You can browse through many of the extensions in the `Extensions <https://www.phpbb.com/customise/db/extensions-36>`_ section of our `Customisation Database`_.

For more information about extensions, please see: https://www.phpbb.com/extensions

**Please remember** that any bugs or other issues that occur after you have added any extension should **NOT** be reported to the bug tracker (see below). First disable the extension and see if the problem is resolved. Any support for an extension should only be sought in the "Discussion/Support" forum for that extension.

Also remember that any extensions which modify the database in any way, may render upgrading your forum to future versions more difficult.

3. Getting Help
============================

phpBB can sometimes seem a little daunting to new users, particularly with regards to the permission system. The first thing you should do is check the FAQ, which covers a few basic getting started questions. If you need additional help there are several places you can find it.

3.i. phpBB Documentation
--------------------------------------------

Comprehensive documentation is now available on the phpBB website:

https://www.phpbb.com/support/docs/en/3.2/ug/

This covers everything from installation to setting permissions and managing users.

3.ii. Knowledge Base
--------------------------------------------

The Knowledge Base consists of a number of detailed articles on some common issues phpBB users may encounter while using the product. The Knowledge Base can be found at:

https://www.phpbb.com/kb/

3.iii. Community Forums
--------------------------------------------

The phpBB project maintains a thriving community where a number of people have generously decided to donate their time to help support users. This site can be found at:

https://www.phpbb.com/community/

If you do seek help via our forums please be sure to do a search before posting; if someone has experienced the issue before, then you may find that your question has already been answered. Please remember that phpBB is entirely staffed by volunteers, no one receives any compensation for the time they give, including moderators as well as developers; please be respectful and mindful when awaiting responses and receiving support.

3.iv Internet Relay Chat
--------------------------------------------

Another place you may find help is our IRC channel. This operates on the Freenode IRC network, `irc.freenode.net <irc://irc.freenode.net>`_

The main phpBB IRC channel is ``#phpBB``, and it is for limited general phpBB support.
For coding discussion related to phpBB in general, to Extensions, Styles, or similar, visit ``#phpBB-Coding``.

An IRC client such as mIRC, XChat, etc. is required to access the Freenode IRC network. Alternatively, the `freenode webchat <https://webchat.freenode.net/>`_ can be used to access phpBB's IRC channels. There are other IRC channels available, please see https://www.phpbb.com/support/irc/ for the complete list. Again, please do not abuse this service and be respectful of other users.

Once you have the client up and running, type ``/server irc.freenode.net`` to connect to the freenode IRC network, and then ``/join #phpbb`` to join the phpBB IRC channel. Alternatively, try clicking the following links to start up your client and connect automatically.

`#phpBB channel <irc://irc.freenode.net/phpbb>`_
`#phpBB-Coding channel <irc://irc.freenode.net/phpbb-coding>`_

3.v Discord
--------------------------------------------

phpBB is also running a Discord server for discussing phpBB core development and related topics like Extensions and Styles. Please note that only limited support can be offered.
To join the phpBB Discord server, follow this `invite link <https://discord.gg/y6kjMdA>`_.

The channels on Discord are bridged to IRC so users on IRC will see your messages posted by the phpbb-discord user while posts from IRC will be flagged with a Bot flag next to a user's name in Discord.

4. Status of this version
============================

This is a stable release of phpBB. The 3.2.x line is feature frozen, with point releases principally including fixes for bugs and security issues. Feature alterations and minor feature additions may be done if deemed absolutely required. The next major release will be phpBB 3.3 which is currently under development. Please do not post questions asking when 3.3 will be available, no release date has been set.

Those interested in the development of phpBB should keep an eye on the development forums to see how things are progressing:

http://area51.phpbb.com/phpBB/

Please note that the development forums should **NOT** be used to seek support for phpBB, the main community forums are the place for this.

5. Reporting Bugs
============================

The phpBB developers use a bug tracking system to store, list and manage all reported bugs, it can be found at the location listed below. Please **DO NOT** post bug reports to our forums. In addition please **DO NOT** use the bug tracker for support requests. Posting such a request will only see you directed to the support forums (while taking time away from working on real bugs).

http://tracker.phpbb.com/browse/PHPBB3

While we very much appreciate receiving bug reports (the more reports the more stable phpBB will be) we ask you carry out a few steps before adding new entries:

First, determine if your bug is reproduceable; how to determine this depends on the bug in question. Only if the bug is reproduceable is it likely to be a problem with phpBB (or in some way connected). If something cannot be reproduced it may turn out to have been your hosting provider working on something, a user doing something silly, etc. Bug reports for non-reproduceable events can slow down our attempts to fix real, reproduceable issues

Next, please read or search through the existing bug reports to see if your bug (or one very similar to it) is already listed. If it is please add to that existing bug rather than creating a new duplicate entry (all this does is slow us down).

Check the forums (use search!) to see if people have discussed anything that sounds similar to what you are seeing. However, as noted above please **DO NOT** post your particular bug to the forum unless it's non-reproduceable or you are sure it’s related to something you have done rather than phpBB

If no existing bug exists then please feel free to add it
If you do post a new bug (i.e. one that isn't already listed in the bug tracker) first make sure that you have logged in (your username and password are the same as for the community forums) then please include the following details:

Your server type/version, e.g. Apache 2.2.3, IIS 7, Sambar, etc.
PHP version and mode of operation, e.g. PHP 7.1.0 as a module, PHP 7.1.0 running as CGI, etc.
DB type/version, e.g. MySQL 5.0.77, PostgreSQL 9.0.6, MSSQL Server 2000 (via ODBC), etc.
The relevant database type/version is listed within the administration control panel.

Please be as detailed as you can in your report, and if possible, list the steps required to duplicate the problem. If you have a patch that fixes the issue, please attach it to the ticket or submit a pull request to our repository on `GitHub <https://github.com/phpbb/phpbb>`_.

If you create a patch, it is very much appreciated (but not required) if you follow the phpBB coding guidelines. Please note that the coding guidelines are somewhat different between different versions of phpBB. For phpBB 3.2.x the coding guidelines may be found here: http://area51.phpbb.com/docs/32x/coding-guidelines.html

Once a bug has been submitted you will be emailed any follow up comments added to it. **Please** if you are requested to supply additional information, do so! It is frustrating for us to receive bug reports, ask for additional information but get nothing. In these cases we have a policy of closing the bug, which may leave a very real problem in place. Obviously we would rather not have this situation arise.

5.i. Security related bugs
--------------------------------------------

If you find a potential security related vulnerability in phpBB please **DO NOT** post it to the bug tracker, public forums, etc.! Doing so may allow unscrupulous users to take advantage of it before we have time to put a fix in place. All security related bugs should be sent to our security tracker:

https://www.phpbb.com/security/

6. Overview of current bug list
============================

This list is not complete but does represent those bugs which may affect users on a wider scale. Other bugs listed in the tracker have typically been shown to be limited to certain setups or methods of installation, updating and/or conversions.

Conversions may fail to complete on large boards under some hosts.
Updates may fail to complete on large update sets under some hosts.
Smilies placed directly after bbcode tags will not get parsed. Smilies always need to be separated by spaces.

7. PHP compatibility issues
============================

phpBB 3.2.x takes advantage of new features added in PHP 7.1.0. We recommend that you upgrade to the latest stable release of PHP to run phpBB. The minimum version required is PHP 7.1.0 and the maximum supported version is the latest stable version of PHP.

Please remember that running any application on a development (unstable, e.g. a beta release) version of PHP can lead to strange/unexpected results which may appear to be bugs in the application. Therefore, we recommend you upgrade to the newest stable version of PHP before running phpBB. If you are running a development version of PHP please check any bugs you find on a system running a stable release before submitting.

This board has been developed and tested under Linux and Windows (amongst others) running Apache using MySQL 3.23, 4.x, 5.x, MariaDB 5.x, PostgreSQL 8.x, Oracle 8 and SQLite 3. Versions of PHP used range from 7.1.0 to 7.2.x and 7.3.x without issues.

7.i. Notice on PHP security issues
--------------------------------------------

Currently there are no known issues regarding PHP security.


.. _Language Packs: https://www.phpbb.com/languages/
.. _Customisation Database: https://www.phpbb.com/customise/db/
