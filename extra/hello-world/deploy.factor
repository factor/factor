USING: tools.deploy.config ;
V{
    { deploy-ui? f }
    { deploy-io 3 }
    { deploy-reflection 1 }
    { deploy-compiler? t }
    { deploy-math? f }
    { deploy-word-props? f }
    { deploy-c-types? f }
    { "stop-after-last-window?" t }
    { deploy-name "Hello world (console)" }
}
