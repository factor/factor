! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel arrays strings math.parser peg ;
IN: peg.pl0

#! Grammar for PL/0 based on http://en.wikipedia.org/wiki/PL/0

: 'ident' ( -- parser )
  CHAR: a CHAR: z range 
  CHAR: A CHAR: Z range 2array choice repeat1 
  [ >string ] action ;

: 'number' ( -- parser )
  CHAR: 0 CHAR: 9 range repeat1 [ string>number ] action ;
