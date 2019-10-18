! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators continuations deques
dlists fry io.backend io.directories io.files.info io.pathnames
kernel kernel.private locals math namespaces sequences sorting
strings system unicode vocabs ;
IN: io.directories.search

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

:: iterate-directory-entries ( ... iter quot: ( ... obj -- ... obj ) -- ... directory-entry/f )
    iter next-directory-entry [
        quot call
        [ iter quot iterate-directory-entries ] unless*
    ] [
        f
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
    [
        [
            [ name>> dup ] [ directory? ] bi
            [ directory-size ] [ link-size/0 ] if
        ] { } map>assoc
    ] with-qualified-directory-entries sort-values ;

: find-files-by-extensions ( path extensions -- seq )
    [ >lower ] map
    '[ >lower _ [ tail? ] with any? ] find-files ;

: find-files-by-extension ( path extension -- seq )
    1array find-files-by-extensions ;

: find-files-larger-than ( path size -- seq )
    '[ link-info size>> _ > ] find-files ;
