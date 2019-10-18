IN: temporary
USING: modules kernel test namespaces assocs
sequences parser ;

SYMBOL: foo

V{ } clone foo set

[ ] [ "core/test/modules/a" remove-module ] unit-test
[ ] [ "core/test/modules/b" remove-module ] unit-test

[ ] [ "core/test/modules/b" require ] unit-test

[ V{ "a" "b" } ] [ foo get ] unit-test

foo get delete-all

: dirty
    module-def source-files get at
    0 over set-source-file-modified
    0 swap set-source-file-checksum ;

[ ] [ "core/test/modules/a" dirty ] unit-test

[ t ] [ "core/test/modules/a" module-def source-modified? ] unit-test

: reload-tests
    module-names
    [ "core/test/modules/" head? ] subset
    reload-modules ;

[ ] [ reload-tests ] unit-test

foo get delete-all

[ ] [ "core/test/modules/a" dirty ] unit-test
[ ] [ "core/test/modules/b" dirty ] unit-test

[ ] [ reload-tests ] unit-test

[ V{ "a" "b" } ] [ foo get ] unit-test
