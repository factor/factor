! Copyright (C) 2010 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: combinators system vocabs ;

IN: io.files.trash

HOOK: send-to-trash os ( path -- )

{
    { [ os windows? ] [ "io.files.trash.windows" ] }
    { [ os macos? ] [ "io.files.trash.macos" ] }
    { [ os unix? ] [ "io.files.trash.unix" ] }
} cond require
