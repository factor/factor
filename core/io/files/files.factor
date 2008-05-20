! Copyright (C) 2004, 2008 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: io.backend io.files.private io hashtables kernel math
memory namespaces sequences strings assocs arrays definitions
system combinators splitting sbufs continuations destructors
io.encodings io.encodings.binary init accessors math.order ;
IN: io.files

HOOK: (file-reader) io-backend ( path -- stream )

HOOK: (file-writer) io-backend ( path -- stream )

HOOK: (file-appender) io-backend ( path -- stream )

: <file-reader> ( path encoding -- stream )
    swap normalize-path (file-reader) swap <decoder> ;

: <file-writer> ( path encoding -- stream )
    swap normalize-path (file-writer) swap <encoder> ;

: <file-appender> ( path encoding -- stream )
    swap normalize-path (file-appender) swap <encoder> ;

: file-lines ( path encoding -- seq )
    <file-reader> lines ;

: with-file-reader ( path encoding quot -- )
    >r <file-reader> r> with-input-stream ; inline

: file-contents ( path encoding -- str )
    <file-reader> contents ;

: with-file-writer ( path encoding quot -- )
    >r <file-writer> r> with-output-stream ; inline

: set-file-lines ( seq path encoding -- )
    [ [ print ] each ] with-file-writer ;

: set-file-contents ( str path encoding -- )
    [ write ] with-file-writer ;

: with-file-appender ( path encoding quot -- )
    >r <file-appender> r> with-output-stream ; inline

! Pathnames
: path-separator? ( ch -- ? ) os windows? "/\\" "/" ? member? ;

: path-separator ( -- string ) os windows? "\\" "/" ? ;

: right-trim-separators ( str -- newstr )
    [ path-separator? ] right-trim ;

: left-trim-separators ( str -- newstr )
    [ path-separator? ] left-trim ;

: last-path-separator ( path -- n ? )
    [ length 1- ] keep [ path-separator? ] find-last-from ;

HOOK: root-directory? io-backend ( path -- ? )

M: object root-directory? ( path -- ? )
    dup empty? [ drop f ] [ [ path-separator? ] all? ] if ;

ERROR: no-parent-directory path ;

: parent-directory ( path -- parent )
    dup root-directory? [
        right-trim-separators
        dup last-path-separator [
            1+ cut
        ] [
            drop "." swap
        ] if
        { "" "." ".." } member? [
            no-parent-directory
        ] when
    ] unless ;

<PRIVATE

