! (c)2010 Joe Groff bsd license
USING: fry globs io.directories io.directories.hierarchy io.files.info
io.pathnames kernel regexp sequences sets vocabs.loader
vocabs.metadata ;
IN: vocabs.metadata.resources

<PRIVATE

: copy-vocab-resource ( to from file -- )
    [ append-path ] curry bi@
    dup file-info directory?
    [ drop make-directories ]
    [ swap make-parent-directories copy-file ] if ;

PRIVATE>

: vocab-dir-in-root ( vocab -- dir )
    vocab-source-path parent-directory ;

: expand-resource ( resource-path -- filenames )
    dup dup file-info directory? [
        dup directory-tree-files [ append-path ] with map
    ] [ drop { } ] if swap prefix ;

ERROR: resource-missing pattern ;

: match-pattern ( pattern files -- files' )
    over <glob> '[ _ matches? ] filter
    [ resource-missing ] [ nip ] if-empty ;

: match-patterns ( patterns files -- files' )
    '[ _ match-pattern ] map concat members ;

: vocab-resource-files ( vocab -- filenames )
    [ vocab-resources ] [ vocab-dir-in-root ] bi
    [
        match-patterns [ expand-resource ] map concat
    ] with-directory-files ;

: copy-vocab-resources ( dir vocab -- )
    dup vocab-resource-files
    [ 2drop ] [
        [ [ vocab-dir append-path ] [ vocab-dir-in-root ] bi ] dip
        [ 2drop make-directories ]
        [ [ copy-vocab-resource ] 2with each ] 3bi
    ] if-empty ;
