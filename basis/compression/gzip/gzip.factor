! Copyright (C) 2020 Jacob Fischer and Abtin Molavi.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays combinators fry kernel locals math sequences vectors ;
IN: compression.gzip

! :: deflate-lz77 ( byte-array -- seq )

:: longest-prefix-end ( ind seq -- i )
     seq length  [ ind swap seq subseq 0 ind seq subseq subseq? ] find-last-integer  ;

: subseq-length ( ind seq -- n )
    [ longest-prefix-end ] 2keep drop - ;

:: offset ( ind seq -- o )
    ind ind ind seq longest-prefix-end seq subseq seq subseq-start - ;

:: create-triple ( ind seq -- array )
    {
    ! no match
    { [ ind seq subseq-length 0 = ]  [ 0 0 3array ] } 
    ! end of sequence
    { [ ind seq longest-prefix-end seq length = ] [ ind seq offset ind seq subseq-length 1 -  seq last 3array ]  }
    ! general case
     [ ind seq offset ind seq subseq-length ind seq longest-prefix-end seq nth 3array ] 
    }
    cond ;

: sum-vec ( vec -- n )
 [ 1 swap nth 1 + ] map 0 [ + ] reduce ;

:: compress-lz77 ( seq -- vec )
0 seq create-triple seq length <vector> ?push [ dup sum-vec seq length < ] [ dup sum-vec seq create-triple swap ?push ] while ;