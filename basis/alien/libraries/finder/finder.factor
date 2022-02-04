USING: accessors alien.libraries kernel lexer parser sequences
system vocabs vocabs.platforms ;
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

! Try to find the library from a list, but if it's not found,
! try to open a library that is the first name in that list anyway
! or "library_not_found" as a last resort for better debugging.
: find-library-from-list ( seq -- path/f )
    dup [ find-library* ] map-find drop
    [ ] [ ?first "library_not_found" or ] ?if ;

SYNTAX: ADD-FIRST-LIBRARY:
    scan-token scan-word scan-object
    find-library-from-list swap add-library ;

USE-OS-SUFFIX: alien.libraries.finder
