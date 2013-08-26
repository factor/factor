APPNAME = 'factor'
VERSION = '0.96'

def options(opt):
    opt.load('compiler_cxx')

def configure(conf):
    conf.load('compiler_cxx')
    conf.check(features='cxx cxxprogram', cflags=['-Wall'])
    conf.check_cxx(lib = 'shell32', uselib_store='shell32')
    conf.env.LINKFLAGS.append('/SUBSYSTEM:console')

def build(bld):
    bld.recurse('vm')
