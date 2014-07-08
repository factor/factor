USING: combinators kernel sequences system vocabs
alien.libraries ;
IN: alien.libraries.finder

HOOK: find-library* os ( name -- path/f )

: find-library ( name -- path/library-not-found )
    dup find-library* [ nip ] when* ;
    
: find-library-from-list ( seq -- path/f )
    [ find-library* ] map [ ] find nip ;

{
    { [ os macosx?  ] [ "alien.libraries.finder.macosx"  ] }
    { [ os linux?   ] [ "alien.libraries.finder.linux"   ] }
    { [ os windows? ] [ "alien.libraries.finder.windows" ] }
} cond require
