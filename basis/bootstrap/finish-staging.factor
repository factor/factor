USING: command-line init io kernel namespaces sequences system
vocabs.loader ;

[
    boot
    do-startup-hooks
    (command-line) parse-command-line
    "run" get run
    output-stream get [ stream-flush ] when*
    quit
] set-startup-quot
