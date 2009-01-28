USING: init command-line system namespaces kernel vocabs.loader
io ;

[
    boot
    do-init-hooks
    (command-line) parse-command-line
    "run" get run
    output-stream get [ stream-flush ] when*
] set-boot-quot
