APPNAME = 'factor'
VERSION = '0.96'

def options(opt):
    opt.load('compiler_cxx')

def configure(conf):
    conf.load('compiler_cxx')
    conf.check(features='cxx cxxprogram', cflags=['-Wall'])

    dest_os = conf.env.DEST_OS
    if dest_os == 'win32':
        conf.check_cxx(lib = 'shell32', uselib_store = 'shell32')
        conf.env.LINKFLAGS.append('/SUBSYSTEM:console')
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
