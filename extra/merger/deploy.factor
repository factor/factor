USING: tools.deploy.config ;
H{
    { deploy-name "Merger" }
    { deploy-c-types? f }
    { "stop-after-last-window?" t }
    { deploy-unicode? f }
    { deploy-threads? t }
    { deploy-reflection 1 }
    { deploy-word-defs? f }
    { deploy-math? t }
    { deploy-ui? t }
    { deploy-word-props? f }
    { deploy-io 3 }
}
