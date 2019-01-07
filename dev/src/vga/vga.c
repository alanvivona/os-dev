#include <stddef.h>
#include <stdint.h>

volatile uint16_t *vga_buffer = (uint16_t *)0xB8000;
const int VGA_COLS = 80;
const int VGA_ROWS = 25;

int term_col = 0;
int term_row = 0;

void buffer_fix_boundaries()
{
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

size_t buffer_get_index()
{
	return (VGA_COLS * term_row) + term_col;
}

void buffer_next_line()
{
	term_col = 0;
	term_row++;
	buffer_fix_boundaries();
}

void buffer_next()
{
	term_col++;
	buffer_fix_boundaries();
}

void buffer_jump_to(int row, int col)
{
	term_col = col;
	term_row = row;
	buffer_fix_boundaries();
}