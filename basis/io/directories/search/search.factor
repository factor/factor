! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays continuations deques dlists fry
io.directories io.files io.files.info io.pathnames kernel
sequences system vocabs.loader locals math namespaces
sorting assocs calendar threads io math.parser ;
IN: io.directories.search

: qualified-directory-entries ( path -- seq )
    dup directory-entries
    [ [ append-path ] change-name ] with map ;

: qualified-directory-files ( path -- seq )
    dup directory-files [ append-path ] with map ;

: with-qualified-directory-files ( path quot -- )
    '[ "" qualified-directory-files @ ] with-directory ; inline

: with-qualified-directory-entries ( path quot -- )
    '[ "" qualified-directory-entries @ ] with-directory ; inline

<PRIVATE

TUPLE: directory-iterator path bfs queue ;

: push-directory-entries ( path iter -- )
    [ qualified-directory-entries ] dip '[
        _ [ queue>> ] [ bfs>> ] bi
        [ push-front ] [ push-back ] if
    ] each ;

: <directory-iterator> ( path bfs? -- iterator )
    <dlist> directory-iterator boa
    dup path>> over push-directory-entries ;

: next-directory-entry ( iter -- directory-entry/f )
    dup queue>> deque-empty? [ drop f ] [
        dup queue>> pop-back
        dup directory?
        [ name>> over push-directory-entries next-directory-entry ]
        [ nip ] if
    ] if ; recursive

:: iterate-directory-entries ( iter quot -- directory-entry/f )
    iter next-directory-entry [
        quot call( obj -- obj )
        [ iter quot iterate-directory-entries ] unless*
    ] [
        f
    ] if* ; inline recursive

: iterate-directory ( iter quot -- path/f )
    [ name>> ] prepose iterate-directory-entries ;

: setup-traversal ( path bfs quot -- iterator quot' )
    [ <directory-iterator> ] dip [ f ] compose ;

PRIVATE>

: each-file ( path bfs? quot -- )
    setup-traversal iterate-directory drop ;

: each-directory-entry ( path bfs? quot -- )
    setup-traversal iterate-directory-entries drop ;

: recursive-directory-files ( path bfs? -- paths )
    [ ] accumulator [ each-file ] dip ;

: recursive-directory-entries ( path bfs? -- paths )
    [ ] accumulator [ each-directory-entry ] dip ;

: find-file ( path bfs? quot -- path/f )
    '[
        _ _ _ [ <directory-iterator> ] dip
        [ keep and ] curry iterate-directory
    ] [ drop f ] recover ;

: find-all-files ( path quot -- paths/f )
    '[
        _ _ [ f <directory-iterator> ] dip
        pusher [ [ f ] compose iterate-directory drop ] dip
    ] [ drop f ] recover ;

ERROR: file-not-found path bfs? quot ;

: find-file-throws ( path bfs? quot -- path )
    3dup find-file dup [ 2nip nip ] [ drop file-not-found ] if ;

: find-in-directories ( directories bfs? quot -- path'/f )
    '[ _ [ _ _ find-file-throws ] attempt-all ]
    [ drop f ] recover ;

: find-all-in-directories ( directories quot -- paths/f )
    '[ _ find-all-files ] map concat ;

: link-size/0 ( path -- n )
    [ link-info size-on-disk>> ] [ 2drop 0 ] recover ;

: directory-size ( path -- n )
    0 swap t [ link-size/0 + ] each-file ;

: path>usage ( directory-entry -- name size )
    [ name>> dup ] [ directory? ] bi
    [ directory-size ] [ link-size/0 ] if ;

: directory-usage ( path -- assoc )
    [
        [
            [ path>usage ] [ drop name>> 0 ] recover
        ] { } map>assoc
    ] with-qualified-directory-entries sort-values ;

os windows? [ "io.directories.search.windows" require ] when
