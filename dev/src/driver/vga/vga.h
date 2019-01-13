#include <stddef.h>
#include <stdint.h>

size_t buffer_get_index(int col, int row);

void buffer_next_line(int *col, int *row);

void buffer_next(int *col, int *row);