: head-path-separator? ( path1 ? -- ?' )
    [
        dup empty? [ drop t ] [ first path-separator? ] if
    ] [
        drop f
    ] if ;

: head.? ( path -- ? ) "." ?head head-path-separator? ;

: head..? ( path -- ? ) ".." ?head head-path-separator? ;

: append-path-empty ( path1 path2 -- path' )
    {
        { [ dup head.? ] [
            rest left-trim-separators append-path-empty
        ] }
        { [ dup head..? ] [ drop no-parent-directory ] }
        [ nip ]
    } cond ;

PRIVATE>

: windows-absolute-path? ( path -- path ? )
    {
        { [ dup "\\\\?\\" head? ] [ t ] }
        { [ dup length 2 < ] [ f ] }
        { [ dup second CHAR: : = ] [ t ] }
        [ f ]
    } cond ;

: absolute-path? ( path -- ? )
    {
        { [ dup empty? ] [ f ] }
        { [ dup "resource:" head? ] [ t ] }
        { [ os windows? ] [ windows-absolute-path? ] }
        { [ dup first path-separator? ] [ t ] }
        [ f ]
    } cond nip ;

: append-path ( str1 str2 -- str )
    {
        { [ over empty? ] [ append-path-empty ] }
        { [ dup empty? ] [ drop ] }
        { [ dup absolute-path? ] [ nip ] }
        { [ dup head.? ] [ rest left-trim-separators append-path ] }
        { [ dup head..? ] [
            2 tail left-trim-separators
            >r parent-directory r> append-path
        ] }
        { [ over absolute-path? over first path-separator? and ] [
            >r 2 head r> append
        ] }
        [
            >r right-trim-separators "/" r>
            left-trim-separators 3append
        ]
    } cond ;

: prepend-path ( str1 str2 -- str )
    swap append-path ; inline

: file-name ( path -- string )
    dup root-directory? [
        right-trim-separators
        dup last-path-separator [ 1+ tail ] [
            drop "resource:" ?head [ file-name ] when
        ] if
    ] unless ;

! File info
TUPLE: file-info type size permissions modified ;

HOOK: file-info io-backend ( path -- info )

! Symlinks
HOOK: link-info io-backend ( path -- info )

HOOK: make-link io-backend ( target symlink -- )

HOOK: read-link io-backend ( symlink -- path )

: copy-link ( target symlink -- )
    >r read-link r> make-link ;

SYMBOL: +regular-file+
SYMBOL: +directory+
SYMBOL: +symbolic-link+
SYMBOL: +character-device+
SYMBOL: +block-device+
SYMBOL: +fifo+
SYMBOL: +socket+
SYMBOL: +unknown+

! File metadata
: exists? ( path -- ? ) normalize-path (exists?) ;

: directory? ( file-info -- ? ) type>> +directory+ = ;

<PRIVATE

HOOK: cd io-backend ( path -- )

HOOK: cwd io-backend ( -- path )

M: object cwd ( -- path ) "." ;

PRIVATE>

SYMBOL: current-directory

[ cwd current-directory set-global ] "io.files" add-init-hook

: resource-path ( path -- newpath )
    "resource-path" get [ image parent-directory ] unless*
    prepend-path ;

: (normalize-path) ( path -- path' )
    "resource:" ?head [
        left-trim-separators resource-path
        (normalize-path)
    ] [
        current-directory get prepend-path
    ] if ;

M: object normalize-path ( path -- path' )
    (normalize-path) ;

: set-current-directory ( path -- )
    (normalize-path) current-directory set ;

: with-directory ( path quot -- )
    >r (normalize-path) current-directory r> with-variable ; inline

! Creating directories
HOOK: make-directory io-backend ( path -- )

: make-directories ( path -- )
    normalize-path right-trim-separators {
        { [ dup "." = ] [ ] }
        { [ dup root-directory? ] [ ] }
        { [ dup empty? ] [ ] }
        { [ dup exists? ] [ ] }
        [
            dup parent-directory make-directories
            dup make-directory
        ]
    } cond drop ;

! Directory listings
: fixup-directory ( path seq -- newseq )
    [
        dup string?
        [ tuck append-path file-info directory? 2array ] [ nip ] if
    ] with map
    [ first { "." ".." } member? not ] filter ;

: directory ( path -- seq )
    normalize-directory dup (directory) fixup-directory ;

: directory* ( path -- seq )
    dup directory [ first2 >r append-path r> 2array ] with map ;

! Touching files
HOOK: touch-file io-backend ( path -- )

! Deleting files
HOOK: delete-file io-backend ( path -- )

HOOK: delete-directory io-backend ( path -- )

: delete-tree ( path -- )
    dup link-info type>> +directory+ = [
        dup directory over [
            [ first delete-tree ] each
        ] with-directory delete-directory
    ] [
        delete-file
    ] if ;

: to-directory over file-name append-path ;

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
    normalize-path
    over link-info type>>
    {
        { +symbolic-link+ [ copy-link ] }
        { +directory+ [
            >r dup directory r> rot [
                [ >r first r> copy-tree-into ] curry each
            ] with-directory
        ] }
        [ drop copy-file ]
    } case ;

: copy-tree-into ( from to -- )
    to-directory copy-tree ;

: copy-trees-into ( files to -- )
    [ copy-tree-into ] curry each ;

! Special paths

: temp-directory ( -- path )
    "temp" resource-path dup make-directories ;

: temp-file ( name -- path )
    temp-directory prepend-path ;

! Pathname presentations
TUPLE: pathname string ;

C: <pathname> pathname

M: pathname <=> [ pathname-string ] compare ;

! Home directory
HOOK: home os ( -- dir )

M: winnt home "USERPROFILE" os-env ;

M: wince home "" resource-path ;

M: unix home "HOME" os-env ;
