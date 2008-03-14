USING: tools.deploy.config ;
H{
    { deploy-name "Sudoku" }
    { deploy-threads? f }
    { deploy-c-types? f }
    { deploy-compiler? t }
    { deploy-ui? f }
    { deploy-math? f }
    { deploy-reflection 1 }
    { deploy-word-defs? f }
    { deploy-io 2 }
    { deploy-word-props? f }
    { "stop-after-last-window?" t }
}
