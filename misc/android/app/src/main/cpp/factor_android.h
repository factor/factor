#pragma once

#include <stdint.h>
#include <jni.h>

#ifdef __cplusplus
extern "C" {
#endif

enum factor_android_event_type {
  FACTOR_ANDROID_EVENT_NONE = 0,
  FACTOR_ANDROID_EVENT_SURFACE = 1,
  FACTOR_ANDROID_EVENT_SURFACE_LOST = 2,
  FACTOR_ANDROID_EVENT_RESIZE = 3,
  FACTOR_ANDROID_EVENT_FOCUS = 4,
  FACTOR_ANDROID_EVENT_POINTER_DOWN = 5,
  FACTOR_ANDROID_EVENT_POINTER_UP = 6,
  FACTOR_ANDROID_EVENT_POINTER_MOVE = 7,
  FACTOR_ANDROID_EVENT_KEY_DOWN = 8,
  FACTOR_ANDROID_EVENT_KEY_UP = 9,
  FACTOR_ANDROID_EVENT_QUIT = 10,
  FACTOR_ANDROID_EVENT_TEXT = 11,
};

struct factor_android_event {
  int32_t type;
  int32_t code;
  int32_t modifiers;
  int32_t pointer;
  float x;
  float y;
  uint32_t character = 0;
};

int factor_android_poll_event(struct factor_android_event* event);
int factor_android_wait_for_surface(int timeout_ms);
int factor_android_surface_width(void);
int factor_android_surface_height(void);
float factor_android_density(void);

int factor_android_gl_open(void);
int factor_android_gl_make_current(void);
int factor_android_gl_swap(void);
void factor_android_gl_close(void);
void factor_android_gl_suspend(void);
void* factor_android_gl_proc(const char* name);
void* factor_android_gl_context(void);

char* factor_android_clipboard_get(void);
void factor_android_clipboard_set(const char* text);
void factor_android_free(void* pointer);
void factor_android_finish(void);
void factor_android_show_keyboard(int visible);
void factor_android_open_url(const char* url);
JavaVM* factor_android_java_vm(void);
jobject factor_android_activity(void);

#ifdef __cplusplus
}
#endif
