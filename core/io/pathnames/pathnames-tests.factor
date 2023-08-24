USING: io.backend io.directories io.files.private io.pathnames
kernel math namespaces sequences system tools.test vocabs.loader ;

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

[| path |
    { } [ 2 [ path touch-file ] times ] unit-test
] with-test-file

! aum's bug
H{
    { current-directory "." }
    { "resource-path" ".." }
} [
    [ "../basis/bootstrap/stage2.factor" ]
    [ "resource:basis/bootstrap/stage2.factor" absolute-path ]
    unit-test
] with-variables

{ t } [ cwd "misc" resource-path [ ] with-directory cwd = ] unit-test

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

! Absolute paths
os windows? [
    { "c:/" } [ "c:/" canonicalize-path ] unit-test
    { "c:/" } [ "c:/." canonicalize-path ] unit-test
    { "c:/" } [ "c:/.." canonicalize-path ] unit-test
    { "c:/" } [ "c:/Users/.." canonicalize-path ] unit-test
    { "c:/" } [ "c:/Users/../" canonicalize-path ] unit-test
    { "c:/" } [ "c:/Users/../." canonicalize-path ] unit-test
    { "c:/" } [ "c:/Users/.././" canonicalize-path ] unit-test
    { "c:/" } [ "c:/Users/.././././././" canonicalize-path ] unit-test
    { "c:/" } [ "c:/Users/../././/////./././/././././//././././././." canonicalize-path ] unit-test
    { "c:/" } [ "c:/Users/../../../..////.././././././/../" canonicalize-path ] unit-test
    { "c:/Users" } [ "c:/Users/../../../Users" canonicalize-path ] unit-test

    { "c:/Users" } [ "c:/Users" canonicalize-path ] unit-test
    { "c:/Users" } [ "c:/Users/." canonicalize-path ] unit-test
    { "c:/Users\\foo\\bar" } [ "c:/Users/foo/bar" canonicalize-path ] unit-test
] [
    { "/" } [ "/" canonicalize-path ] unit-test
    { "/" } [ "/." canonicalize-path ] unit-test
    { "/" } [ "/.." canonicalize-path ] unit-test
    { "/" } [ "/Users/.." canonicalize-path ] unit-test
    { "/" } [ "/Users/../" canonicalize-path ] unit-test
    { "/" } [ "/Users/../." canonicalize-path ] unit-test
    { "/" } [ "/Users/.././" canonicalize-path ] unit-test
    { "/" } [ "/Users/.././././././" canonicalize-path ] unit-test
    { "/" } [ "/Users/../././/////./././/././././//././././././." canonicalize-path ] unit-test
    { "/" } [ "/Users/../../../..////.././././././/../" canonicalize-path ] unit-test
    { "/Users" } [ "/Users/../../../Users" canonicalize-path ] unit-test

    { "/Users" } [ "/Users" canonicalize-path ] unit-test
    { "/Users" } [ "/Users/." canonicalize-path ] unit-test
    { "/Users/foo/bar" } [ "/Users/foo/bar" canonicalize-path ] unit-test
] if


! Relative paths
{ "." } [ f canonicalize-path ] unit-test
{ "." } [ "" canonicalize-path ] unit-test
{ "." } [ "." canonicalize-path ] unit-test
{ "." } [ "./" canonicalize-path ] unit-test
{ "." } [ "./." canonicalize-path ] unit-test
{ ".." } [ ".." canonicalize-path ] unit-test
{ ".." } [ "../" canonicalize-path ] unit-test
{ ".." } [ "../." canonicalize-path ] unit-test
{ ".." } [ ".././././././//." canonicalize-path ] unit-test

{ t } [ "../.." canonicalize-path { "../.." "..\\.." } member? ] unit-test
{ t } [ "../../" canonicalize-path { "../.." "..\\.." } member? ] unit-test
{ t } [ "../.././././/./././" canonicalize-path { "../.." "..\\.." } member? ] unit-test


! Root paths
os windows? [
    { "d:\\" } [ "d:\\" root-path ] unit-test
    { "d:\\" } [ "d:\\\\\\\\//////" root-path ] unit-test
    { "c:\\" } [ "c:\\Users\\merlen" root-path ] unit-test
    { "c:\\" } [ "c:\\\\\\//Users//\\//merlen//" root-path ] unit-test
    { "d:\\" } [ "d:\\././././././/../../../" root-path ] unit-test
    { "d:\\" } [ "d:\\merlen\\dog" root-path ] unit-test

    { "d:\\" } [ "\\\\?\\d:\\" root-path ] unit-test
    { "d:\\" } [ "\\\\?\\d:\\\\\\\\//////" root-path ] unit-test
    { "c:\\" } [ "\\\\?\\c:\\Users\\merlen" root-path ] unit-test
    { "c:\\" } [ "\\\\?\\c:\\\\\\//Users//\\//merlen//" root-path ] unit-test
    { "d:\\" } [ "\\\\?\\d:\\././././././/../../../" root-path ] unit-test
    { "d:\\" } [ "\\\\?\\d:\\merlen\\dog" root-path ] unit-test
] [
    { "/" } [ "/" root-path ] unit-test
    { "/" } [ "//" root-path ] unit-test
    { "/" } [ "/Users" root-path ] unit-test
    { "/" } [ "//Users" root-path ] unit-test
    { "/" } [ "/Users/foo/bar////././." root-path ] unit-test
    { "/" } [ "/Users/foo/bar////.//../../../../../../////./." root-path ] unit-test
    { "/" } [ "/Users/////" root-path ] unit-test
] if

{ t } [ "." has-file-extension? ] unit-test
{ t } [ ".." has-file-extension? ] unit-test
{ t } [ "a.b" has-file-extension? ] unit-test
{ f } [ "a/" has-file-extension? ] unit-test
{ f } [ "a.b/" has-file-extension? ] unit-test
{ t } [ "math.factor" has-file-extension? ] unit-test
{ t } [ "math." has-file-extension? ] unit-test
{ f } [ "math" has-file-extension? ] unit-test

{ "resource:core/math" } [ "math" vocab-path ] unit-test
{ "resource:core/math/" } [ "math/" vocab-path ] unit-test

[ "math.omg" vocab-path ] [ not-found-in-roots? ] must-fail-with
[ "math.omg/" vocab-path ] [ not-found-in-roots? ] must-fail-with
[ "accessors" vocab-path ] [ not-found-in-roots? ] must-fail-with
[ "asdfasdfasdfasfd1231231" vocab-path ] [ not-found-in-roots? ] must-fail-with
[ "resource:extra/benchmark/sum-file/sum-file.txt/" vocab-path ]
[ not-found-in-roots? ] must-fail-with

{ "resource:extra/benchmark/sum-file/sum-file.txt" }
[ "benchmark/sum-file/sum-file.txt" vocab-path ] unit-test

{ "resource:extra/benchmark/sum-file" }
[ "benchmark/sum-file" vocab-path ] unit-test

{ "resource:extra/benchmark/sum-file/" }
[ "benchmark/sum-file/" vocab-path ] unit-test

! Would be a core/ path except the path already exists in basis
{ "resource:basis/bootstrap/finish-bootstrap.factor" }
[ "bootstrap/finish-bootstrap.factor" vocab-path ] unit-test
