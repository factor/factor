! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors furnace.actions furnace.redirection http.server
http.server.dispatchers io.directories io.encodings.utf8 io.files
io.pathnames kernel math math.parser namespaces sequences
webapps.utils ;
IN: webapps.imagebin

TUPLE: imagebin < dispatcher path n ;

: <uploaded-image-action> ( -- action )
    <page-action>
        { imagebin "uploaded-image" } >>template ;

: next-image-path ( -- path )
    imagebin get
    [ path>> ] [ [ 1 + ] change-n n>> number>string ] bi append-path ;

M: imagebin call-responder*
    [ imagebin set ] [ call-next-method ] bi ;

: move-image ( mime-file -- )
    [ next-image-path dup file-exists? ] [ drop ] while
    [ [ temporary-path>> ] dip move-file ]
    [ [ filename>> ] dip ".txt" append utf8 set-file-contents ] 2bi ;

: <upload-image-action> ( -- action )
    <page-action>
        { imagebin "upload-image" } >>template
        [
            "file1" param [ move-image ] when*
            "file2" param [ move-image ] when*
            "file3" param [ move-image ] when*
            "uploaded-image" <redirect>
        ] >>submit ;

: <imagebin> ( image-directory -- responder )
    imagebin new-dispatcher
        swap [ make-directories ] [ >>path ] bi
        0 >>n
        <upload-image-action> "" add-responder
        <upload-image-action> "upload-image" add-responder
        <uploaded-image-action> "uploaded-image" add-responder ;

: start-imagebin ( -- )
    "resource:images" <imagebin> main-responder set-global
    run-test-httpd ;
