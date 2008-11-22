USING: accessors io io.streams.string kernel mime.multipart
tools.test make multiline ;
IN: mime.multipart.tests

[ { "a" f } ] [
    [
        "azzbzzczzdzz" <string-reader> "z" <multipart-stream> 1 >>n
        [ , ] [ ] multipart-step-loop drop
    ] { } make
] unit-test

[ { "a" f } ] [
    [
        "azzbzzczzdzz" <string-reader> "z" <multipart-stream> 2 >>n
        [ , ] [ ] multipart-step-loop drop
    ] { } make
] unit-test

[ { "a" f } ] [
    [
        "azzbzzczzdzz" <string-reader> "z" <multipart-stream> 3 >>n
        [ , ] [ ] multipart-step-loop drop
    ] { } make
] unit-test

[ { "a" f } ] [
    [
        "azzbzzczzdzz" <string-reader> "z" <multipart-stream> 4 >>n
        [ , ] [ ] multipart-step-loop drop
    ] { } make
] unit-test

[ { "a" f } ] [
    [
        "azzbzzczzdzz" <string-reader> "z" <multipart-stream> 5 >>n
        [ , ] [ ] multipart-step-loop drop
    ] { } make
] unit-test


[ { "a" "a" f } ] [
    [
        "aazzbzzczzdzz" <string-reader> "z" <multipart-stream> 1 >>n
        [ , ] [ ] multipart-step-loop drop
    ] { } make
] unit-test

[ { "aa" f } ] [
    [
        "aazzbzzczzdzz" <string-reader> "z" <multipart-stream> 2 >>n
        [ , ] [ ] multipart-step-loop drop
    ] { } make
] unit-test

[ { "aa" f } ] [
    [
        "aazzbzzczzdzz" <string-reader> "z" <multipart-stream> 3 >>n
        [ , ] [ ] multipart-step-loop drop
    ] { } make
] unit-test

[ { "aa" f } ] [
    [
        "aazzbzzczzdzz" <string-reader> "z" <multipart-stream> 4 >>n
        [ , ] [ ] multipart-step-loop drop
    ] { } make
] unit-test

[ { "aa" f } ] [
    [
        "aazzbzzczzdzz" <string-reader> "z" <multipart-stream> 5 >>n
        [ , ] [ ] multipart-step-loop drop
    ] { } make
] unit-test



[ { "a" f } ] [
    [
        "azzbzzczzdzz" <string-reader> "zz" <multipart-stream> 1 >>n
        [ , ] [ ] multipart-step-loop drop
    ] { } make
] unit-test

[ { "a" "z" "z" "b" "z" "z" "c" "z" "z" "d" "zz" } ] [
    [
        "azzbzzczzdzz" <string-reader> "zzz" <multipart-stream> 1 >>n
        [ , ] [ ] multipart-step-loop drop
    ] { } make
] unit-test

[ { "a" "z" "z" "b" "z" "z" "c" "z" "z" "d" f } ] [
    [
        "azzbzzczzdzzz" <string-reader> "zzz" <multipart-stream> 1 >>n
        [ , ] [ ] multipart-step-loop drop
    ] { } make
] unit-test

[ { "az" "zb" "zz" "cz" "zd" f } ] [
    [
        "azzbzzczzdzzz" <string-reader> "zzz" <multipart-stream> 2 >>n
        [ , ] [ ] multipart-step-loop drop
    ] { } make
] unit-test

[ { "a" "zzb" "zzc" "zzd" f } ] [
    [
        "azzbzzczzdzzz" <string-reader> "zzz" <multipart-stream> 3 >>n
        [ , ] [ ] multipart-step-loop drop
    ] { } make
] unit-test

[ { "az" "zbzz" "czzd" f } ] [
    [
        "azzbzzczzdzzz" <string-reader> "zzz" <multipart-stream> 4 >>n
        [ , ] [ ] multipart-step-loop drop
    ] { } make
] unit-test

[ { "azz" "bzzcz" "zd" f } ] [
    [
        "azzbzzczzdzzz" <string-reader> "zzz" <multipart-stream> 5 >>n
        [ , ] [ ] multipart-step-loop drop
    ] { } make
] unit-test


