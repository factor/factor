! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays continuations deques dlists fry
io.directories io.files io.files.info io.pathnames kernel
sequences system vocabs.loader locals math namespaces
sorting assocs calendar threads ;
IN: io.directories.search

: qualified-directory-entries ( path -- seq )
    dup directory-entries
    [ [ append-path ] change-name ] with map ;

: qualified-directory-files ( path -- seq )
    dup directory-files [ append-path ] with map ;

<PRIVATE

TUPLE: directory-iterator path bfs queue ;

: push-directory ( path iter -- )
    [ dup directory-entry? [ name>> ] when ] dip
    [ qualified-directory-entries ] dip '[
        _ [ queue>> ] [ bfs>> ] bi
        [ push-front ] [ push-back ] if
    ] each ;

: <directory-iterator> ( path bfs? -- iterator )
    <dlist> directory-iterator boa
    dup path>> over push-directory ;

: next-file ( iter -- file/f )
    dup queue>> deque-empty? [ drop f ] [
        dup queue>> pop-back dup directory?
        [ over push-directory next-file ]
        [ nip name>> ] if
    ] if ;

:: iterate-directory ( iter quot: ( obj -- ? ) -- obj )
    iter next-file [
        quot call [ iter quot iterate-directory ] unless*
    ] [
        f
    ] if* ; inline recursive

PRIVATE>

: each-file ( path bfs? quot: ( obj -- ) -- )
    [ <directory-iterator> ] dip
    [ f ] compose iterate-directory drop ; inline

: recursive-directory ( path bfs? -- paths )
    [ ] accumulator [ each-file ] dip ;

: find-file ( path bfs? quot: ( obj -- ? ) -- path/f )
    '[
        _ _ _ [ <directory-iterator> ] dip
        [ keep and ] curry iterate-directory
    ] [ drop f ] recover ; inline

: find-all-files ( path quot: ( obj -- ? ) -- paths/f )
    f swap
    '[
        _ _ _ [ <directory-iterator> ] dip
        pusher [ [ f ] compose iterate-directory drop ] dip
    ] [ drop f ] recover ; inline

ERROR: file-not-found ;

: find-in-directories ( directories bfs? quot: ( obj -- ? ) -- path'/f )
    '[
        _ [ _ _ find-file [ file-not-found ] unless* ] attempt-all
    ] [
        drop f
    ] recover ; inline

: find-all-in-directories ( directories bfs? quot: ( obj -- ? ) -- paths/f )
    '[ _ _ find-all-files ] map concat ; inline

: with-qualified-directory-files ( path quot -- )
    '[ "" qualified-directory-files @ ] with-directory ; inline

: with-qualified-directory-entries ( path quot -- )
    '[ "" qualified-directory-entries @ ] with-directory ; inline

: directory-size ( path -- n )
    0 swap t [
        [ link-info size-on-disk>> + ] [ 2drop ] recover
    ] each-file ;

: path>usage ( directory-entry -- name size )
    [ name>> dup ] [ directory? ] bi [
        directory-size
    ] [
        [ link-info size-on-disk>> ] [ 2drop 0 ] recover
    ] if ;

: directory-usage ( path -- assoc )
    [
        [ [ path>usage ] [ drop name>> 0 ] recover ] { } map>assoc
    ] with-qualified-directory-entries sort-values ;

os windows? [ "io.directories.search.windows" require ] when
