! Copyright (C) 2011 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.private compiler.utilities kernel namespaces
stack-checker.alien threads threads.private ;
IN: compiler.threads

[ yield ] yield-hook set-global

[
    dup current-callback eq?
    [ drop ] [ wait-for-callback ] if
] wait-for-callback-hook set-global
