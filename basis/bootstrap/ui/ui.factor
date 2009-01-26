USING: alien namespaces system combinators kernel sequences
vocabs vocabs.loader ;
IN: bootstrap.ui

"bootstrap.compiler" vocab [
    "ui-backend" get [
        {
            { [ os macosx? ] [ "cocoa" ] }
            { [ os windows? ] [ "windows" ] }
            { [ os unix? ] [ "x11" ] }
        } cond
    ] unless* "ui.backend." prepend require

    "ui-text-backend" get [
        {
            { [ os macosx? ] [ "core-text" ] }
            { [ os windows? ] [ "freetype" ] }
            { [ os unix? ] [ "freetype" ] }
        } cond
    ] unless* "ui.text." prepend require
] when
