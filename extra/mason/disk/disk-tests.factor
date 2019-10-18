USING: mason.config mason.disk namespaces io.directories
io.files.temp tools.test strings sequences ;

"builds" temp-file builds-dir [
    builds-dir get make-directories

    [ t ] [ disk-usage string? ] unit-test

    [ t ] [ sufficient-disk-space? { t f } member? ] unit-test
] with-variable
