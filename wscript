APPNAME = 'factor'
VERSION = '0.96'

def options(opt):
    opt.load('compiler_cxx')

def configure(conf):
    conf.load('compiler_cxx')
    conf.check(features='cxx cxxprogram', cflags=['-Wall'])
    env = conf.env
    dest_cpu = env.DEST_CPU
    dest_os = env.DEST_OS
    if dest_os == 'win32':
        conf.check_cxx(lib = 'shell32', uselib_store = 'shell32')
        env.LINKFLAGS.append('/SUBSYSTEM:console')
        env.CXXFLAGS.append('/EHsc')
        if dest_cpu == 'i386':
            env.LINKFLAGS.append('/safesh')
        conf.load('winres')
        env.WINRCFLAGS.append('/nologo')
        conf.define('_CRT_SECURE_NO_WARNINGS', None)
    elif dest_os == 'linux':
        conf.check_cxx(lib = 'pthread', uselib_store = 'pthread')
        conf.check_cxx(lib = 'dl', uselib_store = 'dl')
        conf.check_cxx(
            function_name = 'clock_gettime',
            header_name = ['sys/time.h','time.h'],
            lib = 'rt', uselib_store = 'rt'
        )

def build(bld):
    bld.recurse('vm')
