#include <pebble.h>

static Window *s_main_window;
static TextLayer *s_time_layer;

typedef enum {
  AppKeyInteger = 0,
  AppKeyString = 1,
  AppKeyBoolean = 2,
  AppKeyData = 3
} AppKeys;

static void tick_handler(struct tm *tick_time, TimeUnits units_changed) {
  static char s_time_buffer[sizeof("00:00")];
  strftime(
    s_time_buffer,
    sizeof(s_time_buffer),
    clock_is_24h_style() ? "%H:%M" : "%I:%M",
    tick_time
  );
}

static void inbox_received_callback(DictionaryIterator *iter, void *context) {
  APP_LOG(APP_LOG_LEVEL_DEBUG, "New message received");

  Tuple *tuple = dict_find(iter, AppKeyInteger);
  if (tuple) {
    APP_LOG(APP_LOG_LEVEL_DEBUG, "Got integer %d", (int) tuple->value->int32);
  }

  tuple = dict_find(iter, AppKeyString);
  if (tuple) {
    APP_LOG(APP_LOG_LEVEL_DEBUG, "Got string %s", tuple->value->cstring);
  }

  tuple = dict_find(iter, AppKeyBoolean);
  if (tuple) {
    APP_LOG(APP_LOG_LEVEL_DEBUG, "Got boolean %s", tuple->value->int16 ? "true" : "false");
  }
}

static void inbox_dropped_callback(AppMessageResult reason, void *context) {
  APP_LOG(APP_LOG_LEVEL_ERROR, "Message dropped. Reason: %d", (int) reason);
}

static void outbox_sent_callback(DictionaryIterator *iter, void *context) {
  APP_LOG(APP_LOG_LEVEL_DEBUG, "Message sent successfully");
}

static void outbox_failed_callback(DictionaryIterator *iter,
    AppMessageResult reason, void *context) {

  APP_LOG(APP_LOG_LEVEL_ERROR, "Message sent failed. Reason %d", (int) reason);
}

static void main_window_load(Window *window) {
  Layer *window_layer = window_get_root_layer(s_main_window);
  GRect bounds = layer_get_bounds(window_layer);

  s_time_layer = text_layer_create(GRect(
      bounds.origin.x, bounds.origin.y, bounds.size.w, 42));
  text_layer_set_background_color(s_time_layer, GColorClear);
  text_layer_set_font(s_time_layer, fonts_get_system_font(FONT_KEY_BITHAM_42_BOLD));
  text_layer_set_text_alignment(s_time_layer, GTextAlignmentCenter);
  text_layer_set_text(s_time_layer, "00:00");

  layer_add_child(window_layer, text_layer_get_layer(s_time_layer));
}

static void main_window_unload(Window *window) {
  text_layer_destroy(s_time_layer);
}

static void init() {
  s_main_window = window_create();

  window_set_window_handlers(s_main_window, (WindowHandlers) {
    .load = main_window_load,
    .unload = main_window_unload
  });

  window_stack_push(s_main_window, true);

  app_message_register_inbox_received(inbox_received_callback);
  app_message_register_inbox_dropped(inbox_dropped_callback);
  app_message_register_outbox_sent(outbox_sent_callback);
  app_message_register_outbox_failed(outbox_failed_callback);

  const uint32_t inbox_size = 150;
  const uint32_t outbox_size = inbox_size;
  app_message_open (inbox_size, outbox_size);

  tick_timer_service_subscribe(MINUTE_UNIT, tick_handler);
}

static void deinit() {
  window_destroy(s_main_window);
}

int main(void) {
  init();
  app_event_loop();
  deinit();

  return 0;
}
