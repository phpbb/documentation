4. Templating
=============

4.i. General Templating
-----------------------

File naming
+++++++++++

Firstly templates now take the suffix ".html" rather than ".tpl". This was done simply to make the lives of some people easier wrt syntax highlighting, etc.

Variables
+++++++++

All template variables should be named appropriately (using underscores for spaces), language entries should be prefixed with ``L_``, system data with ``S_``, urls with ``U_``, javascript urls with ``UA_``, language to be put in javascript statements with ``LA_``, all other variables should be presented 'as is'.

``L_*`` template variables are automatically mapped to the corresponding language entry if the code does not set (and therefore overwrite) this variable specifically and if the language entry exists. For example ``{L_USERNAME}`` maps to ``$user->lang['USERNAME']``. The ``LA_*`` template variables are handled within the same way, but properly escaped so they can be put in javascript code. This should reduce the need to assign loads of new language variables in MODifications.

Blocks/Loops
++++++++++++

The basic block level loop remains and takes the form:

.. code:: html
	<!-- BEGIN loopname -->
		markup, {loopname.X_YYYYY}, etc.
	<!-- END loopname -->

A bit later loops will be explained further. To not irritate you we will explain conditionals as well as other statements first.

Including files
+++++++++++++++

Something that existed in 2.0.x which no longer exists in 3.x is the ability to assign a template to a variable. This was used (for example) to output the jumpbox. Instead (perhaps better, perhaps not but certainly more flexible) we now have INCLUDE. This takes the simple form:

.. code:: html
	<!-- INCLUDE filename -->

You will note in the 3.x templates the major sources start with <!-- INCLUDE overall_header.html --> or <!-- INCLUDE simple_header.html -->, etc. In 2.0.x control of "which" header to use was defined entirely within the code. In 3.x the template designer can output what they like. Note that you can introduce new templates (i.e. other than those in the default set) using this system and include them as you wish ... perhaps useful for a common "menu" bar or some such. No need to modify loads of files as with 2.0.x.

Added in **3.0.6** is the ability to include a file using a template variable to specify the file, this functionality only works for root variables (i.e. not block variables).

.. code:: html
	<!-- INCLUDE {FILE_VAR} -->

Template defined variables can also be utilised.

.. code:: html
	<!-- DEFINE $SOME_VAR = 'my_file.html' -->
	<!-- INCLUDE {$SOME_VAR} -->

PHP
+++

A contentious decision has seen the ability to include PHP within the template introduced. This is achieved by enclosing the PHP within relevant tags:

.. code:: html
	<!-- PHP -->
		echo "hello!";
	<!-- ENDPHP -->

You may also include PHP from an external file using:

.. code:: html
	<!-- INCLUDEPHP somefile.php -->

it will be included and executed inline.

.. note:: it is very much encouraged that template designers do not include PHP. The ability to include raw PHP was introduced primarily to allow end users to include banner code, etc. without modifying multiple files (as with 2.0.x). It was not intended for general use ... hence htps://www.phpbb.com will **not** make available template sets which include PHP. And by default templates will have PHP disabled (the admin will need to specifically activate PHP for a template).

Conditionals/Control structures
+++++++++++++++++++++++++++++++

The most significant addition to 3.x are conditions or control structures, "if something then do this else do that". The system deployed is very similar to Smarty. This may confuse some people at first but it offers great potential and great flexibility with a little imagination. In their most simple form these constructs take the form:

.. code:: html
	<!-- IF expr -->
		markup
	<!-- ENDIF -->

expr can take many forms, for example:

.. code:: html
	<!-- IF loop.S_ROW_COUNT is even -->
		markup
	<!-- ENDIF -->

This will output the markup if the S_ROW_COUNT variable in the current iteration of loop is an even value (i.e. the expr is TRUE). You can use various comparison methods (standard as well as equivalent textual versions noted in square brackets) including (``not, or, and, eq, neq, is`` should be used if possible for better readability):

.. code:: php
	== [eq]
	!= [neq, ne]
	<> (same as !=)
	!== (not equivalent in value and type)
	=== (equivalent in value and type)
	> [gt]
	< [lt]
	>= [gte]
	<= [lte]
	&& [and]
	|| [or]
	% [mod]
	! [not]
	+
	-
	*
	/
	,
	<< (bitwise shift left)
	>> (bitwise shift right)
	| (bitwise or)
	^ (bitwise xor)
	& (bitwise and)
	~ (bitwise not)
	is (can be used to join comparison operations)

Basic parenthesis can also be used to enforce good old BODMAS rules. Additionally some basic comparison types are defined:

