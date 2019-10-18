USING: assocs namespaces sequences source-files strings
tools.test ;

{ { } } [ source-files get keys [ string? ] reject ] unit-test
