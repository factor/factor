#include "factor_android.h"
#include "factor_android_assets.h"
#include "factor_android_jni.hpp"
#include "factor_android_utf.h"

#include <EGL/egl.h>
#include <GLES3/gl3.h>
#include <android/asset_manager.h>
#include <android/input.h>
#include <android/log.h>
#include <android/native_activity.h>
#include <android/native_window.h>
#include <android_native_app_glue.h>
#include <jni.h>

#include <array>
#include <condition_variable>
#include <cstdlib>
#include <cstring>
#include <fcntl.h>
#include <mutex>
#include <string>
#include <thread>
#include <unistd.h>

namespace {
constexpr char tag[] = "Factor";
constexpr size_t event_capacity = 256;

JNIEnv* env_for(ANativeActivity* activity, bool* attached);
uint32_t key_character(ANativeActivity* activity, int device, int code,
                       int modifiers);

struct state {
  std::mutex mutex;
  std::condition_variable changed;
  android_app* app = nullptr;
  ANativeWindow* window = nullptr;
  std::array<factor_android_event, event_capacity> events{};
  size_t event_read = 0;
  size_t event_count = 0;
  float density = 1.0f;
  bool factor_started = false;
  ANativeActivity* factor_activity = nullptr;
  EGLDisplay display = EGL_NO_DISPLAY;
  EGLSurface surface = EGL_NO_SURFACE;
  EGLContext context = EGL_NO_CONTEXT;
};

// Factor can request process exit from its worker while Android is still
// delivering lifecycle callbacks. Keep bridge synchronization alive until the
// kernel tears down the process; static destruction would race those callbacks.
state& global = *new state;

extern "C" void factor_android_start(const char*) __attribute__((weak));
extern "C" void factor_android_start_run(const char*, const char*)
    __attribute__((weak));
extern "C" void factor_android_set_executable_path(const char*)
    __attribute__((weak));

std::string intent_string_extra(ANativeActivity*, const char*);
std::string native_library_directory(ANativeActivity*);

void log_error(const char* message) {
  __android_log_write(ANDROID_LOG_ERROR, tag, message);
}

void push_event(factor_android_event event) {
  std::lock_guard<std::mutex> lock(global.mutex);
  if (global.event_count == event_capacity) {
    global.event_read = (global.event_read + 1) % event_capacity;
    --global.event_count;
  }
  const size_t index = (global.event_read + global.event_count) % event_capacity;
  global.events[index] = event;
  ++global.event_count;
  global.changed.notify_all();
}

void update_window(ANativeWindow* next) {
  std::lock_guard<std::mutex> lock(global.mutex);
  if (next) ANativeWindow_acquire(next);
  if (global.window) ANativeWindow_release(global.window);
  global.window = next;
  global.changed.notify_all();
}

void finish_factor(ANativeActivity* expected, int status) {
  ANativeActivity* activity = nullptr;
  {
    std::lock_guard<std::mutex> lock(global.mutex);
    if (expected && global.factor_activity != expected) return;
    activity = global.factor_activity;
    global.factor_activity = nullptr;
  }
  __android_log_print(ANDROID_LOG_INFO, tag, "Factor exited with status %d", status);
  if (activity) ANativeActivity_finish(activity);
}

void start_factor(android_app* app) {
  {
    std::lock_guard<std::mutex> lock(global.mutex);
    if (global.factor_started) return;
    global.factor_started = true;
    global.factor_activity = app->activity;
  }
  const std::string path = app->activity->internalDataPath;
  setenv("SSL_CERT_DIR", "/system/etc/security/cacerts", 0);
#if defined(__aarch64__)
  constexpr char image_asset[] = "factor.arm64-v8a.image";
#else
#error Unsupported Factor Android ABI
#endif
  AAssetManager* assets = app->activity->assetManager;
  if (!factor_android::extract_resources(assets, path + "/factor") ||
      !factor_android::copy_asset(assets, image_asset, path + "/factor.image")) {
    log_error("unable to prepare packaged Factor resources");
    finish_factor(app->activity, 1);
    return;
  }
  const std::string run = intent_string_extra(app->activity, "factorRun");
  const std::string executable = native_library_directory(app->activity) +
                                 "/libfactor-cli.so";
  std::thread([activity = app->activity, path, run, executable] {
    JNIEnv* factor_env = nullptr;
    const bool attached = activity->vm->AttachCurrentThread(&factor_env, nullptr) == JNI_OK;
    if (!attached) {
      log_error("unable to attach Factor worker to Java");
      finish_factor(activity, 1);
      return;
    }
    const int log = open((path + "/factor.log").c_str(),
                         O_WRONLY | O_CREAT | O_TRUNC, 0600);
    if (log >= 0) {
      dup2(log, STDOUT_FILENO);
      dup2(log, STDERR_FILENO);
      close(log);
    }
    if (factor_android_set_executable_path)
      factor_android_set_executable_path(executable.c_str());
    if (factor_android_start_run) {
      factor_android_start_run(path.c_str(), run.empty() ? nullptr : run.c_str());
    } else if (factor_android_start) {
      factor_android_start(path.c_str());
    } else {
      log_error("factor_android_start is not linked");
    }
    activity->vm->DetachCurrentThread();
    finish_factor(activity, 0);
  }).detach();
}

void app_command(android_app* app, int32_t command) {
  switch (command) {
    case APP_CMD_START:
      start_factor(app);
      break;
    case APP_CMD_INIT_WINDOW:
      update_window(app->window);
      push_event({FACTOR_ANDROID_EVENT_SURFACE, 0, 0, 0, 0.0f, 0.0f});
      break;
    case APP_CMD_TERM_WINDOW:
      update_window(nullptr);
      push_event({FACTOR_ANDROID_EVENT_SURFACE_LOST, 0, 0, 0, 0.0f, 0.0f});
      break;
    case APP_CMD_WINDOW_RESIZED:
    case APP_CMD_CONTENT_RECT_CHANGED:
      push_event({FACTOR_ANDROID_EVENT_RESIZE, 0, 0, 0, 0.0f, 0.0f});
      break;
    case APP_CMD_CONFIG_CHANGED: {
      const float density = app->config
          ? AConfiguration_getDensity(app->config) /
                static_cast<float>(ACONFIGURATION_DENSITY_MEDIUM)
          : 1.0f;
      {
        std::lock_guard<std::mutex> lock(global.mutex);
        global.density = density;
      }
      push_event({FACTOR_ANDROID_EVENT_RESIZE, 0, 0, 0, 0.0f, 0.0f});
      break;
    }
    case APP_CMD_GAINED_FOCUS:
      push_event({FACTOR_ANDROID_EVENT_FOCUS, 1, 0, 0, 0.0f, 0.0f});
      break;
    case APP_CMD_LOST_FOCUS:
      push_event({FACTOR_ANDROID_EVENT_FOCUS, 0, 0, 0, 0.0f, 0.0f});
      break;
    case APP_CMD_DESTROY:
      push_event({FACTOR_ANDROID_EVENT_QUIT, 0, 0, 0, 0.0f, 0.0f});
      break;
    default:
      break;
  }
}

int32_t input_event(android_app* app, AInputEvent* input) {
  const int32_t source = AInputEvent_getSource(input);
  if (AInputEvent_getType(input) == AINPUT_EVENT_TYPE_MOTION) {
    const int32_t action = AMotionEvent_getAction(input);
    const int32_t index = (action & AMOTION_EVENT_ACTION_POINTER_INDEX_MASK) >>
                          AMOTION_EVENT_ACTION_POINTER_INDEX_SHIFT;
    const int32_t masked = action & AMOTION_EVENT_ACTION_MASK;
    int type = FACTOR_ANDROID_EVENT_POINTER_MOVE;
    if (masked == AMOTION_EVENT_ACTION_DOWN ||
        masked == AMOTION_EVENT_ACTION_POINTER_DOWN)
      type = FACTOR_ANDROID_EVENT_POINTER_DOWN;
    else if (masked == AMOTION_EVENT_ACTION_UP ||
             masked == AMOTION_EVENT_ACTION_POINTER_UP ||
             masked == AMOTION_EVENT_ACTION_CANCEL)
      type = FACTOR_ANDROID_EVENT_POINTER_UP;
    push_event({type, source, AMotionEvent_getMetaState(input),
                AMotionEvent_getPointerId(input, static_cast<size_t>(index)),
                AMotionEvent_getX(input, static_cast<size_t>(index)),
                AMotionEvent_getY(input, static_cast<size_t>(index))});
    return 1;
  }
  if (AInputEvent_getType(input) == AINPUT_EVENT_TYPE_KEY) {
    const int action = AKeyEvent_getAction(input);
    const int code = AKeyEvent_getKeyCode(input);
    const int modifiers = AKeyEvent_getMetaState(input);
    push_event({action == AKEY_EVENT_ACTION_UP ? FACTOR_ANDROID_EVENT_KEY_UP
                                               : FACTOR_ANDROID_EVENT_KEY_DOWN,
                code, modifiers, 0, 0.0f, 0.0f,
                key_character(app->activity, AInputEvent_getDeviceId(input),
                              code, modifiers)});
    return 1;
  }
  return 0;
}

JNIEnv* env_for(ANativeActivity* activity, bool* attached) {
  *attached = false;
  JNIEnv* env = nullptr;
  if (activity->vm->GetEnv(reinterpret_cast<void**>(&env), JNI_VERSION_1_6) != JNI_OK) {
    if (activity->vm->AttachCurrentThread(&env, nullptr) != JNI_OK) return nullptr;
    *attached = true;
  }
  return env;
}

uint32_t key_character(ANativeActivity* activity, int device, int code,
                       int modifiers) {
  bool attached = false;
  JNIEnv* env = env_for(activity, &attached);
  if (!env) return 0;
  jclass type = env->GetObjectClass(activity->clazz);
  jmethodID method = env->GetMethodID(type, "keyCharacter", "(III)I");
  const uint32_t result = method
      ? static_cast<uint32_t>(env->CallIntMethod(activity->clazz, method, device,
                                                code, modifiers))
      : 0;
  if (env->ExceptionCheck()) {
    env->ExceptionClear();
    env->DeleteLocalRef(type);
    if (attached) activity->vm->DetachCurrentThread();
    return 0;
  }
  env->DeleteLocalRef(type);
  if (attached) activity->vm->DetachCurrentThread();
  return result;
}

jobject clipboard_manager(JNIEnv* env, jobject activity) {
  jclass activity_class = env->GetObjectClass(activity);
  jmethodID service = env->GetMethodID(activity_class, "getSystemService",
                                       "(Ljava/lang/String;)Ljava/lang/Object;");
  jstring name = env->NewStringUTF("clipboard");
  jobject manager = env->CallObjectMethod(activity, service, name);
  env->DeleteLocalRef(name);
  env->DeleteLocalRef(activity_class);
  return manager;
}

std::string intent_string_extra(ANativeActivity* activity, const char* name) {
  bool attached = false;
  JNIEnv* env = env_for(activity, &attached);
  if (!env) return {};
  jclass activity_class = env->GetObjectClass(activity->clazz);
  jmethodID get_intent = env->GetMethodID(
      activity_class, "getIntent", "()Landroid/content/Intent;");
  jobject intent = env->CallObjectMethod(activity->clazz, get_intent);
  jclass intent_class = env->GetObjectClass(intent);
  jmethodID get_extra = env->GetMethodID(
      intent_class, "getStringExtra", "(Ljava/lang/String;)Ljava/lang/String;");
  jstring key = env->NewStringUTF(name);
  jstring value = static_cast<jstring>(env->CallObjectMethod(intent, get_extra, key));
  std::string result;
  if (value) {
    const char* utf8 = env->GetStringUTFChars(value, nullptr);
    result = utf8;
    env->ReleaseStringUTFChars(value, utf8);
    env->DeleteLocalRef(value);
  }
  env->DeleteLocalRef(key);
  env->DeleteLocalRef(intent_class);
  env->DeleteLocalRef(intent);
  env->DeleteLocalRef(activity_class);
  if (attached) activity->vm->DetachCurrentThread();
  return result;
}

std::string native_library_directory(ANativeActivity* activity) {
  bool attached = false;
  JNIEnv* env = env_for(activity, &attached);
  if (!env) return {};
  jclass activity_class = env->GetObjectClass(activity->clazz);
  jmethodID get_info = env->GetMethodID(
      activity_class, "getApplicationInfo", "()Landroid/content/pm/ApplicationInfo;");
  jobject info = env->CallObjectMethod(activity->clazz, get_info);
  jclass info_class = env->GetObjectClass(info);
  jfieldID field = env->GetFieldID(info_class, "nativeLibraryDir",
                                   "Ljava/lang/String;");
  jstring value = static_cast<jstring>(env->GetObjectField(info, field));
  const char* utf8 = env->GetStringUTFChars(value, nullptr);
  std::string result = utf8;
  env->ReleaseStringUTFChars(value, utf8);
  env->DeleteLocalRef(value);
  env->DeleteLocalRef(info_class);
  env->DeleteLocalRef(info);
  env->DeleteLocalRef(activity_class);
  if (attached) activity->vm->DetachCurrentThread();
  return result;
}
}  // namespace

