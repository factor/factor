USING: io kernel accessors math.parser sequences prettyprint
debugger peg ;
IN: peg.debugger

M: parse-error error.
  "Peg parsing error at character position " write dup position>> number>string write 
  "." print "Expected " write messages>> [ " or " write ] [ write ] interleave nl ;

M: parse-failed error.
  "The " write dup word>> pprint " word could not parse the following input:" print nl
  input>> . ;

