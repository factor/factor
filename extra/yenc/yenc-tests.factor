USING: assocs byte-arrays io.encodings.binary io.files kernel sequences splitting
tools.test yenc ;
IN: yenc.tests

{ t } [ 256 <iota> >byte-array dup yenc ydec = ] unit-test

{ t } [
    "resource:LICENSE.txt"
    [ yenc-file ydec-file 2nip ] [ binary file-contents ] bi =
] unit-test

! CRC32(00 01 02) = 0854897f, independently of the file's pathname.
{ "0854897F" } [
    [
        [ B{ 0 1 2 } swap binary set-file-contents ] keep
        yenc-file ydec-file drop nip "crc32" swap at
    ] with-test-file
] unit-test

CONSTANT: single-envelope
"=ybegin line=128 size=3 name=a file=with spaces.bin\r\n*+,\r\n=yend size=3 crc32=0854897f\r\n"

{ "a file=with spaces.bin" B{ 0 1 2 } } [
    single-envelope ydec-file [ drop "name" swap at ] dip
] unit-test

{ B{ 0 1 2 } } [
    "Ignored preamble\n" single-envelope append
    "Ignored epilogue\n" append ydec-file 2nip
] unit-test

{ B{ 0 1 2 } } [
    single-envelope " crc32=0854897f" "" replace ydec-file 2nip
] unit-test

{ B{ } } [
    "=ybegin line=128 size=0 name=empty\n\n=yend size=0 crc32=00000000"
    ydec-file 2nip
] unit-test

CONSTANT: part-envelope
"=ybegin part=2 total=2 line=128 size=6 name=a file.bin\r\n=ypart begin=4 end=6\r\n*+,\r\n=yend size=3 part=2 pcrc32=0854897f crc32=ffffffff\r\n"

{ "4" "6" B{ 0 1 2 } } [
    part-envelope ydec-file
    [ drop [ "begin" swap at ] [ "end" swap at ] bi ] dip
] unit-test

{ B{ 0 1 2 } } [
    part-envelope " total=2" "" replace ydec-file 2nip
] unit-test

{ B{ 0 1 2 } } [
    part-envelope "begin=4" "begin=1" replace
    "size=6" "size=3" replace "end=6" "end=3" replace
    "crc32=ffffffff" "crc32=0854897f" replace ydec-file 2nip
] unit-test

[
    single-envelope "line=128 size=3" "line=128 size=4" replace ydec-file
] [ invalid-yenc? ] must-fail-with

[
    single-envelope "=yend size=3" "=yend size=2" replace ydec-file
] [ invalid-yenc? ] must-fail-with

[
    single-envelope "*+," "*+-" replace ydec-file
] [ invalid-yenc? ] must-fail-with

[
    single-envelope "0854897f" "zzzzzzzz" replace ydec-file
] [ invalid-yenc? ] must-fail-with

[
    single-envelope "0854897f" "854897f" replace ydec-file
] [ invalid-yenc? ] must-fail-with

[
    single-envelope "size=3" "size=oops" replace ydec-file
] [ invalid-yenc? ] must-fail-with

[
    single-envelope "=yend" "=missing" replace ydec-file
] [ invalid-yenc? ] must-fail-with

[
    single-envelope "=ybegin" "=missing" replace ydec-file
] [ invalid-yenc? ] must-fail-with

[
    part-envelope "=ypart begin=4 end=6\r\n" "" replace ydec-file
] [ invalid-yenc? ] must-fail-with

[
    part-envelope "begin=4" "begin=0" replace ydec-file
] [ invalid-yenc? ] must-fail-with

[
    part-envelope "end=6" "end=7" replace ydec-file
] [ invalid-yenc? ] must-fail-with

[
    part-envelope "begin=4" "begin=5" replace ydec-file
] [ invalid-yenc? ] must-fail-with

[
    part-envelope "=yend size=3 part=2" "=yend size=3 part=1" replace ydec-file
] [ invalid-yenc? ] must-fail-with

[
    part-envelope "part=2" "part=0" replace ydec-file
] [ invalid-yenc? ] must-fail-with

[
    part-envelope "total=2" "total=1" replace ydec-file
] [ invalid-yenc? ] must-fail-with

[
    part-envelope "pcrc32=0854897f" "pcrc32=ffffffff" replace ydec-file
] [ invalid-yenc? ] must-fail-with

[
    part-envelope " pcrc32=0854897f" "" replace ydec-file
] [ invalid-yenc? ] must-fail-with

[
    part-envelope "=yend size=3" "=yend size=4" replace ydec-file
] [ invalid-yenc? ] must-fail-with

[
    part-envelope "=yend size=3" "=yend size=3 total=3" replace ydec-file
] [ invalid-yenc? ] must-fail-with
