=================
Tutorial: Modules
=================

Introduction
============

In phpBB you can create your own modules for the User, Moderator and
Administration Control Panels. This modular approach has many advantages
over creating settings pages from scratch:

  * You can manage modules in the ACP.
  * You don't have to directly handle authorisation.
  * You get a navigation tree built-in to the system.
  * The module templates already contain features like pagination,
    breadcrumbs and confirmation messages.

This tutorial explains:

 * `Creating Control Panel Modules`_
 * `Installing Control Panel Modules`_

.. note::
    This tutorial describes how to create an ACP module. To
    create MCP or UCP modules, you usually only need to replace all occurrences
    of "acp" with "mcp" or "ucp".


Creating Control Panel Modules
==============================

A module requires three files:

 1. `Module info`_
 2. `Module class`_
 3. `Module template`_

Module info
-----------

The module info class simply contains a method that returns an array
of information describing the module. Information like the name of
the module, available modes and required permissions.

This file must always end in ``*_info.php`` and
should be stored in the ``acp/`` folder of the extension.
For this tutorial, we will use ``ext/acme/demo/acp/main_info.php``:

.. code-block:: php

    <?php

    namespace acme\demo\acp;

    class main_info
    {
        public function module()
        {
            return array(
                'filename'  => '\acme\demo\acp\main_module',
                'title'     => 'ACP_DEMO_TITLE',
                'modes'    => array(
                    'settings'  => array(
                        'title' => 'ACP_DEMO',
                        'auth'  => 'ext_acme/demo && acl_a_board',
                        'cat'   => array('ACP_DEMO_TITLE'),
                    ),
                ),
            );
        }
    }

The ``main_info`` class has only one method ``module()`` which returns an array
with the following information:

.. csv-table::
    :header: "Key", "Content"
    :delim: |

    ``filename`` | "Fully name-spaced path to the `Module class`_, starting with a leading slash."
    ``title`` | "Language key for the module-title that is displayed in the ACP module
    management section."
    ``modes`` | "Contains an array of modes for the module. See the next table
    for more details."

Note that we have defined one mode named ``settings`` with the following information:

.. csv-table::
    :header: "Key", "Content"
    :delim: |

    ``title`` | "Language key of the mode-title that is displayed in the ACP module
    management section."
    ``auth`` | "An authorisation key used to control access to the mode. The extension
    vendor/name ``acme/demo`` is required to ensure the extension is enabled. Optionally
    we also specify that the user must have, in this case, the ``a_board`` permission."
    ``cat`` | "References the parent category the mode belongs to. Should
    typically contain the language key of the parent category."

Module class
------------

The module class contains the actual code for the module. This
file will also be stored in the ``acp/`` folder of the extension.
For this tutorial, we will use ``ext/acme/demo/acp/main_module.php``:

.. code-block:: php

    <?php

    namespace acme\demo\acp;

    class main_module
    {
        public $u_action;
        public $tpl_name;
        public $page_title;

        public function main($id, $mode)
        {
            global $language, $template, $request, $config;

            $this->tpl_name = 'acp_demo_body';
            $this->page_title = $language->lang('ACP_DEMO_TITLE');

            add_form_key('acme_demo_settings');

            if ($request->is_set_post('submit'))
            {
                if (!check_form_key('acme_demo_settings'))
                {
                     trigger_error('FORM_INVALID');
                }

                $config->set('acme_demo_goodbye', $request->variable('acme_demo_goodbye', 0));
                trigger_error($language->lang('ACP_DEMO_SETTING_SAVED') . adm_back_link($this->u_action));
            }

            $template->assign_vars(array(
                'ACME_DEMO_GOODBYE' => $config['acme_demo_goodbye'],
                'U_ACTION'          => $this->u_action,
            ));
        }
    }

The module itself must contain a ``main($id, $mode)`` method,
which takes the ``id`` of the module in the database and the ``mode``
being called as arguments.

In the code of the ``main`` method, we first set the name of the
`Module template`_ file that is used to render the module, and the page
title is assigned a language key.

.. _form key:

To strengthen the form against security vulnerabilities, we
use a form key check to verify that the form being submitting
is valid. This is done by calling ``add_form_key('acme_demo_settings')``
when displaying the form and then later checking the form key
when it is being submitted:

.. code-block:: php

    if (!check_form_key('acme_demo_settings'))
    {
        trigger_error('FORM_INVALID');
    }

.. warning::

    The form key should be unique for every form. The key can be
    any string value, but extensions should include their vendor
    and extension names.

If the form key passes, we set the configuration value to the
submitted value and display a success message to the user:

.. code-block:: php

    $config->set('acme_demo_goodbye', $request->variable('acme_demo_goodbye', 0));
    trigger_error($language->lang('ACP_DEMO_SETTING_SAVED') . adm_back_link($this->u_action));

