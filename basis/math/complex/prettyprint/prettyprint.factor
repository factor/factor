! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: math math.functions arrays prettyprint.custom kernel ;
IN: math.complex.prettyprint

M: complex pprint* pprint-object ;
M: complex pprint-delims drop \ C{ \ } ;
M: complex >pprint-sequence >rect 2array ;
