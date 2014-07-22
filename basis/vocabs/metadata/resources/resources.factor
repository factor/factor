! (c)2010 Joe Groff bsd license
USING: arrays fry globs io.directories io.directories.hierarchy
io.files.info io.pathnames kernel regexp sequences vocabs.loader
vocabs.metadata ;
IN: vocabs.metadata.resources

<PRIVATE

: (expand-vocab-resource) ( resource-path -- filenames )
    dup file-info directory?
    [ dup '[ _ directory-tree-files [ append-path ] with map ] [ prefix ] bi ]
    [ 1array ] if ;

: filter-resources ( vocab-files resource-globs -- resource-files )
    '[ _ [ matches? ] with any? ] filter ;

: copy-vocab-resource ( to from file -- )
    [ append-path ] curry bi@
    dup file-info directory?
    [ drop make-directories ]
    [ swap [ parent-directory make-directories ] [ copy-file ] bi ] if ;

PRIVATE>

: vocab-dir-in-root ( vocab -- dir )
    [ find-vocab-root ] [ vocab-dir ] bi append-path ;

: expand-vocab-resource-files ( vocab resource-glob-strings -- filenames )
    [ vocab-dir-in-root ] dip [ <glob> ] map '[
        _ filter-resources
        [ (expand-vocab-resource) ] map concat
    ] with-directory-tree-files ;

: vocab-resource-files ( vocab -- filenames )
    dup vocab-resources
    [ drop f ] [ expand-vocab-resource-files ] if-empty ;

: copy-vocab-resources ( dir vocab -- )
    dup vocab-resource-files
    [ 2drop ] [
        [ [ vocab-dir append-path ] [ vocab-dir-in-root ] bi ] dip
        [ 2drop make-directories ]
        [ [ copy-vocab-resource ] 2with each ] 3bi
    ] if-empty ;
