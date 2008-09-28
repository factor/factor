USING: tools.deploy.config ;
H{
    { deploy-threads? f }
    { deploy-ui? f }
    { deploy-io 1 }
    { deploy-c-types? f }
    { deploy-name "tools.deploy.test.6" }
    { deploy-compiler? t }
    { deploy-reflection 1 }
    { deploy-word-props? f }
    { deploy-word-defs? f }
    { "stop-after-last-window?" t }
    { deploy-random? f }
    { deploy-math? f }
}
