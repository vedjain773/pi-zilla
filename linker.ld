ENTRY(_start)

SECTIONS
{
	. = 0x80000;

	.text : {
		KEEP(*(.text.boot))
		*(.text .text.*)
	}

	.rodata : {
		*(.rodata .rodata.*)
	}

	.data : {
		*(.data .data.*)
	}

	. = ALIGN(16);
	.bss (NOLOAD) : {
		bss_begin = .;
		*(.bss .bss.*)
		*(COMMON)
		. = ALIGN(16);
		bss_end = .;
	}

	/DISCARD/ : {
		*(.comment)
		*(.eh_frame*)
	}
}
