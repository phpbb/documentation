================
Config Text Tool
================

The config_text tool helps adding, updating, and removing config_text
settings. The config_text table is used to store options with an arbitrary
length value in a TEXT column. In contrast to config values, config_text are
not cached or prefetched.

Add Config_Text Setting
=======================

Add a new config_text setting

.. code-block:: php

    array('config_text.add', array(config name, config value)),

Example
-------

.. code-block:: php

    public function update_data()
    {
        return array(
             array('config_text.add', array('foo', 'bar')), // Add Config_Text 'foo' with value 'bar';
             array('config_text.add', array('foo2', 1)), // Add Config_Text 'foo2' with value '1';
        );
    }

Update Config_Text Setting
==========================

Update a config_text setting

.. code-block:: php

    array('config_text.update', array(config name, new config value)),

Example
-------

.. code-block:: php

    public function update_data()
    {
        return array(
             array('config_text.update', array('foo', 'bar')), // Config_Text 'foo' updated to 'bar';
        );
    }

Delete Config_Text Setting
==========================

Delete a config_text setting

.. code-block:: php

    array('config_text.remove', array(config name)),

Example
-------

.. code-block:: php

    public function update_data()
    {
        return array(
             array('config_text.remove', array('foo')), // Config_Text 'foo' removed;
        );
    }