extern "C" void android_main(android_app* app) {
  {
    std::lock_guard<std::mutex> lock(global.mutex);
    global.app = app;
    global.event_read = 0;
    global.event_count = 0;
  }
  app->onAppCmd = app_command;
  app->onInputEvent = input_event;
  if (app->config) {
    global.density = AConfiguration_getDensity(app->config) /
                     static_cast<float>(ACONFIGURATION_DENSITY_MEDIUM);
  }
  while (!app->destroyRequested) {
    int events = 0;
    android_poll_source* source = nullptr;
    const int result = ALooper_pollOnce(-1, nullptr, &events,
                                        reinterpret_cast<void**>(&source));
    if (result >= 0 && source) source->process(app, source);
  }
  update_window(nullptr);
}

extern "C" __attribute__((visibility("default"))) void factor_android_finished(
    int status) {
  finish_factor(nullptr, status);
}

extern "C" int factor_android_poll_event(factor_android_event* event) {
  if (!event) return 0;
  std::lock_guard<std::mutex> lock(global.mutex);
  if (!global.event_count) return 0;
  *event = global.events[global.event_read];
  global.event_read = (global.event_read + 1) % event_capacity;
  --global.event_count;
  return 1;
}

extern "C" int factor_android_wait_for_surface(int timeout_ms) {
  std::unique_lock<std::mutex> lock(global.mutex);
  global.changed.wait_for(lock, std::chrono::milliseconds(timeout_ms),
                          [] { return global.window != nullptr; });
  return global.window != nullptr;
}

