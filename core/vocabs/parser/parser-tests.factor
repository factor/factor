IN: vocabs.parser.tests
USING: vocabs.parser tools.test eval kernel accessors ;

[ "FROM: kernel => doesnotexist ;" eval( -- ) ]
[ error>> T{ no-word-in-vocab { word "doesnotexist" } { vocab "kernel" } } = ]
must-fail-with

[ "RENAME: doesnotexist kernel => newname" eval( -- ) ]
[ error>> T{ no-word-in-vocab { word "doesnotexist" } { vocab "kernel" } } = ]
must-fail-with