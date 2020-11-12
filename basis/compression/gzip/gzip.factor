! Copyright (C) 2020 Jacob Fischer and Abtin Molavi.
! See http://factorcode.org/license.txt for BSD license.
USING: compression.huffman compression.inflate compression.zlib ;
IN: compression.gzip

! :: deflate-lz77 ( byte-array -- seq )

:: create-triple ( INT seq -- array INT )
    seq length 1 - '[subseq INT _ subseq 0 INT 1 - subseq?] find-last-integer