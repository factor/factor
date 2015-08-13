! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs continuations deques dlists fry
io.backend io.directories io.files.info io.pathnames kernel
kernel.private locals math sequences sequences.extras sorting
strings system unicode.case vocabs ;
IN: io.directories.search

: qualified-directory-entries ( path -- seq )
    absolute-path
    dup directory-entries [ [ append-path ] change-name ] with map! ;

: qualified-directory-files ( path -- seq )
    absolute-path
    dup directory-files [ append-path ] with map! ;

: with-qualified-directory-files ( path quot -- )
    '[ "" qualified-directory-files @ ] with-directory ; inline

: with-qualified-directory-entries ( path quot -- )
    '[ "" qualified-directory-entries @ ] with-directory ; inline

<PRIVATE

TUPLE: directory-iterator
{ path string }
{ bfs boolean }
{ queue dlist } ;

: push-directory-entries ( path iter -- )
    { directory-iterator } declare
    [ [ qualified-directory-entries ] [ 2drop f ] recover ] dip '[
        _ [ queue>> ] [ bfs>> ] bi
        [ push-front ] [ push-back ] if
    ] each ;

: <directory-iterator> ( path bfs? -- iterator )
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

: setup-traversal ( path bfs quot -- iterator quot' )
    [ <directory-iterator> ] dip [ f ] compose ; inline

PRIVATE>

: each-file ( path bfs? quot -- )
    setup-traversal iterate-directory drop ; inline

: each-file-breadth ( path quot -- )
    t swap each-file ; inline

: each-file-depth ( path quot -- )
    f swap each-file ; inline

: filter-files-by-depth ( quot -- seq )
    selector* [ each-file-depth ] dip ; inline

: filter-files-by-breadth ( quot -- seq )
    selector* [ each-file-breadth ] dip ; inline

: all-files-by-depth ( quot -- seq )
    collector [ each-file-depth ] dip ; inline

: all-files-by-breadth ( quot -- seq )
    collector [ each-file-breadth ] dip ; inline

: each-directory-entry ( path bfs? quot: ( ... entry -- ... ) -- )
    setup-traversal iterate-directory-entries drop ; inline

: recursive-directory-files ( path bfs? -- paths )
    [ ] collector [ each-file ] dip ;

: recursive-directory-entries ( path bfs? -- directory-entries )
    [ ] collector [ each-directory-entry ] dip ;

: find-file ( path bfs? quot: ( ... name -- ... ? ) -- path/f )
    [ <directory-iterator> ] dip
    [ keep and ] curry iterate-directory ; inline

: find-all-files ( path quot: ( ... name -- ... ? ) -- paths )
    f swap selector [ each-file ] dip ; inline

ERROR: file-not-found path bfs? quot ;

: find-file-throws ( path bfs? quot -- path )
    3dup find-file [ 2nip nip ] [ throw-file-not-found ] if* ; inline

ERROR: sequence-expected obj ;

: ensure-sequence-of-directories ( obj -- seq )
    dup string? [ 1array ] when
    dup sequence? [ throw-sequence-expected ] unless ;

! Can't make this generic# on string/sequence because of combinators
: find-in-directories ( directories bfs? quot -- path'/f )
    [ ensure-sequence-of-directories ] 2dip
    '[ _ [ _ _ find-file-throws ] attempt-all ]
    [ drop f ] recover ; inline

: find-all-in-directories ( directories quot -- paths/f )
    '[ _ find-all-files ] map concat ; inline

: ?parent-directory ( path -- path'/f )
    dup parent-directory 2dup = [ 2drop f ] [ nip ] if ;

: ?file-info ( path -- file-info/f )
    [ file-info ] [ 2drop f ] recover ;

: containing-directory ( path -- path' )
    dup ?file-info directory? [ parent-directory ] unless ;

: ?qualified-directory-files ( path -- seq )
    [ qualified-directory-files ]
    [ drop ?parent-directory [ ?qualified-directory-files ] [ f ] if* ] recover ;

: (find-up-to-root) ( path  quot: ( path -- ? ) -- obj )
    [ [ ?qualified-directory-files ] dip find swap ] 2keep rot [
        2drop
    ] [
        [ nip ?parent-directory ] dip over
        [ (find-up-to-root) ] [ 2drop f ] if
    ] if ; inline recursive

: find-up-to-root ( path quot -- obj )
    [ normalize-path containing-directory ] dip (find-up-to-root) ; inline

: link-size/0 ( path -- n )
    [ link-info size-on-disk>> ] [ 2drop 0 ] recover ;

: directory-size ( path -- n )
    0 swap t [ link-size/0 + ] each-file ;

: directory-usage ( path -- assoc )
    [
        [
            [ name>> dup ] [ directory? ] bi
            [ directory-size ] [ link-size/0 ] if
        ] { } map>assoc
    ] with-qualified-directory-entries sort-values ;

: find-by-extensions ( path extensions -- seq )
    [ >lower ] map
    '[ >lower _ [ tail? ] with any? ] find-all-files ;

: find-by-extension ( path extension -- seq )
    1array find-by-extensions ;

: find-files-larger-than ( path size -- seq )
    '[ file-info size>> _ > ] filter-files-by-depth ;

: file-info-recursive ( path -- seq )
    [ dup ?file-info [ 2array ] [ drop f ] if* ] filter-files-by-depth ;

os windows? [ "io.directories.search.windows" require ] when
