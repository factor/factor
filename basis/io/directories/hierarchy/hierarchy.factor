! Copyright (C) 2004, 2008 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel sequences combinators fry
io.directories io.pathnames io.files.info io.files.types
io.files.links io.backend ;
IN: io.directories.hierarchy

: directory-tree-files ( path -- seq )
    dup directory-entries
    [
        dup type>> +directory+ =
        [ name>>
            [ append-path directory-tree-files ]
            [ [ prepend-path ] curry map ]
            [ prefix ] tri
        ] [ nip name>> 1array ] if
    ] with map concat ;

: with-directory-tree-files ( path quot -- )
    '[ "" directory-tree-files @ ] with-directory ; inline

: delete-tree ( path -- )
    dup link-info directory? [
        [ [ [ delete-tree ] each ] with-directory-files ]
        [ delete-directory ]
        bi
    ] [ delete-file ] if ;

DEFER: copy-tree-into

: copy-tree ( from to -- )
    normalize-path
    over link-info type>>
    {
        { +symbolic-link+ [ copy-link ] }
        { +directory+ [ '[ [ _ copy-tree-into ] each ] with-directory-files ] }
        [ drop copy-file-and-info ]
    } case ;

: copy-tree-into ( from to -- )
    to-directory copy-tree ;

: copy-trees-into ( files to -- )
    '[ _ copy-tree-into ] each ;
