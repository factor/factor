USING: init command-line debugger system continuations
namespaces eval kernel vocabs.loader io ;

[
    boot
    do-init-hooks
    [
        (command-line) parse-command-line
        load-vocab-roots
        run-user-init
        "e" get [ eval( -- ) ] when*
        ignore-cli-args? not script get and
        [ run-script ] [ "run" get run ] if*
        output-stream get [ stream-flush ] when*
        0 exit
    ] [ print-error 1 exit ] recover
] set-boot-quot
