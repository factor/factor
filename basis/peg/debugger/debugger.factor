USING: accessors debugger io kernel math.parser peg prettyprint
sequences ;
IN: peg.debugger

M: parse-error error.
    [
        "Peg parsing error at character position " write
        position>> number>string write
    ] [
        ".\nExpected " write messages>> " or " join write
    ] [
        "\nGot '" write got>> write "'" print
    ] tri ;
