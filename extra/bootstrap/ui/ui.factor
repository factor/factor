USING: alien namespaces system combinators kernel sequences
vocabs vocabs.loader ;

"bootstrap.compiler" vocab [
    "ui-backend" get [
        {
            { [ macosx? ] [ "cocoa" ] }
            { [ windows? ] [ "windows" ] }
            { [ unix? ] [ "x11" ] }
        } cond
    ] unless* "ui." swap append require

    "ui.freetype" require
] when
