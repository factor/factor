USING: tools.deploy.config ;
H{
    { deploy-name "Hello world" }
    { deploy-ui? t }
    { deploy-c-types? f }
    { deploy-unicode? f }
    { "stop-after-last-window?" t }
    { deploy-io 1 }
    { deploy-reflection 2 }
    { deploy-word-props? f }
    { deploy-math? t }
    { deploy-threads? t }
    { deploy-word-defs? f }
}
