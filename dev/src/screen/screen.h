#include <stddef.h>
#include <stdint.h>

void screen_set_default_colors(uint8_t *fg, uint8_t *bg);

void screen_putc(char c, uint8_t *color);

void screen_puts(const char *str, uint8_t *color);

void screen_print_line(uint8_t *color, bool is_vertical, uint8_t position, uint8_t size);

void screen_print_square(uint8_t *color, uint8_t position, uint8_t size);

void screen_clear();