" Vim syntax file
" Language:	factor
" Maintainer:	Alex Chapman <chapman.alex@gmail.com>
" Last Change:	2007 Jan 18

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" factor is case sensitive.
syn case match

" make all of these characters part of a word (useful for skipping over words with w, e, and b)
if version >= 600
    setlocal iskeyword=!,@,33-35,%,$,38-64,A-Z,91-96,a-z,123-126,128-255
else
    set iskeyword=!,@,33-35,%,$,38-64,A-Z,91-96,a-z,123-126,128-255
endif

syn cluster factorCluster contains=factorComment,factorKeyword,factorRepeat,factorConditional,factorBoolean,factorString,factorSbuf,@factorNumber,@factorNumErr,factorDelimiter,factorChar,factorCharErr,factorBackslash,@factorWordOps,factorAlien,factorTuple

syn match factorTodo /\(TODO\|FIXME\|XXX\):\=/ contained
syn match factorComment /\<#! .*/ contains=factorTodo
syn match factorComment /\<! .*/ contains=factorTodo

syn region None matchgroup=factorDefinition start=/\<\(C\|M\|G\|UNION\|PREDICATE\)\?:\>/ end=/\<;\>/ contains=@factorCluster,factorStackEffect,factorStackEffectErr,factorArray0,factorQuotation0

syn region None matchgroup=factorGeneric start=/\<GENERIC:\>/ end=/$/ contains=factorStackEffect,factorStackEffectErr

syn keyword factorBoolean boolean f general-t t
syn keyword factorCompileDirective inline foldable parsing



