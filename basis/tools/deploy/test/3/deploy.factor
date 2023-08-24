USING: tools.deploy.config ;
H{
    { deploy-unicode? f }
    { deploy-name "tools.deploy.test.3" }
    { deploy-ui? f }
    { "stop-after-last-window?" t }
    { deploy-word-defs? f }
    { deploy-reflection 1 }
    { deploy-threads? t }
    { deploy-io 3 }
    { deploy-math? t }
    { deploy-word-props? f }
    { deploy-c-types? f }
}
