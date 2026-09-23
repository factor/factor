USING: io.files io.files.info io.pathnames kernel sequences tools.test windows.processes ;
IN: windows.processes.tests

{ t t } [
    get-my-process-image-name
    [ file-exists? >boolean ] [ file-name "factor.com" = ] bi
] unit-test
