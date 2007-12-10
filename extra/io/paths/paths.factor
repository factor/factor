USING: assocs io.files kernel namespaces sequences ;
IN: io.paths

: find-file ( seq str -- path/f )
    [
        [ path+ exists? ] curry find nip
    ] keep over [ path+ ] [ drop ] if ;

<PRIVATE
: append-path ( path files -- paths )
    [ path+ ] curry* map ;

: get-paths ( dir -- paths )
    dup directory keys append-path ;

: (walk-dir) ( path -- )
    dup directory? [
        get-paths dup % [ (walk-dir) ] each
    ] [
        drop
    ] if ;
PRIVATE>

: walk-dir ( path -- seq ) [ (walk-dir) ] { } make ;