.. code:: text
	even
	odd
	div

Beyond the simple use of IF you can also do a sequence of comparisons using the following:

.. code:: html
	<!-- IF expr1 -->
		markup
	<!-- ELSEIF expr2 -->
		markup
		.
		.
		.
	<!-- ELSEIF exprN -->
		markup
	<!-- ELSE -->
		markup
	<!-- ENDIF -->

Each statement will be tested in turn and the relevant output generated when a match (if a match) is found. It is not necessary to always use ELSEIF, ELSE can be used alone to match "everything else".

So what can you do with all this? Well take for example the colouration of rows in viewforum. In 2.0.x row colours were predefined within the source as either row color1, row color2 or row class1, row class2. In 3.x this is moved to the template, it may look a little daunting at first but remember control flows from top to bottom and it's not too difficult:

.. code:: html
	<table>
		<!-- IF loop.S_ROW_COUNT is even -->
			<tr class="row1">
		<!-- ELSE -->
			<tr class="row2">
		<!-- ENDIF -->
			<td>HELLO!</td>
		</tr>
	</table>

This will cause the row cell to be output using class row1 when the row count is even, and class row2 otherwise. The S_ROW_COUNT parameter gets assigned to loops by default. Another example would be the following:

.. code:: html
	<table>
		<!-- IF loop.S_ROW_COUNT > 10 -->
			<tr bgcolor="#FF0000">
		<!-- ELSEIF loop.S_ROW_COUNT > 5 -->
			<tr bgcolor="#00FF00">
		<!-- ELSEIF loop.S_ROW_COUNT > 2 -->
			<tr bgcolor="#0000FF">
		<!-- ELSE -->
			<tr bgcolor="#FF00FF">
		<!-- ENDIF -->
			<td>hello!</td>
		</tr>
	</table>

This will output the row cell in purple for the first two rows, blue for rows 2 to 5, green for rows 5 to 10 and red for remainder. So, you could produce a "nice" gradient effect, for example.

What else can you do? Well, you could use IF to do common checks on for example the login state of a user:

.. code:: html
	<!-- IF S_USER_LOGGED_IN -->
		markup
	<!-- ENDIF -->

This replaces the existing (fudged) method in 2.0.x using a zero length array and BEGIN/END.

Extended syntax for Blocks/Loops
++++++++++++++++++++++++++++++++

Back to our loops - they had been extended with the following additions. Firstly you can set the start and end points of the loop. For example:

.. code:: html
	<!-- BEGIN loopname(2) -->
		markup
	<!-- END loopname -->

Will start the loop on the third entry (note that indexes start at zero). Extensions of this are:

``loopname(2)``: Will start the loop on the 3rd entry
``loopname(-2)``: Will start the loop two entries from the end
``loopname(3,4)``: Will start the loop on the fourth entry and end it on the fifth
``loopname(3,-4)``: Will start the loop on the fourth entry and end it four from last

A further extension to begin is ``BEGINELSE``:

.. code:: html
	<!-- BEGIN loop -->
		markup
	<!-- BEGINELSE -->
		markup
	<!-- END loop -->

This will cause the markup between ``BEGINELSE`` and ``END`` to be output if the loop contains no values. This is useful for forums with no topics (for example) ... in some ways it replaces "bits of" the existing "switch_" type control (the rest being replaced by conditionals).

Another way of checking if a loop contains values is by prefixing the loops name with a dot:

.. code:: html
	<!-- IF .loop -->
		<!-- BEGIN loop -->
			markup
		<!-- END loop -->
	<!-- ELSE -->
		markup
	<!-- ENDIF -->

You are even able to check the number of items within a loop by comparing it with values within the IF condition:

.. code:: html
	<!-- IF .loop > 2 -->
		<!-- BEGIN loop -->
			markup
		<!-- END loop -->
	<!-- ELSE -->
		markup
	<!-- ENDIF -->

Nesting loops cause the conditionals needing prefixed with all loops from the outer one to the inner most. An illustration of this:

.. code:: html
	<!-- BEGIN firstloop -->
		{firstloop.MY_VARIABLE_FROM_FIRSTLOOP}

		<!-- BEGIN secondloop -->
			{firstloop.secondloop.MY_VARIABLE_FROM_SECONDLOOP}
		<!-- END secondloop -->
	<!-- END firstloop -->

Sometimes it is necessary to break out of nested loops to be able to call another loop within the current iteration. This sounds a little bit confusing and it is not used very often. The following (rather complex) example shows this quite good - it also shows how you test for the first and last row in a loop (i will explain the example in detail further down):

