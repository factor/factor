
USING: combinators system vocabs ;

IN: alien.libraries.finder

HOOK: find-library os ( name -- path/f )

{
    { [ os macosx?  ] [ "alien.libraries.finder.macosx"  ] }
    { [ os linux?   ] [ "alien.libraries.finder.linux"   ] }
    { [ os windows? ] [ "alien.libraries.finder.windows" ] }
} cond require
