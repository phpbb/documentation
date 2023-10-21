=======
Plurals
=======

Short Example
=============

The english language is very simple when it comes to plurals:

    *You have 0 elephants, 1 elephant, or 2+ elephants.*

So basically you have 2 different forms: one singular and one plural.


But for some other languages this is quite a bit more difficult. Let's take
the Bosnian language as another example:

    *You have [1/21/31] slon, [2/3/4] slona, [0/5/6] slonova and [7/8/9/11] ...*

The problem with the old system of plurals was that you would have needed to
specify them all, and get a loop in there.


As we are not the first developers facing this problem, it was not really hard
to find a suitable solution. We decided to use the system from
`Unicode.org`_, which is e.g. used by Mozilla.

Plural Rules
============
So we defined the following 16 rules for plurals. First point is the language
family, afterwards there are a number of rows with the following format:
**<key> - <rule>: <example-numbers>**

.. note::

    0 is handled as a special case. If you add a key 0 to your
    array, that will be used in case of 0 independent of the plural rule.

Rule #0
-------
* Families: Asian (Chinese, Japanese, Korean, Vietnamese), Persian, Turkic/Altaic (Turkish), Thai, Lao
* 1 - everything: 0, 1, 2, ...

Rule #1
-------
* Families: Germanic (Danish, Dutch, English, Faroese, Frisian, German, Norwegian, Swedish),
  Finno-Ugric (Estonian, Finnish, Hungarian), Language isolate (Basque), Latin/Greek (Greek),
  Semitic (Hebrew), Romanic (Italian, Portuguese, Spanish, Catalan)
* 1 - 1
* 2 - everything else: 0, 2, 3, ...

Rule #2
-------
* Families: Romanic (French, Portuguese, Brazilian Portuguese)
* 1 - 0, 1
* 2 - everything else: 2, 3, ...

Rule #3
-------
* Families: Baltic (Latvian)
* 1 - 0
* 2 - ends in 1, excluding 11: 1, 21, ... 101, 121, ...
* 3 - everything else: 2, 3, ... 10, 11, 12, ... 20, 22, ...

Rule #4
-------
* Families: Celtic (Scottish Gaelic)
* 1 - is 1 or 11: 1, 11
* 2 - is 2 or 12: 2, 12
* 3 - others between 3 and 19: 3, 4, ... 10, 13, ... 18, 19
* 4 - everything else: 0, 20, 21, ...

Rule #5
-------
* Families: Romanic (Romanian)
* 1 - 1
* 2 - is 0 or ends in 01-19, excluding 1: 0, 2, 3, ... 19, 101, 102, ... 119, 201, ...
* 3 - everything else: 20, 21, ...

Rule #6
-------
* Families: Baltic (Lithuanian)
* 1 - ends in 1, excluding 11: 1, 21, 31, ... 101, 121, ...
* 2 - ends in 0 or ends in 10-20:  0, 10, 11, 12, ... 19, 20, 30, 40, ...
* 3 - everything else: 2, 3, ... 8, 9, 22, 23, ... 29, 32, 33, ...

Rule #7
-------
* Families: Slavic (Bosnian, Croatian, Serbian, Russian, Ukrainian)
* 1 - ends in 1, excluding 11: 1, 21, 31, ... 101, 121, ...
* 2 - ends in 2-4, excluding 12-14: 2, 3, 4, 22, 23, 24, 32, ...
* 3 - everything else: 0, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 25, 26, ...

Rule #8
-------
* Families: Slavic (Slovak, Czech)
* 1 - 1
* 2 - 2, 3, 4
* 3 - everything else: 0, 5, 6, 7, ...

Rule #9
-------
* Families: Slavic (Polish)
* 1 - 1
* 2 - ends in 2-4, excluding 12-14: 2, 3, 4, 22, 23, 24, 32, ... 104, 122, ...
* 3 - everything else: 0, 5, 6, ... 11, 12, 13, 14, 15, ... 20, 21, 25, ...

