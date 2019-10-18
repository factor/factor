! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs combinators kernel sequences splitting system
vocabs.loader init ;
IN: environment

HOOK: os-env os ( key -- value )

HOOK: set-os-env os ( value key -- )

HOOK: unset-os-env os ( key -- )

HOOK: (os-envs) os ( -- seq )

HOOK: (set-os-envs) os ( seq -- )

: os-envs ( -- assoc )
    (os-envs) [ "=" split1 ] H{ } map>assoc ;

: set-os-envs ( assoc -- )
    [ "=" glue ] { } assoc>map (set-os-envs) ;

{
    { [ os unix? ] [ "environment.unix" require ] }
    { [ os winnt? ] [ "environment.winnt" require ] }
    { [ os wince? ] [ ] }
} cond

[
    "FACTOR_ROOTS" os-env
    [
        os windows? ";" ":" ? split
        [ add-vocab-root ] each
    ] when*    
] "environment" add-startup-hook
