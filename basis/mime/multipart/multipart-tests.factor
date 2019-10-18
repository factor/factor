! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs continuations fry http.server io
io.encodings.ascii io.files io.files.unique
io.servers io.streams.duplex io.streams.string
kernel math.ranges mime.multipart multiline namespaces random
sequences strings threads tools.test ;
IN: mime.multipart.tests

: upload-separator ( -- seq )
   "----WebKitFormBoundary6odjpVPXIighAE2L" ;

: upload ( -- seq )
   "------WebKitFormBoundary6odjpVPXIighAE2L\r\nContent-Disposition: form-data; name=\"file1\"; filename=\"up.txt\"\r\nContent-Type: text/plain\r\n\r\nuploaded!\n\r\n------WebKitFormBoundary6odjpVPXIighAE2L\r\nContent-Disposition: form-data; name=\"file2\"; filename=\"\"\r\n\r\n\r\n------WebKitFormBoundary6odjpVPXIighAE2L\r\nContent-Disposition: form-data; name=\"file3\"; filename=\"\"\r\n\r\n\r\n------WebKitFormBoundary6odjpVPXIighAE2L\r\nContent-Disposition: form-data; name=\"text1\"\r\n\r\nlol\r\n------WebKitFormBoundary6odjpVPXIighAE2L--\r\n" ;

: mime-test-stream ( -- stream )
   upload
   "mime" "test" make-unique-file ascii
   [ set-file-contents ] [ <file-reader> ] 2bi ;

[ ] [ mime-test-stream [ ] with-input-stream ] unit-test

[ t ] [
    mime-test-stream [ upload-separator parse-multipart ] with-input-stream
    "file1" swap key?
] unit-test

[ t ] [
    mime-test-stream [ upload-separator parse-multipart ] with-input-stream
    "file1" swap key?
] unit-test

[ t ] [
    mime-test-stream [ upload-separator parse-multipart ] with-input-stream
    "file1" of filename>> "up.txt" =
] unit-test

SYMBOL: mime-test-server

: with-test-server ( quot -- )
    [
        <http-server>
            f >>secure
            0 >>insecure
    ] dip with-threaded-server ; inline

: test-server-port ( -- n )
    mime-test-server get insecure>> ;

: a-stream ( n -- stream )
    CHAR: a <string> <string-reader> ;

[ ] [
    [
    ] with-test-server
] unit-test
