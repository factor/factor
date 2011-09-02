USING: init command-line.startup debugger system continuations ;

[
    boot
    do-startup-hooks
    [ command-line-startup ] [ print-error 1 exit ] recover
] set-startup-quot
