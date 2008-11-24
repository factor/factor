USING: tools.deploy.config ;
H{
    { deploy-threads? f }
    { deploy-name "Hello world (console)" }
    { deploy-word-defs? f }
    { deploy-word-props? f }
    { deploy-ui? f }
    { deploy-compiler? f }
    { deploy-io 2 }
    { deploy-math? f }
    { deploy-reflection 1 }
    { deploy-unicode? f }
    { "stop-after-last-window?" t }
    { deploy-c-types? f }
}
