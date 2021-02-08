! Copyright (C) 2021 Jacob Fischer and Abtin Molavi.
! See http://factorcode.org/license.txt for BSD license.

USING: byte-arrays ;

IN: compression.gzip-huffman-comp ;

:: read-frequency-element ( element assoc -- dict )
      element assoc at* [ 1 + element assoc set-at ] [ 1 element assoc set-at ] if 
