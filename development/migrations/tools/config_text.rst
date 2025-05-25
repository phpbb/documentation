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

    ['config_text.add', [config name, config value]],

.. rubric:: Example

.. code-block:: php

    public function update_data()
    {
        return [
             ['config_text.add', ['foo', 'bar']], // Add Config_Text 'foo' with value 'bar';
             ['config_text.add', ['foo2', 1]], // Add Config_Text 'foo2' with value '1';
        ];
    }

Update Config_Text Setting
==========================

Update a config_text setting

.. code-block:: php

    ['config_text.update', [config name, new config value]],

.. rubric:: Example

.. code-block:: php

    public function update_data()
    {
        return [
             ['config_text.update', ['foo', 'bar'], // Config_Text 'foo' updated to 'bar';
        ];
    }

Delete Config_Text Setting
==========================

Delete a config_text setting

.. code-block:: php

    ['config_text.remove', [config name]],

.. rubric:: Example

.. code-block:: php

    public function update_data()
    {
        return [
             ['config_text.remove', ['foo']], // Config_Text 'foo' removed;
        ];
    }
