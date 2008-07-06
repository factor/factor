! Copyright (C) 2008 Alfredo Beaumont
! See http://factorcode.org/license.txt for BSD license.

! Simple Ctags generator
! Alfredo Beaumont <alfredo.beaumont@gmail.com>

USING: kernel sequences io io.files io.backend
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

: ctags-write ( seq path -- )
  ascii [ [ ctag print ] each ] with-file-writer ;

: (ctags) ( -- seq )
  { } all-words [
    dup where [
      { } 2sequence suffix
    ] [
      drop
    ] if*
  ] each ;

: ctags ( path -- )
  (ctags) sort-keys swap ctags-write ;