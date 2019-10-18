USING: kernel vocabs sequences system vocabs.loader ;

{ "ui" "help" "tools" }
[ "bootstrap." prepend lookup-vocab ] all? [
    "ui.tools" require

    { "ui.backend.cocoa" } "ui.backend.cocoa.tools" require-when

    "ui.tools.walker" require
] when
