
USING: kernel fry io io.files io.encodings.ascii sequences
regexp command-line namespaces ;

IN: tools.grep

! TODO: getopt
! TODO: color
! TODO: case-insensitive

: grep-lines ( regexpt -- )
    '[ dup _ matches? [ print ] [ drop ] if ] each-line ;

: grep-file ( pattern filename -- )
    ascii [ grep-lines ] with-file-reader ;

: grep-usage ( -- )
    "Usage: factor grep.factor <pattern> [<file>...]" print ;

: run-grep ( -- )
    command-line get [
        grep-usage
    ] [
        unclip ".*" 1surround <regexp> swap [
            grep-lines
        ] [
            [ grep-file ] with each
        ] if-empty
    ] if-empty ;

MAIN: run-grep
