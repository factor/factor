USING: accessors bunny.fixed-pipeline destructors kernel tools.test ;
IN: bunny.fixed-pipeline.tests

{ t } [
    f <bunny-fixed-pipeline> dup dispose
    dup dispose disposed>>
] unit-test
