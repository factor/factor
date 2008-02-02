USING: io.files io.launcher system tools.deploy.backend
namespaces sequences kernel ;
IN: benchmark.bootstrap2

: bootstrap-benchmark
    "." resource-path cd
    [
        vm ,
        "-i=" boot-image-name append ,
        "-output-image=foo.image" ,
        "-no-user-init" ,
    ] { } make run-process drop ;

MAIN: bootstrap-benchmark
