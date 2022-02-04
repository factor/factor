! Copyright (C) 2014 John Benediktsson.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors sequences system vocabs vocabs.platforms ;
IN: file-picker

HOOK: open-file-dialog os ( -- paths )
HOOK: save-file-dialog os ( path -- paths )

USE-OS-SUFFIX: file-picker
