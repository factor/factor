! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs checksums grouping kernel math sequences ;
IN: checksums.interleave

: seq>2seq ( seq -- seq1 seq2 )
    ! { abcdefgh } -> { aceg } { bdfh }
    2 group flip [ { } { } ] [ first2 ] if-empty ;

: 2seq>seq ( seq1 seq2 -- seq )
    ! { aceg } { bdfh } -> { abcdefgh }
    [ zip concat ] keep like ;

:: interleaved-checksum ( bytes checksum -- seq )
    bytes [ zero? ] trim-head
    dup length odd? [ rest-slice ] when
    seq>2seq [ checksum checksum-bytes ] bi@ 2seq>seq ;
