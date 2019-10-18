
" Vim syntax file
" Language: Factor
" Maintainer: Alex Chapman <chapman.alex@gmail.com>
" Last Change: 2012 Jul 11
" To run: USING: html.templates html.templates.fhtml ; "resource:misc/factor.vim.fgen" <fhtml> call-template

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif

" Factor is case sensitive.
syn case match

" Make all of these characters part of a word (useful for skipping over words with w, e, and b)
if version >= 600
    setlocal iskeyword=!,@,33-35,%,$,38-64,A-Z,91-96,a-z,123-126,128-255
else
    set iskeyword=!,@,33-35,%,$,38-64,A-Z,91-96,a-z,123-126,128-255
endif

syn cluster factorCluster contains=factorComment,factorFrySpecifier,factorKeyword,factorRepeat,factorConditional,factorBoolean,factorBreakpoint,factorDeclaration,factorCallQuotation,factorExecute,factorCallNextMethod,factorString,factorTriString,factorSbuf,@factorNumber,@factorNumErr,factorDelimiter,factorChar,factorBackslash,factorMBackslash,factorLiteral,factorLiteralBlock,@factorWordOps,factorAlien,factorSlot,factorTuple,factorError,factorStruct

syn match factorTodo /\(TODO\|FIXME\|XXX\):\=/ contained
syn match factorComment /\<#\?!\>.*/ contains=factorTodo,@Spell
syn match factorShebang /\%\^#!.*/ display
syn match factorShebangErr /\%\^#!\S\+/

syn cluster factorDefnContents contains=@factorCluster,factorStackEffect,factorLiteralStackEffect,factorArray0,factorQuotation0

syn region factorDefn matchgroup=factorDefnDelims start=/\<\(SYNTAX\|\(MACRO\|MEMO\|TYPED\)\?:\?\):\s\+\S\+\>/ end=/\<;\>/ contains=@factorDefnContents
syn region factorMethod matchgroup=factorMethodDelims start=/\<M::\?\s\+\S\+\s\+\S\+\>/ end=/\<;\>/ contains=@factorDefnContents
syn region factorGeneric matchgroup=factorGenericDelims start=/\<\(GENERIC\|MATH\|PRIMITIVE\):\s\+\S\+\>/ end=/$/ contains=factorStackEffect
syn region factorGenericN matchgroup=factorGenericNDelims start=/\<GENERIC#:\s\+\S\+\s\+\d\+\>/ end=/$/ contains=factorStackEffect

syn region factorPrivateDefn matchgroup=factorPrivateDefnDelims start=/\<\(SYNTAX\|\(MACRO\|MEMO\|TYPED\)\?:\?\):\s\+\S\+\>/ end=/\<;\>/ contains=@factorDefnContents contained
syn region factorPrivateMethod matchgroup=factorPrivateMethodDelims start=/\<M::\?\s\+\S\+\s\+\S\+\>/ end=/\<;\>/ contains=@factorDefnContents contained
syn region factorPGeneric matchgroup=factorPGenericDelims start=/\<\(GENERIC\|MATH\|PRIMITIVE\):\s\+\S\+\>/ end=/$/ contains=factorStackEffect contained
syn region factorPGenericN matchgroup=factorPGenericNDelims start=/\<GENERIC#:\s\+\S\+\s\+\d\+\>/ end=/$/ contains=factorStackEffect contained

syn region None matchgroup=factorPrivate start=/\<<PRIVATE\>/ end=/\<PRIVATE>\>/ contains=@factorDefnContents,factorPrivateDefn,factorPrivateMethod,factorPGeneric,factorPGenericN


syn keyword factorBoolean f t
syn keyword factorBreakpoint B
syn keyword factorFrySpecifier @ _ contained
syn keyword factorDeclaration delimiter deprecated final flushable foldable inline recursive
syn match factorCallQuotation /\<call(\s\+\(\S*\s\+\)*--\(\s\+\S*\)*\s\+)\>/ contained contains=factorStackEffect
syn match factorExecute /\<execute(\s\+\(\S*\s\+\)*--\(\s\+\S*\)*\s\+)\>/ contained contains=factorStackEffect
syn keyword factorCallNextMethod call-next-method

