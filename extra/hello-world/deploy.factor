USING: tools.deploy.config ;
H{
    { deploy-word-defs? f }
    { deploy-random? f }
    { deploy-name "Hello world (console)" }
    { deploy-threads? f }
    { deploy-compiler? f }
    { deploy-math? f }
    { deploy-c-types? f }
    { deploy-io 2 }
    { deploy-reflection 1 }
    { deploy-ui? f }
    { "stop-after-last-window?" t }
    { deploy-word-props? f }
}
