! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors db db.tuples db.types furnace.actions
furnace.redirection html.forms http http.server
http.server.dispatchers io.directories io.pathnames kernel
multiline namespaces urls ;
IN: webapps.imagebin

SYMBOL: image-directory

image-directory [ "resource:images" ] initialize

TUPLE: imagebin < dispatcher ;

TUPLE: image id path ;

image "IMAGE" {
    { "id" "ID" INTEGER +db-assigned-id+ }
    { "path" "PATH" { VARCHAR 256 } +not-null+ }
} define-persistent

: <uploaded-image-action> ( -- action )
    <page-action>
        image-directory get >>temporary-directory
        { imagebin "uploaded-image" } >>template ;

SYMBOL: my-post-data
: <upload-image-action> ( -- action )
    <page-action>
        { imagebin "upload-image" } >>template
        image-directory get >>temporary-directory
        [
            "file1" param [
                temporary-path>> image-directory get move-file
            ] when*
            ! image new
            !    "file" value
                ! insert-tuple
            "uploaded-image" <redirect>
        ] >>submit ;

: initialize-image-directory ( -- )
    image-directory get make-directories ;

: <imagebin> ( -- responder )
    imagebin new-dispatcher
        <upload-image-action> "" add-responder
        <upload-image-action> "upload-image" add-responder
        <uploaded-image-action> "uploaded-image" add-responder ;

initialize-image-directory
<imagebin> main-responder set-global
