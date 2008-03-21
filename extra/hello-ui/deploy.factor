USING: tools.deploy.config ;
H{
    { deploy-word-defs? f }
    { deploy-random? f }
    { deploy-name "Hello world" }
    { deploy-threads? t }
    { deploy-compiler? t }
    { deploy-math? t }
    { deploy-c-types? f }
    { deploy-io 1 }
    { deploy-reflection 1 }
    { deploy-ui? t }
    { "stop-after-last-window?" t }
    { deploy-word-props? f }
}
