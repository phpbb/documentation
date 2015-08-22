======
Config
======

Basics
======

The config CLI commands allow you to get, set, increment and delete config key values.

config:delete
=============

Deletes a configuration option.

.. code-block:: console

    $ php bin/phpbbcli.php config:delete config_key_name

.. csv-table::
   :header: "Arguments", "Usage"
   :delim: |

   key | The configuration option’s name (required)

config:get
==========

Gets a configuration option’s value.

.. code-block:: console

    $ php bin/phpbbcli.php config:get config_key_name

.. csv-table::
   :header: "Arguments", "Usage"
   :delim: |

   key | The configuration option’s name (required)

.. code-block:: console

    $ php bin/phpbbcli.php config:get config_key_name --no-newline

.. csv-table::
   :header: "Options", "Usage"
   :delim: |

   --no-newline | Set this option if the value should be printed without a new line at the end.

config:increment
================

Increments a configuration option’s value.

.. code-block:: console

    $ php bin/phpbbcli.php config:increment config_key_name 1

.. csv-table::
   :header: "Arguments", "Usage"
   :delim: |

   key | The configuration option’s name (required)
   increment | Amount to increment by (required)

.. code-block:: console

    $ php bin/phpbbcli.php config:increment config_key_name 1 --dynamic

.. code-block:: console

    $ php bin/phpbbcli.php config:increment config_key_name 1 -d

.. csv-table::
   :header: "Options", "Usage"
   :delim: |

   --dynamic (-d) | Set this option if the configuration option changes too frequently to be efficiently cached.

config:set
==========

Sets a configuration option’s value.

.. code-block:: console

    $ php bin/phpbbcli.php config:set config_key_name foo

.. csv-table::
   :header: "Arguments", "Usage"
   :delim: |

   key | The configuration option’s name (required)
   value | New configuration value, use 0 and 1 to specify boolean values (required)

.. code-block:: console

    $ php bin/phpbbcli.php config:set config_key_name foo --dynamic

.. code-block:: console

    $ php bin/phpbbcli.php config:set config_key_name foo -d

.. csv-table::
   :header: "Options", "Usage"
   :delim: |

   --dynamic (-d) | Set this option if the configuration option changes too frequently to be efficiently cached.

config:set-atomic
=================

Sets a configuration option’s value only if the old matches the current value.

.. code-block:: console

    $ php bin/phpbbcli.php config:set-atomic config_key_name foo bar

.. csv-table::
   :header: "Arguments", "Usage"
   :delim: |

   key | The configuration option’s name (required)
   old | Current configuration value, use 0 and 1 to specify boolean values (required)
   new | New configuration value, use 0 and 1 to specify boolean values (required)

.. code-block:: console

    $ php bin/phpbbcli.php config:set-atomic config_key_name foo bar --dynamic

.. code-block:: console

    $ php bin/phpbbcli.php config:set-atomic config_key_name foo bar -d

.. csv-table::
   :header: "Options", "Usage"
   :delim: |

   --dynamic (-d) | Set this option if the configuration option changes too frequently to be efficiently cached.