syn keyword factorKeyword (clone) -roll -rot -rotd 2bi 2bi* 2bi@ 2curry 2dip 2drop 2dup 2keep 2keepd 2nip 2nipd 2over 2tri 2tri* 2tri@ 2with 3bi 3curry 3dip 3drop 3dup 3keep 3nip 3nipd 3tri 4dip 4drop 4dup 4keep 4nip 5drop 5nip <wrapper> = >boolean ? ?if and assert assert= assert? bi bi* bi-curry bi-curry* bi-curry@ bi@ boa boolean boolean? both? build call callstack callstack>array callstack? clear clone compose composed composed? curried curried? curry die dip do drop dup dupd either? eq? equal? execute get-callstack get-datastack get-retainstack hashcode hashcode* identity-hashcode identity-tuple identity-tuple? if if* keep keepd keepdd loop most new nip nipd not null object or over overd pick pickd prepose reach roll rot rotd same? spin swap swapd throw tri tri* tri-curry tri-curry* tri-curry@ tri@ tuck tuple tuple? unless unless* until when when* while with wrapper wrapper? xor
syn keyword factorKeyword 2cache <enumerated> >alist ?at ?of assoc assoc-all? assoc-any? assoc-clone-like assoc-combine assoc-diff assoc-diff! assoc-differ assoc-each assoc-empty? assoc-filter assoc-filter! assoc-filter-as assoc-find assoc-hashcode assoc-intersect assoc-like assoc-map assoc-map-as assoc-partition assoc-refine assoc-reject assoc-reject! assoc-reject-as assoc-size assoc-stack assoc-subset? assoc-union assoc-union! assoc-union-as assoc= assoc>map assoc? at at* at+ cache change-at clear-assoc collect-by delete-at delete-at* enumerated enumerated? extract-keys harvest-keys harvest-values inc-at key? keys map>alist map>assoc maybe-set-at new-assoc of push-at rename-at set-at sift-keys sift-values substitute unzip value-at value-at* value? values zip zip-as zip-index zip-index-as
syn keyword factorKeyword 2cleave 2cleave>quot 3cleave 3cleave>quot 4cleave 4cleave>quot alist>quot call-effect case case-find case>quot cleave cleave>quot cond cond>quot deep-spread>quot execute-effect linear-case-quot no-case no-case? no-cond no-cond? recursive-hashcode shallow-spread>quot spread to-fixed-point wrong-values wrong-values?
syn keyword factorKeyword (all-integers?) (each-integer) (find-integer) * + - / /f /i /mod 2/ 2^ < <= <fp-nan> > >= >bignum >fixnum >float >fraction >integer >rect ?1+ abs align all-integers? bignum bignum? bit? bitand bitnot bitor bits>double bits>float bitxor complex complex? denominator double>bits each-integer even? find-integer find-last-integer fixnum fixnum? float float>bits float? fp-bitwise= fp-infinity? fp-nan-payload fp-nan? fp-qnan? fp-sign fp-snan? fp-special? gcd if-zero imaginary-part integer integer>fixnum integer>fixnum-strict integer? log2 log2-expects-positive log2-expects-positive? mod neg neg? next-float next-power-of-2 number number= number? numerator odd? power-of-2? prev-float ratio ratio? rational rational? real real-part real? recip rect> rem sgn shift simple-gcd sq times u< u<= u> u>= unless-zero unordered? when-zero zero?
syn keyword factorKeyword 1sequence 2all? 2each 2each-from 2map 2map-as 2map-reduce 2reduce 2selector 2sequence 3append 3append-as 3each 3map 3map-as 3sequence 4sequence <iota> <repetition> <reversed> <slice> ?first ?last ?nth ?second ?set-nth accumulate accumulate! accumulate* accumulate*! accumulate*-as accumulate-as all? any? append append! append-as assert-sequence assert-sequence= assert-sequence? binary-reduce bounds-check bounds-check? bounds-error bounds-error? but-last but-last-slice cartesian-each cartesian-map cartesian-product change-nth check-slice clone-like collapse-slice collector collector-as collector-for collector-for-as concat concat-as copy count cut cut* cut-slice delete-all delete-slice drop-prefix each each-from each-index empty? exchange filter filter! filter-as find find-from find-index find-index-from find-last find-last-from first first2 first3 first4 flip follow fourth glue halves harvest head head* head-slice head-slice* head? if-empty immutable immutable-sequence immutable-sequence? immutable? index index-from indices infimum infimum-by insert-nth interleave iota iota? join join-as last last-index last-index-from length lengthen like longer longer? longest map map! map-as map-find map-find-last map-index map-index-as map-integers map-reduce map-sum max-length member-eq? member? midpoint@ min-length mismatch move new-like new-resizable new-sequence non-negative-integer-expected non-negative-integer-expected? none? nth nths pad-head pad-tail padding partition pop pop* prefix prepend prepend-as produce produce-as product push push-all push-either push-if reduce reduce-index reject reject! reject-as remove remove! remove-eq remove-eq! remove-nth remove-nth! repetition repetition? replace-slice replicate replicate-as rest rest-slice reverse reverse! reversed reversed? second selector selector-as sequence sequence-hashcode sequence= sequence? set-first set-fourth set-last set-length set-nth set-second set-third short shorten shorter shorter? shortest sift slice slice-error slice-error? slice? snip snip-slice subseq subseq-as subseq-start subseq-start-from subseq? suffix suffix! sum sum-lengths supremum supremum-by surround tail tail* tail-slice tail-slice* tail? third trim trim-head trim-head-slice trim-slice trim-tail trim-tail-slice unclip unclip-last unclip-last-slice unclip-slice unless-empty virtual-exemplar virtual-sequence virtual-sequence? virtual@ when-empty
syn keyword factorKeyword +@ change change-global counter dec get get-global get-namestack global inc init-namespaces initialize namespace off on set set-global set-namestack toggle with-global with-scope with-variable with-variable-off with-variable-on with-variables
syn keyword factorKeyword 1array 2array 3array 4array <array> >array array array? pair pair? resize-array
syn keyword factorKeyword (each-stream-block) (each-stream-block-slice) (stream-contents-by-block) (stream-contents-by-element) (stream-contents-by-length) (stream-contents-by-length-or-block) +byte+ +character+ bad-seek-type bad-seek-type? bl contents each-block each-block-size each-block-slice each-line each-morsel each-stream-block each-stream-block-slice each-stream-line error-stream flush input-stream input-stream? invalid-read-buffer invalid-read-buffer? lines nl output-stream output-stream? print read read-into read-partial read-partial-into read-until read1 readln seek-absolute seek-absolute? seek-end seek-end? seek-input seek-output seek-relative seek-relative? stream-bl stream-contents stream-contents* stream-copy stream-copy* stream-element-type stream-flush stream-length stream-lines stream-nl stream-print stream-read stream-read-into stream-read-partial stream-read-partial-into stream-read-partial-unsafe stream-read-unsafe stream-read-until stream-read1 stream-readln stream-seek stream-seekable? stream-tell stream-write stream-write1 tell-input tell-output with-error-stream with-error-stream* with-error>output with-input-output+error-streams with-input-output+error-streams* with-input-stream with-input-stream* with-output+error-stream with-output+error-stream* with-output-stream with-output-stream* with-output>error with-streams with-streams* write write1
syn keyword factorKeyword 1string <string> >string resize-string string string?
syn keyword factorKeyword 1vector <vector> >vector ?push vector vector?
syn keyword factorKeyword <condition> <continuation> <restart> attempt-all attempt-all-error attempt-all-error? callback-error-hook callcc0 callcc1 cleanup compute-restarts condition condition? continuation continuation? continue continue-restart continue-with current-continuation error error-continuation error-in-thread error-thread ifcc ignore-error ignore-error/f ignore-errors in-callback? original-error recover restart restart? restarts rethrow rethrow-restarts return return-continuation thread-error-hook throw-continue throw-restarts with-datastack with-return


