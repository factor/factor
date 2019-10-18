USING: tools.deploy.config ;
H{
    { deploy-name "gpu.demos.bunny" }
    { deploy-word-defs? f }
    { deploy-io 3 }
    { "stop-after-last-window?" t }
    { deploy-math? t }
    { deploy-word-props? f }
    { deploy-threads? t }
    { deploy-c-types? f }
    { deploy-reflection 2 }
    { deploy-unicode? f }
    { deploy-ui? t }
}
