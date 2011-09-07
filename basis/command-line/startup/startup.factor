! Copyright (C) 2011 Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: command-line eval io io.pathnames kernel namespaces
system vocabs.loader ;
IN: command-line.startup

: cli-usage ( -- )
"""
Usage: """ write vm file-name write """ [Factor arguments] [script] [script arguments]

Common arguments:
    -help            print this message and exit
    -i=<image>       load Factor image file <image> (default """ write vm file-name write """.image)
    -run=<vocab>     run the MAIN: entry point of <vocab>
    -e=<code>        evaluate <code>
    -no-user-init    suppress loading of .factor-rc

Enter
    "command-line" help
from within Factor for more information.

""" write ;

: command-line-startup ( -- )
    (command-line) parse-command-line
    "help" get "-help" get or "h" get or [ cli-usage ] [
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