.. code:: html
	<!-- BEGIN l_block1 -->
		<!-- IF l_block1.S_SELECTED -->
			<strong>{l_block1.L_TITLE}</strong>
			<!-- IF S_PRIVMSGS -->

				<!-- the ! at the beginning of the loop name forces the loop to be not a nested one of l_block1 -->
				<!-- BEGIN !folder -->
					<!-- IF folder.S_FIRST_ROW -->
						<ul class="nav">
					<!-- ENDIF -->

					<li><a href="{folder.U_FOLDER}">{folder.FOLDER_NAME}</a></li>

					<!-- IF folder.S_LAST_ROW -->
						</ul>
					<!-- ENDIF -->
				<!-- END !folder -->

			<!-- ENDIF -->

			<ul class="nav">
			<!-- BEGIN l_block2 -->
				<li>
					<!-- IF l_block1.l_block2.S_SELECTED -->
						<strong>{l_block1.l_block2.L_TITLE}</strong>
					<!-- ELSE -->
						<a href="{l_block1.l_block2.U_TITLE}">{l_block1.l_block2.L_TITLE}</a>
					<!-- ENDIF -->
				</li>
			<!-- END l_block2 -->
			</ul>
		<!-- ELSE -->
			<a class="nav" href="{l_block1.U_TITLE}">{l_block1.L_TITLE}</a>
		<!-- ENDIF -->
	<!-- END l_block1 -->

Let us first concentrate on this part of the example:

.. code:: html
	<!-- BEGIN l_block1 -->
		<!-- IF l_block1.S_SELECTED -->
			markup
		<!-- ELSE -->
			<a class="nav" href="{l_block1.U_TITLE}">{l_block1.L_TITLE}</a>
		<!-- ENDIF -->
	<!-- END l_block1 -->

Here we open the loop ``l_block1`` and do some things if the value ``S_SELECTED`` within the current loop iteration is true, else we write the blocks link and title. Here, you see ``{l_block1.L_TITLE}`` referenced - you remember that ``L_*`` variables get automatically assigned the corresponding language entry? This is true, but not within loops. The ``L_TITLE`` variable within the loop l_block1 is assigned within the code itself.

Let's have a closer look at the markup:

.. code:: html
	<!-- BEGIN l_block1 -->
	.
	.
		<!-- IF S_PRIVMSGS -->

			<!-- BEGIN !folder -->
				<!-- IF folder.S_FIRST_ROW -->
					<ul class="nav">
				<!-- ENDIF -->

				<li><a href="{folder.U_FOLDER}">{folder.FOLDER_NAME}</a></li>

				<!-- IF folder.S_LAST_ROW -->
					</ul>
				<!-- ENDIF -->
			<!-- END !folder -->

		<!-- ENDIF -->
	.
	.
	<!-- END l_block1 -->

The ``<!-- IF S_PRIVMSGS -->`` statement clearly checks a global variable and not one within the loop, since the loop is not given here. So, if ``S_PRIVMSGS`` is true we execute the shown markup. Now, you see the ``<!-- BEGIN !folder -->`` statement. The exclamation mark is responsible for instructing the template engine to iterate through the main loop folder. So, we are now within the loop folder - with ``<!-- BEGIN folder -->`` we would have been within the loop ``l_block1.folder`` automatically as is the case with ``l_block2``:

.. code:: html
	<!-- BEGIN l_block1 -->
	.
	.
		<ul class="nav">
		<!-- BEGIN l_block2 -->
			<li>
				<!-- IF l_block1.l_block2.S_SELECTED -->
					<strong>{l_block1.l_block2.L_TITLE}</strong>
				<!-- ELSE -->
					<a href="{l_block1.l_block2.U_TITLE}">{l_block1.l_block2.L_TITLE}</a>
				<!-- ENDIF -->
			</li>
		<!-- END l_block2 -->
		</ul>
	.
	.
	<!-- END l_block1 -->

You see the difference? The loop l_block2 is a member of the loop l_block1 but the loop folder is a main loop.

Now back to our folder loop:

.. code:: html
	<!-- IF folder.S_FIRST_ROW -->
		<ul class="nav">
	<!-- ENDIF -->

	<li><a href="{folder.U_FOLDER}">{folder.FOLDER_NAME}</a></li>

	<!-- IF folder.S_LAST_ROW -->
		</ul>
	<!-- ENDIF -->

You may have wondered what the comparison to S_FIRST_ROW and S_LAST_ROW is about. If you haven't guessed already - it is checking for the first iteration of the loop with S_FIRST_ROW and the last iteration with S_LAST_ROW. This can come in handy quite often if you want to open or close design elements, like the above list. Let us imagine a folder loop build with three iterations, it would go this way:

