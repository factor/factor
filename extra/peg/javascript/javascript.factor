! Copyright (C) 2008 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors peg.javascript.tokenizer peg.javascript.parser ;
IN: peg.javascript

: parse-javascript ( string -- ast )
  javascript ;