" kernel vocab keywords
syn keyword factorKeyword continuation-name set-datastack wrapper continuation-catch set-continuation-name slip pick 2slip 2nip tuple set-boot clone with-datastack cpu -roll tuck -rot (continue) set-continuation-retain swapd <continuation> >boolean wrapper? dupd 3dup dup ifcc callstack windows? os-env = over continuation alist>quot ? <wrapper> 2dup cond win64? <quotation> continue 3drop hashcode quotation xor when curry millis set-callstack unless >r die version callcc0 or os callcc1 get-walker-hook depth equal? 3keep no-cond? continue-with if exit tuple? set-retainstack unix? (continue-with) general-t continuation? 3slip <no-cond> macosx? r> rot win32? retainstack 2apply >quotation >continuation< type continuation-call clear call drop continuation-data set-continuation-call 2drop no-cond unit set-continuation-data keep-datastack and when* quotation? ?if literalize datastack swap unless* 2swap set-continuation-catch eq? not roll set-walker-hook continuation-retain with make-dip wrapped keep 2keep <=> if* nip 
syn keyword factorKeyword sin integer? log2 cot oct> number>string integer first-bignum sech abs repeat tanh real? vmin norm-sq neg between? asech >rect bignum? atanh -i * + fp-nan? - small / sqrt infimum fix-float cosech even? v*n < bits>double > most-positive-fixnum ^theta numerator digit+ >base (random-int) acosech cosh min pi number vmax zero? sum digit> rem bitor supremum string>integer most-negative-fixnum >polar >fraction ceiling acos acot ^ asin acosh /f ratio e fixnum? /i ^n cis coth 1+ 1- conjugate sinh acosec i number= number? double>bits epsilon float product string>number n/v norm max tan acoth absq float? asinh denominator rational? fixnum rect> >fixnum imaginary recip exp sec bitxor w>h/h >bin align base> times log <= [-] init-random sq odd? (repeat) [v-] ^mag bitnot ratio? random-int >digit (next-power-of-2) v* v+ v- v. v/ >float [-1,1]? arg small? bitand set-axis >oct v/n complex rational shift (^) polar> (gcd) cosec next-power-of-2 >float-rect atan sgn >= float>bits normalize real bin> complex? gcd d>w/w hex> mod string>ratio asec floor n*v >hex truncate bits>float vneg >bignum bignum power-of-2? integer, /mod (string>integer) cos 
syn keyword factorKeyword second sort-values all-eq? pop* find slice-error-reason inject-with prune remove (group) split1-slice slice-error (slice*) split* head-slice* find* split, first remove-nth hash-prune push-if ?push reverse subseq split1 diff subset split new padding column? copy-into-check column@ <column> peek last/first add find-last ?nth add* slice-from cache-nth subseq? <reversed> <slice-error> (3append) replace-slice reversed-seq find-last-with empty? ((append)) reversed? reversed@ map-with find-last-with* set-slice-error-reason set-column-col natural-sort (subst) set-slice-seq index* concat push binsearch slice-seq 3append nsort length tail-slice* reversed ?head sequence= ?tail sequence? memq? join split-next, delete set-nth subst monotonic? group map flip unclip set-reversed-seq find-last* start* max-length assoc min-length all-equal? all? pad-left contains? inject slice <slice> first2 first3 first4 exchange bounds-check? column-seq check-slice pad-right each subset-with unpair tail head interleave (delete) copy-into sort sequence reduce set-slice-from set-slice-to 2map (cut) member? cut rassoc (append) last-index* sort-keys change-nth 2each >sequence nth tail* head* third tail-slice set-length collapse-slice column (mismatch) contains-with? push-new pop tail? head? slice? slice@ delete-all binsearch* move find-with* 2reduce slice-to find-with like slice-error? set-column-seq nappend column-col cut* (split) index each-with last-index fourth append accumulate drop-prefix mismatch head-slice all-with? start 
syn keyword factorKeyword namespace-error-object inc dec make off bind get-global init-namespaces set-global namespace on ndrop namespace-error? namestack namespace-error +@ # % make-hash global , set-namestack with-scope building <namespace-error> change nest set-namespace-error-object get set counter 
syn keyword factorKeyword array <array> pair byte-array pair? 1array 2array resize-array 4array 3array byte-array? <byte-array> array? >array 
syn keyword factorKeyword cwd duplex-stream pathname? set-pathname-string with-log-file directory duplex-stream-out format <nested-style-stream> (readln) duplex-stream? read1 with-stream-style c-stream-error? <file-reader> stream-write1 with-stream line-reader? set-duplex-stream-out server? cr> <check-closed> directory? log-message flush format-column stream-readln nested-style-stream? <line-reader> <file-r/w> set-timeout write-pathname file-modified duplex-stream-closed? print set-duplex-stream-closed? pathname line-reader ?resource-path terpri write-object le> string-out stream-terpri log-client do-nested-style path+ <c-stream-error> set-client-stream-host plain-writer? server-stream resource-path >be parent-dir with-stream* <file-writer> server-loop string-in nested-style-stream stream-close stream-copy c-stream-error <client-stream> with-style client-stream-host stat plain-writer file-length contents <string-reader> stream-read stream-format check-closed? set-client-stream-port <duplex-stream> <server> write1 bl write-outliner map-last (with-stream-style) set-line-reader-cr tabular-output (lines) stream-write log-stream server-client (stream-copy) with-nested-stream lines readln cd client-stream nth-byte with-logging stream-read1 nested-style-stream-style accept check-closed client-stream-port do-nested-quot pathname-string set-nested-style-stream-style read home close with-stream-table stdio be> log-error duplex-stream-out+ server stream-flush set-duplex-stream-in line-reader-cr >le with-client <client> <pathname> <string-writer> (directory) set-server-client stream-print with-server exists? <plain-writer> with-nesting string-lines write duplex-stream-in client-stream? duplex-stream-in+ 
syn keyword factorKeyword sbuf ch>upper string? LETTER? >sbuf >lower quotable? string>sbuf blank? string sbuf? printable? >string letter? resize-string control? alpha? <string> >upper Letter? ch>lower digit? <sbuf> ch>string 
syn keyword factorKeyword <vector> >vector array>vector vector? vector 
syn keyword factorKeyword set-restart-continuation cleanup error-hook restart-name restarts. stack-underflow. expired-error. restart restart? word-xt. (:help-none) set-catchstack c-string-error. condition <assert> debug-help :get datastack-overflow. set-condition-restarts condition? error. objc-error. print-error assert :res catchstack rethrow assert= kernel-error restart-obj assert? undefined-symbol-error. retainstack-overflow. restarts error-help divide-by-zero-error. ffi-error. signal-error. (:help-multi) set-restart-obj xt. memory-error. retainstack-underflow. set-condition-continuation datastack-underflow. try assert-depth error-continuation error-stack-trace assert-expect recover :edit kernel-error? error callstack-overflow. stack-overflow. callstack-underflow. set-assert-got set-restart-name restart-continuation condition-restarts heap-scan-error. :help type-check-error. <condition> assert-got throw negative-array-size-error. :c condition-continuation :trace undefined-word-error. io-error. parse-dump <restart> set-assert-expect :r :s compute-restarts catch restart. 


syn cluster factorReal   contains=factorInt,factorFloat,factorRatio,factorBinary,factorHex,factorOctal
syn cluster factorNumber contains=@factorReal,factorComplex
syn cluster factorNumErr contains=factorBinErr,factorHexErr,factorOctErr
syn match   factorInt 		/\<-\=\d\+\>/
syn match   factorFloat		/\<-\=\d*\.\d\+\>/
syn match   factorRatio		/\<-\=\d*\.*\d\+\/-\=\d*\.*\d\+\>/
syn region  factorComplex	start=/\<C{\>/ end=/\<}\>/ contains=@factorReal
syn match   factorBinErr        /\<BIN:\s\+[01]*[^\s01]\S*\>/
syn match   factorBinary        /\<BIN:\s\+[01]\+\>/
syn match   factorHexErr        /\<HEX:\s\+\x*[^\x\s]\S*\>/
syn match   factorHex           /\<HEX:\s\+\x\+\>/
syn match   factorOctErr        /\<OCT:\s\+\o*[^\o\s]\S*\>/
syn match   factorOctal         /\<OCT:\s\+\o\+\>/

