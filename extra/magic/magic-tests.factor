USING: kernel magic sequences system tools.test ;
IN: magic.tests

{ t } [
    image-path guess-file [ "data" = ] [ "symbolic link" head? ] bi or
] unit-test
{ t } [
    image-path guess-mime-type
    { "application/octet-stream" "inode/symlink" } member?
] unit-test
{ "binary" } [ image-path guess-mime-encoding ] unit-test
