! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel present prettyprint.custom prettyprint.sections
prettyprint.backend urls ;
IN: urls.prettyprint

M: url pprint*
    \ URL" record-vocab
    dup present "URL\" " "\"" pprint-string ;
