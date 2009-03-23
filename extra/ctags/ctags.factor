! Copyright (C) 2008 Alfredo Beaumont
! See http://factorcode.org/license.txt for BSD license.

! Simple Ctags generator
! Alfredo Beaumont <alfredo.beaumont@gmail.com>

USING: arrays kernel sequences io io.files io.backend
io.encodings.ascii math.parser vocabs definitions
namespaces make words sorting present ;
IN: ctags

: ctag-word ( ctag -- word )
  first ;

: ctag-path ( ctag -- path )
  second first ;

: ctag-lineno ( ctag -- n )
  second second ;

: ctag ( seq -- str )
  [
    dup ctag-word present %
    "\t" %
    dup ctag-path normalize-path %
    "\t" %
    ctag-lineno number>string %
  ] "" make ;

: ctag-strings ( alist -- seq )
  [ ctag ] map ;

: ctags-write ( seq path -- )
  [ ctag-strings ] dip ascii set-file-lines ;

: (ctags) ( -- seq )
  all-words [
    dup where [
      2array
    ] when*
  ] map [ sequence? ] filter ;

: ctags ( path -- )
  (ctags) sort-keys swap ctags-write ;