SECTIONS
{
    . = 0x7c00;
    .text :
    {
        mine.o (.text)
        . = 0x1FE - 0xb;
        SHORT(0x0)
        . = 0x1FE - 0x9;
        BYTE(0x0)
        . = 0x1FE - 0x8;
        BYTE(0x0)
        BYTE(0x79)
        BYTE(0x72)
        BYTE(0x74)
        BYTE(0x71)
        BYTE(0x76)
        BYTE(0x73)
        BYTE(0x78)
        . = 0x1FE;
        SHORT(0xAA55)
    }
}

