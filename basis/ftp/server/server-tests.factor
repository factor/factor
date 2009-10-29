USING: calendar ftp.server io.encodings.ascii io.files
io.files.unique namespaces threads tools.test kernel
io.servers.connection ftp.client accessors urls
io.pathnames io.directories sequences fry ;
FROM: ftp.client => ftp-get ;
IN: ftp.server.tests

: test-file-contents ( -- string )
    "Files are so boring anymore." ;

: create-test-file ( -- path )
    test-file-contents
    "ftp.server" "test" make-unique-file
    [ ascii set-file-contents ] [ normalize-path ] bi ;

: test-ftp-server ( quot -- )
    '[
        current-temporary-directory get 0
        <ftp-server>
        [ start-server* ]
        [
            sockets>> first addr>> port>>
            <url>
                swap >>port
                "ftp" >>protocol
                "localhost" >>host
                create-test-file >>path
                _ call
        ]
        [ stop-server ] tri
    ] with-unique-directory drop ; inline

[ t ]
[
    
    [
        unique-directory [
            [ ftp-get ] [ path>> file-name ascii file-contents ] bi
        ] with-directory
    ] test-ftp-server test-file-contents =
] unit-test

[
    
    [
        "/" >>path
        unique-directory [
            [ ftp-get ] [ path>> file-name ascii file-contents ] bi
        ] with-directory
    ] test-ftp-server test-file-contents =
] must-fail
