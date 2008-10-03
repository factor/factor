! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: io.files kernel sequences accessors
dlists deques arrays ;
IN: io.paths

TUPLE: directory-iterator path bfs queue ;

: qualified-directory ( path -- seq )
    dup directory [ first2 [ append-path ] dip 2array ] with map ;

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
        dup queue>> pop-back first2
        [ over push-directory next-file ] [ nip ] if
    ] if ;

: iterate-directory ( iter quot -- obj )
    over next-file [
        over call
        [ 2drop ] [ iterate-directory ] if
    ] [
        2drop f
    ] if* ; inline recursive

: find-file ( path bfs? quot -- path/f )
    [ <directory-iterator> ] dip
    [ keep and ] curry iterate-directory ; inline

: each-file ( path bfs? quot -- )
    [ <directory-iterator> ] dip
    [ f ] compose iterate-directory drop ; inline

: find-all-files ( path bfs? quot -- paths )
    [ <directory-iterator> ] dip
    pusher [ [ f ] compose iterate-directory drop ] dip ; inline

: recursive-directory ( path bfs? -- paths )
    [ ] accumulator [ each-file ] dip ;
