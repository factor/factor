! Copyright (C) 2004, 2008 Slava Pestov, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators
combinators.short-circuit continuations deques destructors
dlists fry io io.backend io.encodings.binary io.files
io.files.info io.files.links io.files.types io.pathnames kernel
kernel.private make math namespaces sequences sorting strings
system unicode vocabs ;
IN: io.directories

: set-current-directory ( path -- )
    absolute-path current-directory set ;

: with-directory ( path quot -- )
    [ absolute-path current-directory ] dip with-variable ; inline

: with-resource-directory ( quot -- )
    [ "resource:" ] dip with-directory ; inline

! Creating directories
HOOK: make-directory io-backend ( path -- )

DEFER: make-parent-directories

: make-directories ( path -- )
    normalize-path trim-tail-separators dup {
        [ "." = ]
        [ root-directory? ]
        [ empty? ]
        [ file-exists? ]
    } 1|| [
        make-parent-directories
        dup make-directory
    ] unless drop ;

: make-parent-directories ( filename -- filename )
    dup parent-directory make-directories ;

: with-ensure-directory ( path quot -- )
    [ absolute-path dup make-directories current-directory ] dip with-variable ; inline

! Listing directories
TUPLE: directory-entry name type ;

C: <directory-entry> directory-entry

HOOK: (directory-entries) os ( path -- seq )

: directory-entries ( path -- seq )
    normalize-path
    (directory-entries)
    [ name>> { "." ".." } member? ] reject ;

: directory-files ( path -- seq )
    directory-entries [ name>> ] map! ;

: with-directory-entries ( path quot -- )
    '[ "" directory-entries @ ] with-directory ; inline

: with-directory-files ( path quot -- )
    '[ "" directory-files @ ] with-directory ; inline

! Finding directories

: qualified-directory-entries ( path -- seq )
    dup directory-entries [ [ append-path ] change-name ] with map! ;

: qualified-directory-files ( path -- seq )
    dup directory-files [ append-path ] with map! ;

SYMBOL: traversal-method

SYMBOLS: +depth-first+ +breadth-first+ ;

traversal-method [ +depth-first+ ] initialize

<PRIVATE

TUPLE: directory-iterator
{ path string }
{ bfs boolean }
{ queue dlist } ;

