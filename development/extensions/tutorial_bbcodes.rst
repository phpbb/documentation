==============================
Tutorial: Working With BBCodes
==============================

Introduction
============

phpBB 3.2 introduced an all new BBCode engine powered by the s9e/TextFormatter
library. This tutorial explains several ways extensions can tap into the new
BBCode engine to manipulate and create more powerful BBCodes.

This tutorial explains:

* `Toggle BBCodes On / Off`_
* `Executing PHP Code With BBCodes`_
* `Template Parameters`_
* `Registering Custom Variables`_
* `Enable Text Formatter Plugins`_

Toggle BBCodes On / Off
=======================

BBCodes and other tags can be toggled before or after parsing using any of the following events:

.. csv-table::
   :header: "Event", "Description"
   :delim: |

   ``core.text_formatter_s9e_parser_setup`` | Triggers once, when the text Parser service is first created.
   ``core.text_formatter_s9e_parse_before`` | Triggers every time text is parsed, before parsing begins.
   ``core.text_formatter_s9e_parse_after`` | Triggers every time text is parsed, **after** parsing has completed. This can be used to restore values to their original state, for example.

Most common operations are available through the Parser service using the ``phpbb\textformatter\parser_interface`` API.
This includes the functions:

.. csv-table::
    :header: "Function", "Description"
    :delim: |

    ``disable_bbcode($name)`` | Disable a BBCode
    ``disable_bbcodes()`` | Disable BBCodes in general
    ``disable_censor()`` | Disable the censor
    ``disable_magic_url()`` | Disable magic URLs
    ``disable_smilies()`` | Disable smilies
    ``enable_bbcode($name)`` | Enable a specific BBCode
    ``enable_bbcodes()`` | Enable BBCodes in general
    ``enable_censor()`` | Enable the censor
    ``enable_magic_url()`` | Enable magic URLs
    ``enable_smilies()`` | Enable smilies

For more advanced functions, the instance of ``s9e\TextFormatter\Parser`` can be retrieved via ``get_parser()`` to access its API.

The following sample code shows how BBCodes can be toggled and manipulated using a PHP event listener:

.. code-block:: php

    class listener implements EventSubscriberInterface
    {
        public static function getSubscribedEvents()
        {
            return [
                'core.text_formatter_s9e_parse_before' => 'toggle_bbcodes',
            ];
        }

        public function toggle_bbcodes($event)
        {
            // Get the parser service: \phpbb\textformatter\parser_interface
            $service = $event['parser'];

            // Disable the [color] BBCode through the parser service
            $service->disable_bbcode('color');

            // Set the [url] BBCode to only parse the first occurrence.
            // Note this requires an instance of \s9e\TextFormatter\Parser
            $service->get_parser()->setTagLimit('URL', 1);
        }
    }

.. seealso::

    - `phpBB API Documentation <https://area51.phpbb.com/docs/code/3.3.x/phpbb/textformatter/parser_interface.html>`_
    - `Runtime configuration - s9e\\TextFormatter <https://s9etextformatter.readthedocs.io/Getting_started/Runtime_configuration/>`_


Executing PHP Code With BBCodes
===============================

Extensions can configure BBCodes to execute PHP functions. This makes it possible to create BBCodes that do a lot
more than just generically format text.

In the following simple example, we re-configure the ``QUOTE`` tag (which handles the ``[quote]`` BBCode) to run a PHP
method to read and change its attributes during parsing based on who is being quoted in the BBCode.

.. code-block:: php

    class listener implements EventSubscriberInterface
    {
        public static function getSubscribedEvents()
        {
            return [
                'core.text_formatter_s9e_configure_after' => 'configure_quotes'
            ];
        }

        public function configure_quotes($event)
        {
            // Add self::filter_quote() to filter the QUOTE tag that handles quotes
            $event['configurator']->tags['QUOTE']->filterChain
                ->append([__CLASS__, 'filter_quote']);
        }

        static public function filter_quote(\s9e\TextFormatter\Parser\Tag $tag)
        {
            if (!$tag->hasAttribute('author'))
            {
                // If the author is empty, we attribute the quote to Mark Twain
                $tag->setAttribute('author', 'Mark Twain');
            }
            elseif (stripos($tag->getAttribute('author'), 'Gary Oak') !== false)
            {
                // If the author is Gary Oak we invalidate the tag to disallow it
                $tag->invalidate();

                // Return FALSE for backward compatibility
                return false;
            }

            // We return TRUE for backward compatibility, to indicate that the tag is allowed
            return true;
        }
    }

