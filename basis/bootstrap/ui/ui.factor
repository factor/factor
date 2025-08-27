USING: alien namespaces system combinators kernel sequences
vocabs ;
IN: bootstrap.ui

"bootstrap.math" require
"bootstrap.compiler" require
"bootstrap.threads" require

"ui-backend" get [
    "ui.backend." prepend
] [
    {
        { [ os macos? ] [ "ui.backend.cocoa" ] }
        { [ os windows? ] [ "ui.backend.windows" ] }
        { [ os unix? ] [ "ui.backend.gtk2" ] }
    } cond
] if* require
