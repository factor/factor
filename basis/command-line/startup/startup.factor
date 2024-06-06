! Copyright (C) 2011 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators combinators.smart command-line eval
io io.pathnames kernel layouts math math.parser namespaces
parser parser.notes prettyprint sequences source-files system
vocabs.loader ;
IN: command-line.startup

: help? ( -- ? )
    "help" get "h" get or
    os windows? [ script get "/?" = or ] when ;

: help. ( -- )
"Usage: " write vm-path file-name write " [options] [script] [arguments]

Options:
    -help               print this message and exit
    -version            print the Factor version and exit
    -i=<image>          load Factor image file <image> [" write vm-path file-stem write ".image]
    -run=<vocab>        run the MAIN: entry point of <vocab>
        -run=listener   run terminal listener
        -run=ui.tools   run Factor development UI
    -e=<code>           evaluate <code>
    -no-user-init       suppress loading of .factor-rc
    -datastack=<int>    datastack size in KiB [" write cell 32 * number>string write "]
    -retainstack=<int>  retainstack size in KiB [" write cell 32 * number>string write "]
    -callstack=<int>    callstack size in KiB [" write cell cpu ppc? 256 128 ? * number>string write "]
    -callbacks=<int>    callback heap size in KiB [256]
    -young=<int>        young gc generation 0 size in MiB [" write cell 4 / number>string write "]
    -aging=<int>        aging gc generation 1 size in MiB [" write cell 2 / number>string write "]
    -tenured=<int>      tenured gc generation 2 size in MiB [" write cell 24 * number>string write "]
    -codeheap=<int>     codeheap size in MiB [96]
    -pic=<int>          max pic size [3]
    -fep                enter fep mode immediately
    -no-signals         turn off OS signal handling
    -roots=<paths>      '" write os windows? ";" ":" ? write "'-separated list of extra vocab root directories

Enter
    \"command-line\" help
from within Factor for more information.
" write ;

: version? ( -- ? ) "version" get ;

: run-script ( file -- )
    t parser-quiet? [
        [ parse-file [ output>array datastack. ] call( quot -- ) ]
        [ path>source-file main>> [ execute( -- ) ] when* ] bi
    ] with-variable ;

: command-line-startup ( -- )
    (command-line) parse-command-line {
        { [ help? ] [ help. ] }
        { [ version? ] [ vm-info print ] }
        [
            load-vocab-roots
            run-user-init
            "e" get script get or [
                t auto-use? [
                    "e" get [ eval-with-stack ] when*
                    script get [ run-script ] when*
                ] with-variable
            ] [
                "run" get run
            ] if
        ]
    } cond

    output-stream get [ stream-flush ] when*
    quit ;