extern "C" int factor_android_surface_width() {
  std::lock_guard<std::mutex> lock(global.mutex);
  return global.window ? ANativeWindow_getWidth(global.window) : 0;
}

extern "C" int factor_android_surface_height() {
  std::lock_guard<std::mutex> lock(global.mutex);
  return global.window ? ANativeWindow_getHeight(global.window) : 0;
}

extern "C" float factor_android_density() {
  std::lock_guard<std::mutex> lock(global.mutex);
  return global.density;
}

extern "C" int factor_android_gl_open() {
  std::lock_guard<std::mutex> lock(global.mutex);
  if (!global.window) return 0;
  if (global.display == EGL_NO_DISPLAY) {
    global.display = eglGetDisplay(EGL_DEFAULT_DISPLAY);
    if (global.display == EGL_NO_DISPLAY ||
        !eglInitialize(global.display, nullptr, nullptr)) return 0;
  }
  const EGLint attributes[] = {EGL_RENDERABLE_TYPE, EGL_OPENGL_ES3_BIT,
                               EGL_SURFACE_TYPE, EGL_WINDOW_BIT,
                               EGL_RED_SIZE, 8, EGL_GREEN_SIZE, 8,
                               EGL_BLUE_SIZE, 8, EGL_ALPHA_SIZE, 8,
                               EGL_NONE};
  EGLConfig config = nullptr;
  EGLint count = 0;
  if (!eglChooseConfig(global.display, attributes, &config, 1, &count) || !count) return 0;
  const EGLint context_attributes[] = {EGL_CONTEXT_CLIENT_VERSION, 3, EGL_NONE};
  if (global.context == EGL_NO_CONTEXT)
    global.context = eglCreateContext(global.display, config, EGL_NO_CONTEXT,
                                      context_attributes);
  if (global.surface == EGL_NO_SURFACE)
    global.surface = eglCreateWindowSurface(global.display, config, global.window,
                                            nullptr);
  return global.context != EGL_NO_CONTEXT && global.surface != EGL_NO_SURFACE &&
         eglMakeCurrent(global.display, global.surface, global.surface, global.context);
}

