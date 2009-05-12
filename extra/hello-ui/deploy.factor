USING: tools.deploy.config ;
H{
    { deploy-c-types? f }
    { deploy-unicode? f }
    { deploy-word-defs? f }
    { deploy-name "Hello world" }
    { "stop-after-last-window?" t }
    { deploy-reflection 1 }
    { deploy-ui? t }
    { deploy-math? t }
    { deploy-io 1 }
    { deploy-word-props? f }
    { deploy-threads? t }
}
