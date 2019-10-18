nmap <silent> <Leader>fi :FactorVocabImpl<CR>
nmap <silent> <Leader>fd :FactorVocabDocs<CR>
nmap <silent> <Leader>ft :FactorVocabTests<CR>
nmap <Leader>fv :FactorVocab<SPACE>
nmap <Leader>fn :NewFactorVocab<SPACE>

if !exists("g:FactorRoot")
    let g:FactorRoot = "~/factor"
endif

if !exists("g:FactorVocabRoots")
    let g:FactorVocabRoots = ["core", "basis", "extra", "work"]
endif

if !exists("g:FactorNewVocabRoot")
    let g:FactorNewVocabRoot = "work"
endif

command! -nargs=1 -complete=customlist,FactorCompleteVocab FactorVocab :call GoToFactorVocab("<args>")
command! -nargs=1 -complete=customlist,FactorCompleteVocab NewFactorVocab :call MakeFactorVocab("<args>")
command! FactorVocabImpl  :call GoToFactorVocabImpl()
command! FactorVocabDocs  :call GoToFactorVocabDocs()
command! FactorVocabTests :call GoToFactorVocabTests()

function! FactorVocabRoot(root)
    let cwd = getcwd()
    exe "lcd " fnameescape(g:FactorRoot)
    let vocabroot = fnamemodify(a:root, ":p")
    exe "lcd " fnameescape(cwd)
    return vocabroot
endfunction

function! s:unique(list)
    let dict = {}
    for value in a:list
        let dict[value] = 1
    endfor
    return sort(keys(dict))
endfunction

function! FactorCompleteVocab(arglead, cmdline, cursorpos)
    let vocabs = []
    let vocablead = substitute(a:arglead, "\\.", "/", "g")
    for root in g:FactorVocabRoots
        let vocabroot = FactorVocabRoot(root)
        let newvocabs = globpath(vocabroot, vocablead . "*")
        if newvocabs != ""
            let newvocabsl = split(newvocabs, "\n")
            let newvocabsl = filter(newvocabsl, 'getftype(v:val) == "dir"')
            let newvocabsl = map(newvocabsl, 'substitute(v:val, "^\\V" . escape(vocabroot, "\\"), "\\1", "g")')
            let vocabs += newvocabsl
        endif
    endfor
    let vocabs = s:unique(vocabs)
    let vocabs = map(vocabs, 'substitute(v:val, "/\\|\\\\", ".", "g")')
    return vocabs
endfunction

function! FactorVocabFile(root, vocab, mustexist)
    let vocabpath = substitute(a:vocab, "\\.", "/", "g")
    let vocabfile = FactorVocabRoot(a:root) . vocabpath . "/" . fnamemodify(vocabpath, ":t") . ".factor"

    if !a:mustexist || getftype(vocabfile) != ""
        return vocabfile
    else
        return ""
    endif
endfunction

function! GoToFactorVocab(vocab)
    for root in g:FactorVocabRoots
        let vocabfile = FactorVocabFile(root, a:vocab, 1)
        if vocabfile != ""
            exe "edit " fnameescape(vocabfile)
            return
        endif
    endfor
    echo "Vocabulary " vocab " not found"
endfunction

function! MakeFactorVocab(vocab)
    let vocabfile = FactorVocabFile(g:FactorNewVocabRoot, a:vocab, 0)
    echo vocabfile
    let vocabdir = fnamemodify(vocabfile, ":h")
    echo vocabdir
    exe "!mkdir -p " shellescape(vocabdir)
    exe "edit " fnameescape(vocabfile)
endfunction

function! FactorFileBase()
    let filename = expand("%:r")
    let filename = substitute(filename, "-docs", "", "")
    let filename = substitute(filename, "-tests", "", "")
    return filename
endfunction

function! GoToFactorVocabImpl()
    exe "edit " fnameescape(FactorFileBase() . ".factor")
endfunction

function! GoToFactorVocabDocs()
    exe "edit " fnameescape(FactorFileBase() . "-docs.factor")
endfunction

function! GoToFactorVocabTests()
    exe "edit " fnameescape(FactorFileBase() . "-tests.factor")
endfunction
