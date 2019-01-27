ENTRY(_Kernel.Start)
OUTPUT_FORMAT(elf32-i386)

SECTIONS {
	. = 0x100000;

	.text : {
		*(.text);
	}
}