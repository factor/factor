USING: accessors bootstrap.image classes.struct fry graphviz
io.encodings.binary io.files io.pathnames
kernel sequences system tools.image.analyzer
tools.image.analyzer.graphviz tools.test ;
FROM: tools.image => valid-header? ;
FROM: tools.image.analyzer.vm => image-header ;
IN: tools.image.analyzer.graphviz.tests

! Copy paste!
: boot-image-path ( arch -- path )
    boot-image-name resource-path ;

: ?make-image ( arch -- )
    dup boot-image-path dup file-exists? [
        binary [ image-header read-struct valid-header? ] with-file-reader
    ] [ drop f ] if
    [ drop ] [ make-image ] if ;

: loadable-images ( -- images )
    image-names cpu name>> '[ _ tail? ] filter ;

! Sanity test
{ t } [
    loadable-images [ [ ?make-image ] each ] [
        [
            boot-image-path load-image image>graph graph?
        ] all?
    ] bi
] unit-test
