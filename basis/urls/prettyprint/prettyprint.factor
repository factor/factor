! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel present prettyprint.custom prettyprint.backend urls ;
IN: urls.prettyprint

M: url pprint* dup present "URL\" " "\"" pprint-string ;
