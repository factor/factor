USING: editors io.pathnames io.standard-paths kernel make
math.parser namespaces sequences system ;

IN: editors.cudatext

SINGLETON: cudatext

HOOK: find-cudatext-path os ( -- path )

M: object find-cudatext-path f ;

M: macosx find-cudatext-path
    "com.uvviewsoft.cudatext" find-native-bundle [
        "Contents/MacOS/cudatext" append-path
    ] [
        f
    ] if* ;

: cudatext-path ( -- path )
    \ cudatext-path get [
        find-cudatext-path [ "cudatext" ?find-in-path ] unless*
    ] unless* ;

M: cudatext editor-command
    [
        cudatext-path , number>string ":" glue ,
    ] { } make ;
