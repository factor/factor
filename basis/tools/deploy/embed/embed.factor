! (c)2010 Joe Groff bsd license
USING: alien.c-types alien.data bootstrap.image
bootstrap.image.private destructors io io.directories
io.encodings.binary io.files locals system ;
IN: tools.deploy.embed

:: embed-image ( from-image to-executable -- )
    vm to-executable copy-file
    to-executable binary <file-appender> [| out |
        out stream-tell :> offset
        from-image binary <file-reader> [| in |
            in out stream-copy*
        ] with-disposal
        image-magic uintptr_t <ref> out stream-write
        offset uintptr_t <ref> out stream-write
    ] with-disposal ;

