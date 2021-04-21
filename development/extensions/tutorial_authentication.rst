========================
Tutorial: Authentication
========================

Introduction
============

phpBB 3.1 introduced built-in authentication plugins which you can extend or
create your own.

This tutorial explains:

* `Authentication Providers`_
* `OAuth Providers`_

Authentication Providers
========================
phpBB 3.1 introduced support for external authentication plugins that may be used in place of the
built-in authentication providers. Only one provider may currently be active at a
time and the active one is chosen from the ACP.

Creating an Authentication Provider
-----------------------------------
Authentication providers in phpBB require a minimum of two files: a PHP class
and a YAML service file.

The class file
^^^^^^^^^^^^^^
The provider class must implement the ``\phpbb\auth\provider\provider_interface`` in order to
ensure proper functionality. However, it is recommended to extend
``\phpbb\auth\provider\base`` so as to not implement unneeded methods and to ensure
that the provider will not break due to an update to the interface. An example
authentication provider class is show below:

.. code-block:: php

    <?php

    namespace acme\demo\auth\provider;

    /**
     * Database authentication provider for phpBB3
     *
     * This is for authentication via the integrated user table
     */
    class db2 extends \phpbb\auth\provider\base
    {
        /** @var \phpbb\db\driver\driver_interface $db */
        protected $db;

        /**
         * Database Authentication Constructor
         *
         * @param \phpbb\db\driver\driver_interface $db
         */
        public function __construct(\phpbb\db\driver\driver_interface $db)
        {
            $this->db = $db;
        }

        /**
         * {@inheritdoc}
         */
        public function login($username, $password)
        {
            // Auth plugins get the password untrimmed.
            // For compatibility we trim() here.
            $password = trim($password);

            // do not allow empty password
            if (!$password)
            {
                return [
                    'status'    => LOGIN_ERROR_PASSWORD,
                    'error_msg' => 'NO_PASSWORD_SUPPLIED',
                    'user_row'  => ['user_id' => ANONYMOUS],
                ];
            }

            if (!$username)
            {
                return [
                    'status'    => LOGIN_ERROR_USERNAME,
                    'error_msg' => 'LOGIN_ERROR_USERNAME',
                    'user_row'  => ['user_id' => ANONYMOUS],
                ];
            }

            $username_clean = utf8_clean_string($username);

            $sql = 'SELECT user_id, username, user_password, user_passchg, user_pass_convert, user_email, user_type, user_login_attempts
                FROM ' . USERS_TABLE . "
                WHERE username_clean = '" . $this->db->sql_escape($username_clean) . "'";
            $result = $this->db->sql_query($sql);
            $row = $this->db->sql_fetchrow($result);
            $this->db->sql_freeresult($result);

            // Successful login... set user_login_attempts to zero...
            return [
                'status'    => LOGIN_SUCCESS,
                'error_msg' => false,
                'user_row'  => $row,
            ];
        }
    }

The service file
^^^^^^^^^^^^^^^^
For proper `dependency injection <https://wiki.phpbb.com/Dependency_Injection_Container>`_
the provider must be added to ``services.yml``. The name of the service 
must be in the form of ``auth.provider.<service name>`` in order for phpBB to register it.
The arguments are those of the provider's constructor and may be empty if no arguments are
necessary. The provider must be tagged with ``{ name: auth.provider }`` in order
for the class to be made available in phpBB.

.. code-block:: yaml

    services:
        auth.provider.db2:
            class: acme\demo\auth\provider\db2
            arguments:
                - '@dbal.conn'
            tags:
                - { name: auth.provider }

The template file
^^^^^^^^^^^^^^^^^
Following the above steps renders the authentication provider visible in the ACP.
However, to allow an admin to configure your plugin the available fields need to
be created in order to reach the configuration from the php-auth-provider plugin.
This interface is configured in HTML format in ``adm/style/auth_provider_<providername>.html``.

For example, the sample below is based on existing LDAP terms used to configure an HTTPS server:

