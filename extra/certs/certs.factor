! Copyright (C) 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs io.directories io.encodings.utf8 io.files
io.files.unique io.launcher kernel qw ;
IN: certs

: generate-rsa-2048-key ( -- )
    qw{ openssl genrsa 2048 -out server.key } try-process ;

: generate-rsa-2048-csr ( -- )
    qw{ openssl req -subj /C=GB/ -new -key server.key -out server.csr } try-process ;

: generate-rsa-2048-crt ( -- )
    qw{ openssl x509 -req -days 36500 -in server.csr -signkey server.key -out server.crt } try-process ;

: generate-ssl-certs ( -- assoc )
    [
        generate-rsa-2048-key
        generate-rsa-2048-csr
        generate-rsa-2048-crt
        "." directory-files [ utf8 file-contents ] zip-with
    ] cleanup-unique-directory ;

: certs>directory ( assoc path -- )
    dup make-directories [
        [
            swap utf8 set-file-contents
        ] assoc-each
    ] with-directory ;

: directory>certs ( path -- assoc )
    [
        "." directory-files [ utf8 file-contents ] zip-with
    ] with-directory ;
