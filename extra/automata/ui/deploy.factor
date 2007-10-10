USING: tools.deploy.config ;
V{
    { strip-prettyprint? t }
    { strip-globals? t }
    { strip-word-props? t }
    { strip-word-names? t }
    { strip-dictionary? t }
    { strip-debugger? t }
    { strip-c-types? t }
    { deploy-math? t }
    { deploy-compiled? t }
    { deploy-io? f }
    { deploy-ui? t }
    { "stop-after-last-window?" t }
    { "bundle-name" "Cellular Automata.app" }
}
