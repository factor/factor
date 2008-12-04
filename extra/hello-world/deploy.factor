USING: tools.deploy.config ;
H{
    { deploy-unicode? f }
    { deploy-reflection 1 }
    { deploy-word-props? f }
    { deploy-math? f }
    { deploy-name "Hello world (console)" }
    { deploy-word-defs? f }
    { "stop-after-last-window?" t }
    { deploy-ui? f }
    { deploy-compiler? f }
    { deploy-io 2 }
    { deploy-c-types? f }
}
