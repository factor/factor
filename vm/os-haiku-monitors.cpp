// Public Haiku Storage Kit NodeMonitor adapter.
#include "master.hpp"
#include <Directory.h>
#include <Entry.h>
#include <Looper.h>
#include <Handler.h>
#include <vector>
#include <algorithm>
#include <Message.h>
#include <NodeMonitor.h>
#include <fcntl.h>
#include <deque>
#include <map>
#include <mutex>
#include <set>
#include <string>

namespace factor {
// Stable exported record; actions are independent of Haiku opcode values.
struct haiku_monitor_event { int32 action; char name[256]; };

class haiku_monitor;
static BLooper* monitor_looper;
static std::mutex monitor_init_mutex;
static std::vector<haiku_monitor*> active_monitors;
static size_t next_monitor_index;
static int shared_read_fd = -1, shared_write_fd = -1;

static bool monitor_pipe(int* descriptors) {
  if (pipe(descriptors) < 0) return false;
  for (int i = 0; i < 2; ++i) {
    int flags = fcntl(descriptors[i], F_GETFL);
    if (flags < 0 || fcntl(descriptors[i], F_SETFL, flags | O_NONBLOCK) < 0
        || fcntl(descriptors[i], F_SETFD, FD_CLOEXEC) < 0) {
      int error = errno; close(descriptors[0]); close(descriptors[1]);
      errno = error; return false;
    }
  }
  return true;
}
static bool ensure_monitor_looper() {
  std::lock_guard<std::mutex> guard(monitor_init_mutex);
  if (monitor_looper) return true;
  int descriptors[2];
  if (!monitor_pipe(descriptors)) return false;
  BLooper* looper = NULL;
  try { looper = new BLooper("Factor NodeMonitor"); }
  catch (const std::bad_alloc&) {
    close(descriptors[0]); close(descriptors[1]); errno = ENOMEM; return false;
  }
  ::thread_id thread = looper->Run();
  if (thread < 0) {
    delete looper; close(descriptors[0]); close(descriptors[1]);
    errno = thread; return false;
  }
  shared_read_fd = descriptors[0]; shared_write_fd = descriptors[1];
  monitor_looper = looper;
  return true;
}

class haiku_monitor : public BHandler {
  node_ref root;
  bool directory, owns_read_fd;
  int read_fd, write_fd;
  std::mutex queue_mutex;
  std::deque<haiku_monitor_event> events;
  std::map<ino_t, std::set<std::string> > names;
  int failure;

