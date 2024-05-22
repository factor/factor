! Copyright (c) 2012 Anonymous
! See https://factorcode.org/license.txt for BSD license.
USING: accessors http.download io io.encodings.ascii io.files
io.files.temp kernel math math.parser sequences
splitting urls ;
IN: rosetta-code.text-processing.max-licenses

! https://rosettacode.org/wiki/Text_processing/Max_licenses_in_use

! A company currently pays a fixed sum for the use of a
! particular licensed software package. In determining if it has a
! good deal it decides to calculate its maximum use of the
! software from its license management log file.

! Assume the software's licensing daemon faithfully records a
! checkout event when a copy of the software starts and a checkin
! event when the software finishes to its log file. An example of
! checkout and checkin events are:

!  License OUT @ 2008/10/03_23:51:05 for job 4974
!  ...
!  License IN  @ 2008/10/04_00:18:22 for job 4974

! Save the 10,000 line log file from here into a local file then
! write a program to scan the file extracting both the maximum
! licenses that were out at any time, and the time(s) at which
! this occurs.

TUPLE: maxlicense max-count current-count times ;

<PRIVATE

: <maxlicense> ( -- max ) -1 0 V{ } clone \ maxlicense boa ; inline

: out? ( line -- ? ) "OUT" subseq-of? ; inline

: line-time ( line -- time ) split-words harvest fourth ; inline

: update-max-count ( max -- max' )
    dup [ current-count>> ] [ max-count>> ] bi >
    [ dup current-count>> >>max-count V{ } clone >>times ] when ;

: (inc-current-count) ( max ? -- max' )
    [ [ 1 + ] change-current-count ]
    [ [ 1 - ] change-current-count ]
    if
    update-max-count ; inline

: inc-current-count ( max ? time -- max' time )
    [ (inc-current-count) ] dip ;

: current-max-equal? ( max -- max ? )
    dup [ current-count>> ] [ max-count>> ] bi = ;

: update-time ( max time -- max' )
    [ current-max-equal? ] dip
    swap
    [ [ suffix ] curry change-times ] [ drop ] if ;

: split-line ( line -- ? time ) [ out? ] [ line-time ] bi ;

: process ( max line -- max ) split-line inc-current-count update-time ;

MEMO: mlijobs ( -- lines )
    URL" https://raw.githubusercontent.com/def-/nim-unsorted/master/mlijobs.txt"
    "mlijobs.txt" temp-file download-once-as ascii file-lines ;

PRIVATE>

: find-max-licenses ( -- max )
    mlijobs <maxlicense> [ process ] reduce ;

: print-max-licenses ( max -- )
    [ times>> ] [ max-count>> ] bi
    "Maximum simultaneous license use is " write
    number>string write
    " at the following times: " print
    [ print ] each ;
