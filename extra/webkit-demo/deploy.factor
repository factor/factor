USING: tools.deploy.config ;
H{
    { deploy-ui? f }
    { deploy-compiler? t }
    { deploy-c-types? f }
    { deploy-reflection 1 }
    { deploy-name "WebKit demo" }
    { deploy-io 1 }
    { deploy-math? f }
    { deploy-word-props? f }
    { "stop-after-last-window?" t }
    { deploy-word-defs? f }
    { deploy-threads? f }
}
