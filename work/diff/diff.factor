! Copyright (C) 2012 PolyMicro Systems.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors io.backend io.directories io.encodings.utf8 io.files
kernel locals math sequences sets sorting ;

IN: diff

TUPLE: file-compare file1-path file2-path file1-content file2-content ;

! Accessors
! : «file1-path ( file-compare -- path file-compare )
!     [ file1-path>> ] keep ;

! : »file1-path ( path file-compare -- file-compare )
!     swap >>file1-path ;

! : «file2-path ( file-compare -- path file-compare )
!     [ file2-path>> ] keep ;

! : »file2-path ( path file-compare -- file-compare )
!     swap >>file2-path ;

! : «file1-content ( file-compare -- seq file-compare )
!     [ file1-content>> ] keep ;

! : »file1-content ( seq file-compare -- file-compare )
!     swap >>file1-content ;

! : «file2-content ( file-compare -- seq file-compare )
!     [ file2-content>> ] keep ;

! : »file2-content ( seq file-compare -- file-compare )
!     swap >>file2-content ;

: shortest-first ( seq1 seq2 -- shorter-seq longer-seq )
    2dup [ length ] bi@
    >
    [ swap ]
    [ ] if
    ;

: strip-blanks ( seq -- seq )
    [ "" = not ] filter
    ;

: unique ( seq -- unique )
    natural-sort
    "" swap
    [ 2dup =  [ drop f ] [ swap drop t ] if ] filter
    nip
    ;

:: <file-compare> ( file1 file2 -- file-compare )
    file-compare new
    file1 normalize-path >>file1-path
    file2 normalize-path >>file2-path
    [ dup file1-path>>  utf8 file-lines
      strip-blanks unique  >>file1-content ]
    [ file2-path>>  utf8 file-lines
      strip-blanks unique >>file2-content ] bi
;


: file-compare-contents ( file-compare -- file1-entries file2-entries )
  dup file1-content>>   
  swap file2-content>>
;

: file-diff ( file-compare -- seq )
    file-compare-contents diff ;

: file-intersect ( file-compare -- seq )
    file-compare-contents intersect
    ;

: file-union ( file-compare -- seq )
    file-compare-contents union
    ;

:: merge-lines ( seq1 seq2 -- seq )
    seq1 seq2 shortest-first swap
    [ [ = ] curry [ dup ] dip  find >boolean
      [ >boolean ] when
    ] B filter
    [ swap remove ] each
    seq1 prepend natural-sort
    ;

: unique-only ( file1 file2 -- lines )
    <file-compare>
    file-compare-contents merge-lines
 ;

: write-file ( seq file -- )
    normalize-path dup exists?
    [ dup delete-file ] when
    utf8 set-file-lines
    ;

: merge-files ( file1 file2 output -- )
    [ <file-compare> file-compare-contents merge-lines ] dip
    write-file    ;

:: diff-files ( file1 file2 output -- )
    file1 file2  <file-compare>
    dup file-compare-contents swap diff
    dup output write-file
    over file1-content>> append
    swap file1-path>> utf8 set-file-lines ;

: testfiles ( -- file1 file2 )
    "~/Desktop/import1.txt"
    "~/Desktop/wine.txt"
    ;

: difftest ( -- x )
    testfiles unique-only ;

: mergetest ( -- )
    testfiles "~/Desktop/export1.txt" merge-files ;