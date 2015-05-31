================================
Tutorial: Modules and Migrations
================================

Introduction
============

This tutorial explains:

 * Control Panel Modules
 * Migrations: Database changes

Module information
==================

First we need to specify the information about the module in the
``*_info.php`` file in the ``acp/`` folder of the extension. The name name of
the info and module file have to match. In this tutorial we will use
``main_info.php`` and ``main_module.php``.

.. code-block:: php

    <?php
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

    namespace acme\demo\acp;

    class main_info
    {
        public function module()
        {
            return array(
                'filename'	=> '\acme\demo\acp\main_module',
                'title'		=> 'ACP_DEMO_TITLE',
                'version'	=> '1.0.0',
                'modes'		=> array(
                    'settings' => array(
                        'title' => 'ACP_DEMO',
                        'auth'  => 'ext_acme/demo && acl_a_board',
                        'cat'   => array('ACP_DEMO_TITLE'),
                    ),
                ),
            );
        }
    }

The ``main_info`` class has only one method ``module()`` which returns an array
with the necessary information.

.. csv-table::
    :header: "Field", "Content"
    :delim: |

    ``filename`` | Class name of the module starting with a leading slash
    ``title`` | "Language key of the module-title that is used in the ACP module
    management section"
    ``version`` | "The version number is deprecated and will be removed in a
    future phpBB version"
    ``modes`` | "Contains the allowed modes for the module. See the next table
    for an explanation of those values"

.. csv-table::
    :header: "Field", "Content"
    :delim: |

    ``title`` | "Language key of the mode-title that is used in the ACP module
    management section"
    ``auth`` | "The ``auth`` section can be used to limit access to the mode.
    In this case we require the extension ``acme/demo`` to be enabled and also
    check, whether the user has the ``a_board`` permission."
    ``cat`` | "Should contain the language string of the parent category"

Module
======

.. code-block:: php

    <?php
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

    namespace acme\demo\acp;

    class main_module
    {
        public $u_action;
        public $tpl_name;
        public $page_title;

        public function main($id, $mode)
        {
            global $user, $template, $request, $config;

            $this->tpl_name = 'acp_demo_body';
            $this->page_title = $user->lang('ACP_DEMO_TITLE');

            add_form_key('acme/demo');

            if ($request->is_set_post('submit'))
            {
                if (!check_form_key('acme/demo'))
                {
                    $user->add_lang('acp/common');
                    trigger_error('FORM_INVALID');
                }

                $config->set('acme_demo_goodbye', $request->variable('acme_demo_goodbye', 0));

                trigger_error($user->lang('ACP_DEMO_SETTING_SAVED') . adm_back_link($this->u_action));
            }

            $template->assign_vars(array(
                'U_ACTION'				=> $this->u_action,
                'ACME_DEMO_GOODBYE'		=> $config['acme_demo_goodbye'],
            ));
        }
    }

The module itself must contain a ``main($id, $mode)`` method, which takes the
id of the module in the database and the mode it is being called with as
arguments.

First we set the name of the template file that is used to render our module.
Afterwards the page title is set to another language variable. At the end of the
method we assign two template variables, so the values can be used in the
template file.

Form key
========

In order to avoid running into security problems, we need to verify that the
administrator was not tricked into submitting the form that is being displayed.

This is done by calling ``add_form_key('acme/demo')`` when displaying the form
and then checking the form key when it is being submitted:

.. code-block:: php

    if (!check_form_key('acme/demo'))
    {
        $user->add_lang('acp/common');
        trigger_error('FORM_INVALID');
    }

In case the check was fine, we set the configuration value to the submitted
value and display a success message:

.. code-block:: php

    $config->set('acme_demo_goodbye', $request->variable('acme_demo_goodbye', 0));
    trigger_error($user->lang('ACP_DEMO_SETTING_SAVED') . adm_back_link($this->u_action));

ACP template file
=================

Since the administration control panel uses a different style then the board,
the files are also stored in an other directory. Since we specified
``acp_demo_body`` to be the template name, we have to put our form into
``adm/style/acp_demo_body.html``:

.. code-block:: html

    <!-- INCLUDE overall_header.html -->

    <h1>{L_SETTINGS}</h1>

    <form id="acp_board" method="post" action="{U_ACTION}">
        <fieldset>
            <dl>
                <dt><label for="acme_demo_goodbye">{L_ACP_DEMO_GOODBYE}</label></dt>
                <dd><input type="radio" class="radio" name="acme_demo_goodbye" value="1" <!-- IF ACME_DEMO_GOODBYE -->checked="checked"<!-- ENDIF -->/> {L_YES} &nbsp;
                    <input type="radio" class="radio" name="acme_demo_goodbye" value="0" <!-- IF not ACME_DEMO_GOODBYE -->checked="checked"<!-- ENDIF --> /> {L_NO}</dd>
            </dl>

            <p class="submit-buttons">
                <input class="button1" type="submit" id="submit" name="submit" value="{L_SUBMIT}" />&nbsp;
                <input class="button2" type="reset" id="reset" name="reset" value="{L_RESET}" />
            </p>

            {S_FORM_TOKEN}
        </fieldset>
    </form>

    <!-- INCLUDE overall_footer.html -->

The ``{S_FORM_TOKEN}`` template variable belongs to the `Form key`_ security
check. Other then that, the page just contains two radio buttons and two buttons
to submit or reset the form.

Migrations
==========

The module is now completed, but it does not show up so far. We need to add a
migration that installs the module, when the extension is enabled. The migration
files need to be in a directory called ``migrations``. In case of this demo
extension we only add the config value that is being set by the administrator
form and the category and module in the ACP.

.. code-block:: php

    <?php
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

    namespace acme\demo\migrations;

    use phpbb\db\migration\migration;

    class add_module extends migration
    {
        public function effectively_installed()
        {
            return isset($this->config['acme_demo_goodbye']);
        }

        static public function depends_on()
        {
            return array('\phpbb\db\migration\data\v31x\v314');
        }

        public function update_data()
        {
            return array(
                array('config.add', array('acme_demo_goodbye', 0)),

                array('module.add', array(
                    'acp',
                    'ACP_CAT_DOT_MODS',
                    'ACP_DEMO_TITLE'
                )),

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

If you want to learn more about migrations, please have a look at the
:doc:`../migrations/index` section.

When you now disable and reenable the extension in "ACP" > "Customise", the
module is going to be created and will then be accessible via the "ACP" >
"Extensions"

Only the language keys are missing, so we add some more language variables to
the array in ``language/en/demo.php``:

.. code-block:: php

        'ACP_DEMO_TITLE'         => 'Demo Module',
        'ACP_DEMO'               => 'Settings',
        'ACP_DEMO_GOODBYE'       => 'Should say goodbye?',
        'ACP_DEMO_SETTING_SAVED' => 'Settings have been saved successfully!',
