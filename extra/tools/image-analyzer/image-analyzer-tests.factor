USING: accessors bootstrap.image fry grouping io.files io.pathnames kernel
sequences system tools.deploy.backend tools.image-analyzer tools.test ;
IN: tools.image-analyzer.tests

: image-path ( arch -- path )
    boot-image-name resource-path ;

: ?make-image ( arch -- )
    dup image-path exists? [ drop ] [ make-image ] if ;

: loadable-images ( -- images )
    image-names cpu name>> '[ _ tail? ] filter ;

{ t } [
    loadable-images [ [ ?make-image ] each ] [
        [
            image-path load-image 2drop code-size>>
        ] map [ 0 = ] all?
    ] bi
] unit-test
