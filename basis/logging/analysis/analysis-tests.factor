USING: io.directories io.encodings.utf8 io.files io.files.temp
io.files.unique io.pathnames io.streams.string kernel locals
logging.analysis logging.server namespaces sequences splitting tools.test ;
IN: logging.analysis.tests

:: report-fixture ( text limit -- report )
    [
        [
            current-directory get [
                "report" log-path make-directories
                text "report" log-path 1 log# utf8 set-file-contents
                limit log-report-limit [
                    [ "report" { "hit" } analyze-log-file ] with-string-writer
                ] with-variable
            ] with-log-root
        ] cleanup-unique-directory
    ] with-temp-directory ;

{ t t f } [
    "[2026-09-12T14:00:00Z] NOTICE hit: retained\n" 1024 report-fixture
    [ "retained" swap subseq? ]
    [ "NOTICE hit" swap subseq? ]
    [ "Partial log report" swap subseq? ] tri
] unit-test

{ t t f } [
    "[2026-09-12T14:00:00Z] NOTICE hit: discarded\n[2026-09-12T14:00:00Z] NOTICE hit: retained\n"
    40 report-fixture
    [ "Partial log report" swap subseq? ]
    [ "retained" swap subseq? ]
    [ "discarded" swap subseq? ] tri
] unit-test

{ t } [
    "a single oversized line without a newline" 4 report-fixture
    "Partial log report" swap subseq?
] unit-test
