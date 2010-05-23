USING: alien namespaces system combinators kernel sequences
vocabs vocabs.loader ;
IN: bootstrap.ui

"bootstrap.compiler" vocab [
    "ui-backend" get [
        {
            { [ os macosx? ] [ "cocoa" ] }
            { [ os windows? ] [ "windows" ] }
            { [ os unix? ] [ "gtk" ] }
        } cond
    ] unless* "ui.backend." prepend require
] when
