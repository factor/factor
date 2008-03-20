USING: vocabs.loader sequences system
random random.mersenne-twister ;

"random.mersenne-twister" require

{
    { [ windows? ] [ "random.windows" require ] }
    { [ unix? ] [ "random.unix" require ] }
} cond

[ millis <mersenne-twister> random-generator set-global ]
"generator.random" add-init-hook
