USING: kernel parser ;
<<
"resource:core/system/system.factor" run-file
"resource:basis/compiler/constants/constants.factor" run-file
"resource:basis/cpu/alpha/64/assembler/assembler.factor" run-file
"resource:basis/cpu/alpha/64/64.factor" run-file
>>
USING: system compiler.codegen.relocation compiler.cfg.comparisons cpu.alpha.64 cpu.alpha.64.assembler
cpu.alpha.64.assembler.registers cpu.architecture generic.parser
io.encodings.binary io.files make sequences namespaces memory ;
[ init-relocation ds-0 DS 0 LDQ ds-1 DS -8 LDQ DS DS -8 LDA
  ds-0 ds-1 ds-0 M\ alpha.64 %add execute ds-0 DS 0 STQ ] B{ } make
"alpha-fixnum+fast.bin" binary set-file-contents
[ init-relocation ds-0 DS 0 LDQ ds-1 DS -8 LDQ DS DS -8 LDA
  ds-0 ds-0 4 SRAI
  ds-0 ds-1 ds-0 M\ alpha.64 %mul execute ds-0 DS 0 STQ ] B{ } make
"alpha-fixnum*fast.bin" binary set-file-contents
[ init-relocation ds-0 DS 0 LDQ ds-1 DS -8 LDQ DS DS -8 LDA
  ds-0 ds-1 ds-0 cc> temp2 M\ alpha.64 %compare execute ds-0 DS 0 STQ ] B{ } make
"alpha-fixnum>.bin" binary set-file-contents

[ temp2 0x123456789abcdef0 M\ alpha.64 %load-immediate execute temp2 DS 0 STQ ] B{ } make
"alpha-immediate-temp2.bin" binary set-file-contents
[ temp3 0x123456789abcdef0 M\ alpha.64 %load-immediate execute temp3 DS 0 STQ ] B{ } make
"alpha-immediate-temp3.bin" binary set-file-contents

! A real word must bind the relocation; template placeholders would leave
! the word on the data stack and make GC-map recording consume it.
[ init-relocation \ minor-gc M\ alpha.64 %call execute
  literal-table get first \ minor-gc eq?
  [ ] [ "Alpha optimizer call lost its word relocation" throw ] if ] B{ } make
"alpha-word-call.bin" binary set-file-contents
[ init-relocation \ minor-gc M\ alpha.64 %jump execute
  literal-table get first \ minor-gc eq?
  [ ] [ "Alpha optimizer jump lost its word relocation" throw ] if ] B{ } make
"alpha-word-jump.bin" binary set-file-contents
