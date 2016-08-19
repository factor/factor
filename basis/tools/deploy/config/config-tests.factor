USING: tools.deploy.config tools.test ;
IN: tools.deploy.config.tests

! config>profile
{
    { "math" "threads" "compiler" "io" }
    { "math" "threads" "compiler" "io" "ui" "unicode" "help" }
} [
    "hello-ui" default-config config>profile

    H{
        { deploy-console? t }
        { deploy-io 3 }
        { deploy-reflection 6 }
        { deploy-ui? t }
        { deploy-word-defs? t }
        { deploy-threads? t }
        { "stop-after-last-window?" t }
        { deploy-math? t }
        { deploy-word-props? t }
        { deploy-c-types? t }
        { deploy-help? t }
        { deploy-name "deploytest" }
        { deploy-unicode? t }
    } config>profile
] unit-test
