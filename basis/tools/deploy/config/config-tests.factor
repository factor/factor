USING: tools.deploy.config tools.test ;
IN: tools.deploy.config.tests

{ { "math" "threads" "compiler" "io" } } [
    "hello-ui" default-config config>profile
] unit-test
