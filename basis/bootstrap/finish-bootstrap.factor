USING: init io command-line.startup debugger system
continuations parser.notes namespaces ;

[
    ! Set parser-quiet? to match parser.notes top-level form
    t parser-quiet? set-global
    
    boot
    [ do-startup-hooks command-line-startup ]
    [ print-error nl :c flush 1 exit ]
    recover
] set-startup-quot