: push-directory-entries ( path iter -- )
    { directory-iterator } declare
    [ [ qualified-directory-entries ] [ 2drop f ] recover ] dip
    [ bfs>> [ [ <reversed> ] unless ] keep ]
    [ queue>> swap '[ _ _ [ push-front ] [ push-back ] if ] each ] bi ;

: <directory-iterator> ( path bfs? -- iter )
    [ pathname> ] dip
    <dlist> directory-iterator boa
    dup path>> over push-directory-entries ;

: next-directory-entry ( iter -- directory-entry/f )
    { directory-iterator } declare
    dup queue>> deque-empty? [ drop f ] [
        dup queue>> pop-back
        dup directory?
        [ [ name>> swap push-directory-entries ] keep ]
        [ nip ] if
    ] if ;

: iterate-directory-entries ( ... iter quot: ( ... directory-entry -- ... obj/f ) -- ... obj/f )
    over next-directory-entry [
        over curry 2dip
        [ iterate-directory-entries ] 2curry unless*
    ] [
        2drop f
    ] if* ; inline recursive

: iterate-directory ( iter quot -- path/f )
    [ name>> ] prepose iterate-directory-entries ; inline

: bfs? ( -- bfs? )
    traversal-method get {
        { +breadth-first+ [ t ] }
        { +depth-first+ [ f ] }
    } case ; inline

: setup-traversal ( path quot -- iter quot' )
    [ bfs? <directory-iterator> ] dip [ f ] compose ; inline

PRIVATE>

: each-file ( ... path quot: ( ... name -- ... ) -- ... )
    setup-traversal iterate-directory drop ; inline

: each-directory-entry ( path quot: ( ... entry -- ... ) -- )
    setup-traversal iterate-directory-entries drop ; inline

: recursive-directory-files ( path -- paths )
    [ ] collector [ each-file ] dip ;

: recursive-directory-entries ( path -- directory-entries )
    [ ] collector [ each-directory-entry ] dip ;

: find-file ( path quot: ( ... name -- ... ? ) -- path/f )
    [ bfs? <directory-iterator> ] dip
    '[ _ keep and ] iterate-directory ; inline

: find-files ( path quot: ( ... name -- ... ? ) -- paths )
    selector [ each-file ] dip ; inline

ERROR: sequence-expected obj ;

: ensure-sequence-of-directories ( obj -- seq )
    dup string? [ 1array ] when
    dup sequence? [ sequence-expected ] unless ;

: find-file-in-directories ( directories quot: ( ... name -- ... ? ) -- path'/f )
    [ ensure-sequence-of-directories ] dip
    '[ _ find-file ] map-find drop ; inline

: find-files-in-directories ( directories quot: ( ... name -- ... ? ) -- paths/f )
    [ ensure-sequence-of-directories ] dip
    '[ _ find-files ] map concat ; inline

: ?parent-directory ( path -- path'/f )
    dup parent-directory 2dup = [ 2drop f ] [ nip ] if ;

: containing-directory ( path -- path' )
    dup file-info directory? [ parent-directory ] unless ;

: ?qualified-directory-files ( path -- seq )
    [ qualified-directory-files ]
    [ drop ?parent-directory [ ?qualified-directory-files ] [ f ] if* ] recover ;

: (find-up-to-root) ( path quot: ( path -- ? ) -- obj )
    [ [ ?qualified-directory-files ] dip find swap ] 2keep rot [
        2drop
    ] [
        [ nip ?parent-directory ] dip over
        [ (find-up-to-root) ] [ 2drop f ] if
    ] if ; inline recursive

: find-up-to-root ( path quot: ( path -- ? ) -- obj )
    [ normalize-path containing-directory ] dip (find-up-to-root) ; inline

: link-size/0 ( path -- n )
    [ link-info size-on-disk>> ] [ 2drop 0 ] recover ;

: directory-size ( path -- n )
    0 swap [ link-size/0 + ] each-file ;

: directory-usage ( path -- assoc )
    qualified-directory-entries [
        [ name>> dup ] [ directory? ] bi
        [ directory-size ] [ link-size/0 ] if
    ] { } map>assoc sort-values ;

: find-files-by-extensions ( path extensions -- seq )
    [ >lower ] map
    '[ >lower _ [ tail? ] with any? ] find-files ;

: find-files-by-extension ( path extension -- seq )
    1array find-files-by-extensions ;

: find-files-larger-than ( path size -- seq )
    '[ link-info size>> _ > ] find-files ;

HOOK: touch-file io-backend ( path -- )

HOOK: truncate-file io-backend ( path n -- )

HOOK: delete-file io-backend ( path -- )

HOOK: delete-directory io-backend ( path -- )

: ?delete-file ( path -- )
    '[ _ delete-file ] ignore-errors ;

: to-directory ( from to -- from to' )
    over file-name append-path ;

HOOK: move-file io-backend ( from to -- )

HOOK: move-file-atomically io-backend ( from to -- )

: move-file-into ( from to -- )
    to-directory move-file ;

: move-files-into ( files to -- )
    '[ _ move-file-into ] each ;

HOOK: copy-file io-backend ( from to -- )

M: object copy-file
    make-parent-directories binary <file-writer> [
        swap binary <file-reader> [
            swap stream-copy
        ] with-disposal
    ] with-disposal ;

: copy-file-into ( from to -- )
    to-directory copy-file ;

: copy-files-into ( files to -- )
    '[ _ copy-file-into ] each ;

: delete-tree ( path -- )
    dup link-info directory? [
        [ [ [ delete-tree ] each ] with-directory-files ]
        [ delete-directory ]
        bi
    ] [ delete-file ] if ;

: ?delete-tree ( path -- )
    dup file-exists? [ delete-tree ] [ drop ] if ;

DEFER: copy-trees-into

: copy-tree ( from to -- )
    normalize-path
    over link-info type>>
    {
        { +symbolic-link+ [ copy-link ] }
        { +directory+ [ '[ _ copy-trees-into ] with-directory-files ] }
        [ drop copy-file ]
    } case ;

: copy-tree-into ( from to -- )
    to-directory copy-tree ;

: copy-trees-into ( files to -- )
    '[ _ copy-tree-into ] each ;

{
    { [ os unix? ] [ "io.directories.unix" require ] }
    { [ os windows? ] [ "io.directories.windows" require ] }
} cond
