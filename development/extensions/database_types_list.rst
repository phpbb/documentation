===================
Database Types List
===================

Introduction
============

The purpose of the Database Type Map is to simplify the process of creating installations for multiple database systems.
Instead of writing specific installation instructions for each individual database system, you can create a single set of
instructions and use the Database Type Map to modify any supported database system with just one command. This makes it
easier and more efficient to work with multiple database systems, as you don't need to write and maintain separate
instructions for each one.

.. note::

    With some commands you may enter the `Zerofill <https://www.tutorialspoint.com/what-is-the-benefit-of-zerofill-in-mysql>`_,
    example ``INT:11``, if the field is a numeric one. With some you may enter the length of the field, example ``VARCHAR:255``,
    which will make a varchar(255) column in MySQL. In all of the fields supporting this, they will have a colon followed by ``%d``
    meaning any number may fill the space of the ``%d``.

Numeric
=======

.. list-table::
    :widths: 20 20 60
    :header-rows: 1

    * - Command
      - MySQL Equivalent
      - Storage Range (on MySQL)
    * - TINT:%d
      - tinyint(%d)
      - -128 to 127
    * - INT:%d
      - int(%d)
      - -2,147,483,648 to 2,147,483,648
    * - BINT
      - bigint(20)
      - -9,223,372,036,854,775,808 to 9,223,372,036,854,775,808
    * - USINT
      - smallint(4) UNSIGNED
      - 0 to 65,535
    * - UINT
      - mediumint(8) UNSIGNED
      - 0 to 16,777,215
    * - UINT:%d
      - int(%d) UNSIGNED
      - 0 to 4,294,967,295
    * - ULINT
      - int(10) UNSIGNED
      - 0 to 4,294,967,295

Decimal
=======

.. list-table::
    :widths: 20 20 60
    :header-rows: 1

    * - Command
      - MySQL Equivalent
      - Storage Range (on MySQL)
    * - DECIMAL
      - decimal(5,2)
      - -999.99 to 999.99
    * - DECIMAL:%d
      - decimal(%d, 2)
      - -(%d - 2 digits to the left of the decimal).99 to (%d - 2 digits to the left of the decimal).99
    * - PDECIMAL
      - decimal(6,3)
      - -999.999 to 999.999
    * - PDECIMAL:%d
      - decimal(%d,3)
      - -(%d - 3 digits to the left of the decimal).999 to (%d - 3 digits to the left of the decimal).999

Text
====

These should only be used for ASCII characters.  If you plan to use it for something like message text read the Unicode Text section

.. list-table::
    :widths: 20 20 60
    :header-rows: 1

    * - Command
      - MySQL Equivalent
      - Explain
    * - VCHAR
      - varchar(255)
      - text for storing 255 characters (normal input field with a max of 255 chars)
    * - VCHAR:%d
      - varchar(%d)
      - text for storing %d characters (normal input field with a max of %d chars)
    * - CHAR:%d
      - char(%d)
      - text for storing up to 30 characters (normal input field with a max of 30 chars)
    * - XSTEXT
      - text
      - text for storing 100 characters
    * - STEXT
      - text
      - text for storing 255 characters
    * - TEXT
      - text
      - text for storing 3000 characters
    * - MTEXT
      - mediumtext
      - (post text, large text)

Unicode Text
============

.. list-table::
    :widths: 20 20 60
    :header-rows: 1

    * - Command
      - MySQL Equivalent
      - Explain
    * - VCHAR_UNI
      - varchar(255)
      - text for storing 255 characters (normal input field with a max of 255 single-byte chars)
    * - VCHAR_UNI:%d
      - varchar(%d)
      - text for storing %d characters (normal input field with a max of %d single-byte chars)
    * - XSTEXT_UNI
      - varchar(100)
      - text for storing 100 characters (topic_title for example)
    * - STEXT_UNI
      - varchar(255)
      - text for storing 255 characters (normal input field with a max of 255 single-byte chars)
    * - TEXT_UNI
      - text
      - text for storing 3000 characters (short text, descriptions, comments, etc.)
    * - MTEXT_UNI
      - mediumtext
      - (post text, large text)

Miscellaneous
=============

.. list-table::
    :widths: 20 20 60
    :header-rows: 1

    * - Command
      - MySQL Equivalent
      - Explain
    * - BOOL
      - tinyint(1) UNSIGNED
      - Storing boolean values (true/false)
    * - TIMESTAMP
      - int(11) UNSIGNED
      - For storing UNIX timestamps
    * - VCHAR_CI
      - varchar(255)
      - varchar_ci for postgresql, others VCHAR
    * - VARBINARY
      - varbinary(255)
      - Binary storage
