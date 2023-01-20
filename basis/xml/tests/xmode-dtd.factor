! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: xml xml.data kernel tools.test ;
IN: xml.tests

[ t ] [
    "vocab:xmode/xmode.dtd" file>dtd dtd?
] unit-test
