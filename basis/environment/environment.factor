! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs combinators continuations kernel sequences
splitting system vocabs vocabs.loader ;
IN: environment

HOOK: os-env os ( key -- value )

HOOK: set-os-env os ( value key -- )

HOOK: unset-os-env os ( key -- )

HOOK: (os-envs) os ( -- seq )

HOOK: (set-os-envs) os ( seq -- )

HOOK: set-os-envs-pointer os ( malloc -- )

: os-env? ( key -- ? ) os-env empty? not ;

: change-os-env ( key quot -- )
    [ [ os-env ] keep ] dip dip set-os-env ; inline

: os-envs ( -- assoc )
    (os-envs) [ "=" split1 ] H{ } map>assoc ;

: set-os-envs ( assoc -- )
    [ "=" glue ] { } assoc>map (set-os-envs) ;

: with-os-env ( value key quot -- )
    over [ [ [ set-os-env ] 2curry ] [ compose ] bi* ] dip
    [ os-env ] keep [ set-os-env ] 2curry finally ; inline

{
    { [ os unix? ] [ "environment.unix" require ] }
    { [ os windows? ] [ "environment.windows" require ] }
} cond

STARTUP-HOOK: [
    "FACTOR_ROOTS" os-env [
        os windows? ";" ":" ? split
        [ add-vocab-root ] each
    ] when*
]
