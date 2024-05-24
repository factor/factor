USING: accessors bootstrap.image fry graphviz io.files io.pathnames
kernel sequences system tools.image.analyzer
tools.image.analyzer.graphviz tools.test ;
IN: tools.image.analyzer.graphviz.tests

! Copy paste!
: boot-image-path ( arch -- path )
    boot-image-name resource-path ;

: ?make-image ( arch -- )
    dup boot-image-path file-exists? [ drop ] [ make-image ] if ;

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
