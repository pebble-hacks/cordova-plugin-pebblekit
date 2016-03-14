#include <pebble.h>

static Window *s_main_window;
static TextLayer *s_time_layer;
static TextLayer *s_event_title_layer;

typedef enum {
  AppKeyRequestEvent = 0,
  AppKeyEventTitle = 10,
  AppKeyEventHour = 11,
  AppKeyEventMinute = 12
} AppKeys;

static void tick_handler(struct tm *tick_time, TimeUnits units_changed) {
  static char s_time_buffer[sizeof("00:00")];
  strftime(
      s_time_buffer,
      sizeof(s_time_buffer),
      clock_is_24h_style() ? "%H:%M" : "%I:%M",
      tick_time
  );

  text_layer_set_text(s_time_layer, s_time_buffer);
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

  s_event_title_layer = text_layer_create(GRect(
      bounds.origin.x, bounds.size.h / 2, bounds.size.w, 60));
  text_layer_set_background_color(s_event_title_layer, GColorClear);
  text_layer_set_font(s_event_title_layer, fonts_get_system_font(FONT_KEY_GOTHIC_18_BOLD));;
  text_layer_set_text_alignment(s_event_title_layer, GTextAlignmentCenter);
  text_layer_set_text(s_event_title_layer, "Fetching events...");

  layer_add_child(window_layer, text_layer_get_layer(s_time_layer));
  layer_add_child(window_layer, text_layer_get_layer(s_event_title_layer));
}

static void request_event_data() {
  DictionaryIterator *out_iter;
  AppMessageResult result = app_message_outbox_begin(&out_iter);

  if (result != APP_MSG_OK) {
    APP_LOG(APP_LOG_LEVEL_ERROR, "Error preparing outbox: %d", (int) result);
    return;
  }

  int dummy = 0;
  dict_write_int(out_iter, AppKeyRequestEvent, &dummy, sizeof(int), true);
  result = app_message_outbox_send();

  if (result != APP_MSG_OK) {
    APP_LOG(APP_LOG_LEVEL_ERROR, "Error sending the outbox: %d", (int) result);
  } else {
    APP_LOG(APP_LOG_LEVEL_DEBUG, "No error sending the outbox");
  }
}

static void main_window_unload(Window *window) {
  text_layer_destroy(s_time_layer);
  text_layer_destroy(s_event_title_layer);
}

static void set_no_event() {
  text_layer_set_text(s_event_title_layer, "No more events for today");
}

static void inbox_received_callback(DictionaryIterator *iter, void *context) {
  APP_LOG(APP_LOG_LEVEL_DEBUG, "New message received");

  char *title;
  int32_t hour;
  int32_t minute;

  Tuple *tuple = dict_find(iter, AppKeyEventTitle);
  if (tuple) {
    title = tuple->value->cstring;
  } else {
    APP_LOG(APP_LOG_LEVEL_ERROR, "No event title found");
    set_no_event();
    return;
  }

  tuple = dict_find(iter, AppKeyEventHour);
  if (tuple) {
    hour = tuple->value->int32;
  } else {
    APP_LOG(APP_LOG_LEVEL_ERROR, "No hour found");
    set_no_event();
    return;
  }

  tuple = dict_find(iter, AppKeyEventMinute);
  if (tuple) {
    minute = tuple->value->int32;
  } else {
    APP_LOG(APP_LOG_LEVEL_ERROR, "No minute found");
    set_no_event();
    return;
  }

  static char s_event_time_buffer[sizeof("00:00")];
  time_t event_time = time(NULL);
  struct tm *tick_time = localtime(&event_time);
  tick_time->tm_hour = (int) hour;
  tick_time->tm_min = (int) minute;
  strftime(
      s_event_time_buffer,
      sizeof(s_event_time_buffer),
      clock_is_24h_style() ? "%H:%M" : "%I:%M",
      tick_time
  );

  // Pick a large enough size to handle particulartly length
  // event titles
  static char s_event_buffer[100];
  snprintf(
      s_event_buffer,
      sizeof(s_event_buffer),
      "%s at %s",
      title,
      s_event_time_buffer
  );
  text_layer_set_text(s_event_title_layer, s_event_buffer);
}

static void inbox_dropped_callback(AppMessageResult reason, void *context) {
  APP_LOG(APP_LOG_LEVEL_ERROR, "Message dropped. Reason: %d", (int) reason);
}

static void outbox_sent_callback(DictionaryIterator *iter, void *context) {
  APP_LOG(APP_LOG_LEVEL_DEBUG, "Message successfuly sent");
}

static void outbox_failed_callback(DictionaryIterator *iter,
    AppMessageResult reason, void *context) {

  APP_LOG(APP_LOG_LEVEL_ERROR, "Message sent failed. Reason: %d", (int) reason);
}

static void app_timer_callback(void *context) {
  request_event_data();
}

static void init() {
  s_main_window = window_create();

  window_set_window_handlers(s_main_window, (WindowHandlers) {
    .load = main_window_load,
    .unload = main_window_unload
  });

  window_stack_push(s_main_window, true);

  tick_timer_service_subscribe(MINUTE_UNIT, tick_handler);

  app_message_register_inbox_received(inbox_received_callback);
  app_message_register_inbox_dropped(inbox_dropped_callback);
  app_message_register_outbox_sent(outbox_sent_callback);
  app_message_register_outbox_failed(outbox_failed_callback);

  // Pick a large enough value for app messages that may contian particularly
  // lengthy event titles
  const uint32_t inbox_size = 150;
  const uint32_t outbox_size = inbox_size;
  app_message_open(inbox_size, outbox_size);

  app_timer_register(1000, app_timer_callback, NULL);
}

static void deinit() {
  window_destroy(s_main_window);
}

int main() {
  init();
  app_event_loop();
  deinit();

  return 0;
}

