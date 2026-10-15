#!/usr/bin/env python3
import os
"""Issue a command through a FreeBSD QEMU serial socket, preserving its output."""
import argparse,pathlib,pexpect,sys
p=argparse.ArgumentParser();p.add_argument('arch');p.add_argument('command');p.add_argument('--assets',default=os.path.join(os.environ.get('FACTOR_QEMU_MATRIX_DIR','/home/sheeple/factor/work/qemu-matrix'),'freebsd'));p.add_argument('--timeout',type=int,default=180);a=p.parse_args()
c=pexpect.spawn('nc',['-U',a.assets+'/'+a.arch+'.sock'],encoding='utf-8',timeout=a.timeout)
c.logfile=sys.stdout;c.sendline('');i=c.expect(['login:',r'root@[^\r\n]*[#] ',r'[#] '])
if i==0:c.sendline('root');c.expect(r'[#] ')
c.sendline(a.command);c.sendline('echo QEMU_COMMAND_FINISHED');c.expect('QEMU_COMMAND_FINISHED\r\n');c.expect(r'[#] ');c.close()
