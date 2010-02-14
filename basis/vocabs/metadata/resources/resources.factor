! (c)2010 Joe Groff bsd license
USING: arrays fry globs io.directories io.files.info
io.pathnames kernel regexp sequences vocabs.loader
vocabs.metadata ;
IN: vocabs.metadata.resources

<PRIVATE
: (expand-vocab-resource) ( resource-path -- filenames )
    dup file-info directory?
    [ dup '[ _ directory-tree-files [ append-path ] with map ] [ prefix ] bi ]
    [ 1array ] if ;

: filter-resources ( vocab-files resource-globs -- resource-files ) 
    '[ _ [ matches? ] with any? ] filter ;
PRIVATE>

: expand-vocab-resource-files ( vocab resource-glob-strings -- filenames )
    [ [ find-vocab-root ] [ vocab-dir ] bi append-path ] dip [ <glob> ] map '[
        _ filter-resources
        [ (expand-vocab-resource) ] map concat
    ] with-directory-tree-files ;

: vocab-resource-files ( vocab -- filenames )
    dup vocab-resources
    [ drop f ] [ expand-vocab-resource-files ] if-empty ;
