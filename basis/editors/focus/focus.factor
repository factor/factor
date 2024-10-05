USING: assocs cocoa.plists editors io.pathnames
io.standard-paths kernel make math.order math.parser sequences
splitting ;
IN: editors.focus

SINGLETON: focus

! XXX: support Windows and Linux also?

MEMO: supports-open-to-line? ( -- ? )
    "dev.focus-editor" find-native-bundle [
        "Contents/Info.plist" append-path read-plist
        "CFBundleVersion" of "." split [ string>number ] map
        { 0 3 7 } after?
    ] [ f ] if* ;

M: focus editor-command
    supports-open-to-line?
    [ number>string ":" glue ] [ drop ] if
    [ "open" , "-a" , "Focus" , , ] { } make throw ;
