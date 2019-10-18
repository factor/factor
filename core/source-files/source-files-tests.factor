IN: source-files.tests
USING: source-files tools.test assocs sequences strings
namespaces kernel ;

[ { } ] [ source-files get keys [ string? not ] filter ] unit-test
