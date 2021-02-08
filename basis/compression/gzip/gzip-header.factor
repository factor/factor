! Copyright (C) 2021 Jacob Fischer and Abtin Molavi.
! See http://factorcode.org/license.txt for BSD license.

USING: byte-arrays ;

IN: compression.gzip-header ;

: create-gzip-factor ( -- header )
    { 31 139 8 0 0 0 255 0 } >byte-array
