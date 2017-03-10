! Copyright (C) 2011 Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: command-line eval io io.pathnames kernel namespaces
sequences system vocabs.loader ;
IN: command-line.startup

: cli-usage ( -- )
"Usage: " write vm-path file-name write " [Factor arguments] [script] [script arguments]

Factor arguments:
    -help               print this message and exit
    -i=<image>          load Factor image file <image> (default " write vm-path file-stem write ".image)
    -run=<vocab>        run the MAIN: entry point of <vocab>
        -run=listener   run terminal listener
        -run=ui.tools   run Factor development UI
    -e=<code>           evaluate <code>
    -no-user-init       suppress loading of .factor-rc
    -datastack=<int>    datastack size in KiB
    -retainstack=<int>  retainstack size in KiB
    -callstack=<int>    callstack size in KiB
    -callbacks=<int>    callback heap size in KiB
    -young=<int>        young gc generation 0 size in MiB
    -aging=<int>        aging gc generation 1 size in MiB
    -tenured=<int>      tenured gc generation 2 size in MiB
    -codeheap=<int>     codeheap size in MiB
    -pic=<int>          max pic size
    -fep                enter fep mode immediately
    -no-signals         turn off OS signal handling
    -console            open console if possible
    -roots=<paths>      a list of \"" write os windows? ";" ":" ? write "\"-delimited extra vocab roots

Enter
    \"command-line\" help
from within Factor for more information.

" write ;

: help? ( -- ? )
    "help" get "h" get or
    os windows? [ script get "/?" = or ] when ;

: command-line-startup ( -- )
    (command-line) parse-command-line
    help? [ cli-usage ] [
        load-vocab-roots
        run-user-init
        "e" get script get or [
            "e" get [ eval( -- ) ] when*
            script get [ run-script ] when*
        ] [
            "run" get run
        ] if
    ] if

    output-stream get [ stream-flush ] when*
    0 exit ;
