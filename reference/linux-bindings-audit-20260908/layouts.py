#!/usr/bin/env python3
"""Compare native Linux structure sizes, alignment and selected field offsets."""
import argparse
import json
import pathlib
import subprocess
from signatures import FACTOR

# Factor vocabulary/type, C type, and Factor:C field name mappings.
LAYOUTS = [
    ("unix.types", "sigset_t", "sigset_t", ""),
    # glibc 2.39 repurposed the first reserved int as __cgroup; it is not
    # part of the portable public interface, so do not compare __pad.
    ("unix.types", "posix_spawnattr_t", "posix_spawnattr_t", "__flags __pgrp __sd __ss __sp __policy"),
    ("unix.types", "posix_spawn_file_actions_t", "posix_spawn_file_actions_t", "__allocated __used __actions __pad"),
    ("unix.ffi", "sockaddr-in", "sockaddr_in", "family:sin_family port:sin_port addr:sin_addr unused:sin_zero"),
    ("unix.ffi", "sockaddr-in6", "sockaddr_in6", "family:sin6_family port:sin6_port flowinfo:sin6_flowinfo addr:sin6_addr scopeid:sin6_scope_id"),
    ("unix.ffi", "sockaddr-un", "sockaddr_un", "family:sun_family path:sun_path"),
    ("unix.ffi", "addrinfo", "addrinfo", "flags:ai_flags family:ai_family socktype:ai_socktype protocol:ai_protocol addrlen:ai_addrlen addr:ai_addr canonname:ai_canonname next:ai_next"),
    ("unix.ffi", "group", "group", "gr_name gr_passwd gr_gid gr_mem"),
    ("unix.ffi", "passwd", "passwd", "pw_name pw_passwd pw_uid pw_gid pw_gecos pw_dir pw_shell"),
    ("unix.ffi", "dirent", "dirent64", "d_ino d_off d_reclen d_type d_name"),
    ("unix.ffi", "utmpx", "utmpx", "ut_type ut_pid ut_line ut_id ut_user ut_host ut_exit ut_session ut_tv ut_addr_v6 __unused:__glibc_reserved"),
    ("unix.time", "timeval", "timeval", "sec:tv_sec usec:tv_usec"),
    ("unix.time", "timespec", "timespec", "sec:tv_sec nsec:tv_nsec"),
    ("unix.time", "tm", "tm", "sec:tm_sec min:tm_min hour:tm_hour mday:tm_mday mon:tm_mon year:tm_year wday:tm_wday yday:tm_yday isdst:tm_isdst gmtoff:tm_gmtoff zone:tm_zone"),
    ("unix.linux.epoll", "epoll-event", "epoll_event", "events data"),
    ("unix.linux.inotify", "inotify-event", "inotify_event", "wd mask cookie len name"),
    ("unix.statfs.linux", "statfs64", "statfs64", "f_type f_bsize f_blocks f_bfree f_bavail f_files f_ffree f_fsid f_namelen f_frsize f_spare"),
    # New glibc versions repurpose the first reserved int as f_type;
    # retain the compatible storage without promising it on older libc.
    ("unix.statvfs.linux", "statvfs64", "statvfs64", "f_bsize f_frsize f_blocks f_bfree f_bavail f_files f_ffree f_favail f_fsid f_flag f_namemax"),
    ("unix.stat", "stat", "stat64", "st_dev st_ino st_nlink st_mode st_uid st_gid st_rdev st_size st_blksize st_blocks st_atimespec:st_atim st_mtimespec:st_mtim st_ctimespec:st_ctim"),
    ("io.serial.linux.ffi", "termios", "termios", "iflag:c_iflag oflag:c_oflag cflag:c_cflag lflag:c_lflag line:c_line cc:c_cc ispeed:c_ispeed ospeed:c_ospeed"),
    ("linux.input-events.ffi", "input_id", "input_id", "bustype vendor product version"),
    ("linux.input-events.ffi", "input_absinfo", "input_absinfo", "value minimum maximum fuzz flat resolution"),
    ("linux.input-events.ffi", "input_keymap_entry", "input_keymap_entry", "flags len index keycode scancode"),
    ("linux.input-events.ffi", "input_mask", "input_mask", "type codes_size codes_ptr"),
    ("linux.input-events.ffi", "ff_replay", "ff_replay", "length delay"),
    ("linux.input-events.ffi", "ff_trigger", "ff_trigger", "button interval"),
    ("linux.input-events.ffi", "ff_envelope", "ff_envelope", "attack_length attack_level fade_length fade_level"),
    ("linux.input-events.ffi", "ff_constant_effect", "ff_constant_effect", "level envelope"),
    ("linux.input-events.ffi", "ff_ramp_effect", "ff_ramp_effect", "start_level end_level envelope"),
    ("linux.input-events.ffi", "ff_condition_effect", "ff_condition_effect", "right_saturation left_saturation right_coeff left_coeff deadband center"),
    ("linux.input-events.ffi", "ff_periodic_effect", "ff_periodic_effect", "waveform period magnitude offset phase envelope custom_len custom_data"),
    ("linux.input-events.ffi", "ff_rumble_effect", "ff_rumble_effect", "strong_magnitude weak_magnitude"),
    ("linux.input-events.ffi", "ff_effect", "ff_effect", "type id direction trigger replay union:u"),
]

