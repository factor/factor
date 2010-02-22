USING: init command-line debugger system continuations
namespaces eval kernel vocabs.loader io ;

[
    boot
    do-startup-hooks
    [
        (command-line) parse-command-line
        load-vocab-roots
        run-user-init

        "e" get script get or [
            "e" get [ eval( -- ) ] when*
            script get [ run-script ] when*
        ] [
            "run" get run
        ] if

        output-stream get [ stream-flush ] when*
        0 exit
    ] [ print-error 1 exit ] recover
] set-startup-quot
