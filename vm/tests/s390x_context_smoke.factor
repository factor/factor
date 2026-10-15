USING: io kernel namespaces threads ;
IN: s390x.context.thread.smoke
SYMBOL: child-ran
f child-ran set-global
[ t child-ran set-global ] "context-probe" spawn drop
yield
child-ran get-global [ "THREAD-CONTEXT-PASS" print ] [ "thread failed to run" throw ] if
