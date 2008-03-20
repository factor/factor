USING: vocabs.loader sequences system ;

"random.mersenne-twister" require

{
    { [ windows? ] [ "random.windows" require ] }
    { [ unix? ] [ "random.unix" require ] }
} cond
