USING: formatting io kernel accessors math.parser sequences prettyprint
debugger peg ;
IN: peg.debugger


M: parse-error error.
    [ position>> ] [ messages>> " or " join ] [ got>> ] tri
    "Peg parsing error at character position %d.\nExpected %s\nGot '%s'\n"
    printf ;

M: parse-failed error.
    "The " write dup word>> pprint " word could not parse the following input:" print nl
    input>> . ;
