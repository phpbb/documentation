===========
Config Tool
===========

The config tool helps adding, updating, and removing config settings.

Add Config Setting
==================

Add a new config setting

.. code-block:: php

    array('config.add', array(config name, config value, is dynamic (default: false) )),

Example
-------

.. code-block:: php

    public function update_data()
    {
        return array(
             array('config.add', array('foo', 'bar')), // $config['foo'] = 'bar';
             array('config.add', array('foo2', 1, true)), // $config['foo2'] = '1'; Dynamic, do not cache
        );
    }

Update Config Setting
=====================

Update a config setting

.. code-block:: php

    array('config.update', array(config name, new config value)),

Example
-------

.. code-block:: php

    public function update_data()
    {
        return array(
             array('config.update', array('foo', 'bar')), // $config['foo'] = 'bar';
        );
    }

Update if current value equals specific value
=============================================

Update a config setting if the current config value is equal to a specified value

.. code-block:: php

    array('config.update_if_equals', array(compare to, config name, new config value)),

Example
-------

.. code-block:: php

    public function update_data()
    {
        return array(
             array('config.update_if_equals', array('bar', 'foo', 'bar2')), // if ($config['foo'] == 'bar') { $config['foo'] = 'bar2'; }
        );
    }

Delete Config Setting
=====================
Delete a config setting

.. code-block:: php

    array('config.remove', array(config name)),

Example
-------

.. code-block:: php

    public function update_data()
    {
        return array(
             array('config.remove', array('foo')), // unset($config['foo']);
        );
    }
