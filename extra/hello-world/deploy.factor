USING: tools.deploy.config ;
H{
    { deploy-word-props? f }
    { deploy-random? f }
    { deploy-compiler? f }
    { deploy-c-types? f }
    { deploy-ui? f }
    { deploy-reflection 1 }
    { deploy-threads? f }
    { deploy-io 2 }
    { deploy-word-defs? f }
    { "stop-after-last-window?" t }
    { deploy-name "Hello world (console)" }
    { deploy-math? f }
}
