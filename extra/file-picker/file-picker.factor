! Copyright (C) 2014 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences system vocabs ;
IN: file-picker

HOOK: open-file-dialog os ( -- paths )
HOOK: save-file-dialog os ( path -- paths )

os unix? os macos? not and
[ "file-picker.unix" ] [ os name>> "file-picker." prepend ] if require
