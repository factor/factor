! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io.files
USING: io.backend io.files.private io hashtables kernel math
memory namespaces sequences strings assocs arrays definitions
system combinators splitting sbufs continuations ;

HOOK: cd io-backend ( path -- )

HOOK: cwd io-backend ( -- path )

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

: right-trim-separators ( str -- newstr )
    [ path-separator? ] right-trim ;

: left-trim-separators ( str -- newstr )
    [ path-separator? ] left-trim ;

: path+ ( str1 str2 -- str )
    >r right-trim-separators "/" r>
    left-trim-separators 3append ;

: stat ( path -- directory? permissions length modified )
    normalize-pathname (stat) ;

: file-length ( path -- n ) stat 4array third ;

: file-modified ( path -- n ) stat >r 3drop r> ; inline

: exists? ( path -- ? ) file-modified >boolean ;

: directory? ( path -- ? ) stat 3drop ;

: special-directory? ( name -- ? )
    { "." ".." } member? ;

: fixup-directory ( path seq -- newseq )
    [
        dup string?
        [ tuck path+ directory? 2array ] [ nip ] if
    ] with map
    [ first special-directory? not ] subset ;

: directory ( path -- seq )
    normalize-directory dup (directory) fixup-directory ;

: last-path-separator ( path -- n ? )
    [ length 1- ] keep [ path-separator? ] find-last* ;

TUPLE: no-parent-directory path ;

: no-parent-directory ( path -- * )
    \ no-parent-directory construct-boa throw ;

: parent-directory ( path -- parent )
    right-trim-separators {
        { [ dup empty? ] [ drop "/" ] }
        { [ dup root-directory? ] [ ] }
        { [ dup [ path-separator? ] contains? not ] [ drop "." ] }
        { [ t ] [
            dup last-path-separator drop 1+ cut
            special-directory? [ no-parent-directory ] when
        ] }
    } cond ;

: file-name ( path -- string )
    right-trim-separators {
        { [ dup empty? ] [ drop "/" ] }
        { [ dup last-path-separator ] [ 1+ tail ] }
        { [ t ] [ drop ] }
    } cond ;

: resource-path ( path -- newpath )
    \ resource-path get [ image parent-directory ] unless*
    swap path+ ;

: ?resource-path ( path -- newpath )
    "resource:" ?head [ resource-path ] when ;

: resource-exists? ( path -- ? )
    ?resource-path exists? ;

: make-directories ( path -- )
    normalize-pathname right-trim-separators {
        { [ dup "." = ] [ ] }
        { [ dup root-directory? ] [ ] }
        { [ dup empty? ] [ ] }
        { [ dup exists? ] [ ] }
        { [ t ] [
            dup parent-directory make-directories
            dup make-directory
        ] }
    } cond drop ;

HOOK: copy-file io-backend ( from to -- )

M: object copy-file
    dup parent-directory make-directories
    <file-writer> [
        swap <file-reader> [
            swap stream-copy
        ] with-disposal
    ] with-disposal ;

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

: file-lines ( path -- seq ) <file-reader> lines ;

: file-contents ( path -- str )
    dup <file-reader> swap file-length <sbuf>
    [ stream-copy ] keep >string ;

: with-file-reader ( path quot -- )
    >r <file-reader> r> with-stream ; inline

: with-file-writer ( path quot -- )
    >r <file-writer> r> with-stream ; inline

: with-file-appender ( path quot -- )
    >r <file-appender> r> with-stream ; inline
