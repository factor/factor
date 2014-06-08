
USING: combinators kernel system vocabs alien.libraries ;
IN: alien.libraries.finder

HOOK: find-library* os ( name -- path/f )

: find-library ( name -- path/library-not-found )
    dup find-library* [ nip ] when* ;

{
    { [ os macosx?  ] [ "alien.libraries.finder.macosx"  ] }
    { [ os linux?   ] [ "alien.libraries.finder.linux"   ] }
    { [ os windows? ] [ "alien.libraries.finder.windows" ] }
} cond require
