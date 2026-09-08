USING: compiler.units io io.pathnames memory vocabs.loader ;
"cpu.architecture" reload
[
    "alien" reload
    "alien.c-types" reload
    "stack-checker.alien" reload
    "stack-checker.known-words" reload
    "compiler.cfg.builder.alien.params" reload
    "compiler.cfg.builder.alien.boxing" reload
    "compiler.cfg.renaming.functor" reload
    "compiler.cfg.renaming" reload
    "compiler.cfg.ssa.construction" reload
    "compiler.cfg.representations.rewrite" reload
    "compiler.cfg.linear-scan.assignment" reload
    "alien.parser" reload
    "alien.syntax" reload
    "cpu.architecture" reload
    "cpu.arm.64.assembler" reload
    "cpu.arm.64" reload
    "compiler.cfg.builder.alien" reload
    "math.floats.small.c-types" reload
] with-compilation-unit
"reloaded" print flush
"resource:reduced.image" absolute-path save-image
