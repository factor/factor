USING: accessors bootstrap.image classes.struct fry grouping
io.encodings.binary io.files io.pathnames kernel math
sequences system tools.deploy.backend tools.image.analyzer tools.test ;
FROM: tools.image => image-magic image-version valid-header? ;
FROM: tools.image.analyzer.vm => image-header ;
IN: tools.image.analyzer.tests

: boot-image-path ( arch -- path )
    boot-image-name resource-path ;

: ?make-image ( arch -- )
    dup boot-image-path dup file-exists? [
        binary [ image-header read-struct valid-header? ] with-file-reader
    ] [ drop f ] if
    [ drop ] [ make-image ] if ;

: loadable-images ( -- images )
    image-names cpu name>> '[ _ tail? ] filter ;

{ t } [
    loadable-images [ [ ?make-image ] each ] [
        [
            boot-image-path load-image header>> code-size>>
        ] map [ 0 = ] all?
    ] bi
] unit-test

[
    image-header new image-magic >>magic image-version 1 - >>version
    check-supported-header
] [ unsupported-image-format? ] must-fail-with

[
    image-header new 0 >>magic image-version >>version
    check-supported-header
] [ unsupported-image-format? ] must-fail-with