Rule #10
--------
* Families: Slavic (Slovenian, Sorbian)
* 1 - ends in 01: 1, 101, 201, ...
* 2 - ends in 02: 2, 102, 202, ...
* 3 - ends in 03-04: 3, 4, 103, 104, 203, 204, ...
* 4 - everything else: 0, 5, 6, 7, 8, 9, 10, 11, ...

Rule #11
--------
* Families: Celtic (Irish Gaeilge)
* 1 - 1
* 2 - 2
* 3 - is 3-6: 3, 4, 5, 6
* 4 - is 7-10: 7, 8, 9, 10
* 5 - everything else: 0, 11, 12, ...

Rule #12
--------
* Families: Semitic (Arabic)
* 1 - 1
* 2 - 2
* 3 - ends in 03-10: 3, 4, ... 10, 103, 104, ... 110, 203, 204, ...
* 4 - ends in 11-99: 11, ... 99, 111, 112, ...
* 5 - everything else: 100, 101, 102, 200, 201, 202, ...
* 6 - 0

Rule #13
--------
* Families: Semitic (Maltese)
* 1 - 1
* 2 - ends in 01-10: 0, 2, 3, ... 9, 10, 101, 102, ...
* 3 - ends in 11-19: 11, 12, ... 18, 19, 111, 112, ...
* 4 - everything else: 20, 21, ...

Rule #14
--------
* Families: Slavic (Macedonian)
* 1 - ends in 1: 1, 11, 21, ...
* 2 - ends in 2: 2, 12, 22, ...
* 3 - everything else: 0, 3, 4, ... 10, 13, 14, ... 20, 23, ...

Rule #15
--------
* Families: Icelandic
* 1 - ends in 1, excluding 11: 1, 21, 31, ... 101, 121, 131, ...
* 2 - everything else: 0, 2, 3, ... 10, 11, 12, ... 20, 22, ...

How to use the rules
====================
The first thing your language package needs, is a definition, which rule to
use for your package. This is done in the ``language/xy/common.php`` language
file at the beginning of the array, (Rule #1 is the rule for the English
language and will be used by default, if you don't specify one):

.. code-block:: php

    'PLURAL_RULE' => 1,

The following example is using rule **#13**:

It has the following rows:

* 1 - 1
* 2 - ends in 01-10: 2, 3, ... 9, 10, 101, 102, ...
* 3 - ends in 11-19: 11, 12, ... 18, 19, 111, 112, ...
* 4 - everything else: 20, 21, ...

While the English language only has 2 rows in its array:

.. code-block:: php

    'EXAMPLE' => [
        1 => '1 example',
        2 => '2 or more examples',
    ],

You need to specify the zero-row and 4 rows for the "plurals":

.. code-block:: php

    'EXAMPLE' => [
        1 => '1 example',
        2 => '[0 or number ending with 01-10] examples',
        3 => '[number ending with 11-19] example',
        4 => 'even more examples',
    ],

If you require separate handling for 0, you can simple add the 0-case:

.. code-block:: php

    'EXAMPLE' => [
        0 => 'No example',
        1 => '1 example',
        2 => '[zero is not handled here anymore! Only number ending with 01-10] examples',
        3 => '[number ending with 11-19] example',
        4 => 'even more examples',
    ],

If you forget a line the system will automatically use the row before. So if
you forget to add the *3*-row, it will use *2*-row for 11-19 as well. If there
is no previous row, it uses the last row of the array.


**Ensure your cases are in ascending order**, otherwise the system may produce
unexpected results if any keys are missing or out of order.

Credits
=======
The system is based on
`Unicode.org`_, which
uses the "Plural Rules and Families" from
`GNU gettext documentation <http://www.gnu.org/software/gettext/manual/html_node/gettext_150.html#Plural-forms>`_ and is used e.g. by Mozilla.

.. _Unicode.org: https://www.unicode.org/cldr/charts/43/supplemental/language_plural_rules.html
