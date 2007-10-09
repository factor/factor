USING: tools.deploy.config ;
V{
    { strip-prettyprint? t }
    { strip-globals? t }
    { strip-word-props? t }
    { strip-word-names? t }
    { strip-dictionary? t }
    { strip-debugger? t }
    { strip-c-types? t }
    { deploy-math? f }
    { deploy-compiled? f }
    { deploy-io? f }
    { deploy-ui? f }
    { "stop-after-last-window?" t }
}