syn match factorIn /\<IN:\s\+\S\+\>/
syn match factorUse /\<USE:\s\+\S\+\>/

syn match factorCharErr /\<CHAR:\s\+\S\+/
syn match factorChar /\<CHAR:\s\+\\\=\S\>/

syn match factorBackslash /\<\\\>\s\+\S\+\>/

syn region factorUsing start=/\<USING:\>/ end=/;/
syn region factorRequires start=/\<REQUIRES:\>/ end=/;/

syn cluster factorWordOps contains=factorSymbol,factorPostpone,factorDefer,factorForget
syn match factorSymbol /\<SYMBOL:\s\+\S\+\>/
syn match factorPostpone /\<POSTPONE:\s\+\S\+\>/
syn match factorDefer /\<DEFER:\s\+\S\+\>/
syn match factorForget /\<FORGET:\s\+\S\+\>/

syn match factorAlien /\<ALIEN:\s\+\d\+\>/

syn region factorTuple start=/\<TUPLE:\>/ end=/\<;\>/

"TODO:
"misc:
" HELP:
" ARTICLE:
" PROVIDE:
" MAIN:
"literals:
" PRIMITIVE:

"C interface:
" FIELD:
" BEGIN-STRUCT:
" C-ENUM:
" FUNCTION:
" END-STRUCT
" DLL"
" TYPEDEF:
" LIBRARY:
" C-UNION:

syn region factorString start=/"/ skip=/\\"/ end=/"/ oneline
syn region factorSbuf start=/SBUF" / skip=/\\"/ end=/"/ oneline

syn match factorStackEffectErr /\<)\>/
syn region factorStackEffectErr start=/\<(\>/ end=/\<)\>/
syn region factorStackEffect start=/\<(\>/ end=/\<)\>/ contained

"adapted from lisp.vim
if exists("g:factor_norainbow") 
    syn region factorQuotation matchgroup=factorDelimiter start=/\<\[\>/ matchgroup=factorDelimiter end=/\<\]\>/ contains=ALL
else
    syn region factorQuotation0           matchgroup=hlLevel0 start=/\<\[\>/ end=/\<\]\>/ contains=@factorCluster,factorQuotation1,factorArray1
    syn region factorQuotation1 contained matchgroup=hlLevel1 start=/\<\[\>/ end=/\<\]\>/ contains=@factorCluster,factorQuotation2,factorArray2
    syn region factorQuotation2 contained matchgroup=hlLevel2 start=/\<\[\>/ end=/\<\]\>/ contains=@factorCluster,factorQuotation3,factorArray3
    syn region factorQuotation3 contained matchgroup=hlLevel3 start=/\<\[\>/ end=/\<\]\>/ contains=@factorCluster,factorQuotation4,factorArray4
    syn region factorQuotation4 contained matchgroup=hlLevel4 start=/\<\[\>/ end=/\<\]\>/ contains=@factorCluster,factorQuotation5,factorArray5
    syn region factorQuotation5 contained matchgroup=hlLevel5 start=/\<\[\>/ end=/\<\]\>/ contains=@factorCluster,factorQuotation6,factorArray6
    syn region factorQuotation6 contained matchgroup=hlLevel6 start=/\<\[\>/ end=/\<\]\>/ contains=@factorCluster,factorQuotation7,factorArray7
    syn region factorQuotation7 contained matchgroup=hlLevel7 start=/\<\[\>/ end=/\<\]\>/ contains=@factorCluster,factorQuotation8,factorArray8
    syn region factorQuotation8 contained matchgroup=hlLevel8 start=/\<\[\>/ end=/\<\]\>/ contains=@factorCluster,factorQuotation9,factorArray9
    syn region factorQuotation9 contained matchgroup=hlLevel9 start=/\<\[\>/ end=/\<\]\>/ contains=@factorCluster,factorQuotation0,factorArray0
endif

if exists("g:factor_norainbow") 
    syn region factorArray    matchgroup=factorDelimiter start=/\<\(V\|H\|T\|W\)\?{\>/  matchgroup=factorDelimiter end=/\<}\>/ contains=ALL
