#include <stddef.h>
#include <stdint.h>

#if defined(__linux__)
#error "This code must be compiled with a cross-compiler"
#elif !defined(__i386__)
#error "This code must be compiled with an x86-elf compiler"
#endif

/* Defining boolean values */
typedef enum
{
	false,
	true
} bool;

/* VGA buffer definition START */
volatile uint16_t *vga_buffer = (uint16_t *)0xB8000;
const int VGA_COLS = 80;
const int VGA_ROWS = 25;

int term_col = 0;
int term_row = 0;

void buffer_fix_boundaries(){
	if (term_col >= VGA_COLS)
	{
		term_col = 0;
		term_row++;
	}
	if (term_row >= VGA_ROWS)
	{
		term_row = 0;
	}
}

size_t buffer_get_index(){
	return (VGA_COLS * term_row) + term_col;
}

void buffer_jump_line(){
	term_col = 0;
	term_row++;
	buffer_fix_boundaries();
}

void buffer_jump_next(){
	term_col++;
	buffer_fix_boundaries();
}

void buffer_jump_to(int row, int col){
	term_col = col;
	term_row = row;
	buffer_fix_boundaries();
}
/* VGA buffer definition END */

/* Color definitions START */
uint8_t color_black = 0b00000000;
uint8_t color_green = 0b00000001;
uint8_t color_red = 0b00000010;
uint8_t color_cyan = 0b00000011;
uint8_t color_lgray = 0b00000111;
uint8_t color_gray = 0b00001000;
uint8_t color_white = 0b00001111;

uint8_t term_color; // a single byte containing fg and bg color

void term_set_colors(uint8_t *fg, uint8_t *bg)
{
	term_color = *fg | (*bg << 4);
}
/* Color definitions END */

uint8_t tab_size = 0b00000010;

void term_clear()
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

void term_print_char(char c, uint8_t *color, size_t buffer_index)
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
				for(size_t i = 0; i < tab_size; i++)
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

void term_print_string(const char *str, uint8_t *color)
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

void term_print_line(const char c, uint8_t *color, bool is_vertical)
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

void kernel_main()
{
	term_set_colors(&color_white, &color_black);
	term_clear();

	term_print_line('-', &term_color, 0);
	term_print_line('-', &term_color, 1);

	term_set_colors(&color_cyan, &color_black);
	term_print_string("\tGreetins, human!\n", &term_color);

	term_set_colors(&color_red, &color_black);
	term_print_string("\tGreetings, human!\n", &term_color);

	term_set_colors(&color_gray, &color_black);
	term_print_string("\tGreetings, human!\n", &term_color);

	term_set_colors(&color_lgray, &color_red);
	term_print_string("\tGreetings, human!\n", &term_color);

	term_set_colors(&color_green, &color_black);
	term_print_string("\tGreetings, human!\n", &term_color);
}