def main():
    p = argparse.ArgumentParser()
    p.add_argument("root", type=pathlib.Path)
    p.add_argument("output", type=pathlib.Path)
    args = p.parse_args()
    root, out = args.root.resolve(), args.output.resolve()
    out.mkdir(parents=True, exist_ok=True)
    cpp = "#define _GNU_SOURCE 1\n" + "".join(f"#include <{h}>\n" for h in
        "iostream cstddef signal.h spawn.h netinet/in.h sys/un.h netdb.h grp.h pwd.h dirent.h utmpx.h sys/time.h sys/epoll.h sys/inotify.h sys/statfs.h sys/statvfs.h sys/stat.h termios.h linux/input.h".split())
    cpp += "int main() {\n"
    factor = FACTOR + r'''
USING: classes.struct ;
:: layout ( vocab name fields -- row )
    name vocab lookup-word :> type
    fields [| field |
        field type offset-of
    ] map
    type c-type-align prefix type heap-size prefix name prefix ;
'''
    factor += "{ " + " ".join(json.dumps(v) for v in sorted({v for v, *_ in LAYOUTS})) + " } [ require ] each\n"
    for vocab, name, native, mapping in LAYOUTS:
        fields = [pair.split(":") if ":" in pair else [pair, pair] for pair in mapping.split()]
        ctype = native if native in ("sigset_t", "posix_spawnattr_t", "posix_spawn_file_actions_t") else "struct " + native
        cpp += f'std::cout << "{name} " << sizeof({ctype}) << " " << alignof({ctype})'
        for _, cfield in fields:
            cpp += f' << " " << offsetof({ctype}, {cfield})'
        cpp += ' << "\\n";\n'
        factor += f'{json.dumps(vocab)} {json.dumps(name)} {{ ' + " ".join(json.dumps(f) for f, _ in fields) + ' } layout >json print\n'
    cpp += "}\n"
    (out / "layouts.cpp").write_text(cpp)
    (out / "layouts.factor").write_text(factor)
    subprocess.run(["c++", "-std=c++17", str(out / "layouts.cpp"), "-o", str(out / "layouts")], check=True)
    native = subprocess.check_output([str(out / "layouts")], text=True)
    (out / "native-layouts.txt").write_text(native)
    result = subprocess.run([str(root / "factor"), "-q", "-no-user-init", str(out / "layouts.factor")], cwd=root, text=True, capture_output=True)
    (out / "factor-layouts.log").write_text(result.stdout + result.stderr)
    if result.returncode:
        raise SystemExit("Factor layout probe failed")
    c = {row[0]: list(map(int, row[1:])) for row in map(str.split, native.splitlines())}
    rows = [json.loads(line) for line in result.stdout.splitlines() if line.startswith("[")]
    assert len(rows) == len(LAYOUTS)
    mismatches = [{"type": row[0], "factor": row[1:], "native": c[row[0]]} for row in rows if row[1:] != c[row[0]]]
    report = {"checked": len(rows), "mismatches": mismatches}
    (out / "layout-results.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(report, indent=2))
    raise SystemExit(bool(mismatches))

if __name__ == "__main__":
    main()
