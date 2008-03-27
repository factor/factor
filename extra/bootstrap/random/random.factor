USING: vocabs.loader sequences system
random random.mersenne-twister combinators init
namespaces random.backend ;

"random.mersenne-twister" require

{
    { [ windows? ] [ "random.windows" require ] }
    { [ unix? ] [ "random.unix" require ] }
} cond

! [ [ 32 random-bits ] with-secure-random <mersenne-twister> random-generator set-global ]
[ millis <mersenne-twister> random-generator set-global ]
"generator.random" add-init-hook
