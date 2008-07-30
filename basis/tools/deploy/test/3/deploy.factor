USING: tools.deploy.config ;
H{
    { deploy-word-defs? f }
    { deploy-random? f }
    { deploy-name "tools.deploy.test.3" }
    { deploy-threads? t }
    { deploy-compiler? t }
    { deploy-math? t }
    { deploy-c-types? f }
    { deploy-io 3 }
    { deploy-reflection 1 }
    { deploy-ui? f }
    { "stop-after-last-window?" t }
    { deploy-word-props? f }
}
