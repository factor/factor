USING: tools.deploy.config ;
H{
    { deploy-unicode? f }
    { deploy-ui? f }
    { deploy-name "Hello world (console)" }
    { deploy-io 2 }
    { deploy-threads? f }
    { deploy-reflection 1 }
    { deploy-math? f }
    { deploy-word-props? f }
    { deploy-word-defs? f }
    { deploy-c-types? f }
    { "stop-after-last-window?" t }
}
