=======
Request
=======

.. contents:: Table of Contents
   :depth: 3

Introduction
============
The request class contains all request data and provide a clear interface to interact with that data.
Preventing direct access to ``$_GET``, ``$_POST``, ``$_REQUEST``, et cetera.
The request class should be fully backwards compatible and allow for the complete removal of any super global access.

Information
-----------

:Class:  :class:`\\phpbb\\request\\request`
:Interface:  :class:`\\phpbb\\request\\request_interface`
:Declaration:  ``- '@request'``

Super globals
-------------
With this request class in place, the usage of `Super globals <https://www.php.net/manual/en/language.variables.superglobals.php>`_ should no longer be necessary and when possible avoided.
Meaning that there should be no need to use any of the ``$_GET``, ``$_POST``, ``$_REQUEST``, ``$_COOKIE``, ``$_FILES`` and ``$_SERVER`` variables.

The request class provides an additional layer of security for handling request data and user input.
Properly sanitizing the input and casting the variables to the expected types, such as strings, integers and (multidimensional) arrays.

Functions
=========
Below you will find some of the more commonly used functions from the request class.
Each function will have corresponding code samples and a table explaining the function's parameters.

is_ajax
-------
Checks whether the current request is an AJAX request.
Meaning that the request is made as an XMLHttpRequest.
This can be useful for returning different responses.

.. code-block:: php
   :caption: Example of checking for an AJAX request

    if ($request->is_set_post('submit'))
    {
    	$message = $language->lang('CONFIG_UPDATED');

    	if ($request->is_ajax())
    	{
    		// Send a JSON response for an AJAX request
    		$json_response = new \phpbb\json_response();

    		return $json_response->send([
    			'MESSAGE_TITLE'	=> $language->lang('INFORMATION');
    			'MESSAGE_TEXT'	=> $message,
    		]);
    	}

    	// Include a back link for a non-AJAX request
    	$u_back = $helper->route('my_route');
    	$message .= '<br><br>' . $language->lang('RETURN_PAGE', '<a href="' . $u_back . '">', '</a>');

    	return $helper->message($message);
    }

is_secure
---------
Checks if the current request is happening over a secure protocol: HTTPS.
Useful when having to create a protocol prefix for a url or when making API calls.

.. code-block:: php
   :caption: Example of checking a secure connection

   $url = ($request->is_secure() ? 'https://' : 'http://') . $server_name;

   $recaptcha_server = $request->is_secure() ? $recaptcha_server_secure : $recaptcha_server;

is_set
------
Checks whether a certain variable is set in one of the super global arrays.
Optionally you can specify a specific super global in which the variable should be set.
If no super global is specified, it will default to the ``REQUEST`` super global, which contains ``GET``, ``POST`` and ``COOKIE``.

.. code-block:: php
   :caption: Example of checking various super globals

   $print = $request->variable('print');
   $start = $request->variable('start', \phpbb\request\request_interface::GET);
   $submit = $request->variable('submit', \phpbb\request\request_interface::POST);
   $session = $request->variable('user_sid', \phpbb\request\request_interface::COOKIE);

Parameters
++++++++++

.. csv-table::
    :header: "Parameter", "Description"
    :delim: #

    **variable**     # The name of the variable to check
    **super_global** # The super global to check within for the variable. |br| Can be any of ``GET|POST|REQUEST|COOKIE|SERVER|FILES``. |br| Defaults to ``REQUEST``.

is_set_post
-----------
Checks whether a certain variable was sent via a ``POST`` request.
To make sure that a request was sent using ``POST`` you should call this function on at least one variable.
This is a short hand for ``$request->variable('variable', \phpbb\request\request_interface::POST);``.

.. code-block:: php
   :caption: Example of checking POST variables

   $submit = $request->is_set_post('submit');
   $preview = $request->is_set_post('preview');

   if ($submit || $preview)
   {
      // The form was submitted with a POST request
   }

Parameters
++++++++++

.. csv-table::
    :header: "Parameter", "Description"
    :delim: #

    **variable** # The name of the variable to check

variable
--------
This is the central function for handling any input.
All variables in ``GET`` or ``POST`` requests should be retrieved through this function to maximise security.

The variable name should be the value of HTML input's name attribute to retrieve.
So for ``<input name="subject" type="text">`` the variable name is ``subject``.

The default value should be of the exact same type of the expected input.
This is necessary, as the retrieved variables are type casted to the exact same type.
If no variable was available in the request, it will return the provided default value.

When the value that is being requested is a string or an array containing strings, the ``multibyte`` parameter should be set to ``true``.
Or better said, whenever the requested value may contain any UTF-8 characters.
Meaning you will not have to run the returned value through ``utf8_normalize_nfc``.
If set to ``false``, it will cause all bytes outside the ASCII range *(0-127)* to be replaced with question marks.

