! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays continuations deques dlists fry
io.directories io.files io.files.info io.pathnames kernel
sequences system vocabs.loader ;
IN: io.directories.search

<PRIVATE

TUPLE: directory-iterator path bfs queue ;

: qualified-directory ( path -- seq )
    dup directory-files [ append-path ] with map ;

: push-directory ( path iter -- )
    [ qualified-directory ] dip [
        [ queue>> ] [ bfs>> ] bi
        [ push-front ] [ push-back ] if
    ] curry each ;

: <directory-iterator> ( path bfs? -- iterator )
    <dlist> directory-iterator boa
    dup path>> over push-directory ;

: next-file ( iter -- file/f )
    dup queue>> deque-empty? [ drop f ] [
        dup queue>> pop-back dup link-info directory?
        [ over push-directory next-file ] [ nip ] if
    ] if ;

: iterate-directory ( iter quot: ( obj -- ? ) -- obj )
    over next-file [
        over call
        [ 2nip ] [ iterate-directory ] if*
    ] [
        2drop f
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
    [
        '[ _ _ find-file [ file-not-found ] unless* ] attempt-all
    ] [
        drop f
    ] recover ;

: find-all-in-directories ( directories bfs? quot: ( obj -- ? ) -- paths/f )
    '[ _ _ find-all-files ] map concat ;

os windows? [ "io.directories.search.windows" require ] when
