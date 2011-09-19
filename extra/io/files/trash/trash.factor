! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: combinators system vocabs.loader ;

IN: io.files.trash

HOOK: send-to-trash os ( path -- )

{
    { [ os macosx? ] [ "io.files.trash.macosx"  ] }
    { [ os unix?   ] [ "io.files.trash.unix"    ] }
    { [ os windows?  ] [ "io.files.trash.windows" ] }
} cond require

