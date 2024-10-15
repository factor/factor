USING: assocs cocoa.plists editors.focus io.pathnames
io.standard-paths kernel make math.order math.parser sequences
splitting system ;
IN: editors.focus.macos

MEMO: supports-open-to-line? ( -- ? )
    "dev.focus-editor" find-native-bundle [
        "Contents/Info.plist" append-path read-plist
        "CFBundleVersion" of "." split [ string>number ] map
        { 0 3 7 } after?
    ] [ f ] if* ;

M: macos focus-command
    supports-open-to-line?
    [ number>string ":" glue ] [ drop ] if
    [ "open" , "-a" , "Focus" , , ] { } make ;
