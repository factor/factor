#include "factor_android_jni.hpp"
#include "factor_android.h"

#include <condition_variable>
#include <mutex>
#include <thread>
#include <utility>

namespace {

bool run_java_work(JNIEnv* env, const std::function<void(JNIEnv*)>& work) {
  // This thread stays attached for its lifetime, so returning from a callback
  // does not release local references as returning to Java normally would.
  const bool frame_created = env->PushLocalFrame(32) == JNI_OK;
  if (frame_created) work(env);
  const bool failed = env->ExceptionCheck();
  if (failed) {
    env->ExceptionDescribe();
    env->ExceptionClear();
  }
  if (frame_created) env->PopLocalFrame(nullptr);
  return frame_created && !failed;
}

class java_dispatcher {
  // Keep the caller's turn until its callback finishes. Waiting below releases
  // state_mutex; that alone would let another caller replace the pending work.
  std::mutex caller_mutex;
  std::mutex state_mutex;
  std::condition_variable changed;
  bool ready = false;
  bool attached = false;
  bool succeeded = false;
  std::function<void(JNIEnv*)> pending_work;

  void run(JavaVM* vm) {
    JNIEnv* env = nullptr;
    const bool worker_attached = vm && vm->AttachCurrentThread(&env, nullptr) == JNI_OK;
    std::unique_lock<std::mutex> lock(state_mutex);
    attached = worker_attached;
    ready = true;
    changed.notify_all();
    if (!attached) return;
    for (;;) {
      changed.wait(lock, [&] { return static_cast<bool>(pending_work); });
      lock.unlock();
      const bool result = run_java_work(env, pending_work);
      lock.lock();
      succeeded = result;
      pending_work = nullptr;
      changed.notify_all();
    }
  }

public:
  java_dispatcher() {
    std::thread([this, vm = factor_android_java_vm()] { run(vm); }).detach();
  }

  bool dispatch(std::function<void(JNIEnv*)> work) {
    std::lock_guard<std::mutex> caller(caller_mutex);
    std::unique_lock<std::mutex> lock(state_mutex);
    changed.wait(lock, [&] { return ready; });
    if (!attached) return false;
    pending_work = std::move(work);
    changed.notify_all();
    changed.wait(lock, [&] { return !pending_work; });
    return succeeded;
  }
};

}  // namespace

bool factor_android_dispatch_java(std::function<void(JNIEnv*)> work) {
  if (!work) return false;
  // The VM exits the app with _exit while Android callbacks may still run.
  // Keep the attached worker and its synchronization alive for process lifetime.
  static java_dispatcher& dispatcher = *new java_dispatcher;
  return dispatcher.dispatch(std::move(work));
}
