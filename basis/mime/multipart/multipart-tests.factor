! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs continuations fry http.server io
io.encodings.ascii io.files io.files.temp io.files.unique
io.servers io.streams.duplex io.streams.string
kernel ranges mime.multipart multiline namespaces random
sequences sorting strings threads tools.test ;
IN: mime.multipart.tests

CONSTANT: separator1 "----WebKitFormBoundary6odjpVPXIighAE2L"

CONSTANT: upload1 "------WebKitFormBoundary6odjpVPXIighAE2L\r\nContent-Disposition: form-data; name=\"file1\"; filename=\"up.txt\"\r\nContent-Type: text/plain\r\n\r\nuploaded!\n\r\n------WebKitFormBoundary6odjpVPXIighAE2L\r\nContent-Disposition: form-data; name=\"file2\"; filename=\"\"\r\n\r\n\r\n------WebKitFormBoundary6odjpVPXIighAE2L\r\nContent-Disposition: form-data; name=\"file3\"; filename=\"\"\r\n\r\n\r\n------WebKitFormBoundary6odjpVPXIighAE2L\r\nContent-Disposition: form-data; name=\"text1\"\r\n\r\nlol\r\n------WebKitFormBoundary6odjpVPXIighAE2L--\r\n"

: mime-test-stream ( -- stream )
    upload1
    [ "mime" "test" unique-file ] with-temp-directory
    ascii [ set-file-contents ] [ <file-reader> ] 2bi ;

{ } [ mime-test-stream [ ] with-input-stream ] unit-test

{ t } [
    mime-test-stream [ separator1 parse-multipart ] with-input-stream
    "file1" swap key?
] unit-test

{ t } [
    mime-test-stream [ separator1 parse-multipart ] with-input-stream
    "file1" swap key?
] unit-test

{ t } [
    mime-test-stream [ separator1 parse-multipart ] with-input-stream
    "file1" of filename>> "up.txt" =
] unit-test

CONSTANT: separator2 "768de80194d942619886d23f1337aa15"
CONSTANT: upload2 "--768de80194d942619886d23f1337aa15\r\nContent-Disposition: form-data; name=\"text\"; filename=\"upload.txt\"\r\nContent-Type: text/plain\r\n\r\nhello\r\n--768de80194d942619886d23f1337aa15--\r\n"

{
    "upload.txt"
    H{
        { "content-disposition"
          "form-data; name=\"text\"; filename=\"upload.txt\"" }
        { "content-type" "text/plain" }
    }
} [
    upload2 [ separator2 parse-multipart ] with-string-reader
    "text" of [ filename>> ] [ headers>> ] bi
] unit-test

CONSTANT: separator3 "3f116598c7f0431b9f98148ed235c822"
CONSTANT: upload3 "--3f116598c7f0431b9f98148ed235c822\r\nContent-Disposition: form-data; name=\"text\"; filename=\"upload.txt\"\r\n\r\nhello\r\n--3f116598c7f0431b9f98148ed235c822\r\nContent-Disposition: form-data; name=\"text2\"; filename=\"upload.txt\"\r\n\r\nhello\r\n--3f116598c7f0431b9f98148ed235c822--\r\n"

{
    { "text" "text2" }
} [
    upload3 [ separator3 parse-multipart ] with-string-reader
    keys sort
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

{ } [
    [
    ] with-test-server
] unit-test

[
    "--\r\n\r\n" <string-reader> [
        "\r\n\r\n" <multipart>
        "\r\n\r\n" parse-multipart
    ] with-input-stream
] [ mime-decoding-ran-out-of-bytes? ] must-fail-with

