USING: accessors debugger io kernel make math.parser
prettyprint source-files.errors command-line summary ;
IN: source-files.errors.debugger

CONSTANT: +listener-input+ "<Listener input>"

: error-location ( error -- string )
    [
        [ file>> [ % ] [ +listener-input+ % ] if* ]
        [ line#>> [ ": " % # ] when* ] bi
    ] "" make ;

M: source-file-error summary error>> summary ;

M: source-file-error error.
    [ error-location print nl ]
    [ asset>> [ "Asset: " write short. nl ] when* ]
    [ error>> error. ]
    tri ;

M: user-init-error error.
    error>> error. ;