.. seealso::

    - `Attribute filters - s9e\\TextFormatter <https://s9etextformatter.readthedocs.io/Filters/Attribute_filters/>`_
    - `Tag filters - s9e\\TextFormatter <https://s9etextformatter.readthedocs.io/Filters/Tag_filters/>`_
    - `Callback signatures - s9e\\TextFormatter <https://s9etextformatter.readthedocs.io/Filters/Callback_signature/>`_


Template Parameters
===================

Some of phpBB's template variables can be used in BBCodes to produce dynamic output. For example, to create a BBCode
that will only show its content to registered users.

Default phpBB template parameters:

.. csv-table::
    :header: "Variable", "Description"
    :delim: |

    ``S_IS_BOT`` | Whether the current user is a bot.
    ``S_REGISTERED_USER`` | Whether the current user is registered.
    ``S_USER_LOGGED_IN`` | Whether the current user is logged in.
    ``S_VIEWCENSORS`` | Whether the current user's preferences are set to hide censored words.
    ``S_VIEWFLASH`` | Whether the current user's preferences are set to display Flash objects.
    ``S_VIEWIMG`` | Whether the current user's preferences are set to display images.
    ``S_VIEWSMILIES`` | Whether the current user's preferences are set to display smilies.
    ``STYLE_ID`` | ID of the current style.
    ``T_SMILIES_PATH`` | Path to the smilies directory.

In the following example, we will use the Configurator to create a custom BBCode dynamically that only registered
users can see the contents of:

::

    [noguests]{TEXT}[/noguests]

.. code-block:: php

    class listener implements EventSubscriberInterface
    {
        public static function getSubscribedEvents()
        {
            return [
                'core.text_formatter_s9e_configure_after'	=> 'configure_noguests',
            ];
        }

        public function configure_noguests($event)
        {
            // Get the BBCode configurator
            $configurator = $event['configurator'];

            // Let's unset any existing BBCode that might already exist
            unset($configurator->BBCodes['noguests']);
            unset($configurator->tags['noguests']);

            // Let's create the new BBCode
            $configurator->BBCodes->addCustom(
                '[noguests]{TEXT}[/noguests]',
                '<xsl:choose>
                    <xsl:when test="$S_USER_LOGGED_IN and not($S_IS_BOT)">
                        <div>{TEXT}</div>
                    </xsl:when>
                    <xsl:otherwise>
                        <div>Only registered users can read this content</div>
                    </xsl:otherwise>
                </xsl:choose>'
            );
        }
    }

.. note::

    Notice in the code above, a test is used to check the value of the template variable ``S_USER_LOGGED_IN``
    and the appropriate BBCode HTML output is generated.

Template parameters can also be set using any of the following events:

.. csv-table::
    :header: "Event", "Description"
    :delim: |

    ``core.text_formatter_s9e_renderer_setup`` | Triggers once, when the renderer service is created.
    ``core.text_formatter_s9e_render_before`` | Triggers every time a text is rendered, before the HTML is produced.
    ``core.text_formatter_s9e_render_after`` | Triggers every time a text is rendered, *after* the HTML is produced. It can be used to restore values to their original state.

In the following simple example, we set a template parameter to generate a random number in every text.
The number changes every time a new text is rendered. Although this serves no practical application, it
does illustrate how this can be used in conjunction with the events and techniques above to pragmatically create
your own template parameters, in addition to the default one's already available in phpBB.

.. code-block:: php

    class listener implements EventSubscriberInterface
    {
        public static function getSubscribedEvents()
        {
            return [
                'core.text_formatter_s9e_render_before' => 'set_random'
            ];
        }

        public function set_random($event)
        {
            $event['renderer']->get_renderer()->setParameter('RANDOM', mt_rand());
        }
    }


