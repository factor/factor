! Headless ownership and mutable-buffer tests against the real Raylib 6.0 dylib.
USING: accessors alien alien.accessors alien.c-types alien.data alien.strings
byte-arrays compiler.test continuations io.encodings.utf8 io.pathnames
kernel locals namespaces raylib raylib.private sequences specialized-arrays
tools.test ;
IN: raylib.tests
SPECIALIZED-ARRAY: int

: raylib-owned-unit-test ( expected quot -- ) [ compile-call ] curry unit-test ;

{ t "raylib 6.0\n" } [| |
    "resource:extra/raylib/native/text.txt" absolute-path load-file-text-raw :> ptr
    [ ptr alien? ptr utf8 alien>string ] [ ptr unload-file-text ] finally
] raylib-owned-unit-test
{ "raylib 6.0\n" } [| |
    "resource:extra/raylib/native/text.txt" absolute-path load-file-text
] raylib-owned-unit-test
{ B{ 114 97 121 108 105 98 32 54 46 48 10 } } [| |
    "resource:extra/raylib/native/text.txt" absolute-path load-file-data-bytes
] raylib-owned-unit-test

{ t "Aλ🙂" "Aλ🙂" } [| |
    { 65 955 128578 } int >c-array :> points
    points 3 load-utf8-raw :> ptr
    [ ptr alien? ptr utf8 alien>string ] [ ptr unload-utf8 ] finally
    points 3 load-utf8
] raylib-owned-unit-test

! Output count includes the terminating NUL, not just the visible Base64 text.
{ t "AEH/AEI=" 9 "AEH/AEI=" 9 } [| |
    0 int <ref> :> count
    B{ 0 65 255 0 66 } 5 count encode-data-base64-raw :> ptr
    [ ptr alien? ptr utf8 alien>string count int deref ]
    [ ptr mem-free ] finally
    B{ 0 65 255 0 66 } 5 count encode-data-base64
    count int deref
] raylib-owned-unit-test

{ t "ray two ray" } [| |
    "one two one" "one" "ray" text-replace-alloc-raw :> ptr
    [ ptr alien? ptr utf8 alien>string ] [ ptr mem-free ] finally
] raylib-owned-unit-test
{ t "a[x]c" } [| |
    "a[b]c" "[" "]" "x" text-replace-between-alloc-raw :> ptr
    [ ptr alien? ptr utf8 alien>string ] [ ptr mem-free ] finally
] raylib-owned-unit-test
{ t "ab" } [| |
    "a" "b" 1 text-insert-alloc-raw :> ptr
    [ ptr alien? ptr utf8 alien>string ] [ ptr mem-free ] finally
] raylib-owned-unit-test
{ "ray two ray" "a[x]c" "ab" f } [| |
    "one two one" "one" "ray" text-replace-alloc
    "a[b]c" "[" "]" "x" text-replace-between-alloc
    "a" "b" 1 text-insert-alloc
    "missing delimiters" "[" "]" "x" text-replace-between-alloc
] raylib-owned-unit-test

! Static results are still copied to Factor strings, never freed by bindings.
{ "ray two ray" "a[x]c" "ab" "b" "ABC" } [| |
    "one two one" "one" "ray" text-replace
    "a[b]c" "[" "]" "x" text-replace-between
    "a" "b" 1 text-insert
    "a[b]c" "[" "]" get-text-between
    "abc" text-to-upper
] raylib-owned-unit-test

{ 3 "abcdef" 6 } [| |
    16 <byte-array> :> buffer
    buffer "abc" text-copy
    3 int <ref> :> position
    buffer "def" position text-append
    buffer utf8 alien>string position int deref
] raylib-owned-unit-test
! A Factor string is not writable native storage. Old c-string declarations
! silently mutated a temporary encoding instead of the supplied object.
[ [ "____" "abc" text-copy ] compile-call ] must-fail
[ [ "ab__" "c" 2 int <ref> text-append ] compile-call ] must-fail

! Cleanup must still run if copying a native allocation throws. Use a custom
! release quotation around the actual native MemFree, retaining no freed data.
SYMBOL: raylib-string-released
{ t } [| |
    f raylib-string-released set
    2 mem-alloc :> ptr
    255 ptr 0 set-alien-unsigned-1 0 ptr 1 set-alien-unsigned-1
    [ ptr [ mem-free t raylib-string-released set ] copy-raylib-string drop f ]
    [ drop t ] recover
    raylib-string-released get and
] raylib-owned-unit-test
