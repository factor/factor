USING: io.files kernel sequences accessors
dlists arrays sequences.lib ;
IN: io.paths

TUPLE: directory-iterator path bfs queue ;

: qualified-directory ( path -- seq )
    dup directory [ first2 >r append-path r> 2array ] with map ;

: push-directory ( path iter -- )
    >r qualified-directory r> [
        dup queue>> swap bfs>>
        [ push-front ] [ push-back ] if
    ] curry each ;

: <directory-iterator> ( path bfs? -- iterator )
    <dlist> directory-iterator construct-boa
    dup path>> over push-directory ;

: next-file ( iter -- file/f )
    dup queue>> dlist-empty? [ drop f ] [
        dup queue>> pop-back first2
        [ over push-directory next-file ] [ nip ] if
    ] if ;

: iterate-directory ( iter quot -- obj )
    2dup >r >r >r next-file dup [
        r> call dup [
            r> r> 2drop
        ] [
            drop r> r> iterate-directory
        ] if
    ] [
        drop r> r> r> 3drop f
    ] if ; inline

: find-file ( path bfs? quot -- path/f )
    >r <directory-iterator> r>
    [ keep and ] curry iterate-directory ; inline

: each-file ( path bfs? quot -- )
    >r <directory-iterator> r>
    [ f ] compose iterate-directory drop ; inline

: find-all-files ( path bfs? quot -- paths )
    >r <directory-iterator> r>
    pusher >r [ f ] compose iterate-directory drop r> ; inline

: recursive-directory ( path bfs? -- paths )
    [ ] accumulator >r each-file r> ;
