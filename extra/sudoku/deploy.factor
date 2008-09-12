USING: tools.deploy.config ;
H{
    { deploy-word-defs? f }
    { deploy-random? f }
    { deploy-name "Sudoku" }
    { deploy-threads? f }
    { deploy-compiler? t }
    { deploy-math? t }
    { deploy-c-types? f }
    { deploy-io 2 }
    { deploy-reflection 1 }
    { deploy-ui? f }
    { "stop-after-last-window?" t }
    { deploy-word-props? f }
}