extern "C" int factor_android_gl_make_current() {
  std::lock_guard<std::mutex> lock(global.mutex);
  return global.context != EGL_NO_CONTEXT && global.surface != EGL_NO_SURFACE &&
         eglMakeCurrent(global.display, global.surface, global.surface, global.context);
}

extern "C" int factor_android_gl_swap() {
  std::lock_guard<std::mutex> lock(global.mutex);
  return global.surface != EGL_NO_SURFACE && eglSwapBuffers(global.display, global.surface);
}

extern "C" void factor_android_gl_close() {
  std::lock_guard<std::mutex> lock(global.mutex);
  if (global.display == EGL_NO_DISPLAY) return;
  eglMakeCurrent(global.display, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
  if (global.surface != EGL_NO_SURFACE) eglDestroySurface(global.display, global.surface);
  if (global.context != EGL_NO_CONTEXT) eglDestroyContext(global.display, global.context);
  eglTerminate(global.display);
  global.display = EGL_NO_DISPLAY;
  global.surface = EGL_NO_SURFACE;
  global.context = EGL_NO_CONTEXT;
}

extern "C" void factor_android_gl_suspend() {
  std::lock_guard<std::mutex> lock(global.mutex);
  if (global.display == EGL_NO_DISPLAY) return;
  eglMakeCurrent(global.display, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
  if (global.surface != EGL_NO_SURFACE)
    eglDestroySurface(global.display, global.surface);
  global.surface = EGL_NO_SURFACE;
}

extern "C" void* factor_android_gl_proc(const char* name) {
  return reinterpret_cast<void*>(eglGetProcAddress(name));
}

extern "C" void* factor_android_gl_context() {
  std::lock_guard<std::mutex> lock(global.mutex);
  return global.context;
}

extern "C" char* factor_android_clipboard_get() {
  android_app* app = global.app;
  if (!app) return strdup("");
  std::string value;
  factor_android_dispatch_java([&](JNIEnv* env) {
    jobject manager = clipboard_manager(env, app->activity->clazz);
    jclass manager_class = env->GetObjectClass(manager);
    jmethodID get_clip = env->GetMethodID(manager_class, "getPrimaryClip", "()Landroid/content/ClipData;");
    jobject clip = env->CallObjectMethod(manager, get_clip);
    if (clip) {
      jclass clip_class = env->GetObjectClass(clip);
      jmethodID item_at = env->GetMethodID(clip_class, "getItemAt", "(I)Landroid/content/ClipData$Item;");
      jobject item = env->CallObjectMethod(clip, item_at, 0);
      jclass item_class = env->GetObjectClass(item);
      jmethodID coerce = env->GetMethodID(item_class, "coerceToText", "(Landroid/content/Context;)Ljava/lang/CharSequence;");
      jobject text = env->CallObjectMethod(item, coerce, app->activity->clazz);
      if (text) {
        jclass object_class = env->FindClass("java/lang/Object");
        jmethodID to_string = env->GetMethodID(object_class, "toString", "()Ljava/lang/String;");
        jstring string = static_cast<jstring>(env->CallObjectMethod(text, to_string));
        const jchar* utf16 = env->GetStringChars(string, nullptr);
        const jsize length = env->GetStringLength(string);
        value = factor_utf16_to_utf8(reinterpret_cast<const char16_t*>(utf16),
                                     static_cast<size_t>(length));
        env->ReleaseStringChars(string, utf16);
      }
    }
    env->DeleteLocalRef(manager_class);
    env->DeleteLocalRef(manager);
  });
  return strdup(value.c_str());
}

extern "C" void factor_android_clipboard_set(const char* text) {
  android_app* app = global.app;
  if (!app || !text) return;
  const std::u16string utf16 = factor_utf8_to_utf16(
      reinterpret_cast<const uint8_t*>(text), strlen(text));
  factor_android_dispatch_java([&](JNIEnv* env) {
    jobject manager = clipboard_manager(env, app->activity->clazz);
    jclass clip_class = env->FindClass("android/content/ClipData");
    jmethodID plain = env->GetStaticMethodID(clip_class, "newPlainText",
        "(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Landroid/content/ClipData;");
    jstring label = env->NewStringUTF("Factor");
    jstring value = env->NewString(reinterpret_cast<const jchar*>(utf16.data()),
                                   static_cast<jsize>(utf16.size()));
    jobject clip = env->CallStaticObjectMethod(clip_class, plain, label, value);
    jclass manager_class = env->GetObjectClass(manager);
    jmethodID set_clip = env->GetMethodID(manager_class, "setPrimaryClip", "(Landroid/content/ClipData;)V");
    env->CallVoidMethod(manager, set_clip, clip);
    env->DeleteLocalRef(value);
    env->DeleteLocalRef(label);
    env->DeleteLocalRef(manager_class);
    env->DeleteLocalRef(manager);
  });
}

extern "C" void factor_android_free(void* pointer) { free(pointer); }

extern "C" void factor_android_finish() {
  if (global.app) ANativeActivity_finish(global.app->activity);
}

extern "C" void factor_android_show_keyboard(int visible) {
  android_app* app = global.app;
  if (!app) return;
  factor_android_dispatch_java([&](JNIEnv* env) {
    jclass activity_class = env->GetObjectClass(app->activity->clazz);
    jmethodID method = env->GetMethodID(activity_class, "setKeyboardVisible", "(Z)V");
    env->CallVoidMethod(app->activity->clazz, method,
                        visible ? JNI_TRUE : JNI_FALSE);
    env->DeleteLocalRef(activity_class);
  });
}

extern "C" JavaVM* factor_android_java_vm() {
  return global.app ? global.app->activity->vm : nullptr;
}

extern "C" jobject factor_android_activity() {
  return global.app ? global.app->activity->clazz : nullptr;
}

extern "C" void factor_android_open_url(const char* url) {
  android_app* app = global.app;
  if (!app || !url) return;
  std::string address(url);
  factor_android_dispatch_java([&](JNIEnv* env) {
    jclass activity_class = env->GetObjectClass(app->activity->clazz);
    jmethodID method = env->GetMethodID(activity_class, "openUrl",
                                        "(Ljava/lang/String;)V");
    jstring value = env->NewStringUTF(address.c_str());
    env->CallVoidMethod(app->activity->clazz, method, value);
    env->DeleteLocalRef(value);
    env->DeleteLocalRef(activity_class);
  });
}

extern "C" JNIEXPORT void JNICALL
Java_org_factorcode_factor_FactorActivity_nativeCommitText(JNIEnv* env,
                                                            jclass,
                                                            jstring text) {
  if (!text) return;
  const jchar* characters = env->GetStringChars(text, nullptr);
  const jsize length = env->GetStringLength(text);
  for (jsize i = 0; i < length; ++i) {
    uint32_t character = characters[i];
    if (character >= 0xd800 && character <= 0xdbff && i + 1 < length) {
      const uint32_t low = characters[i + 1];
      if (low >= 0xdc00 && low <= 0xdfff) {
        character = 0x10000 + ((character - 0xd800) << 10) + (low - 0xdc00);
        ++i;
      }
    }
    push_event({FACTOR_ANDROID_EVENT_TEXT, 0, 0, 0, 0.0f, 0.0f,
                character});
  }
  env->ReleaseStringChars(text, characters);
}

extern "C" JNIEXPORT void JNICALL
Java_org_factorcode_factor_FactorActivity_nativeDeleteBackward(JNIEnv*,
                                                                jclass,
                                                                jint count) {
  for (jint i = 0; i < count; ++i) {
    push_event({FACTOR_ANDROID_EVENT_KEY_DOWN, AKEYCODE_DEL, 0, 0, 0.0f, 0.0f});
    push_event({FACTOR_ANDROID_EVENT_KEY_UP, AKEYCODE_DEL, 0, 0, 0.0f, 0.0f});
  }
}
