USING: accessors kernel system tools.test vocabs.parser ;
IN: vocabs.metadata

[ os windows? "unix" "windows" ? use-vocab ]
[ error>> unsupported-platform? ] must-fail-with
