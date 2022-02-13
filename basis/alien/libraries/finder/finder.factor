USING: accessors alien.libraries assocs kernel namespaces
sequences system vocabs ;
IN: alien.libraries.finder

HOOK: find-library* os ( name -- path/f )

: find-library ( name -- path/library-not-found )
    dup find-library* [ nip ] when* ;

: ?update-library ( name path abi -- )
    pick lookup-library [ dll>> dll-valid? ] [ f ] if* [
        3drop
    ] [
        [ find-library ] [ update-library ] bi*
    ] if ;


ERROR: library-missing library ;

: find-first-function ( names library -- alien/f name )
    libraries get ?at [
        dll>> '[ _ dlsym ] map-find
    ] [
        library-missing
    ] if ; inline

! Try to find the library from a list, but if it's not found,
! try to open a library that is the first name in that list anyway
! or "library_not_found" as a last resort for better debugging.
: find-library-from-list ( seq -- path/f )
    dup [ find-library* ] map-find drop
    [ ] [ ?first "library_not_found" or ] ?if ;

"alien.libraries.finder." os name>> append require
