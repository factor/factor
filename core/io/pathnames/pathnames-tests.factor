USING: io.backend io.directories io.files.private io.files.temp
io.files.unique io.pathnames kernel locals math namespaces
system tools.test ;

{ "passwd" } [ "/etc/passwd" file-name ] unit-test
{ "awk" } [ "/usr/libexec/awk/" file-name ] unit-test
{ "awk" } [ "/usr/libexec/awk///" file-name ] unit-test
{ "" } [ "" file-name ] unit-test

{ "freetype6.dll" } [ "resource:freetype6.dll" file-name ] unit-test
{ "freetype6.dll" } [ "resource:/freetype6.dll" file-name ] unit-test

{ "/usr/lib" } [ "/usr" "lib" append-path ] unit-test
{ "/usr/lib" } [ "/usr/" "lib" append-path ] unit-test
{ "/usr/lib" } [ "/usr" "./lib" append-path ] unit-test
{ "/usr/lib/" } [ "/usr" "./lib/" append-path ] unit-test
{ "/lib" } [ "/usr" "../lib" append-path ] unit-test
{ "/lib/" } [ "/usr" "../lib/" append-path ] unit-test

{ "" } [ "" "." append-path ] unit-test
[ "" ".." append-path ] must-fail

{ "/" } [ "/" "./." append-path ] unit-test
{ "/" } [ "/" "././" append-path ] unit-test
{ "/a/b/lib" } [ "/a/b/c/d/e/f/" "../../../../lib" append-path ] unit-test
{ "/a/b/lib/" } [ "/a/b/c/d/e/f/" "../../../../lib/" append-path ] unit-test

[ "" "../lib/" append-path ] must-fail
{ "lib" } [ "" "lib" append-path ] unit-test
{ "lib" } [ "" "./lib" append-path ] unit-test

[ "foo/bar/." parent-directory ] must-fail
[ "foo/bar/./" parent-directory ] must-fail
[ "foo/bar/baz/.." parent-directory ] must-fail
[ "foo/bar/baz/../" parent-directory ] must-fail

[ "." parent-directory ] must-fail
[ "./" parent-directory ] must-fail
[ ".." parent-directory ] must-fail
[ "../" parent-directory ] must-fail
[ "../../" parent-directory ] must-fail
[ "foo/.." parent-directory ] must-fail
[ "foo/../" parent-directory ] must-fail
[ "" parent-directory ] must-fail
{ "." } [ "boot.x86.64.image" parent-directory ] unit-test

{ "bar/foo" } [ "bar/baz" "..///foo" append-path ] unit-test
{ "bar/baz/foo" } [ "bar/baz" ".///foo" append-path ] unit-test
{ "bar/foo" } [ "bar/baz" "./..//foo" append-path ] unit-test
{ "bar/foo" } [ "bar/baz" "./../././././././///foo" append-path ] unit-test

{ t } [ "resource:core" absolute-path? ] unit-test
{ f } [ "" absolute-path? ] unit-test

[
    "touch-twice-test" ".txt" [| path |
        { } [ 2 [ path touch-file ] times ] unit-test
    ] cleanup-unique-file
] with-temp-directory

! aum's bug
H{
    { current-directory "." }
    { "resource-path" ".." }
} [
    [ "../core/bootstrap/stage2.factor" ]
    [ "resource:core/bootstrap/stage2.factor" absolute-path ]
    unit-test
] with-variables

[ t ] [ cwd "misc" site-resource-path [ ] with-directory cwd = ] unit-test

! Regression test for bug in file-extension
{ f } [ "/funny.directory/file-with-no-extension" file-extension ] unit-test
{ "" } [ "/funny.directory/file-with-no-extension." file-extension ] unit-test

! Testing ~ special pathname

{ t } [ os windows? "~\\" "~/" ? absolute-path home = ] unit-test
{ t } [ "~/" home [ normalize-path ] same? ] unit-test

{ t } [ "~" absolute-path home = ] unit-test
{ t } [ "~" home [ normalize-path ] same? ] unit-test

{ t } [ "~" home [ "foo" append-path ] bi@ [ normalize-path ] same? ] unit-test
{ t } [ os windows? "~\\~/" "~/~/" ? "~" "~" append-path [ path-components ] same? ] unit-test
