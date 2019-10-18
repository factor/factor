USING: tools.deploy.config ;
V{
    { deploy-ui? t }
    { deploy-io 2 }
    { deploy-reflection 1 }
    { deploy-compiler? t }
    { deploy-math? t }
    { deploy-word-props? f }
    { deploy-word-defs? f }
    { deploy-c-types? f }
    { "stop-after-last-window?" t }
    { "bundle-name" "Belt Tire.app" }
}
