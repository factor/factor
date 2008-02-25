USING: io.files kernel sequences new-slots accessors
dlists arrays ;
IN: io.paths

TUPLE: directory-iterator path bfs queue ;

: qualified-directory ( path -- seq )
    dup directory [ first2 >r path+ r> 2array ] with map ;

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

: prepare-find-file ( path bfs? quot -- iter quot' )
    >r <directory-iterator> r> [ keep and ] curry ; inline

: find-file ( path bfs? quot -- path/f )
    prepare-find-file iterate-directory ;

: find-all-files ( path bfs? quot -- paths )
    prepare-find-file V{ } clone [
        [ over [ push ] [ 2drop ] if f ] curry compose
        iterate-directory
        drop
    ] keep ; inline

: recursive-directory ( path bfs? -- paths )
    <directory-iterator>
    [ dup next-file dup ] [ ] [ drop ] unfold nip ;
