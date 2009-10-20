USING: init command-line system namespaces kernel vocabs.loader
io ;

[
    boot
    do-startup-hooks
    (command-line) parse-command-line
    "run" get run
    output-stream get [ stream-flush ] when*
    0 exit
] set-boot-quot