.. code-block:: html

    <fieldset id="auth_test_settings">
        <legend>{{ TEST }}</legend>
        <dl>
            <dt><label for="https_server">{{ TEST_SERVER ~ lang('COLON') }}</label><br /><span>{{ TEST_SERVER_EXPLAIN }}</span></dt>
            <dd><input type="text" id="https_server" size="40" name="config[https_server]" value="{{ AUTH_HTTPS_SERVER }}" /></dd>
        </dl>
    </fieldset>

This value can then be retrieved from the ``<provider>.php`` file like this:

.. code-block:: php

    $domain = $this->config['https_server'];

OAuth Providers
===============
phpBB 3.1 ships with a new authentication provider: OAuth. This provider is
based on the `Lusitanian/PHPoAuthLib <https://github.com/Lusitanian/PHPoAuthLib>`_
library.

Enabling an OAuth Provider
--------------------------
To enable a new OAuth service in phpBB you need only create two files in your
extension. The class file which defines functionality necessary for phpBB to
get the data it needs from the service, and the service file which allows
phpBB to find the class. To find out how you should most likely make calls
to the OAuh service, it is recommended that you refer to the included OAuth
services and to the examples provided by
`Lusitanian/PHPoAuthLib <https://github.com/Lusitanian/PHPoAuthLib>`_.

The example files below show the minimum needed to enable an OAuth service in
phpBB. They are copies of the bitly service implementation from phpBB3's
develop branch.

The Class file
^^^^^^^^^^^^^^
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

    namespace phpbb\auth\provider\oauth\service;

    /**
    * Bitly OAuth service
    */
    class bitly extends \phpbb\auth\provider\oauth\service\base
    {
        /**
        * phpBB config
        *
        * @var \phpbb\config\config
        */
        protected $config;

        /**
        * phpBB request
        *
        * @var \phpbb\request\request_interface
        */
        protected $request;

        /**
        * Constructor
        *
        * @param    \phpbb\config\config               $config
        * @param    \phpbb\request\request_interface   $request
        */
        public function __construct(\phpbb\config\config $config, \phpbb\request\request_interface $request)
        {
            $this->config = $config;
            $this->request = $request;
        }

        /**
        * {@inheritdoc}
        */
        public function get_service_credentials()
        {
            return [
                'key'     => $this->config['auth_oauth_bitly_key'],
                'secret'  => $this->config['auth_oauth_bitly_secret'],
            ];
        }

        /**
        * {@inheritdoc}
        */
        public function perform_auth_login()
        {
            if (!($this->service_provider instanceof \OAuth\OAuth2\Service\Bitly))
            {
                throw new \phpbb\auth\provider\oauth\service\exception('AUTH_PROVIDER_OAUTH_ERROR_INVALID_SERVICE_TYPE');
            }

            // This was a callback request from bitly, get the token
            $this->service_provider->requestAccessToken($this->request->variable('code', ''));

            // Send a request with it
            $result = json_decode($this->service_provider->request('user/info'), true);

            // Return the unique identifier returned from bitly
            return $result['data']['login'];
        }

        /**
        * {@inheritdoc}
        */
        public function perform_token_auth()
        {
            if (!($this->service_provider instanceof \OAuth\OAuth2\Service\Bitly))
            {
                throw new \phpbb\auth\provider\oauth\service\exception('AUTH_PROVIDER_OAUTH_ERROR_INVALID_SERVICE_TYPE');
            }

            // Send a request with it
            $result = json_decode($this->service_provider->request('user/info'), true);

            // Return the unique identifier returned from bitly
            return $result['data']['login'];
        }
    }

The Service File
^^^^^^^^^^^^^^^^

In the service file, the name of the service must be in the form of
``auth.provider.oauth.service.<service name>`` in order for phpBB to
properly recognise it.

.. code-block:: yaml

    services:
        auth.provider.oauth.service.bitly:
            class: phpbb\auth\provider\oauth\service\bitly
            arguments:
                - '@config'
                - '@request'
            tags:
                - { name: auth.provider.oauth.service }
