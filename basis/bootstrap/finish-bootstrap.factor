USING: init command-line debugger system continuations
namespaces eval kernel vocabs.loader io ;

[
    boot
    do-startup-hooks
    [ command-line-startup ] [ print-error 1 exit ] recover
] set-startup-quot