.. seealso::

    - `Template parameters - s9e\\TextFormatter <https://s9etextformatter.readthedocs.io/Templating/Template_parameters/>`_
    - `Use template parameters - s9e\\TextFormatter <https://s9etextformatter.readthedocs.io/Plugins/BBCodes/Use_template_parameters/>`_


Registering Custom Variables
============================

It is possible to register custom variables to be used during parsing. For instance, phpBB uses
``max_font_size`` to limit the values used in the ``[font]`` tag dynamically. Callbacks used during parsing
must be static and serializable as the parser itself is cached in a serialized form. However, custom variables
are set at parsing time and are not limited to scalar types. For instance, they can be used to access the
current user object during parsing.

In the following example, we add an attribute filter to modify URLs used in ``[url]`` BBCodes and links. In
addition to the attribute's value (the URL) we request that the custom variable ``my.id`` be passed as the
second parameter. It's a good idea to namespace the variable names to avoid collisions with other extensions
or phpBB itself.

The ``core.text_formatter_s9e_parser_setup`` event uses ``$event['parser']->set_var()`` to set a value for
``my.id`` variable once per initialization. The ``core.text_formatter_s9e_parse_before`` event could be used to
set the value before each parsing.

.. code-block:: php

    class listener implements EventSubscriberInterface
    {
        public static function getSubscribedEvents()
        {
            return [
                'core.text_formatter_s9e_configure_after' => 'configure_links',
                'core.text_formatter_s9e_parser_setup'    => 'set_random_id'
            ];
        }

        static public function add_link_id($url, $my_id)
        {
            return $url . '#' . $my_id;
        }

        public function configure_links($event)
        {
            // Add self::add_link_id() to filter the attribute value of [url] BBCodes and links
            $event['configurator']->tags['url']->attributes['url']->filterChain
                ->append([__CLASS__, 'add_link_id'])
                ->resetParameters()
                ->addParameterByName('attrValue')
                ->addParameterByName('my.id');
        }

        public function set_random_id($event)
        {
            // We set my.id to a random number in this example
            $event['parser']->set_var('my.id', mt_rand(111, 999));
        }
    }

.. seealso::

    - `phpBB API Documentation <https://area51.phpbb.com/docs/code/3.3.x/phpbb/textformatter/parser_interface.html>`_
    - `Callback signature - s9e\\TextFormatter <https://s9etextformatter.readthedocs.io/Filters/Callback_signature/>`_
    - `Attribute filters - s9e\\TextFormatter <https://s9etextformatter.readthedocs.io/Filters/Attribute_filters/>`_
    - `Tag filters - s9e\\TextFormatter <https://s9etextformatter.readthedocs.io/Filters/Tag_filters/>`_

Enable Text Formatter Plugins
=============================

The Text Formatter library has a collection of plugins that can be enabled through an extension,
such as MediaEmbed, Pipe Tables, etc.

Plugins can be toggled via the ``configurator`` var available through the ``core.text_formatter_s9e_configure_before``
and ``core.text_formatter_s9e_configure_after`` events which respectively trigger before and after the default
settings are configured.

.. code-block:: php

    class listener implements EventSubscriberInterface
    {
        public static function getSubscribedEvents()
        {
            return [
                'core.text_formatter_s9e_configure_after' => 'configure'
            ];
        }

        public function configure($event)
        {
            $configurator = $event['configurator'];

            // Disable the Autolink plugin
            unset($configurator->Autolink);

            // Enable the PipeTables plugin
            $configurator->PipeTables;

            // Do something if the MediaEmbed plugin is enabled
            $is_enabled = isset($configurator->MediaEmbed);
            if ($is_enabled)
            {
                // ...
            }

            // Get the names of all loaded plugins
            $names = [];
            foreach ($configurator->plugins as $plugin_name => $plugin_configurator)
            {
                $names[] = $plugin_name;
            }
        }
    }

.. seealso::

    `s9e\\TextFormatter  <https://s9etextformatter.readthedocs.io>`_
