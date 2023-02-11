! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors calendar.format combinators io.files
kernel math.parser sequences splitting system tools.files
generalizations tools.files.private io.files.info math.order ;
IN: tools.files.windows

<PRIVATE

M: windows (directory.)
    <listing-tool>
        { +file-datetime+ +directory-or-size+ +file-name+ } >>specs
        { { directory-entry>> name>> <=> } } >>sort
    list-files ;

PRIVATE>
