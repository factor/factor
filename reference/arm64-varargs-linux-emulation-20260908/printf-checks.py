import subprocess
base=["../qemu/usr/bin/qemu-aarch64","-L","/usr/aarch64-linux-gnu","./factor","-i=current.image","-no-user-init","-no-monitors"]
expected=b"value:-42:  1.250:-1234567890123\n"
for flags in [[],["-disable-neon-extensions"]]:
    for name in ["printf.factor","printf-direct.factor"]:
        p=subprocess.run(base+flags+["basis/compiler/tests/varargs/"+name],capture_output=True)
        print(name,flags,"exit",p.returncode,"stdout",repr(p.stdout),"stderr",repr(p.stderr),flush=True)
        assert p.returncode==0 and p.stdout==expected and p.stderr==b"",p
print("All four actual printf subprocess checks passed",flush=True)