.. code:: html
	<ul class="nav"> <!-- written on first iteration -->
		<li>first element</li> <!-- written on first iteration -->
		<li>second element</li> <!-- written on second iteration -->
		<li>third element</li> <!-- written on third iteration -->
	</ul> <!-- written on third iteration -->

As you can see, all three elements are written down as well as the markup for the first iteration and the last one. Sometimes you want to omit writing the general markup - for example:

.. code:: html
	<!-- IF folder.S_FIRST_ROW -->
		<ul class="nav">
	<!-- ELSEIF folder.S_LAST_ROW -->
		</ul>
	<!-- ELSE -->
		<li><a href="{folder.U_FOLDER}">{folder.FOLDER_NAME}</a></li>
	<!-- ENDIF -->

would result in the following markup:

.. code:: html
	<ul class="nav"> <!-- written on first iteration -->
		<li>second element</li> <!-- written on second iteration -->
	</ul> <!-- written on third iteration -->

Just always remember that processing is taking place from top to bottom.

Forms
+++++

If a form is used for a non-trivial operation (i.e. more than a jumpbox), then it should include the {S_FORM_TOKEN} template variable.

.. code:: html
	<form method="post" id="mcp" action="{U_POST_ACTION}">

		<fieldset class="submit-buttons">
			<input type="reset" value="{L_RESET}" name="reset" class="button2" />
			<input type="submit" name="action[add_warning]" value="{L_SUBMIT}" class="button1" />
			{S_FORM_TOKEN}
		</fieldset>
	</form>


4.ii. Styles Tree
-----------------

When basing a new style on an existing one, it is not necessary to provide all the template files. By declaring the base style name in the **parent** field in the **Style configuration file(cfg)**, the style can be set to reuse template files from the parent style.

Style cfg files are simple name-value lists with the information necessary for installing a style. The important part of the style configuration file is assigning an unique name.

The effect of doing so is that the template engine will use the template files in the new style where they exist, but fall back to files in the parent style otherwise.

We strongly encourage the use of parent styles for styles based on the bundled styles, as it will ease the update procedure.

.. code:: php
	# General Information about this style
	name = Custom Style
	copyright = © phpBB Limited, 2007
	style_version = 3.2.0-b1
	phpbb_version = 3.2.0-b1

	# Defining a different template bitfield
	# template_bitfield = lNg=

	# Parent style
	# Set value to empty or to this style's name if this style does not have a parent style
	parent = prosilver

4.iii. Template Events
----------------------

Template events must follow this format: ``<!-- EVENT event_name -->``

Using the above example, files named ``event_name.html`` located within extensions will be injected into the location of the event.

Template event naming guidelines
++++++++++++++++++++++++++++++++

- An event name must be all lowercase, with each word separated by an underscore.
- An event name must briefly describe the location and purpose of the event.
- An event name must end with one of the following suffixes:
	- ``_prepend`` - This event adds an item to the beginning of a block of related items, or adds to the beginning of individual items in a block.
	- ``_append`` - This event adds an item to the end of a block of related items, or adds to the end of individual items in a block.
	- ``_before`` - This event adds content directly before the specified block
	- ``_after`` - This event adds content directly after the specified block

Template event documentation
++++++++++++++++++++++++++++

Events must be documented in ``phpBB/docs/events.md`` in alphabetical order based on the event name. The format is as follows:

- An event found in only one template file:

.. code:: php
	event_name
	===
	* Location: styles/<style_name>/template/filename.html
	* Purpose: A brief description of what this event should be used for.
	This may span multiple lines.
	* Since: Version since when the event was added

- An event found in multiple template files:

.. code:: php
	event_name
	===
	* Locations:
	    + first/file/path.html
	    + second/file/path.html
	* Purpose: Same as above.
	* Since: 3.2.0-b1

- An event that is found multiple times in a file should have the number of instances in parenthesis next to the filename.

.. code:: php
	event_name
	===
	* Locations:
	    + first/file/path.html (2)
	    + second/file/path.html
	* Purpose: Same as above.
	* Since: 3.2.0-b1

- An actual example event documentation:

.. code:: php
	forumlist_body_last_post_title_prepend
	====
	* Locations:
	    + styles/prosilver/template/forumlist_body.html
	    + styles/subsilver2/template/forumlist_body.html
	* Purpose: Add content before the post title of the latest post in a forum on the forum list.
	* Since: 3.2.0-a1