syn cluster factorReal          contains=factorInt,factorFloat,factorPosRatio,factorNegRatio,factorBinary,factorHex,factorOctal
syn cluster factorNumber        contains=@factorReal,factorComplex
syn cluster factorNumErr        contains=factorBinErr,factorHexErr,factorOctErr
syn match   factorInt           /\<[+-]\=[0-9]\([0-9,]*[0-9]\)\?\([eE]\([+-]\)\?[0-9]\+\)\?\>/
syn match   factorFloat         /\<[+-]\=\([0-9,]*[0-9]\)\?\(\.\(\([0-9,]*[0-9]\+\)\?\([eE]\([+-]\)\?[0-9]\+\)\?\)\?\)\?\>/
syn match   factorPosRatio      /\<+\=[0-9]\([0-9,]*[0-9]\)\?\(+[0-9]\([0-9,]*[0-9]\+\)\?\)\?\/-\=[0-9]\([0-9,]*[0-9]\+\)\?\.\?\>/
syn match   factorNegRatio      /\<\-[0-9]\([0-9,]*[0-9]\)\?\(\-[0-9]\([0-9,]*[0-9]\+\)\?\)\?\/-\=[0-9]\([0-9,]*[0-9]\+\)\?\.\?\>/
syn region  factorComplex       start=/\<C{\>/ end=/\<}\>/ contains=@factorReal
syn match   factorBinErr        /\<[+-]\=0b[01,]*[^01 ]\S*\>/
syn match   factorBinary        /\<[+-]\=0b[01,]\+\>/
syn match   factorHexErr        /\<[+-]\=0x\(,\S*\|\S*,\|[-0-9a-fA-Fp,]*[^-0-9a-fA-Fp, ]\S*\)\>/
syn match   factorHex           /\<[+-]\=0x[0-9a-fA-F]\([0-9a-fA-F,]*[0-9a-fA-F]\)\?\(\.[0-9a-fA-F]\([0-9a-fA-F,]*[0-9a-fA-F]\)\?\)\?\(p-\=[0-9]\([0-9,]*[0-9]\)\?\)\?\>/
syn match   factorOctErr        /\<[+-]\=0o\(,\S*\|\S*,\|[0-7,]*[^0-7, ]\S*\)\>/
syn match   factorOctal         /\<[+-]\=0o[0-7,]\+\>/
syn match   factorNan           /\<NAN:\s\+[0-9a-fA-F]\([0-9a-fA-F,]*[0-9a-fA-F]\)\?\>/