[ { "a" f f "b" f f "c" f f "d" f f } ] [
    [
        "azzbzzczzdzz" <string-reader> "z" <multipart-stream> 1 >>n
        [ , ] [ ] multipart-loop-all
    ] { } make
] unit-test

[ { "a" f f "b" f f "c" f f "d" f f } ] [
    [
        "azzbzzczzdzz" <string-reader> "z" <multipart-stream> 2 >>n
        [ , ] [ ] multipart-loop-all
    ] { } make
] unit-test

[ { "a" f f "b" f f "c" f f "d" f f } ] [
    [
        "azzbzzczzdzz" <string-reader> "z" <multipart-stream> 3 >>n
        [ , ] [ ] multipart-loop-all
    ] { } make
] unit-test

[ { "a" f f "b" f f "c" f f "d" f f } ] [
    [
        "azzbzzczzdzz" <string-reader> "z" <multipart-stream> 4 >>n
        [ , ] [ ] multipart-loop-all
    ] { } make
] unit-test

[ { "a" f f "b" f f "c" f f "d" f f } ] [
    [
        "azzbzzczzdzz" <string-reader> "z" <multipart-stream> 5 >>n
        [ , ] [ ] multipart-loop-all
    ] { } make
] unit-test


[ { "a" "a" f f "b" f f "c" f f "d" f f } ] [
    [
        "aazzbzzczzdzz" <string-reader> "z" <multipart-stream> 1 >>n
        [ , ] [ ] multipart-loop-all
    ] { } make
] unit-test

[ { "aa" f f "b" f f "c" f f "d" f f } ] [
    [
        "aazzbzzczzdzz" <string-reader> "z" <multipart-stream> 2 >>n
        [ , ] [ ] multipart-loop-all
    ] { } make
] unit-test

[ { "aa" f f "b" f f "c" f f "d" f f } ] [
    [
        "aazzbzzczzdzz" <string-reader> "z" <multipart-stream> 3 >>n
        [ , ] [ ] multipart-loop-all
    ] { } make
] unit-test

[ { "aa" f f "b" f f "c" f f "d" f f } ] [
    [
        "aazzbzzczzdzz" <string-reader> "z" <multipart-stream> 4 >>n
        [ , ] [ ] multipart-loop-all
    ] { } make
] unit-test

[ { "aa" f f "b" f f "c" f f "d" f f } ] [
    [
        "aazzbzzczzdzz" <string-reader> "z" <multipart-stream> 5 >>n
        [ , ] [ ] multipart-loop-all
    ] { } make
] unit-test



[ { "a" f "b" f "c" f "d" f } ] [
    [
        "azzbzzczzdzz" <string-reader> "zz" <multipart-stream> 1 >>n
        [ , ] [ ] multipart-loop-all
    ] { } make
] unit-test

[ { "a" "z" "z" "b" "z" "z" "c" "z" "z" "d" "zz" } ] [
    [
        "azzbzzczzdzz" <string-reader> "zzz" <multipart-stream> 1 >>n
        [ , ] [ ] multipart-loop-all
    ] { } make
] unit-test

[ { "a" "z" "z" "b" "z" "z" "c" "z" "z" "d" f } ] [
    [
        "azzbzzczzdzzz" <string-reader> "zzz" <multipart-stream> 1 >>n
        [ , ] [ ] multipart-loop-all
    ] { } make
] unit-test

[ { "az" "zb" "zz" "cz" "zd" f } ] [
    [
        "azzbzzczzdzzz" <string-reader> "zzz" <multipart-stream> 2 >>n
        [ , ] [ ] multipart-loop-all
    ] { } make
] unit-test

[ { "a" "zzb" "zzc" "zzd" f } ] [
    [
        "azzbzzczzdzzz" <string-reader> "zzz" <multipart-stream> 3 >>n
        [ , ] [ ] multipart-loop-all
    ] { } make
] unit-test

[ { "az" "zbzz" "czzd" f } ] [
    [
        "azzbzzczzdzzz" <string-reader> "zzz" <multipart-stream> 4 >>n
        [ , ] [ ] multipart-loop-all
    ] { } make
] unit-test

[ { "azz" "bzzcz" "zd" f } ] [
    [
        "azzbzzczzdzzz" <string-reader> "zzz" <multipart-stream> 5 >>n
        [ , ] [ ] multipart-loop-all
    ] { } make
] unit-test