.. code-block:: php
   :caption: Example of default usage

   $int = $request->variable('integer', 0);
   $array1 = $request->variable('array1', [0]);
   $array2 = $request->variable('array2', [0 => ''], true);
   $string = $request->variable('string', '', true);

   // Make sure to type cast the defaults when necessary
   $limit = $request->variable('topics_per_page', (int) $config['topics_per_page']);
   $subject = $request->variable('subject', $row['post_subject'], true);

It is also possible to specify from which super global the variable should be retrieved.
This can help ensuring the correct variable is returned or the form is submitted through the expected manner.

.. code-block:: php
   :caption: Example of specifying a super global

   $start = $request->variable('start', 0, false, \phpbb\request\request_interface::GET);
   $confirm = $request->variable('confirm', '', true, \phpbb\request\request_interface::POST);
   $cookie_data['u'] = $request->variable($config['cookie_name'] . '_u', 0, false, \phpbb\request\request_interface::COOKIE);

If the default value is an array, it is possible to nest it as deeply as is required.
There are no limitations for the nested depth.

.. code-block:: php
   :caption: Example of nesting arrays for default value

   $forum_ids = $request->variable('forum_ids', [0]);
   $user_notes = $request->variable('user_notes', [0 => ['']], true);

   // [forum_id => [user_id => [notes]]]
   $user_notes_per_forum = $request->variable('user_notes_per_forum', [0 => [0 => ['']]], true);

An additional capability is the path syntax.
This allows you to access a single value at a deep location (nested input) while making sure the types are still correct.
This can be achieved by passing an array as the variable name.
Each value in this array represent a key for the request array.
The nesting increased with each value provided.

.. code-block:: php
   :caption: Example of the path syntax

   /**
    * HTML:
    * <textarea name="user_notes_per_forum[10][2][]">An initial note</textarea>
    * <textarea name="user_notes_per_forum[10][2][]">A secondary note</textarea>
    *
    * REQUEST:
    * 'user_notes_per_forum' = [10 => [2 => ['An initial note', 'A secondary note']]]
    */

   $note = $request->variable(['user_notes_per_forum', 10, 2, 1], '', true);

   /**
    * This will return the secondary note,
    * for the forum identifier of 10
    * and the user identifier of 2.
    * Please note that the last array is 0-based.
    */

Parameters
++++++++++

.. csv-table::
    :header: "Parameter", "Description"
    :delim: #

    **variable**     # The name of the variable to retrieve
    **default**      # The default value with the correct variable type
    **multibyte**    # Whether or not the variable may contain any UTF-8 characters
    **super_global** # The super global to check within for the variable. |br| Can be any of ``GET|POST|REQUEST|COOKIE|SERVER|FILES``. |br| Defaults to ``REQUEST``.

file
----
This function is a shortcut to retrieve ``FILES`` variables.
It returns the uploaded file's information, or an empty array if the variable does not exist in ``$_FILES``.
This is a short hand for ``$request->variable('variable', ['name' => 'none'], true, \phpbb\request\request_interface::FILES)``

The variable name should be the value of HTML input's name attribute to retrieve.
So for ``<input name="attachment" type="file">`` the variable name is ``attachment``.

.. code-block:: php
   :caption: Example of retrieving a file

    $upload_file = $request->file('avatar_upload_file');

    if (!empty($upload_file['name']))
    {
    	$file = $upload->handle_upload('files.types.form', 'avatar_upload_file');
    }

Parameters
++++++++++

.. csv-table::
    :header: "Parameter", "Description"
    :delim: #

    **variable** # The name of the HTML file input's name attribute

header
------
This function is a shortcut to retrieve the value of the client's HTTP headers.

.. code-block:: php
   :caption: Example of retrieving headers

    // Basic client information
    $browser		= $request->header('User-Agent');
    $referer		= $request->header('Referer');
    $forwarded_for	= $request->header('X-Forwarded-For');

    // Client's accepted language
    if ($request->header('Accept-Language'))
    {
    	$accept_languages = explode(',', $request->header('Accept-Language'));

    	// ...
    }

Parameters
++++++++++

.. csv-table::
    :header: "Parameter", "Description"
    :delim: #

    **variable** # The name of the header to retrieve
    **default**  # The default value with the correct variable type |br| Defaults to an empty string: ``''``

server
------
This function is a shortcut to retrieve ``SERVER`` variables.
It also provides a fallback to ``getenv()`` as some CGI setups may need it.

.. code-block:: php
   :caption: Example of retrieving SERVER variables

    $script_name = htmlspecialchars_decode($request->server('REQUEST_URI'));
    $script_name = ($pos = strpos($script_name, '?')) !== false ? substr($script_name, 0, $pos) : $script_name;

    $server_name = htmlspecialchars_decode($request->header('Host', $request->server('SERVER_NAME')));
    $server_name = (string) strtolower($server_name);

    $server_port = $request->server('SERVER_PORT', 0);

