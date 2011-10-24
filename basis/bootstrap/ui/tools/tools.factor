USING: kernel vocabs vocabs.loader sequences system ;

{ "ui" "help" "tools" }
[ "bootstrap." prepend lookup-vocab ] all? [
    "ui.tools" require

    { "ui.backend.cocoa" } "ui.backend.cocoa.tools" require-when

    "ui.tools.walker" require
] when
