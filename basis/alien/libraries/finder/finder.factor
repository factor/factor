USING: accessors alien.libraries kernel sequences system vocabs ;
IN: alien.libraries.finder

HOOK: find-library* os ( name -- path/f )

: find-library ( name -- path/library-not-found )
    [ find-library* ] transmute ;

: ?update-library ( name path abi -- )
    pick lookup-library [ dll>> dll-valid? ] [ f ] if* [
        3drop
    ] [
        [ find-library ] [ update-library ] bi*
    ] if ;

! Try to find the library from a list, but if it's not found,
! try to open a library that is the first name in that list anyway
! or "library_not_found" as a last resort for better debugging.
: find-library-from-list ( seq -- path/f )
    [ [ find-library* ] map-find drop ]
    [ ?first "library_not_found" or ] ?unless ;

"alien.libraries.finder." os name>> append require
