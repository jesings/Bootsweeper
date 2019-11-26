SECTIONS
{
    . = 0x7c00;
    .text :
    {
        boot.o (.*)
        . = 0x1FE;
        SHORT(0xAA55)
    }
    .data : { boot.o (.data) }
    .bss : { boot.o (.bss) }
}

