USING: combinators kernel sequences system vocabs
alien.libraries ;
IN: alien.libraries.finder

HOOK: find-library* os ( name -- path/f )

: find-library ( name -- path/library-not-found )
    dup find-library* [ nip ] when* ;

! Try to find the library from a list, but if it's not found,
! try to open a library that is the first name in that list anyway
! or "library_not_found" as a last resort for better debugging. 
: find-library-from-list ( seq -- path/f )
    dup [ find-library* ] map-find drop
    [ nip ] [ ?first "library_not_found" or ] if* ;

{
    { [ os macosx?  ] [ "alien.libraries.finder.macosx"  ] }
    { [ os linux?   ] [ "alien.libraries.finder.linux"   ] }
    { [ os windows? ] [ "alien.libraries.finder.windows" ] }
} cond require
