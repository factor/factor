USING: io.encodings.binary io.streams.byte-array
io.streams.string kernel math msgpack sequences tools.test ;

{
    {
        +msgpack-nil+
        f
        t
        -1
        -31
        128
        -1152921504606846976
        1.5
        1.23434536
        "hello"
        { 1 1234 123456789 }
        H{ { 1 "hello" } { 2 "goodbye" } }
    }
} [

    {
        "\xc0"
        "\xc2"
        "\xc3"
        "\xff"
        "\xe1"
        "\xcc\x80"
        "\xd3\xf0\x00\x00\x00\x00\x00\x00\x00"
        "\xcb?\xf8\x00\x00\x00\x00\x00\x00"
        "\xcb?\xf3\xbf\xe0\xeb\x92\xb5\xa5"
        "\xa5hello"
        "\x93\x01\xcd\x04\xd2\xce\x07[\xcd\x15"
        "\x82\x01\xa5hello\x02\xa7goodbye"
    } [ msgpack> ] map
] unit-test

{ t } [
    {
        +msgpack-nil+
        f
        t
        -1
        -31
        128
        -1152921504606846976
        1.5
        1.23434536
        "hello"
        { 1 1234 123456789 }
        H{ { 1 "hello" } { 2 "goodbye" } }
    } [ dup >msgpack msgpack> = ] all?
] unit-test

[ 64 2^ >msgpack ] [ cannot-convert? ] must-fail-with

! this failure makes it impossible to reliably detect eof when
! reading an msgpack object from a stream
[ "" [ read-msgpack ] with-string-reader ] must-fail

{ t } [
    { "hello" "world" 1234 }
    dup [ >msgpack ] map concat
    binary [ read-msgpacks ] with-byte-reader =
] unit-test
