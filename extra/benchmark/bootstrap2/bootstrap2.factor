USING: tools.deploy.private io.files system
tools.deploy.backend ;
IN: benchmark.bootstrap2

: bootstrap-benchmark
    "." resource-path cd
    vm { "-output-image=foo.image" "-no-user-init" } stage2 ;

MAIN: bootstrap-benchmark