syn match   factorIn            /\<IN:\s\+\S\+\>/
syn match   factorUse           /\<USE:\s\+\S\+\>/
syn match   factorUnuse         /\<UNUSE:\s\+\S\+\>/

syn match   factorChar          /\<CHAR:\s\+\S\+\>/

syn match   factorBackslash     /\<\\\>\s\+\S\+\>/
syn match   factorMBackslash    /\<M\\\>\s\+\S\+\s\+\S\+\>/
syn match   factorLiteral       /\<\$\>\s\+\S\+\>/
syn region  factorLiteralBlock  start=/\<\$\[\>/ end=/\<\]\>/

syn region  factorUsing         start=/\<USING:\>/       end=/;/
syn match   factorQualified     /\<QUALIFIED:\s\+\S\+\>/
syn match   factorQualifiedWith /\<QUALIFIED-WITH:\s\+\S\+\s\+\S\+\>/
syn region  factorExclude       start=/\<EXCLUDE:\>/     end=/;/
syn region  factorFrom          start=/\<FROM:\>/        end=/;/
syn match   factorRename        /\<RENAME:\s\+\S\+\s\+\S\+\s=>\s\+\S\+\>/
syn region  factorSingletons    start=/\<SINGLETONS:\>/  end=/;/
syn match   factorSymbol        /\<SYMBOL:\s\+\S\+\>/
syn region  factorSymbols       start=/\<SYMBOLS:\>/     end=/;/
syn region  factorConstructor2  start=/\<CONSTRUCTOR:\?/ end=/;/
syn region  factorIntersection  start=/\<INTERSECTION:\>/ end=/\<;\>/
syn region  factorTuple         start=/\<\(TUPLE\|BUILTIN\):\>/ end=/\<;\>/
syn region  factorError         start=/\<ERROR:\>/ end=/\<;\>/
syn region  factorUnion         start=/\<UNION:\>/ end=/\<;\>/
syn region  factorStruct        start=/\<\(UNION-STRUCT:\|STRUCT:\)\>/ end=/\<;\>/

