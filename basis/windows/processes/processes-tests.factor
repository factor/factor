USING: io.files io.files.info io.pathnames kernel sequences system tools.test windows.processes ;
IN: windows.processes.tests

{ t t } [
    get-my-process-image-name
    [ file-exists? >boolean ] [ file-name vm-path file-name = ] bi
] unit-test
