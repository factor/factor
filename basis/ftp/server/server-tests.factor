USING: calendar ftp.server io.encodings.ascii io.files
io.files.unique namespaces threads tools.test kernel
io.servers ftp.client accessors urls
io.pathnames io.directories sequences fry io.backend
continuations ;
FROM: ftp.client => ftp-get ;
IN: ftp.server.tests

CONSTANT: test-file-contents "Files are so boring anymore."

: create-test-file ( -- path )
    test-file-contents
    "ftp.server" "test" make-unique-file
    [ ascii set-file-contents ] [ normalize-path ] bi ;

: test-ftp-server ( quot -- )
    '[
        current-temporary-directory get
        0 <ftp-server> [
            "ftp://localhost" >url insecure-addr set-url-addr
                "ftp" >>protocol
                create-test-file >>path
                @
        ] with-threaded-server
    ] cleanup-unique-directory ; inline

[ t ]
[
    [
        [
            [ ftp-get ] [ path>> file-name ascii file-contents ] bi
        ] cleanup-unique-working-directory
    ] test-ftp-server test-file-contents =
] unit-test

[

    [
        "/" >>path
        [
            [ ftp-get ] [ path>> file-name ascii file-contents ] bi
        ] cleanup-unique-working-directory
    ] test-ftp-server test-file-contents =
] must-fail
