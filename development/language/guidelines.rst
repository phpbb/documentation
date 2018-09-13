===============================
Language Pack Submission Policy
===============================
Below are the procedures and guidelines that need to be followed by any translator submitting a language pack to our `Customisations Database`_.
All approved language packs can be found in our `Language Packs Database`_.
If you submit your language pack to our `Customisations Database`_, it will first be automatically sent to the Translations Manager for validation.
The Translations Manager is responsible for ensuring that your submission follows the guidelines below.
Failure to comply with the following instructions could lead to an instant denial of your submission.
Please note the Translations Manager has full discretion on what he approves or denies.
This process can sometimes take a considerable amount of time, so it's in your best interest to follow all of the guidelines from the start.
If your language pack is denied and then resubmitted, it is placed at the end of the queue.

1) Submissions have to be compatible with the latest version of phpBB. Any missing key will be detected during the upload process and your submission will be automatically denied.

2) Submissions have to be complete. Partial translations are not allowed and will be automatically denied. E-mails, text files and theme-images must also be fully translated.

3) Language packs can contain five additional files (one mandatory and four optionals) that are not present in the British English language pack: ``LICENSE`` (mandatory), ``README.md`` (optional), ``AUTHORS.md`` (optional), ``VERSION.md`` (optional) and ``CHANGELOG.md`` (optional). You are free to write whatever you want in the ``README.md`` file, you can list all the authors and contributors of your language pack in the ``AUTHORS.md`` file, you can put the version of your language pack in the ``VERSION.md`` file and you can list the entire version history in the ``CHANGELOG.md`` file. The ``LICENSE`` file is automatically added during the upload process so you do not have to manually add the file. Its purpose is to inform the user what license is used. Language packs inherit phpBB's license of GNU General Public License 2.0_ and no additional or alternative licenses are allowed. All of these additional files must be placed in the ``language/{iso}/`` directory, next to the ``iso.txt`` file. Any other additional file(s) will be detected and your submission will be denied.

4) Submissions must have the following files and structure:

.. code-block:: text

        languagename_versionnumber.zip
           languagename_versionnumber/
              ext/
                 phpbb/
                    viglink/
                       language/
                          {iso}/
                             info_acp_viglink.php
                             viglink_module_acp.php
              language/
                 {iso}/
                    acp/
                       attachments.php
                       ban.php
                       board.php
                       bots.php
                       common.php
                       database.php
                       email.php
                       extensions.php
                       forums.php
                       groups.php
                       index.htm
                       language.php
                       modules.php
                       permissions.php
                       permissions_phpbb.php
                       posting.php
                       profile.php
                       prune.php
                       search.php
                       styles.php
                       users.php
                    email/
                       short/
                          bookmark.txt
                          newtopic_notify.txt
                          post_approved.txt
                          post_disapproved.txt
                          post_in_queue.txt
                          privmsg_notify.txt
                          quote.txt
                          report_pm.txt
                          report_post.txt
                          topic_approved.txt
                          topic_disapproved.txt
                          topic_in_queue.txt
                          topic_notify.txt
                       admin_activate.txt
                       admin_send_email.txt
                       admin_welcome_activated.txt
                       admin_welcome_inactive.txt
                       bookmark.txt
                       contact_admin.txt
                       coppa_resend_inactive.txt
                       coppa_welcome_inactive.txt
                       email_notify.txt
                       forum_notify.txt
                       group_added.txt
                       group_request.txt
                       index.htm
                       installed.txt
                       newtopic_notify.txt
                       pm_report_closed.txt
                       pm_report_deleted.txt
                       post_approved.txt
                       post_disapproved.txt
                       post_in_queue.txt
                       privmsg_notify.txt
                       profile_send_email.txt
                       profile_send_im.txt
                       quote.txt
                       report_closed.txt
                       report_deleted.txt
                       report_pm.txt
                       report_post.txt
                       topic_approved.txt
                       topic_disapproved.txt
                       topic_in_queue.txt
                       topic_notify.txt
                       user_activate.txt
                       user_activate_inactive.txt
                       user_activate_passwd.txt
                       user_reactivate_account.txt
                       user_remind_inactive.txt
                       user_resend_inactive.txt
                       user_welcome.txt
                       user_welcome_inactive.txt
                    help/
                       bbcode.php
                       faq.php
                    app.php
                    AUTHORS.md (optional)
                    captcha_qa.php
                    captcha_recaptcha.php
                    cli.php
                    CHANGELOG.md (optional)
                    common.php
                    groups.php
                    index.htm
                    install.php
                    iso.txt (
                    LICENSE
                    mcp.php
                    memberlist.php
                    migrator.php
                    plupload.php
                    posting.php
                    README.md (optional)
                    search.php
                    ucp.php
                    VERSION.md (optional)
                    viewforum.php
                    viewtopic.php
              styles/
                 prosilver/
                    theme/
                       {iso}/
                          icon_user_online.gif
                          index.htm (optional)
                          stylesheet.css

5) Submissions should follow the recommendations in the `3.2 Translation (i18n/L10n) Guidelines`_ as closely as possible, especially the `3.2 Writing style`_.

6) All PHP and text files must be encoded in UTF-8 without BOM and a new line at the end of the file. Many modern text editors use this as a default setting, but we recommend checking it in your editor's settings. We recommend you use `Notepad++`_ or `PSPad`_, both lightweight and free.

7) The translation is mostly your work and you have a right to hold a copyright on the translation and put your name or the names of those on your team in the ``AUTHORS.md`` file.

8) A maximum of 3 links can be included as an author credit in the footer, customisable via the ``'TRANSLATION_INFO'`` key in ``common.php``. Please note that the Translations Manager has complete discretion on what is acceptable as an author credit link.

9) Submissions have to be submitted as a single zip file. The Customisations Database will automatically name your uploaded language pack using the format ``languagename_versionnumber.zip``. For example, if a Brazilian Portuguese language pack author uploads an archive named ``Brasileiro_1.0.5.zip``, it will be automatically changed to ``brazilian_portuguese_1_0_5.zip``.

10) The contribution description for you language pack in the Customisations Database should be translated into English in addition to your local language. This will facilitate the download of your translation by administrators who do not speak the language.

11) The contribution screenshot in the Customisations Database should only be the flag of the country where the primary spoken language is that of the language pack. For example, the flag of France for the French language.

12) Revision name in the Customisations Database should be left blank, contain the phpBB package version, and/or package release name (e.g. "**3.2.2 / Bertie’s New Year Resolution**" for 3.2.2).

13) The Demo URL in the Customisations Database must be empty, unless you want to put a link to an international community (`officially`_ listed or not) related to the language of the contribution. For example, https://www.phpbb.nl/ as Demo URL concerning the `Dutch language`_ is allowed.

.. _Customisations Database: https://www.phpbb.com/go/customise/language-packs/3.2
.. _Language Packs Database: https://www.phpbb.com/languages/
.. _GNU General Public License 2.0: http://www.opensource.org/licenses/gpl-2.0.php
.. _3.2 Translation (i18n/L10n) Guidelines: https://area51.phpbb.com/docs/32x/coding-guidelines.html#translation
.. _3.2 Writing style: https://area51.phpbb.com/docs/32x/coding-guidelines.html#writingstyle
.. _Notepad++: https://notepad-plus-plus.org/
.. _PSPad: http://www.pspad.com/en/
.. _officially: https://www.phpbb.com/support/intl/
.. _Dutch language: https://www.phpbb.com/customise/db/translation/dutch_casual_honorifics/
