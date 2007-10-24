! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io.files
USING: io.backend io.files.private hashtables kernel math memory
namespaces sequences strings arrays definitions system
combinators splitting ;

HOOK: <file-reader> io-backend ( path -- stream )

HOOK: <file-writer> io-backend ( path -- stream )

HOOK: <file-appender> io-backend ( path -- stream )

HOOK: delete-file io-backend ( path -- )

HOOK: rename-file io-backend ( from to -- )

HOOK: make-directory io-backend ( path -- )

HOOK: delete-directory io-backend ( path -- )

HOOK: root-directory? io-backend ( path -- ? )

M: object root-directory? ( path -- ? ) "/" = ;

! Words for accessing filesystem meta-data.

: path-separator? ( ch -- ? )
    "/\\" member? ;

: path+ ( str1 str2 -- str )
    >r [ path-separator? ] right-trim "/" r>
    [ path-separator? ] left-trim 3append ;

: stat ( path -- directory? permissions length modified )
    normalize-pathname (stat) ;

: exists? ( path -- ? ) stat >r 3drop r> >boolean ;

: directory? ( path -- ? ) stat 3drop ;

: fixup-directory ( path seq -- newseq )
    [
        dup string?
        [ tuck path+ directory? 2array ] [ nip ] if
    ] curry* map
    [ first { "." ".." } member? not ] subset ;

: directory ( path -- seq )
    normalize-directory dup (directory) fixup-directory ;

: file-length ( path -- n ) stat 4array third ;

: file-modified ( path -- n ) stat >r 3drop r> ;

: last-path-separator ( path -- n ? )
    [ length 2 [-] ] keep [ path-separator? ] find-last* ;

TUPLE: no-parent-directory path ;

: parent-dir ( path -- parent )
    {
        { [ dup root-directory? ] [ ] }
        { [ dup "/\\" split ".." over member? "." rot member? or ]
            [ \ no-parent-directory construct-boa throw ] }
        { [ t ] [ dup last-path-separator
                [ 1+ head ] [ 2drop "." ] if ] }
    } cond ;

: file-name ( path -- string )
    dup last-path-separator
    [ 1+ tail ] [ drop ] if ;

: resource-path ( path -- newpath )
    \ resource-path get [ image parent-dir ] unless*
    swap path+ ;

: ?resource-path ( path -- newpath )
    "resource:" ?head [ resource-path ] when ;

: make-directories ( path -- )
    normalize-pathname
    {
        { [ dup "." = ] [ ] }
        { [ dup root-directory? ] [ ] }
        { [ dup empty? ] [ ] }
        { [ dup exists? ] [ ] }
        { [ t ] [
            dup parent-dir make-directories
            dup make-directory
        ] }
    } cond drop ;

TUPLE: pathname string ;

C: <pathname> pathname

M: pathname <=> [ pathname-string ] compare ;

: home ( -- dir )
    {
        { [ winnt? ] [ "USERPROFILE" os-env ] }
        { [ wince? ] [ "" resource-path ] }
        { [ unix? ] [ "HOME" os-env ] }
    } cond ;
