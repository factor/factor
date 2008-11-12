USING: tools.deploy.config ;
H{
    { deploy-c-types? f }
    { deploy-name "Hello world (console)" }
    { deploy-threads? f }
    { deploy-word-props? f }
    { deploy-reflection 2 }
    { deploy-io 2 }
    { deploy-math? f }
    { deploy-ui? f }
    { deploy-compiler? f }
    { "stop-after-last-window?" t }
    { deploy-word-defs? f }
}
