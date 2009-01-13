! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors calendar.format combinators io.files
kernel math.parser sequences splitting system tools.files
generalizations tools.files.private io.files.info ;
IN: tools.files.windows

<PRIVATE

M: windows file-spec>string ( file-listing spec -- string )
    {
        { listing-datetime [ modified>> timestamp>ymdhms ] }
        [ call-next-method ]
    } case ;

M: windows (directory.) ( entries -- lines )
    <listing-tool>
        { file-size file-datetime file-name } >>specs
        { { directory-entry>> name>> <=> } } >>sort
    list-files ;

PRIVATE>
