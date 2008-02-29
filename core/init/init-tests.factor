IN: temporary
USING: init namespaces sequences math tools.test kernel ;

[ t ] [
    init-hooks get [ first "libc" = ] find drop
    init-hooks get [ first "io.backend" = ] find drop <
] unit-test
