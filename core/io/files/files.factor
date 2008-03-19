! Copyright (C) 2004, 2008 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: io.backend io.files.private io hashtables kernel math
memory namespaces sequences strings assocs arrays definitions
system combinators splitting sbufs continuations io.encodings
io.encodings.binary ;
IN: io.files

HOOK: (file-reader) io-backend ( path -- stream )

HOOK: (file-writer) io-backend ( path -- stream )

HOOK: (file-appender) io-backend ( path -- stream )

: <file-reader> ( path encoding -- stream )
    swap (file-reader) swap <decoder> ;

: <file-writer> ( path encoding -- stream )
    swap (file-writer) swap <encoder> ;

: <file-appender> ( path encoding -- stream )
    swap (file-appender) swap <encoder> ;

HOOK: rename-file io-backend ( from to -- )

! Pathnames
: path-separator? ( ch -- ? ) windows? "/\\" "/" ? member? ;

: right-trim-separators ( str -- newstr )
    [ path-separator? ] right-trim ;

: left-trim-separators ( str -- newstr )
    [ path-separator? ] left-trim ;

: path+ ( str1 str2 -- str )
    >r right-trim-separators "/" r>
    left-trim-separators 3append ;

: last-path-separator ( path -- n ? )
    [ length 1- ] keep [ path-separator? ] find-last* ;

HOOK: root-directory? io-backend ( path -- ? )

M: object root-directory? ( path -- ? ) path-separator? ;

: special-directory? ( name -- ? ) { "." ".." } member? ;

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

TUPLE: file-info type size permissions modified ;

HOOK: file-info io-backend ( path -- info )
HOOK: link-info io-backend ( path -- info )

SYMBOL: +regular-file+
SYMBOL: +directory+
SYMBOL: +character-device+
SYMBOL: +block-device+
SYMBOL: +fifo+
SYMBOL: +symbolic-link+
SYMBOL: +socket+
SYMBOL: +unknown+

! File metadata
: stat ( path -- directory? permissions length modified )
    normalize-pathname (stat) ;

: file-modified ( path -- n ) stat >r 3drop r> ;

: exists? ( path -- ? ) file-modified >boolean ;

: directory? ( path -- ? ) file-info file-info-type +directory+ = ;

! Current working directory
HOOK: cd io-backend ( path -- )

HOOK: cwd io-backend ( -- path )

: with-directory ( path quot -- )
    cwd [ cd ] curry rot cd [ ] cleanup ; inline

! Creating directories
HOOK: make-directory io-backend ( path -- )

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

! Directory listings
: fixup-directory ( path seq -- newseq )
    [
        dup string?
        [ tuck path+ directory? 2array ] [ nip ] if
    ] with map
    [ first special-directory? not ] subset ;

: directory ( path -- seq )
    normalize-directory dup (directory) fixup-directory ;

: directory* ( path -- seq )
    dup directory [ first2 >r path+ r> 2array ] with map ;

! Touching files
HOOK: touch-file io-backend ( path -- )

! Deleting files
HOOK: delete-file io-backend ( path -- )

HOOK: delete-directory io-backend ( path -- )

: (delete-tree) ( path dir? -- )
    [
        dup directory* [ (delete-tree) ] assoc-each
        delete-directory
    ] [ delete-file ] if ;

: delete-tree ( path -- )
    dup directory? (delete-tree) ;

: to-directory over file-name path+ ;

! Moving and renaming files
HOOK: move-file io-backend ( from to -- )

: move-file-into ( from to -- )
    to-directory move-file ;

: move-files-into ( files to -- )
    [ move-file-into ] curry each ;

! Copying files
HOOK: copy-file io-backend ( from to -- )

M: object copy-file
    dup parent-directory make-directories
    binary <file-writer> [
        swap binary <file-reader> [
            swap stream-copy
        ] with-disposal
    ] with-disposal ;

: copy-file-into ( from to -- )
    to-directory copy-file ;

: copy-files-into ( files to -- )
    [ copy-file-into ] curry each ;

DEFER: copy-tree-into

: copy-tree ( from to -- )
    over directory? [
        >r dup directory swap r> [
            >r swap first path+ r> copy-tree-into
        ] 2curry each
    ] [
        copy-file
    ] if ;

: copy-tree-into ( from to -- )
    to-directory copy-tree ;

: copy-trees-into ( files to -- )
    [ copy-tree-into ] curry each ;

! Special paths
: resource-path ( path -- newpath )
    \ resource-path get [ image parent-directory ] unless*
    swap path+ ;

: ?resource-path ( path -- newpath )
    "resource:" ?head [ resource-path ] when ;

: resource-exists? ( path -- ? )
    ?resource-path exists? ;

! Pathname presentations
TUPLE: pathname string ;

C: <pathname> pathname

M: pathname <=> [ pathname-string ] compare ;

: file-lines ( path encoding -- seq )
    <file-reader> lines ;

: with-file-reader ( path encoding quot -- )
    >r <file-reader> r> with-stream ; inline

: file-contents ( path encoding -- str )
    <file-reader> contents ;

: with-file-writer ( path encoding quot -- )
    >r <file-writer> r> with-stream ; inline

: set-file-lines ( seq path encoding -- )
    [ [ print ] each ] with-file-writer ;

: set-file-contents ( str path encoding -- )
    [ write ] with-file-writer ;

: with-file-appender ( path encoding quot -- )
    >r <file-appender> r> with-stream ; inline

: temp-directory ( -- path )
    "temp" resource-path
    dup exists? not
      [ dup make-directory ]
    when ;

: temp-file ( name -- path ) temp-directory swap path+ ;

! Home directory
: home ( -- dir )
    {
        { [ winnt? ] [ "USERPROFILE" os-env ] }
        { [ wince? ] [ "" resource-path ] }
        { [ unix? ] [ "HOME" os-env ] }
    } cond ;