Parameters
++++++++++

.. csv-table::
    :header: "Parameter", "Description"
    :delim: #

    **variable** # The name of the variable to retrieve
    **default**  # The default value with the correct variable type |br| Defaults to an empty string: ``''``

overwrite
---------
This function allows to overwrite or set a value in one of the super global arrays.
Changes which are performed on the super globals directly will **not** have any effect on the results of other methods the request class provides.
|br| Meaning that changing a super global variable like so ``$_POST['variable'] = 'changed';``,
|br| will not change the returned value for ``$request->variable('variable', '', true);``.

.. warning::

   Using this function should be avoided if possible! |br|
   It will consume twice the amount of memory of the value.

.. code-block:: php
   :caption: Example of overwriting a variable

    // Reset start parameter if we jumped from the quickmod dropdown
    if ($request->variable('start', 0))
    {
    	$request->overwrite('start', 0);
    }

.. code-block:: php
   :caption: Example of unsetting a variable in a specific super global

    if ($error)
    {
    	$request->overwrite('confirm', null, \phpbb\request\request_interface::POST);
    	$request->overwrite('confirm_key', null, \phpbb\request\request_interface::POST);
    }

Parameters
++++++++++

.. csv-table::
    :header: "Parameter", "Description"
    :delim: #

    **variable**     # The name of the variable that should be overwritten
    **value**        # The value the variable should be set at. |br| Setting it to ``null`` will unset the variable.
    **super_global** # The super global in which the variable should be changed. |br| Can be any of ``GET|POST|REQUEST|COOKIE|SERVER|FILES``. |br| Defaults to ``REQUEST``.

variable_names
--------------
This function returns all variable names for a specific super global.
Optionally you can specify a specific super global in which the variable should be set.
If no super global is specified, it will default to the ``REQUEST`` super global, which contains ``GET``, ``POST`` and ``COOKIE``.
It will then return all the names *(keys)* that exist for that super global.

.. code-block:: php
   :caption: Example of retrieving and iterating over a super global's variables

    // Converts query string (GET) parameters in request into hidden fields.
    $hidden = '';
    $names = $request->variable_names(\phpbb\request\request_interface::GET);

    foreach ($names as $name)
    {
    	// Sessions are dealt with elsewhere, omit sid always
    	if ($name == 'sid')
    	{
    		continue;
    	}

    	$value = $request->variable($name, '', true);
    	$get_value = $request->variable($name, '', true, \phpbb\request\request_interface::GET);

    	if ($value === $get_value)
    	{
    		$escaped_name = phpbb_quoteattr($name);
    		$escaped_value = phpbb_quoteattr($value);

    		$hidden .= "<input type='hidden' name=$escaped_name value=$escaped_value />";
    	}
    }

    return $hidden;

Parameters
++++++++++

.. csv-table::
    :header: "Parameter", "Description"
    :delim: #

    **super_global** # The super global to get the variable names from. |br| Can be any of ``GET|POST|REQUEST|COOKIE|SERVER|FILES``. |br| Defaults to ``REQUEST``.


get_super_global
----------------
This function returns the original array of the requested super global.
Optionally you can specify a specific super global in which the variable should be set.
If no super global is specified, it will default to the ``REQUEST`` super global, which contains ``GET``, ``POST`` and ``COOKIE``.
It will then return the original array with all the variables for that super global.

.. code-block:: php
   :caption: Example of retrieving all POST variables

    // Any post data could be necessary for auth (un)linking
    $link_data = $request->get_super_global(\phpbb\request\request_interface::POST);

    // The current user_id is also necessary
    $link_data['user_id'] = $user->data['user_id'];

    // Tell the provider that the method is auth_link not login_link
    $link_data['link_method'] = 'auth_link';

    if (!empty($link_data['link']))
    {
    	$auth_provider->link_account($link_data);
    }
    else
    {
    	$auth_provider->unlink_account($link_data);
    }

Parameters
++++++++++

.. csv-table::
    :header: "Parameter", "Description"
    :delim: #

    **super_global** # The super global to get the original array from. |br| Can be any of ``GET|POST|REQUEST|COOKIE|SERVER|FILES``. |br| Defaults to ``REQUEST``.

request_var
===========

.. admonition:: Deprecated
   :class: error

   This function is deprecated since phpBB :guilabel:`3.1.0`

The ``request_var`` function was used back in the days of phpBB :guilabel:`2.x` and :guilabel:`3.0`, but has been **deprecated** ever since.
Meaning that this function should no longer be used.
Instead use the phpBB request class's variable_ function, which has more options and capabilities.

.. |br| raw:: html

	<br>