syn match   factorConstant      /\<CONSTANT:\s\+\S\+\>/
syn match   factorAlias         /\<ALIAS:\s\+\S\+\s\+\S\+\>/
syn match   factorSingleton     /\<SINGLETON:\s\+\S\+\>/
syn match   factorPostpone      /\<POSTPONE:\s\+\S\+\>/
syn match   factorDefer         /\<DEFER:\s\+\S\+\>/
syn match   factorForget        /\<FORGET:\s\+\S\+\>/
syn match   factorMixin         /\<MIXIN:\s\+\S\+\>/
syn match   factorInstance      /\<INSTANCE:\s\+\S\+\s\+\S\+\>/
syn match   factorHook          /\<HOOK:\s\+\S\+\s\+\S\+\>/ nextgroup=factorStackEffect skipwhite skipempty
syn match   factorMain          /\<MAIN:\s\+\S\+\>/
syn match   factorConstructor   /\<C:\s\+\S\+\s\+\S\+\>/
syn match   factorAlien         /\<ALIEN:\s\+[0-9a-fA-F]\([0-9a-fA-F,]*[0-9a-fA-F]\)\?\>/
syn match   factorSlot          /\<SLOT:\s\+\S\+\>/

syn cluster factorWordOps       contains=factorConstant,factorAlias,factorSingleton,factorSingletons,factorSymbol,factorSymbols,factorPostpone,factorDefer,factorForget,factorMixin,factorInstance,factorHook,factorMain,factorConstructor

"TODO:
"misc:
" HELP:
" ARTICLE:
"literals:
" PRIMITIVE:

"C interface:
" C-ENUM:
" FUNCTION:
" TYPEDEF:
" LIBRARY:
"#\ "

