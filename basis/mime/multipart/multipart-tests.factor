! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: io.encodings.ascii io.files io.files.unique kernel
mime.multipart tools.test io.streams.duplex io multiline
assocs ;
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
    nip "\"up.txt\"" swap key?
] unit-test

[ t ] [
    mime-test-stream [ upload-separator parse-multipart ] with-input-stream
    drop "\"text1\"" swap key?
] unit-test

