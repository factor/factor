USING: kernel vocabs vocabs.loader sequences system ;

{ "ui" "help" "tools" }
[ "bootstrap." swap append vocab ] all? [
    "ui.tools" require

    "ui.cocoa" vocab [
        "ui.cocoa.tools" require
    ] when

    "ui.tools.walker" require
] when
