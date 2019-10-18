! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: dlists kernel prettyprint.custom ;
IN: dlists.prettyprint

M: dlist pprint-delims drop \ DL{ \ } ;
M: dlist >pprint-sequence dlist>sequence ;
M: dlist pprint-narrow? drop f ;
M: dlist pprint* pprint-object ;
