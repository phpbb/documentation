=========================
Tutorial: Getting Started
=========================

Introduction
============

Welcome to phpBB's official extension tutorial and documentation.

These tutorial pages are based on phpBB's `Acme Demo <https://github.com/phpbb/phpbb-ext-acme-demo>`_ extension. This
simple extension demonstrates many common features of an extension, including using a front-controller page, modifying
phpBB through core events and template events, modifying the database using migrations, and setting up an ACP module
for configuration settings.

This tutorial covers the basic creation of extensions:

 * `Extension folder`_
 * `Composer JSON`_

.. seealso::

    The :doc:`skeleton_extension` is a tool to help developers rapidly generate the initial
    files and components needed to start developing new extensions for phpBB.


Extension Folder
================

All extensions must be located within the ``ext/`` folder which can be found in phpBB's root folder.

Extensions are packaged using a folder structure as follows: ``vendor/extname``.

Thus, an extension should be located in the phpBB directory as follows: ``phpBB/ext/vendor/extname``.

The vendor name can be the author's username or any other name you choose to group your extensions by.
The extension name is the name of the extension. In this tutorial we will use ``acme`` as the vendor name and
``demo`` as the extension name.

.. important::

    Both the vendor and extension names must start with a lower or upper case letter, followed by letters and numbers
    only. **Underscores, dashes and other characters are not permitted.** It is perfectly fine to have an extension
    named ``iamanextension``.


Composer JSON
=============

Every extension requires a meta data file named ``composer.json`` in order for phpBB to identify your extension.
This file contains basic information about an extension as well its dependencies. It is written using the JSON format
and must be stored in the root folder of the extension, e.g. ``phpBB/ext/acme/demo/composer.json``.

The information in ``composer.json`` will be used by the Extensions Manager in the ACP.
The details of the meta data are explained below the sample, but for now let's have a look at the complete file:

.. code-block:: json

    {
        "name": "acme/demo",
        "type": "phpbb-extension",
        "description": "Acme Demo Extension for phpBB 3.1",
        "homepage": "https://github.com/phpbb/phpbb-ext-acme-demo",
        "version": "0.1.0",
        "time": "2013-11-05",
        "keywords": ["phpbb", "extension", "acme", "demo"],
        "license": "GPL-2.0",
        "authors": [
            {
                "name": "Nickv",
                "email": "nickvergessen@localhost",
                "homepage": "https://github.com/nickvergessen/",
                "role": "Lead Developer"
            }
        ],
        "require": {
            "php": ">=5.3.3",
            "composer/installers": "~1.0"
        },
        "require-dev": {
            "phpbb/epv": "dev-master"
        },
        "extra": {
            "display-name": "Acme Demo Extension",
            "soft-require": {
                "phpbb/phpbb": "~3.1"
            }
        }
    }

.. note::

    It is important to remember that the last item or object in any JSON array must not contain a trailing comma.

.. csv-table::
   :header: "Field", "Required", "Content"
   :delim: |

   ``name`` | Yes | "The vendor name and extension name, separated by ``/``, matching the folder
   structure."
   ``type`` | Yes | "The type of package. It should always be ``phpbb-extension``."
   ``description`` | Yes | "A short description of your extension, may be empty
   (but not skipped)."
   ``homepage`` | No | "A valid URL. It is recommended to use the link
   to the contribution in the customisation database, or to the repository of
   your extension (if you are using a public one like GitHub)."
   ``version`` | Yes | "The version of your extension. This should follow the format of X.Y.Z with an optional suffix
   of -dev, -patch, -alpha, -beta or -RC."
   ``time`` | No | "The release date of your extension. Must be in YYYY-MM-DD or YYYY-MM-DD HH:MM:SS format."
   ``keywords`` | No | "An array of keywords related to the extension."
   ``license`` | Yes | "The license of the package. This can be either a string or an array of strings.
   Typically extensions should be licensed under the same GPL-2.0 license as phpBB."
   ``authors`` | Yes | "An array of authors of the extension.
   See `authors`_ for more details."
   ``require`` | Yes | "An array of requirements of the extension.
   See `require`_ for more details."
   ``require-dev`` | No | "An array of development requirements of the extension.
   See `require-dev`_ for more details."
   ``extra`` | Yes | "An array of arbitrary extra data.
   See `extra`_ for more details."

authors
-------

You may have unlimited authors. At least one author is highly recommended.

.. csv-table::
   :header: "Field", "Required", "Content"
   :delim: |

   ``name`` | Yes | "The name of an author."
   ``email`` | No | "An email address of the author."
   ``homepage`` | No | "A URL pointing to the website of the author."
   ``role`` | No | "Role can be used to specify what the author did for the
   extension (e.g. Developer, Translator, Supporter, etc.)"

require
-------

List the dependencies required by the extension, i.e. the PHP version and
`third party libraries <https://packagist.org/>`_.

.. csv-table::
   :header: "Field", "Content"
   :delim: |

   ``php`` | "The minimum-stability version of PHP required by the extension. phpBB 3.1 requires PHP 5.3.3 or higher,
   so the version comparison is ``>= 5.3.3``."
   ``composer/installers`` | "Recommended by phpBB. This will install extensions to the correct location in phpBB when installed via Composer."

require-dev
-----------

In the optional ``require-dev`` section you can list the dependencies of the extension which are only required for
development. Acme Demo uses the `Extension Pre Validator Tool <https://packagist.org/packages/phpbb/epv>`_ from
the phpBB Extensions Team to perform some basic validation when running
tests on Travis CI (see :doc:`tutorial_testing`). Since we always want to have
the newest version, we require ``dev-master``.

extra
-----

This section can contain virtually any arbitrary data according to the composer specification. However, phpBB requires
two special entries in this array for extensions:

.. csv-table::
   :header: "Field", "Content"
   :delim: |

   ``display-name`` | "The name of your extension, e.g. Acme Demo Extension."
   ``soft-require`` | "The minimum-stability version of phpBB required by the extension. In this case we require
   any 3.1 version, which is done by prefixing it with a ``~``: ``""phpbb/phpbb"": ""~3.1""``."

.. seealso::

    A complete explanation of all JSON schema fields available in a composer.json file can be found here: https://getcomposer.org/doc/04-schema.md

    More information on specifying package version constraints can be found here: https://getcomposer.org/doc/articles/versions.md#basic-constraints

So far, our extension has no functionality yet. Continue on to the next sections to learn more about how to write
an extension that will do something useful.
