#include <stddef.h>
#include <stdint.h>

#include "colors.h"

#if defined(__linux__)
#error "This code must be compiled with a cross-compiler"
#elif !defined(__i386__)
#error "This code must be compiled with an x86-elf compiler"
#endif

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