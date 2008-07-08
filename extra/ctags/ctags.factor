! Copyright (C) 2008 Alfredo Beaumont
! See http://factorcode.org/license.txt for BSD license.

! Simple Ctags generator
! Alfredo Beaumont <alfredo.beaumont@gmail.com>

USING: arrays kernel sequences io io.files io.backend
io.encodings.ascii math.parser vocabs definitions
namespaces words sorting ;
IN: ctags

: ctag ( seq -- str )
  [
    dup first ?word-name %
    "\t" %
    second dup first normalize-path %
    "\t" %
    second number>string %
  ] "" make ;

: ctag-strings ( seq1 -- seq2 )
  { } swap [ ctag suffix ] each ;

: ctags-write ( seq path -- )
  >r ctag-strings r> ascii set-file-lines ;

: (ctags) ( -- seq )
  { } all-words [
    dup where [
      2array suffix
    ] [
      drop
    ] if*
  ] each ;

: ctags ( path -- )
  (ctags) sort-keys swap ctags-write ;