At the end of the method we assign two template variables.
The first contains the current value of the config value.
The second contains the ``u_action`` class property which holds
the URL of the current form action.

Module template
---------------

Our ACP module now needs the template file we assigned to it in the `Module class`_.
We will use ``ext/acme/demo/adm/style/acp_demo_body.html``.

.. note::

    The ACP differs from the MCP and UCP in that it has its own
    style. The MCP and UCP use the main board style, i.e. prosilver.
    Therefore, ACP template files must be stored in ``./adm/style/``
    while MCP and UCP template files are stored in ``./styles/prosilver/template/``.

.. code-block:: html

    <!-- INCLUDE overall_header.html -->

    <h1>{L_SETTINGS}</h1>

    <form id="acp_board" method="post" action="{U_ACTION}">
        <fieldset>
            <dl>
                <dt><label for="acme_demo_goodbye">{L_ACP_DEMO_GOODBYE}</label></dt>
                <dd><input type="radio" class="radio" name="acme_demo_goodbye" value="1" <!-- IF ACME_DEMO_GOODBYE -->checked="checked" <!-- ENDIF -->/> {L_YES} &nbsp;
                    <input type="radio" class="radio" name="acme_demo_goodbye" value="0" <!-- IF not ACME_DEMO_GOODBYE -->checked="checked" <!-- ENDIF -->/> {L_NO}</dd>
            </dl>

            <p class="submit-buttons">
                <input class="button1" type="submit" id="submit" name="submit" value="{L_SUBMIT}" />&nbsp;
                <input class="button2" type="reset" id="reset" name="reset" value="{L_RESET}" />
            </p>

            {S_FORM_TOKEN}
        </fieldset>
    </form>

    <!-- INCLUDE overall_footer.html -->

This template renders out a form with a single option for toggling the
*acme_demo_goodbye* setting via two radio buttons, and two input buttons
to submit or reset the form. Note that the ``{S_FORM_TOKEN}`` template
variable is required as part of the `form key`_ security check.

Module language keys
++++++++++++++++++++

Between our module class and template files, we have added some new language keys.
We can add them to our language array in ``acme/demo/language/en/demo.php``:

.. code-block:: php

        'ACP_DEMO_TITLE'         => 'Demo Module',
        'ACP_DEMO'               => 'Settings',
        'ACP_DEMO_GOODBYE'       => 'Should say goodbye?',
        'ACP_DEMO_SETTING_SAVED' => 'Settings have been saved successfully!',

.. note::

    Recall that we load our language file globally throughout phpBB
    via the ``core.user_setup`` event in our event listener. Since we do
    not recommend doing this all the time, an alternative method to
    autoload a language file in the ACP is to prefix the file
    name with ``info_acp_*.php`` for module language keys or ``permissions_*.php`` for
    permission language keys.

Installing Control Panel Modules
================================

The module is now complete, but it will not show up in the ACP yet. To install
the module to the database when the extension is enabled, we need a Migration.

Migration files must be stored in the ``migrations/`` folder of the extension.
For the Acme Demo, we need a migration that will install the following data:

  * A configuration value named ``acme_demo_goodbye`` that can be set by the administrator.
  * The ACP module data.

.. code-block:: php

    <?php

    namespace acme\demo\migrations;

    class add_module extends \phpbb\db\migration\migration
    {
        /**
         * If our config variable already exists in the db
         * skip this migration.
         */
        public function effectively_installed()
        {
            return isset($this->config['acme_demo_goodbye']);
        }

        /**
         * This migration depends on phpBB's v314 migration
         * already being installed.
         */
        static public function depends_on()
        {
            return array('\phpbb\db\migration\data\v31x\v314');
        }

        public function update_data()
        {
            return array(

                // Add the config variable we want to be able to set
                array('config.add', array('acme_demo_goodbye', 0)),

                // Add a parent module (ACP_DEMO_TITLE) to the Extensions tab (ACP_CAT_DOT_MODS)
                array('module.add', array(
                    'acp',
                    'ACP_CAT_DOT_MODS',
                    'ACP_DEMO_TITLE'
                )),

                // Add our main_module to the parent module (ACP_DEMO_TITLE)
                array('module.add', array(
                    'acp',
                    'ACP_DEMO_TITLE',
                    array(
                        'module_basename'	=> '\acme\demo\acp\main_module',
                        'modes'				=> array('settings'),
                    ),
                )),
            );
        }
    }

.. seealso::

    To learn more about migrations, please have a look at the
    :doc:`../migrations/index` documentation.

At this point we have completed the Acme Demo extension! There is more that
extensions can do, however, than what we learned from the Acme Demo.
Continue on to the next sections to learn how to do more with extensions.