  void wake() {
    char byte = 1;
    ssize_t n;
    do { n = write(shared_write_fd, &byte, 1); } while (n < 0 && errno == EINTR);
    // A full nonblocking pipe already contains a wakeup. No event is lost.
    if (n < 0 && errno != EAGAIN) failure = errno;
    if (write_fd >= 0) {
      do { n = write(write_fd, &byte, 1); } while (n < 0 && errno == EINTR);
      if (n < 0 && errno != EAGAIN) failure = errno;
    }
  }
  void fail(int error) {
    std::lock_guard<std::mutex> guard(queue_mutex);
    failure = error;
    wake();
  }
  void enqueue(int action, const char* name) {
    haiku_monitor_event event = {};
    if (!name || strlen(name) >= sizeof(event.name)) { fail(ENAMETOOLONG); return; }
    event.action = action;
    memcpy(event.name, name, strlen(name) + 1);
    std::lock_guard<std::mutex> guard(queue_mutex);
    bool empty = events.empty();
    events.push_back(event);
    if (empty) wake();
  }

public:
  haiku_monitor()
    : BHandler("Factor NodeMonitor"), directory(false), owns_read_fd(true), read_fd(-1),
      write_fd(-1), failure(0) {}
  virtual ~haiku_monitor() {
    if (write_fd >= 0) close(write_fd);
    if (owns_read_fd && read_fd >= 0) close(read_fd);
  }
  status_t start(const char* path) {
    BEntry entry(path, true);
    status_t status = entry.GetNodeRef(&root);
    if (status != B_OK) return status;
    directory = entry.IsDirectory();
    uint32 flags = B_WATCH_NAME | B_WATCH_STAT | B_WATCH_ATTR;
    if (directory) flags |= B_WATCH_DIRECTORY | B_WATCH_CHILDREN;
    // Register before enumeration. The shared looper lock prevents message
    // delivery until the initial inode/name cache is ready; queued creation
    // and removal notifications then update that cache.
    status = watch_node(&root, flags, this);
    if (status != B_OK) return status;
    if (directory) {
      BDirectory dir(&entry);
      status = dir.InitCheck();
      if (status != B_OK) return status;
      BEntry child;
      while ((status = dir.GetNextEntry(&child, false)) == B_OK) {
        node_ref node;
        char name[256];
        status_t child_status = child.GetNodeRef(&node);
        if (child_status != B_OK) return child_status;
        child_status = child.GetName(name);
        if (child_status != B_OK) return child_status;
        names[node.node].insert(name);
      }
      if (status != B_ENTRY_NOT_FOUND) return status;
    }
    return B_OK;
  }
  int descriptor() {
    std::lock_guard<std::mutex> guard(queue_mutex);
    if (read_fd < 0) {
      int descriptors[2];
      if (!monitor_pipe(descriptors)) return -1;
      read_fd = descriptors[0]; write_fd = descriptors[1];
      if (!events.empty() || failure) wake();
    }
    return read_fd;
  }
  int take_descriptor() {
    if (!owns_read_fd) { errno = EBADF; return -1; }
    int result = descriptor();
    if (result >= 0) owns_read_fd = false;
    return result;
  }
  int pop(haiku_monitor_event* event) {
    std::lock_guard<std::mutex> guard(queue_mutex);
    if (failure) { errno = failure; return -1; }
    if (events.empty()) return 0;
    *event = events.front(); events.pop_front(); return 1;
  }
  virtual void MessageReceived(BMessage* message) {
    if (message->what != B_NODE_MONITOR) { BHandler::MessageReceived(message); return; }
    try {
      int32 opcode, device;
      int64 node;
      if (message->FindInt32("opcode", &opcode) != B_OK
          || message->FindInt32("device", &device) != B_OK
          || message->FindInt64("node", &node) != B_OK) { fail(EIO); return; }
      if (device != root.device) return;
      if (opcode == B_ENTRY_CREATED || opcode == B_ENTRY_REMOVED) {
        int64 parent; const char* name;
        if (message->FindInt64("directory", &parent) != B_OK
            || message->FindString("name", &name) != B_OK) { fail(EIO); return; }
        if (directory && parent == root.node) {
          if (opcode == B_ENTRY_CREATED) {
            names[node].insert(name); enqueue(1, name);
          } else {
            enqueue(2, name);
            auto i = names.find(node);
            if (i != names.end()) { i->second.erase(name); if (i->second.empty()) names.erase(i); }
          }
        } else if (!directory && node == root.node) enqueue(opcode == B_ENTRY_CREATED ? 1 : 2, "");
      } else if (opcode == B_ENTRY_MOVED) {
        int64 from, to; const char* old_name; const char* new_name;
        if (message->FindInt64("from directory", &from) != B_OK
            || message->FindInt64("to directory", &to) != B_OK
            || message->FindString("from name", &old_name) != B_OK
            || message->FindString("name", &new_name) != B_OK) { fail(EIO); return; }
        if (directory) {
          if (from == root.node) {
            enqueue(4, old_name);
            auto i = names.find(node);
            if (i != names.end()) { i->second.erase(old_name); if (i->second.empty()) names.erase(i); }
          }
          if (to == root.node) { names[node].insert(new_name); enqueue(5, new_name); }
        } else if (node == root.node) { enqueue(4, ""); enqueue(5, ""); }
      } else if (opcode == B_STAT_CHANGED || opcode == B_ATTR_CHANGED) {
        // Do not notify on mere reads (access time); matches ordinary monitor
        // semantics and avoids initial directory enumeration feedback.
        int32 fields;
        if (opcode == B_STAT_CHANGED && message->FindInt32("fields", &fields) == B_OK
            && (fields & ~B_STAT_ACCESS_TIME) == 0) return;
        if (node == root.node) enqueue(3, "");
        else {
          auto i = names.find(node);
          if (i != names.end()) for (const auto& name : i->second) enqueue(3, name.c_str());
        }
      }
    } catch (const std::bad_alloc&) { fail(ENOMEM); }
  }
};

VM_C_API void* factor_haiku_monitor_open(const char* path) {
  if (!ensure_monitor_looper()) return NULL;
  if (!monitor_looper->Lock()) { errno = EIO; return NULL; }
  haiku_monitor* monitor = NULL;
  try {
    monitor = new haiku_monitor;
    monitor_looper->AddHandler(monitor);
    status_t status = monitor->start(path);
    if (status == B_OK) {
      active_monitors.push_back(monitor);
      monitor_looper->Unlock(); return monitor;
    }
    errno = status;
  } catch (const std::bad_alloc&) { errno = ENOMEM; }
  int error = errno;
  if (monitor) {
    stop_watching(monitor); monitor_looper->RemoveHandler(monitor); delete monitor;
  }
  monitor_looper->Unlock(); errno = error; return NULL;
}
// One native wakeup serves all Factor readers. The legacy per-monitor pipe
// is allocated only when its public fd API is requested.
VM_C_API int factor_haiku_monitor_shared_dup_fd() {
  if (!ensure_monitor_looper()) return -1;
  std::lock_guard<std::mutex> guard(monitor_init_mutex);
  // Keep the native endpoint open: failed Factor port construction must not
  // leave active writers without a reader or prevent a later reader restart.
  int result = dup(shared_read_fd);
  if (result < 0) return -1;
  if (fcntl(result, F_SETFD, FD_CLOEXEC) < 0) {
    int error = errno; close(result); errno = error; return -1;
  }
  char byte = 1;
  ssize_t written;
  do { written = write(shared_write_fd, &byte, 1); } while (written < 0 && errno == EINTR);
  if (written < 0 && errno != EAGAIN) {
    int error = errno; close(result); errno = error; return -1;
  }
  return result;
}
VM_C_API int factor_haiku_monitor_shared_next(void** handle, haiku_monitor_event* event) {
  if (!handle || !event) { errno = EINVAL; return -1; }
  *handle = NULL;
  if (!monitor_looper) return 0;
  if (!monitor_looper->Lock()) { errno = EIO; return -1; }
  int result = 0;
  size_t count = active_monitors.size();
  for (size_t i = 0; i < count; ++i) {
    size_t index = (next_monitor_index + i) % count;
    haiku_monitor* monitor = active_monitors[index];
    result = monitor->pop(event);
    if (result != 0) {
      *handle = monitor; next_monitor_index = (index + 1) % count; break;
    }
  }
  int error = errno;
  monitor_looper->Unlock(); errno = error; return result;
}
VM_C_API int factor_haiku_monitor_fd(void* pointer) {
  return static_cast<haiku_monitor*>(pointer)->descriptor();
}
// Called only after Factor has created an exception-safe fd owner.
VM_C_API int factor_haiku_monitor_take_fd(void* pointer) {
  return static_cast<haiku_monitor*>(pointer)->take_descriptor();
}
VM_C_API int factor_haiku_monitor_next(void* pointer, haiku_monitor_event* event) {
  return static_cast<haiku_monitor*>(pointer)->pop(event);
}
VM_C_API void factor_haiku_monitor_close(void* pointer) {
  haiku_monitor* monitor = static_cast<haiku_monitor*>(pointer);
  if (monitor_looper->Lock()) {
    stop_watching(monitor);
    monitor_looper->RemoveHandler(monitor);
    active_monitors.erase(std::remove(active_monitors.begin(), active_monitors.end(), monitor), active_monitors.end());
    if (!active_monitors.empty()) next_monitor_index %= active_monitors.size();
    else next_monitor_index = 0;
    delete monitor;
    monitor_looper->Unlock();
  }
  // Until take_fd succeeds, the native destructor owns both legacy endpoints.
}
}
