! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays deques dlists io.files
kernel sequences system vocabs.loader fry continuations ;
IN: io.paths

TUPLE: directory-iterator path bfs queue ;

<PRIVATE

: qualified-directory ( path -- seq )
    dup directory-files [ append-path ] with map ;

: push-directory ( path iter -- )
    [ qualified-directory ] dip [
        dup queue>> swap bfs>>
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

: find-file ( path bfs? quot: ( obj -- ? ) -- path/f )
    [ <directory-iterator> ] dip
    [ keep and ] curry iterate-directory ; inline

: each-file ( path bfs? quot: ( obj -- ? ) -- )
    [ <directory-iterator> ] dip
    [ f ] compose iterate-directory drop ; inline

: find-all-files ( path bfs? quot: ( obj -- ? ) -- paths )
    [ <directory-iterator> ] dip
    pusher [ [ f ] compose iterate-directory drop ] dip ; inline

: recursive-directory ( path bfs? -- paths )
    [ ] accumulator [ each-file ] dip ;

: find-in-directories ( directories bfs? quot -- path' )
    '[ _ _ find-file ] attempt-all ; inline

os windows? [ "io.paths.windows" require ] when
