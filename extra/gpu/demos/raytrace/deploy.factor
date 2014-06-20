USING: tools.deploy.config ;
H{
    { deploy-name "Raytrace" }
    { deploy-ui? t }
    { deploy-c-types? f }
    { deploy-console? f }
    { deploy-unicode? f }
    { "stop-after-last-window?" t }
    { deploy-io 3 }
    { deploy-reflection 2 }
    { deploy-word-props? f }
    { deploy-math? t }
    { deploy-threads? t }
    { deploy-word-defs? f }
}
