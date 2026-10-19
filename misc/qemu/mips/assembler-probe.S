.set noreorder
.set noat
.text
.globl probe
probe:
addu $2,$4,$5
subu $2,$4,$5
addiu $2,$4,-123
sll $2,$4,7
beq $4,$5,probe
nop
jalr $31,$25
nop
ld $2,-16($29)
sd $2,-16($29)
daddu $2,$4,$5
add.d $f0,$f2,$f4
jr $31
nop
