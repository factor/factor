USING: tools.deploy.config ;
H{
    { deploy-name "joystick-demo" }
    { deploy-io 2 }
    { deploy-word-defs? f }
    { deploy-c-types? t }
    { deploy-word-props? f }
    { deploy-reflection 1 }
    { deploy-threads? t }
    { deploy-math? t }
    { "stop-after-last-window?" t }
    { deploy-ui? t }
}
