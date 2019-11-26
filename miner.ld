SECTIONS
{
    . = 0x7c00;
    .text :
    {
        mine.o (.*)
        . = 0x1FE;
        SHORT(0xAA55)
    }
    .data : { mine.o (.data) }
    .bss : { mine.o (.bss) }
    . = 0x7e00;
    .text :
    {
        *(.*)
    }
    .data : { *(.data) }
    .bss : { *(.bss) }
}

