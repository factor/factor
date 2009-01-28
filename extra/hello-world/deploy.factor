USING: tools.deploy.config ;
H{
    { deploy-name "Hello world (console)" }
    { deploy-c-types? f }
    { deploy-word-props? f }
    { deploy-ui? f }
    { deploy-reflection 1 }
    { deploy-compiler? f }
    { deploy-unicode? f }
    { deploy-io 2 }
    { deploy-word-defs? f }
    { deploy-threads? f }
    { "stop-after-last-window?" t }
    { deploy-math? f }
}
