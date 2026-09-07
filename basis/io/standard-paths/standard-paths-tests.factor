USING: io.directories io.encodings.utf8 io.files
io.standard-paths.private kernel locals sequences tools.test ;
IN: io.standard-paths.tests

{ { ".EXE" ".CMD" } } [ ".EXE;;.CMD;" executable-extensions ] unit-test
{ { ".COM" ".EXE" ".BAT" ".CMD" } } [ f executable-extensions ] unit-test
{ { } } [ "" executable-extensions ] unit-test

{ { "probe" "probe.CMD" "probe.EXE" } } [
    "probe" { ".CMD" ".EXE" } windows-command-names
] unit-test

{ { "probe.ExE" } } [
    "probe.ExE" { ".CMD" ".EXE" } windows-command-names
] unit-test

:: find-windows-probe ( extensions -- path/f )
    "probe" extensions windows-command-names
    { "first" "second" }
    [ extensions windows-executable-file? ] find-path-entry ;

! Test Windows search ordering without requiring Windows system libraries.
{ "first/probe.CMD" } [
    [
        "first" make-directory "second" make-directory
        "@exit /b 0" "first/probe.CMD" utf8 set-file-contents
        "stub" "second/probe.EXE" utf8 set-file-contents
        { ".EXE" ".CMD" } find-windows-probe
    ] with-test-directory
] unit-test

{ "first/probe.EXE" } [
    [
        "first" make-directory "second" make-directory
        "@exit /b 0" "first/probe.CMD" utf8 set-file-contents
        "stub" "first/probe.EXE" utf8 set-file-contents
        { ".EXE" ".CMD" } find-windows-probe
    ] with-test-directory
] unit-test

{ "first/probe.CMD" } [
    [
        "first" make-directory "second" make-directory
        "first/probe.EXE" make-directory
        "@exit /b 0" "first/probe.CMD" utf8 set-file-contents
        { ".EXE" ".CMD" } find-windows-probe
    ] with-test-directory
] unit-test

{ t } [
    [
        "@exit /b 0" "probe.CmD" utf8 set-file-contents
        "probe.CmD" { ".cmd" } windows-executable-file?
    ] with-test-directory
] unit-test
