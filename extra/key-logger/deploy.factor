USING: tools.deploy.config ;
H{
    { deploy-name "key-logger" }
    { deploy-ui? f }
    { deploy-c-types? f }
    { deploy-console? f }
    { deploy-unicode? f }
    { "stop-after-last-window?" t }
    { deploy-io 3 }
    { deploy-reflection 1 }
    { deploy-word-props? f }
    { deploy-math? t }
    { deploy-threads? t }
    { deploy-word-defs? f }
}
