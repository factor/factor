! Headless native binary-buffer tests; all calls use the real raylib library.
USING: accessors alien alien.accessors alien.c-types alien.data
alien.strings alien.syntax arrays byte-arrays compiler.test continuations
io.encodings.utf8 kernel libc locals namespaces raylib sequences tools.test ;
IN: raylib.tests

SYMBOL: raylib-binary-allocation

:: raylib-binary-loader ( name count -- pointer )
    name drop
    B{ 0 65 255 0 66 } :> bytes
    bytes length count 0 set-alien-signed-4
    bytes length mem-alloc :> pointer
    pointer bytes bytes length memcpy
    pointer raylib-binary-allocation set-global
    pointer ;

! A real LoadFileData call must preserve both embedded NUL and non-UTF8 bytes.
! Retain the original callback allocation so even the old string-boxing binding
! can fail without leaking memory or passing a copied Factor string to free().
{ B{ 0 65 255 0 66 } 5 } [ [| |
    [ raylib-binary-loader ] LoadFileDataCallback [| callback |
        [
            callback set-load-file-data-callback
            0 int <ref> :> count
            "native-binary" count load-file-data dup alien?
            [ count int deref memory>byte-array ]
            [ drop "ownership pointer was lost" ] if
            count int deref
        ] [
            f set-load-file-data-callback
            raylib-binary-allocation get-global unload-file-data
            f raylib-binary-allocation set-global
        ] finally
    ] with-callback
] compile-call ] unit-test

! Encoded input is a C string; decoded output is length-delimited binary.
{ B{ 0 65 255 0 66 } } [ [| |
    0 int <ref> :> count
    "AEH/AEI=" count decode-data-base64 :> pointer
    [ pointer count int deref memory>byte-array ]
    [ pointer mem-free ] finally
] compile-call ] unit-test

! A generated PNG tests real image encode/decode with an embedded binary buffer.
{ 3 2 } [ [| |
    3 2 RED gen-image-color :> original
    [
        0 int <ref> :> count
        original ".png" count export-image-to-memory :> data
        [
            ".png" data count int deref load-image-from-memory :> decoded
            [ decoded [ width>> ] [ height>> ] bi ]
            [ decoded unload-image ] finally
        ] [ data mem-free ] finally
    ] [ original unload-image ] finally
] compile-call ] unit-test

! RIFF PCM, one channel, 8-bit samples containing NUL and 0xff. No audio device.
{ 2 8000 16 1 B{ 0 128 0 127 } } [ [| |
    B{ 82 73 70 70 38 0 0 0 87 65 86 69 102 109 116 32
       16 0 0 0 1 0 1 0 64 31 0 0 64 31 0 0 1 0 8 0
       100 97 116 97 2 0 0 0 0 255 } :> data
    ".wav" data data length load-wave-from-memory :> wave
    [ wave frameCount>> wave sampleRate>> wave sampleSize>> wave channels>>
      wave data>> 4 memory>byte-array ]
    [ wave unload-wave ] finally
] compile-call ] unit-test

: raylib-buffer-unit-test ( expected quot -- ) [ compile-call ] curry unit-test ;

{ 3 "abcdef" 6 } [| |
    16 <byte-array> :> buffer
    buffer "abc" text-copy
    3 int <ref> :> position
    buffer "def" position text-append
    buffer utf8 alien>string position int deref
] raylib-buffer-unit-test
! A Factor string is not writable native storage. Old c-string declarations
! silently mutated a temporary encoding instead of the supplied object.
[ [ "____" "abc" text-copy ] compile-call ] must-fail
[ [ "ab__" "c" 2 int <ref> text-append ] compile-call ] must-fail
