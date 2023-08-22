! Copyright (C) 2014 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors sequences system vocabs ;
IN: file-picker

HOOK: open-file-dialog os ( -- paths )
HOOK: save-file-dialog os ( path -- paths )

os name>> "file-picker." prepend require
