IN: source-files.tests
USING: source-files tools.test assocs sequences strings
namespaces kernel ;

[ { } ] [ source-files get keys [ string? ] reject ] unit-test
