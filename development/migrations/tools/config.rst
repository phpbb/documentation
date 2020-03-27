===========
Config Tool
===========

The config tool helps adding, updating, and removing config settings.

Add Config Setting
==================

Add a new config setting

.. code-block:: php

    ['config.add', [config name, config value, is dynamic (default: false) ]],

Example
-------

.. code-block:: php

    public function update_data()
    {
        return [
             ['config.add', ['foo', 'bar']], // $config['foo'] = 'bar';
             ['config.add', ['foo2', 1, true]], // $config['foo2'] = '1'; Dynamic, do not cache
        ];
    }

Update Config Setting
=====================

Update a config setting

.. code-block:: php

    ['config.update', [config name, new config value]],

Example
-------

.. code-block:: php

    public function update_data()
    {
        return [
             ['config.update', ['foo', 'bar']], // $config['foo'] = 'bar';
        ];
    }

Update if current value equals specific value
=============================================

Update a config setting if the current config value is equal to a specified
value

.. code-block:: php

    ['config.update_if_equals', [compare to, config name, new config value]],

Example
-------

.. code-block:: php

    public function update_data()
    {
        return [
             ['config.update_if_equals', ['bar', 'foo', 'bar2']], // if ($config['foo'] == 'bar') { $config['foo'] = 'bar2'; }
        ];
    }

Delete Config Setting
=====================

Delete a config setting

.. code-block:: php

    ['config.remove', [config name]],

Example
-------

.. code-block:: php

    public function update_data()
    {
        return [
             ['config.remove', ['foo']], // unset($config['foo']);
        ];
    }
