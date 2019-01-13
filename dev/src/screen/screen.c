#include <stddef.h>
#include <stdint.h>

#include "driver/vga/vga.h"
#include "driver/vga/colors.h"

const uint8_t screen_tab_size = 0b00000010;

uint8_t screen_color; // a single byte containing fg and bg color

void screen_set_default_colors(uint8_t *fg, uint8_t *bg)
{
	screen_color = *fg | (*bg << 4);
}

void screen_putc(char c, uint8_t *color)
{
	switch (c)
	{
	case '\n':
		// support for new line
		{
			buffer_jump_line();
			break;
		}
	case '\t':
		// support for tab
		{
			for (size_t i = 0; i < screen_tab_size; i++)
			{
				buffer_jump_next();
			}
			break;
		}
	default:
	{
		vga_buffer[buffer_index] = ((uint16_t)*color << 8) | c;
		term_col++;
		break;
	}
	}
}

void screen_puts(const char *str, uint8_t *color)
{
	if (!color)
	{
		color = &term_color;
	}
	for (size_t i = 0; str[i] != '\0'; i++)
	{
		term_print_char(str[i], color, buffer_get_index());
	}
}

void screen_print_line(uint8_t *color, bool is_vertical, uint8_t position, uint8_t size)
{
	if (!color)
	{
		color = &term_color;
	}

	int limit = VGA_COLS;
	if (is_vertical)
	{
		int limit = VGA_ROWS;
	}

	for (size_t i = 0; i < limit; i++)
	{
		term_print_char(c, color, buffer_get_index());

		if (is_vertical)
		{
			term_print_char('\n', color, buffer_get_index());
		}
	}
}

void screen_print_square(uint8_t *color, uint8_t position, uint8_t size)
{
    
}

void screen_clear()
{
	for (int row = 0; row < VGA_ROWS; row++)
	{
		for (int col = 0; col < VGA_COLS; col++)
		{
			const size_t index = (VGA_COLS * row) + col;
			// Entries in the VGA buffer take the binary form BBBBFFFFCCCCCCCC, where:
			// - B is the background color
			// - F is the foreground color
			// - C is the ASCII character
			vga_buffer[index] = ((uint16_t)term_color << 8) | ' ';
		}
	}
}