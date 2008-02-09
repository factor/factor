USING: io.files io.launcher system bootstrap.image
namespaces sequences kernel ;
IN: benchmark.bootstrap2

: bootstrap-benchmark
    "." resource-path cd
    [
        vm ,
        "-i=" my-boot-image-name append ,
        "-output-image=foo.image" ,
        "-no-user-init" ,
    ] { } make try-process ;

MAIN: bootstrap-benchmark
