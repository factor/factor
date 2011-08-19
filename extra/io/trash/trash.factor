! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: combinators system vocabs.loader ;

IN: io.trash

HOOK: send-to-trash os ( path -- )

{
    { [ os macosx? ] [ "io.trash.macosx"  ] }
    { [ os unix?   ] [ "io.trash.unix"    ] }
    { [ os winnt?  ] [ "io.trash.windows" ] }
} cond require

