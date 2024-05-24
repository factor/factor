USING: accessors bootstrap.image fry grouping io.files io.pathnames kernel
sequences system tools.deploy.backend tools.image.analyzer tools.test ;
IN: tools.image.analyzer.tests

: boot-image-path ( arch -- path )
    boot-image-name resource-path ;

: ?make-image ( arch -- )
    dup boot-image-path file-exists? [ drop ] [ make-image ] if ;

: loadable-images ( -- images )
    image-names cpu name>> '[ _ tail? ] filter ;

{ t } [
    loadable-images [ [ ?make-image ] each ] [
        [
            boot-image-path load-image header>> code-size>>
        ] map [ 0 = ] all?
    ] bi
] unit-test
