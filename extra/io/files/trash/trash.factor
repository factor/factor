! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: combinators system vocabs ;

IN: io.files.trash

HOOK: send-to-trash os ( path -- )

USE-MACOSX: io.files.trash.macosx
USE-UNIX: io.files.trash.unix
USE-WINDOWS: io.files.trash.windows
