USING: editors io.pathnames io.standard-paths kernel make
math.parser namespaces ;
IN: editors.coteditor

SINGLETON: coteditor

: find-cot-bundle-path ( -- path/f )
    "com.coteditor.CotEditor" find-native-bundle [
        "Contents/MacOS/cot" append-path
    ] [
        f
    ] if* ;

M: coteditor editor-command
    [ find-cot-bundle-path , "-l" , number>string , , ] { } make ;
