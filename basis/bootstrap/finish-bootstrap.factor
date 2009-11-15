USING: init command-line debugger system continuations
namespaces eval kernel vocabs.loader io destructors ;

[
    boot
    [
        do-startup-hooks
        [
            (command-line) parse-command-line
            load-vocab-roots
            run-user-init
            "e" get [ eval( -- ) ] when*
            ignore-cli-args? not script get and
            [ run-script ] [ "run" get run ] if*
            output-stream get [ stream-flush ] when*
            0
        ] [ print-error 1 ] recover
     ] with-destructors exit
] set-boot-quot
