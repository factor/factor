USING: tools.deploy.config ;
H{
    { deploy-c-types? f }
    { deploy-name "tools.deploy.test.1" }
    { deploy-io 2 }
    { deploy-random? f }
    { deploy-math? t }
    { deploy-compiler? t }
    { deploy-reflection 2 }
    { "stop-after-last-window?" t }
    { deploy-threads? t }
    { deploy-ui? f }
    { deploy-word-props? f }
    { deploy-word-defs? f }
}
