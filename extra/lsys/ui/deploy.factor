USING: tools.deploy.config ;
V{
    { deploy-ui? t }
    { deploy-io 1 }
    { deploy-reflection 2 }
    { deploy-compiler? t }
    { deploy-math? t }
    { deploy-word-props? t }
    { deploy-word-defs? t }
    { deploy-c-types? f }
    { "stop-after-last-window?" t }
    { "bundle-name" "Lindenmayer System Explorer.app" }
}
