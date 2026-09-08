"""macOS process counters; time fields are Mach ticks, NOT nanoseconds."""
import ctypes

class Timebase(ctypes.Structure):
    _fields_ = [('numer', ctypes.c_uint32), ('denom', ctypes.c_uint32)]

class RUsageV4(ctypes.Structure):
    _fields_ = [('uuid', ctypes.c_uint8 * 16)] + [(name, ctypes.c_uint64) for name in (
        'user_time', 'system_time', 'pkg_idle_wkups', 'interrupt_wkups', 'pageins',
        'wired_size', 'resident_size', 'phys_footprint', 'proc_start_abstime',
        'proc_exit_abstime', 'child_user_time', 'child_system_time', 'child_pkg_idle_wkups',
        'child_interrupt_wkups', 'child_pageins', 'child_elapsed_abstime',
        'diskio_bytesread', 'diskio_byteswritten', 'cpu_time_qos_default',
        'cpu_time_qos_maintenance', 'cpu_time_qos_background', 'cpu_time_qos_utility',
        'cpu_time_qos_legacy', 'cpu_time_qos_user_initiated', 'cpu_time_qos_user_interactive',
        'billed_system_time', 'serviced_system_time', 'logical_writes',
        'lifetime_max_phys_footprint', 'instructions', 'cycles', 'billed_energy',
        'serviced_energy', 'interval_max_phys_footprint', 'runnable_time')]

libproc = ctypes.CDLL('/usr/lib/libproc.dylib', use_errno=True)
libproc.proc_pid_rusage.argtypes = [ctypes.c_int, ctypes.c_int, ctypes.c_void_p]
libproc.proc_pid_rusage.restype = ctypes.c_int
libsystem = ctypes.CDLL('/usr/lib/libSystem.B.dylib')
libsystem.mach_timebase_info.argtypes = [ctypes.POINTER(Timebase)]
timebase = Timebase()
assert libsystem.mach_timebase_info(ctypes.byref(timebase)) == 0
tick_seconds = timebase.numer / timebase.denom / 1e9

def usage(pid):
    buf = RUsageV4()
    if libproc.proc_pid_rusage(pid, 4, ctypes.byref(buf)):
        return None
    return dict(cpu=(buf.user_time + buf.system_time) * tick_seconds,
                user=buf.user_time * tick_seconds, system=buf.system_time * tick_seconds,
                instructions=buf.instructions, cycles=buf.cycles, rss=buf.resident_size,
                background_cpu=buf.cpu_time_qos_background * tick_seconds,
                disk_read_bytes=buf.diskio_bytesread, disk_written_bytes=buf.diskio_byteswritten)
