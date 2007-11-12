! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io.files
USING: io.backend io.files.private io hashtables kernel math
memory namespaces sequences strings arrays definitions system
combinators splitting ;

HOOK: <file-reader> io-backend ( path -- stream )

HOOK: <file-writer> io-backend ( path -- stream )

HOOK: <file-appender> io-backend ( path -- stream )

HOOK: delete-file io-backend ( path -- )

HOOK: rename-file io-backend ( from to -- )

HOOK: make-directory io-backend ( path -- )

HOOK: delete-directory io-backend ( path -- )

: path-separator? ( ch -- ? ) windows? "/\\" "/" ? member? ;

HOOK: root-directory? io-backend ( path -- ? )

M: object root-directory? ( path -- ? ) path-separator? ;

: trim-path-separators ( str -- newstr )
    [ path-separator? ] right-trim ;

: path+ ( str1 str2 -- str )
    >r trim-path-separators "/" r>
    [ path-separator? ] left-trim 3append ;

: stat ( path -- directory? permissions length modified )
    normalize-pathname (stat) ;

: exists? ( path -- ? ) stat >r 3drop r> >boolean ;

: directory? ( path -- ? ) stat 3drop ;

: special-directory? ( name -- ? )
    { "." ".." } member? ;

: fixup-directory ( path seq -- newseq )
    [
        dup string?
        [ tuck path+ directory? 2array ] [ nip ] if
    ] curry* map
    [ first special-directory? not ] subset ;

: directory ( path -- seq )
    normalize-directory dup (directory) fixup-directory ;

: file-length ( path -- n ) stat 4array third ;

: file-modified ( path -- n ) stat >r 3drop r> ;

: last-path-separator ( path -- n ? )
    [ length 2 [-] ] keep [ path-separator? ] find-last* ;

TUPLE: no-parent-directory path ;

: no-parent-directory ( path -- * )
    \ no-parent-directory construct-boa throw ;

: parent-directory ( path -- parent )
    trim-path-separators {
        { [ dup empty? ] [ drop "/" ] }
        { [ dup root-directory? ] [ ] }
        { [ dup [ path-separator? ] contains? not ] [ drop "." ] }
        { [ t ] [
            dup last-path-separator drop 1+ cut
            special-directory? [ no-parent-directory ] when
        ] }
    } cond ;

: file-name ( path -- string )
    dup last-path-separator [ 1+ tail ] [ drop ] if ;

: resource-path ( path -- newpath )
    \ resource-path get [ image parent-directory ] unless*
    swap path+ ;

: ?resource-path ( path -- newpath )
    "resource:" ?head [ resource-path ] when ;

: make-directories ( path -- )
    normalize-pathname trim-path-separators {
        { [ dup "." = ] [ ] }
        { [ dup root-directory? ] [ ] }
        { [ dup empty? ] [ ] }
        { [ dup exists? ] [ ] }
        { [ t ] [
            dup parent-directory make-directories
            dup make-directory
        ] }
    } cond drop ;

: copy-file ( from to -- )
    dup parent-directory make-directories
    <file-writer> [
        stdio get swap
        <file-reader> [
            stdio get swap stream-copy
        ] with-stream
    ] with-stream ;

: copy-directory ( from to -- )
    dup make-directories
    >r dup directory swap r> [
        >r >r first r> over path+ r> rot path+ copy-file
    ] 2curry each ;

: home ( -- dir )
    {
        { [ winnt? ] [ "USERPROFILE" os-env ] }
        { [ wince? ] [ "" resource-path ] }
        { [ unix? ] [ "HOME" os-env ] }
    } cond ;

TUPLE: pathname string ;

C: <pathname> pathname

M: pathname <=> [ pathname-string ] compare ;
