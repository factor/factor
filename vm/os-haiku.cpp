#include "master.hpp"
#include <sys/socket.h>
#include <fs_info.h>
#include <Entry.h>
#include <Path.h>
#include <atomic>
#include <mutex>
#include <sys/wait.h>

namespace factor {
// Retain libnetwork for default-handle FFI even when linked with --as-needed.
static void* const network_dependency __attribute__((used)) = (void*)&socket;

const char* vm_executable_path() {
  image_info info;
  int32 cookie = 0;
  while (get_next_image_info(B_CURRENT_TEAM, &cookie, &info) == B_OK) {
    if (info.type == B_APP_IMAGE) return safe_strdup(info.name);
  }
  return NULL;
}

// Public Storage Kit calls resolve a volume root without private kernel APIs.
VM_C_API int factor_haiku_volume_path(int32 device, char* buffer, size_t size) {
  fs_info info;
  if (fs_stat_dev(device, &info) < 0) return -1;
  entry_ref ref(device, info.root, ".");
  BEntry entry(&ref, true);
  BPath path;
  status_t status = entry.GetPath(&path);
  if (status != B_OK) { errno = status; return -1; }
  size_t length = strlen(path.Path());
  if (length >= size) { errno = ENAMETOOLONG; return -1; }
  memcpy(buffer, path.Path(), length + 1);
  return 0;
}

// Haiku retains only 32 uncollected child exit records. Capture real waitpid
// statuses at SIGCHLD delivery, and only for children owned by the launcher.
// Each slot remains owned until the VM consumer takes its authoritative status.
static_assert(ATOMIC_INT_LOCK_FREE == 2, "SIGCHLD ownership requires lock-free atomics");
struct haiku_child_record {
  std::atomic<int> state; // 0 free, 1 waiting, 2 collecting, 3 exit, 4 error, 5 registering
  int pid;
  int status;
  int error;
};
static haiku_child_record haiku_children[4096];
static std::mutex haiku_child_install_lock;
static bool haiku_child_handler_installed = false;
static struct sigaction haiku_previous_sigchld;

static void haiku_collect_child(haiku_child_record& child) {
  int waiting = 1;
  if (!child.state.compare_exchange_strong(waiting, 2, std::memory_order_acquire)) return;
  int status = 0;
  pid_t result;
  do { result = waitpid(child.pid, &status, WNOHANG); } while (result < 0 && errno == EINTR);
  if (result == child.pid) {
    child.status = status;
    child.state.store(3, std::memory_order_release);
  } else if (result == 0) {
    child.state.store(1, std::memory_order_release);
  } else {
    child.error = errno;
    child.state.store(4, std::memory_order_release);
  }
}

static void haiku_child_signal(int signal, siginfo_t* info, void* context) {
  int saved_errno = errno;
  for (auto& child : haiku_children) haiku_collect_child(child);
  // Retain a pre-existing caught handler; unowned children are never reaped here.
  if (haiku_previous_sigchld.sa_handler != SIG_DFL
      && haiku_previous_sigchld.sa_handler != SIG_IGN) {
    if (haiku_previous_sigchld.sa_flags & SA_SIGINFO)
      haiku_previous_sigchld.sa_sigaction(signal, info, context);
    else
      haiku_previous_sigchld.sa_handler(signal);
  }
  errno = saved_errno;
}

// Reject only the newly created child supplied by the Factor launcher. Probe
// parent ownership before sending a signal; never kill an unowned native PID.
static int haiku_reject_child(int pid, int original_error) {
  int status = 0;
  pid_t result;
  do { result = waitpid(pid, &status, WNOHANG); } while (result < 0 && errno == EINTR);
  if (result == 0) {
    kill(pid, SIGKILL);
    do { result = waitpid(pid, &status, 0); } while (result < 0 && errno == EINTR);
  }
  errno = original_error;
  return -1;
}

// Reject unsupported auto-reaping before posix_spawn can create a child.
// Keep post-spawn ownership registration and rejection as the final authority.
// Inspect the current disposition even after our watcher has been installed.
VM_C_API int factor_haiku_prepare_process() {
  std::lock_guard<std::mutex> lock(haiku_child_install_lock);
  struct sigaction action;
  if (sigaction(SIGCHLD, NULL, &action) < 0) return -1;
  if (action.sa_handler == SIG_IGN
      || (action.sa_flags & (SA_NOCLDWAIT | SA_RESETHAND))) {
    errno = ENOTSUP;
    return -1;
  }
  return 0;
}

VM_C_API int factor_haiku_watch_process(int pid) {
  if (pid <= 0) { errno = EINVAL; return -1; }
  {
    std::lock_guard<std::mutex> lock(haiku_child_install_lock);
    if (!haiku_child_handler_installed) {
      if (sigaction(SIGCHLD, NULL, &haiku_previous_sigchld) < 0) return haiku_reject_child(pid, errno);
      // Auto-reaping dispositions cannot supply authoritative child statuses.
      if (haiku_previous_sigchld.sa_handler == SIG_IGN
          || (haiku_previous_sigchld.sa_flags & (SA_NOCLDWAIT | SA_RESETHAND))) {
        return haiku_reject_child(pid, ENOTSUP);
      }
      struct sigaction action = haiku_previous_sigchld;
      action.sa_sigaction = haiku_child_signal;
      action.sa_flags |= SA_SIGINFO | SA_RESTART;
      if (sigaction(SIGCHLD, &action, NULL) < 0) return haiku_reject_child(pid, errno);
      haiku_child_handler_installed = true;
    }
  }
  for (auto& child : haiku_children) {
    int free = 0;
    if (!child.state.compare_exchange_strong(free, 5, std::memory_order_acquire)) continue;
    child.pid = pid;
    child.status = 0;
    child.error = 0;
    child.state.store(1, std::memory_order_release);
    // A child may have exited before its PID was registered.
    haiku_collect_child(child);
    if (child.state.load(std::memory_order_acquire) == 4) {
      int error = child.error;
      child.state.store(0, std::memory_order_release);
      return haiku_reject_child(pid, error);
    }
    return 0;
  }
  return haiku_reject_child(pid, ENOSPC);
}

VM_C_API int factor_haiku_next_process_exit(int* pid, int* status) {
  for (auto& child : haiku_children) {
    // Recheck also covers a SIGCHLD arriving while registration was publishing.
    haiku_collect_child(child);
    int state = child.state.load(std::memory_order_acquire);
    if (state != 3 && state != 4) continue;
    if (!child.state.compare_exchange_strong(state, 5, std::memory_order_acquire)) continue;
    *pid = child.pid;
    *status = child.status;
    int error = child.error;
    child.state.store(0, std::memory_order_release);
    if (state == 4) { errno = error; return -1; }
    return 1;
  }
  return 0;
}
}
