#include <stddef.h>
#include <stdint.h>

// The VGA Buffer is at 0xB8000
volatile uint16_t *vga_buffer = (uint16_t *)0xB8000;
const int VGA_COLS = 80;
const int VGA_ROWS = 25;

void buffer_fix_boundaries(int *col, int *row)
{
	if (*col >= VGA_COLS)
	{
		*col = 0;
		*row++;
	}
	if (*row >= VGA_ROWS)
	{
		*row = 0;
	}
}

size_t buffer_get_index(int col, int row)
{
    buffer_fix_boundaries(&col, &row);
	return (VGA_COLS * row) + col;
}

void buffer_next_line(int *col, int *row)
{
	*col = 0;
	*row++;
	buffer_fix_boundaries(&col, &row);
}

void buffer_next(int *col, int *row)
{
	*col++;
	buffer_fix_boundaries(&col, &row);
}