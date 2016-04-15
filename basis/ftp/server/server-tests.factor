USING: accessors fry ftp.server io.encodings.ascii io.files
io.pathnames io.servers kernel tools.test urls ;
FROM: ftp.client => ftp-get ;
IN: ftp.server.tests

CONSTANT: test-file-contents "Files are so boring anymore."

: create-test-file ( -- path )
    test-file-contents "ftp.server" [ ascii set-file-contents ] keep ;

: test-ftp-server ( quot: ( server path -- ) -- )
    '[
        "." 0 <ftp-server> [
            "ftp://localhost" >url insecure-addr set-url-addr
                "ftp" >>protocol
                create-test-file >>path
                @
        ] with-threaded-server
    ] with-test-directory ; inline

{ t } [
    [
        ! give client its own directory so we don't overwrite the ftp server's file
        [
            [ ftp-get ]
            [ path>> file-name ascii file-contents ] bi
        ] with-test-directory
    ] test-ftp-server test-file-contents =
] unit-test

[

    [
        ! give client its own directory so we don't overwrite the ftp server's file
        [
            "/" >>path
            [ ftp-get ]
            [ path>> file-name ascii file-contents ] bi
        ] with-test-directory
    ] test-ftp-server test-file-contents =
] must-fail
