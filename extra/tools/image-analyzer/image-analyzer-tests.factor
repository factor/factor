USING: accessors bootstrap.image fry grouping io.files io.pathnames kernel
sequences system tools.deploy.backend tools.image-analyzer tools.test ;
IN: tools.image-analyzer.tests

: ?make-image ( arch -- )
    dup boot-image-name resource-path exists? [ drop ] [ make-image ] if ;

: loadable-images ( -- images )
    images cpu name>> '[ _ tail? ] filter ;

{ t } [
    loadable-images [ [ ?make-image ] each ] [
        [
            boot-image-name resource-path load-image 2drop code-size>>
        ] map [ 0 = ] all?
    ] bi
] unit-test
