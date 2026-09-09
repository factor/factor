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

! Inject a copying exception while using real native allocation/release.
! UTF-8 normally replaces invalid bytes, so malformed text is not an exception.
TUPLE: raylib-copy-failure pointer ;
C: <raylib-copy-failure> raylib-copy-failure
ERROR: raylib-copy-error ;
M: raylib-copy-failure alien>string 2drop raylib-copy-error ;
SYMBOL: raylib-string-released
{ t } [| |
    f raylib-string-released set
    2 mem-alloc <raylib-copy-failure> :> ptr
    [ ptr [ pointer>> mem-free t raylib-string-released set ]
      copy-raylib-string drop f ]
    [ raylib-copy-error? ] recover
    raylib-string-released get and
] raylib-owned-unit-test
