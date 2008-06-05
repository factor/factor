! Copyright (C) 2008 Matthew Willis.
! See http://factorcode.org/license.txt for BSD license.
USING: prettyprint sequences ui.gadgets.panes
pango.cairo.gadgets math kernel cairo cairo.ffi
pango.cairo tools.time namespaces assocs
threads io.backend io.encodings.utf8 io.files ;

IN: pango.cairo.samples

: hello-pango ( -- )
    "monospace 10" "resource:extra/pango/cairo/gadgets/gadgets.factor"
    normalize-path utf8 file-contents
    <pango-gadget> gadget. ;

: time-pango ( -- )
    [ hello-pango ] time ;

! clear the caches, for testing.
: clear-pango ( -- )
    dims get clear-assoc
    textures get clear-assoc ;

MAIN: time-pango
