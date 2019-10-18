! Copyright (C) 2004, 2008 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences combinators fry io.directories
io.pathnames io.files.info io.files.types io.files.links
io.backend ;
IN: io.directories.hierarchy

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

