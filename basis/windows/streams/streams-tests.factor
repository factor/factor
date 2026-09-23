USING: accessors alien.c-types alien.data byte-arrays byte-vectors
classes.struct destructors io.encodings.binary io.streams.byte-array kernel libc locals
sequences tools.test windows.com windows.ole32 windows.streams windows.types ;
IN: windows.streams.tests

! CopyTo's counts are ULARGE_INTEGER outputs, unlike Write's ULONG output.
! The maximum count means copy to EOF, not allocate an enormous buffer.
{ 0 70000 70000 t } [ [| |
    70000 <byte-array> [ drop 42 ] map! :> payload
    payload binary <byte-reader> stream>IStream :> source
    BV{ } clone :> output
    output stream>IStream :> destination
    source [| source |
        destination [| destination |
            0x1122334455667788 ULARGE_INTEGER <ref> malloc-byte-array &free :> read-count
            0x1122334455667788 ULARGE_INTEGER <ref> malloc-byte-array &free :> written-count
            source destination 0xFFFFFFFFFFFFFFFF read-count written-count IStream::CopyTo
            read-count ULARGE_INTEGER deref
            written-count ULARGE_INTEGER deref
            output >byte-array payload =
        ] with-com-interface
    ] with-com-interface
] with-destructors ] unit-test

{ 0 3 } [ [| |
    B{ 1 2 3 } binary <byte-reader> stream>IStream [| source |
        STATSTG malloc-struct &free :> stat
        source stat 1 IStream::Stat
        stat cbSize>>
    ] with-com-interface
] with-destructors ] unit-test