syn match factorEscape /\\\([\\astnrbvf0e\"]\|u\x\{6}\|u{\S\+}\|x\x\{2}\)/ contained display
syn region factorString start=/\<"/ skip=/\\"/ end=/"/ contains=factorEscape
syn region factorTriString start=/\<"""/ skip=/\\"/ end=/"""/ contains=factorEscape
syn region factorSbuf start=/\<[-a-zA-Z0-9]\+"\>/ skip=/\\"/ end=/"/

syn region factorMultiString matchgroup=factorMultiStringDelims start=/\<STRING:\s\+\S\+\>/ end=/^;$/ contains=factorMultiStringContents
syn match factorMultiStringContents /.*/ contained

"syn match factorStackEffectErr /\<)\>/
"syn region factorStackEffectErr start=/\<(\>/ end=/\<)\>/
"syn region factorStackEffect start=/\<(\>/ end=/\<)\>/ contained
syn match factorStackEffect /(\s\+\(\S*\s\+\)*--\(\s\+\S*\)*\s\+)\>/ contained contains=factorStackDelims,factorStackItems,factorStackVariables,factorCallExecuteDelim
syn match factorLiteralStackEffect /((\s\+\(\S*\s\+\)*--\(\s\+\S*\)*\s\+))\>/ contained contains=factorStackDelims,factorStackItems,factorStackVariables,factorCallExecuteDelim
syn match factorStackVariables contained "\<\.\.\S\+\>"
syn match factorStackItems contained "\<\(\.\.\)\@!\S\+\>"
syn keyword factorStackDelims contained ( ) (( )) --
syn match factorCallExecuteDelim contained /(\s/

"adapted from lisp.vim
if exists("g:factor_norainbow")
    syn region factorQuotation matchgroup=factorDelimiter start=/\<\(\(\('\|\$\|\)\[\)\|\[\(let\||\)\)\>/ matchgroup=factorDelimiter end=/\<\]\>/ contains=ALL
else
    syn region factorQuotation0           matchgroup=hlLevel0 start=/\<\(\(\('\|\$\|\)\[\)\|\[\(let\||\)\)\>/  end=/\<\]\>/ contains=@factorCluster,factorQuotation1,factorArray1
    syn region factorQuotation1 contained matchgroup=hlLevel1 start=/\<\(\(\('\|\$\|\)\[\)\|\[\(let\||\)\)\>/  end=/\<\]\>/ contains=@factorCluster,factorQuotation2,factorArray2
    syn region factorQuotation2 contained matchgroup=hlLevel2 start=/\<\(\(\('\|\$\|\)\[\)\|\[\(let\||\)\)\>/  end=/\<\]\>/ contains=@factorCluster,factorQuotation3,factorArray3
    syn region factorQuotation3 contained matchgroup=hlLevel3 start=/\<\(\(\('\|\$\|\)\[\)\|\[\(let\||\)\)\>/  end=/\<\]\>/ contains=@factorCluster,factorQuotation4,factorArray4
    syn region factorQuotation4 contained matchgroup=hlLevel4 start=/\<\(\(\('\|\$\|\)\[\)\|\[\(let\||\)\)\>/  end=/\<\]\>/ contains=@factorCluster,factorQuotation5,factorArray5
    syn region factorQuotation5 contained matchgroup=hlLevel5 start=/\<\(\(\('\|\$\|\)\[\)\|\[\(let\||\)\)\>/  end=/\<\]\>/ contains=@factorCluster,factorQuotation6,factorArray6
    syn region factorQuotation6 contained matchgroup=hlLevel6 start=/\<\(\(\('\|\$\|\)\[\)\|\[\(let\||\)\)\>/  end=/\<\]\>/ contains=@factorCluster,factorQuotation7,factorArray7
    syn region factorQuotation7 contained matchgroup=hlLevel7 start=/\<\(\(\('\|\$\|\)\[\)\|\[\(let\||\)\)\>/  end=/\<\]\>/ contains=@factorCluster,factorQuotation8,factorArray8
    syn region factorQuotation8 contained matchgroup=hlLevel8 start=/\<\(\(\('\|\$\|\)\[\)\|\[\(let\||\)\)\>/  end=/\<\]\>/ contains=@factorCluster,factorQuotation9,factorArray9
    syn region factorQuotation9 contained matchgroup=hlLevel9 start=/\<\(\(\('\|\$\|\)\[\)\|\[\(let\||\)\)\>/  end=/\<\]\>/ contains=@factorCluster,factorQuotation0,factorArray0
endif

if exists("g:factor_norainbow")
    syn region factorArray    matchgroup=factorDelimiter start=/\<\(\$\|[-a-zA-Z0-9]\+\)\?{\>/  matchgroup=factorDelimiter end=/\<}\>/ contains=ALL
else
    syn region factorArray0           matchgroup=hlLevel0 start=/\<\(\$\|[-a-zA-Z0-9]\+\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray1,factorQuotation1
    syn region factorArray1 contained matchgroup=hlLevel1 start=/\<\(\$\|[-a-zA-Z0-9]\+\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray2,factorQuotation2
    syn region factorArray2 contained matchgroup=hlLevel2 start=/\<\(\$\|[-a-zA-Z0-9]\+\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray3,factorQuotation3
    syn region factorArray3 contained matchgroup=hlLevel3 start=/\<\(\$\|[-a-zA-Z0-9]\+\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray4,factorQuotation4
    syn region factorArray4 contained matchgroup=hlLevel4 start=/\<\(\$\|[-a-zA-Z0-9]\+\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray5,factorQuotation5
    syn region factorArray5 contained matchgroup=hlLevel5 start=/\<\(\$\|[-a-zA-Z0-9]\+\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray6,factorQuotation6
    syn region factorArray6 contained matchgroup=hlLevel6 start=/\<\(\$\|[-a-zA-Z0-9]\+\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray7,factorQuotation7
    syn region factorArray7 contained matchgroup=hlLevel7 start=/\<\(\$\|[-a-zA-Z0-9]\+\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray8,factorQuotation8
    syn region factorArray8 contained matchgroup=hlLevel8 start=/\<\(\$\|[-a-zA-Z0-9]\+\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray9,factorQuotation9
    syn region factorArray9 contained matchgroup=hlLevel9 start=/\<\(\$\|[-a-zA-Z0-9]\+\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray0,factorQuotation0
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

    HiLink factorComment                Comment
    HiLink factorShebang                PreProc
    HiLink factorShebangErr             Error
    HiLink factorStackEffect            Typedef
    HiLink factorStackDelims            Delimiter
    HiLink factorCallExecuteDelim       Delimiter
    HiLink factorStackVariables         Special
    HiLink factorStackItems             Identifier
    HiLink factorLiteralStackEffect     Typedef
    HiLink factorTodo                   Todo
    HiLink factorInclude                Include
    HiLink factorRepeat                 Repeat
    HiLink factorConditional            Conditional
    HiLink factorKeyword                Keyword
    HiLink factorCallQuotation          Keyword
    HiLink factorExecute                Keyword
    HiLink factorCallNextMethod         Keyword
    HiLink factorOperator               Operator
    HiLink factorFrySpecifier           Operator
    HiLink factorBoolean                Boolean
    HiLink factorBreakpoint             Debug
    HiLink factorDefnDelims             Typedef
    HiLink factorMethodDelims           Typedef
    HiLink factorGenericDelims          Typedef
    HiLink factorGenericNDelims         Typedef
    HiLink factorConstructor            Typedef
    HiLink factorConstructor2           Typedef
    HiLink factorPrivate                Special
    HiLink factorPrivateDefnDelims      Special
    HiLink factorPrivateMethodDelims    Special
    HiLink factorPGenericDelims         Special
    HiLink factorPGenericNDelims        Special
    HiLink factorEscape                 SpecialChar
    HiLink factorString                 String
    HiLink factorTriString              String
    HiLink factorSbuf                   String
    HiLink factorMultiStringContents    String
    HiLink factorMultiStringDelims      Typedef
    HiLink factorBracketErr             Error
    HiLink factorComplex                Number
    HiLink factorPosRatio               Number
    HiLink factorNegRatio               Number
    HiLink factorBinary                 Number
    HiLink factorBinErr                 Error
    HiLink factorHex                    Number
    HiLink factorHexErr                 Error
    HiLink factorNan                    Number
    HiLink factorOctal                  Number
    HiLink factorOctErr                 Error
    HiLink factorFloat                  Float
    HiLink factorInt                    Number
    HiLink factorUsing                  Include
    HiLink factorQualified              Include
    HiLink factorQualifiedWith          Include
    HiLink factorExclude                Include
    HiLink factorFrom                   Include
    HiLink factorRename                 Include
    HiLink factorUse                    Include
    HiLink factorUnuse                  Include
    HiLink factorIn                     Define
    HiLink factorChar                   Character
    HiLink factorDelimiter              Delimiter
    HiLink factorBackslash              Special
    HiLink factorMBackslash             Special
    HiLink factorLiteral                Special
    HiLink factorLiteralBlock           Special
    HiLink factorDeclaration            Typedef
    HiLink factorSymbol                 Define
    HiLink factorSymbols                Define
    HiLink factorConstant               Define
    HiLink factorAlias                  Define
    HiLink factorSingleton              Define
    HiLink factorSingletons             Define
    HiLink factorMixin                  Typedef
    HiLink factorInstance               Typedef
    HiLink factorHook                   Typedef
    HiLink factorMain                   Define
    HiLink factorPostpone               Define
    HiLink factorDefer                  Define
    HiLink factorForget                 Define
    HiLink factorAlien                  Define
    HiLink factorSlot                   Define
    HiLink factorIntersection           Typedef
    HiLink factorTuple                  Typedef
    HiLink factorError                  Typedef
    HiLink factorUnion                  Typedef
    HiLink factorStruct                 Typedef

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

" vim:set ft=vim sw=4:
