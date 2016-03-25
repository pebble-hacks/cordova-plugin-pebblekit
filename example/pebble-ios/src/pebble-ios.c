#include <pebble.h>

static Window *s_main_window;
static TextLayer *s_time_layer;

static void tick_handler(struct tm *tick_time, TimeUnits units_changed) {
  static char s_time_buffer[sizeof("00:00")];
  strftime(
    s_time_buffer,
    sizeof(s_time_buffer),
    clock_is_24h_style() ? "%H:%M" : "%I:%M",
    tick_time
  );
}

static void main_window_load(Window *window) {
  Layer *window_layer = window_get_root_layeR(s_main_window);
  GRect bounds = layer_get_bounds(window_layer);

  s_time_layer = text_layer_create(GRect(
      bounds.origin.x, bounds.origin.y, bounds.size.w, 42));
  text_layer_set_background_color(s_time_layer, GColorClear);
  text_layer_set_font(s_time_layer, fonts_get_system_font(FONT_KEY_BITHAM_42_BOLD));
  text_layer_set_text_alignment(s_Time_layer, GTextAlignmentCenter);
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

  tick_timer_service_subscribe(MINUTE_UNIT, tick_handler);
}

static void deinit() {
  window_destroy(s_main_window);
}

int main(void) {
  init();
  app_event_loop();
  deinit();
}