else
    syn region factorArray0           matchgroup=hlLevel0 start=/\<\(V\|H\|T\|W\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray1,factorQuotation1
    syn region factorArray1 contained matchgroup=hlLevel1 start=/\<\(V\|H\|T\|W\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray2,factorQuotation2
    syn region factorArray2 contained matchgroup=hlLevel2 start=/\<\(V\|H\|T\|W\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray3,factorQuotation3
    syn region factorArray3 contained matchgroup=hlLevel3 start=/\<\(V\|H\|T\|W\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray4,factorQuotation4
    syn region factorArray4 contained matchgroup=hlLevel4 start=/\<\(V\|H\|T\|W\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray5,factorQuotation5
    syn region factorArray5 contained matchgroup=hlLevel5 start=/\<\(V\|H\|T\|W\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray6,factorQuotation6
    syn region factorArray6 contained matchgroup=hlLevel6 start=/\<\(V\|H\|T\|W\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray7,factorQuotation7
    syn region factorArray7 contained matchgroup=hlLevel7 start=/\<\(V\|H\|T\|W\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray8,factorQuotation8
    syn region factorArray8 contained matchgroup=hlLevel8 start=/\<\(V\|H\|T\|W\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray9,factorQuotation9
    syn region factorArray9 contained matchgroup=hlLevel9 start=/\<\(V\|H\|T\|W\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray0,factorQuotation0
endif

syn match factorBracketErr /\<\]\>/
syn match factorBracketErr /\<}\>/

syn sync lines=100

if version >= 508 || !exists("did_factor_syn_inits")
    if version <= 508
	let did_factor_syn_inits = 1
	command -nargs=+ HiLink hi link <args>
    else
	command -nargs=+ HiLink hi def link <args>
    endif

    HiLink factorComment	Comment
    HiLink factorStackEffect	Typedef
    HiLink factorTodo		Todo
    HiLink factorInclude	Include
    HiLink factorRepeat		Repeat
    HiLink factorConditional	Conditional
    HiLink factorKeyword	Keyword
    HiLink factorOperator	Operator
    HiLink factorBoolean	Boolean
    HiLink factorDefinition	Typedef
    HiLink factorString		String
    HiLink factorSbuf		String
    HiLink factorBracketErr     Error
    HiLink factorStackEffectErr Error
    HiLink factorComplex	Number
    HiLink factorRatio          Number
    HiLink factorBinary         Number
    HiLink factorBinErr         Error
    HiLink factorHex            Number
    HiLink factorHexErr         Error
    HiLink factorOctal          Number
    HiLink factorOctErr         Error
    HiLink factorFloat		Float
    HiLink factorInt		Number
    HiLink factorUsing          Include
    HiLink factorUse            Include
    HiLink factorRequires       Include
    HiLink factorIn             Define
    HiLink factorChar           Character
    HiLink factorCharErr        Error
    HiLink factorDelimiter      Delimiter
    HiLink factorBackslash      Special
    HiLink factorCompileDirective Keyword
    HiLink factorSymbol         Define
    HiLink factorPostpone       Define
    HiLink factorDefer          Define
    HiLink factorForget         Define
    HiLink factorAlien          Define
    HiLink factorTuple          Typedef
    HiLink factorGeneric        Define

    if &bg == "dark"
	hi   hlLevel0 ctermfg=red         guifg=red1
	hi   hlLevel1 ctermfg=yellow      guifg=orange1
	hi   hlLevel2 ctermfg=green       guifg=yellow1
	hi   hlLevel3 ctermfg=cyan        guifg=greenyellow
	hi   hlLevel4 ctermfg=magenta     guifg=green1
	hi   hlLevel5 ctermfg=red         guifg=springgreen1
	hi   hlLevel6 ctermfg=yellow      guifg=cyan1
	hi   hlLevel7 ctermfg=green       guifg=slateblue1
	hi   hlLevel8 ctermfg=cyan        guifg=magenta1
	hi   hlLevel9 ctermfg=magenta     guifg=purple1
    else
	hi   hlLevel0 ctermfg=red         guifg=red3
	hi   hlLevel1 ctermfg=darkyellow  guifg=orangered3
	hi   hlLevel2 ctermfg=darkgreen   guifg=orange2
	hi   hlLevel3 ctermfg=blue        guifg=yellow3
	hi   hlLevel4 ctermfg=darkmagenta guifg=olivedrab4
	hi   hlLevel5 ctermfg=red         guifg=green4
	hi   hlLevel6 ctermfg=darkyellow  guifg=paleturquoise3
	hi   hlLevel7 ctermfg=darkgreen   guifg=deepskyblue4
	hi   hlLevel8 ctermfg=blue        guifg=darkslateblue
	hi   hlLevel9 ctermfg=darkmagenta guifg=darkviolet
    endif

    delcommand HiLink
endif

let b:current_syntax = "factor"

set sw=4
set ts=4
set expandtab
set autoindent " annoying?

" vim: syntax=vim
