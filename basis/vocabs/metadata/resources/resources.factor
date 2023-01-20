! Copyright (C) 2010 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: globs io.directories io.files.info io.pathnames kernel
regexp sequences sets vocabs.loader vocabs.metadata ;
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
        recursive-directory-files
    ] [
        drop { }
    ] if swap prefix ;

ERROR: resource-missing pattern ;

: match-pattern ( pattern filenames -- filenames' )
    over <glob> '[ _ matches? ] filter
    [ resource-missing ] [ nip ] if-empty ;

: match-patterns ( patterns filenames -- filenames' )
    '[ _ match-pattern ] gather ;

: vocab-resource-files ( vocab -- filenames )
    dup vocab-resources [
        swap vocab-dir-in-root
        [
            match-patterns [ expand-resource ] map concat
        ] with-directory-files
    ] [ drop f ] if* ;

: copy-vocab-resources ( dir vocab -- )
    dup vocab-resource-files
    [ 2drop ] [
        [ [ vocab-dir append-path ] [ vocab-dir-in-root ] bi ] dip
        [ 2drop make-directories ]
        [ [ copy-vocab-resource ] 2with each ] 3bi
    ] if-empty ;
