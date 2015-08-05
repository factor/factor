! (c)2010 Joe Groff bsd license
USING: alien.c-types alien.data bootstrap.image
bootstrap.image.private destructors io io.directories
io.encodings.binary io.files locals system kernel ;
IN: tools.deploy.embed

:: embed-image ( image executable -- )
    executable binary <file-appender> [| out |
        out stream-tell :> offset
        image binary <file-reader> [| in |
            in out stream-copy*
        ] with-disposal
        image-magic uintptr_t <ref> out stream-write
        offset uintptr_t <ref> out stream-write
    ] with-disposal ;

: make-embedded-image* ( from-image from-executable to-executable -- )
    swap [ copy-file ] keep embed-image ;

: make-embedded-image ( from-image to-executable -- )
    vm-path swap make-embedded-image* ;
