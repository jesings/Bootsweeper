#60 free bytes to play with
.global _start
.code16
.macro getrand #Credit goes to https://b2d-f9r.blogspot.com/2010/08/16-bit-xorshift-rng-now-with-more.html for the xorshift algorithm
#static uint16_t x=1,y=1;
#uint16_t t=(x^(x<<5)); 
    movw (0x7df3), %cx
    shlw $5, %cx
    xorw (0x7df3), %cx
#x=y;
    movw (0x7df5), %ax
    movw %ax, (0x7df3)
#return y=(y^(y>>1))^(t^(t>>3));
    shrw %ax
    xorw (0x7df5), %ax
    movw %cx, %bx
    shrw $3, %bx
    xorw %bx, %cx
    xorw %ax, %cx
    movw %cx, (0x7df5)
#Random number is now in %cx
.endm
#16x16 board, each tile is a single bit, mine or not
.text

_start:
    xorw %ax, %ax
    pushw %ax
    movw %sp, %bp
    sub $32, %sp
    pushw %ax
    movw %ax, %ds
    movb $0x02, %ah 
    int $0x1A #Read RTC value
    movw %cx, (0x7df3) #Seed RNG
    movw %dx, (0x7df5) #Seed RNG
newgame:
#initialize screen
    xorw %ax, %ax
	int $0x10 #clear screen (40x25)
#Sweep cursor across board
    movw $0x050C, %dx #Set coords at top left of board
    rows:
    xorb %bh, %bh
    movw $0x10, %cx
    movb $0x02, %ah
    int $0x10 #set cursor to the beginning of row
    movw $0xAB1, %ax
    int $0x10 #print out 16 dummy characters for each row
    getrand
    mov %cx, %si
    getrand
    andw %si, %cx #And 2 random-ish numbers, making it so that on average 25% of tiles will be mines
    movzxb %dh, %di
    subw $0x5, %di#di is used for index in 16 bit
    shlw %di
    movw %cx, (%bp,%di)#Populate row of board with 16 bits stating mine value for each tile
    incb %dh
    cmpb $21, %dh
    jl rows

    xorb %bh, %bh
    movw $0x050C, %dx
    movb $0x02, %ah
    int $0x10#Set cursor back to the beginning of the baord
    gameloop:
#Loop until input, this is a busy loop, however it's running as a boot sector program so it's the way to go
    xor %ah, %ah
    int $0x16 #Get input status (input key in %ah)
    testb %ah, %ah
    jz gameloop
    cmpb $0x48, %ah
    je up_arrow
    cmpb $0x4b, %ah
    je left_arrow
    cmpb $0x4d, %ah
    je right_arrow
    cmpb $0x50, %ah
    je down_arrow
    cmpb $0x21, %ah
    je f_flag #If f is pressed, go to flag toggle subroutine
    cmpb $0x13, %ah
    je newgame #If r is pressed, reset board
#Else for any other key, uncover the tile
#Test if tile is a number, if it is, go to chording routine
    pusha
    call uncover1
    jnz lose #If tile is not a mine, populate it
    call uncover2
    popa
    call uncover3

    jmp gameloop
    f_flag: #Toggle flag at cursor
    movw $0x007f, %bx
    movb $0x08, %ah
    int $0x10
    movw $1, %cx
    cmpb $0xD5, %al
    je unset_flag
    jmp set_flag
    unset_flag:
    movw $0x09B1, %ax
    movb $0x07, %bl
    jmp i10thengl
    set_flag:
    movw $0x09D5, %ax
    uf2:
    jmp i10thengl

    left_arrow: #For all of the below, update cursor position
    subb $2, %dl
    right_arrow:
    incb %dl
    decb %dh
    down_arrow:
    addb $2, %dh
    up_arrow:
    decb %dh
 
    rectify:#If the cursor has gone past the bounds of the board, have it loop around
    subb $0x05, %dh
    subb $0x0C, %dl
    andw $0x0f0f, %dx 
    addw $0x050C, %dx
    movb $02, %ah
    i10thengl: #int $0x10 then game loop
    int $0x10
    jmp gameloop

    lose: #If the game is lost (a mine was uncovered) explore the whole board
    popa
    movb $0x05, %dh
    loserow:#Loop through rows
    movb $0x0C, %dl
    losecolumn: #Loop through columns
    movb $0x02, %ah
    int $0x10 #Set cursor at row and column coords
    call putnum #Put proper number (or mine) at cursor coord
    incb %dl
    cmpb $0x1C, %dl
    jl losecolumn
    incb %dh
    cmpb $0x15, %dh
    jl loserow
    jmp gameloop #Keep waiting for input (In case reset mostly)
    ret

tileval: #Add 1 to SI if the tile at coord (around cursor) is a mine, else add 0
    andw %bx, %cx
    movw %cx, %ax
    bsrw %ax, %cx
    shrw %cl, %ax
    addw %ax, %si
    ret
sidebatch:
    movw -2(%bp,%di), %cx #Top
    call tileval
    movw (%bp,%di), %cx #Middle
    call tileval
    movw 2(%bp,%di), %cx #Bottom
    call tileval
    ret
uncover1: #Retrieve row of board, location of tile at cursor in that 16 bit row, if the tile is a mine, prepare to do something
    subw $0x050C, %dx
    movzxb %dh, %di
    shlw %di
    movw $1, %ax
    movb %dl, %cl
    shlw %cl, %ax
    testw (%bp, %di), %ax
    ret
uncover2: #Calculate adjacent mines for tile at cursor, keeping in mind edge cases
    xorw %si, %si
    movw $1, %bx
    shlw %cl, %bx
    call sidebatch#because center square must be 0 (not a mine), this is okay
    test %dl, %dl
    jz noleftsq
    shrw %bx
    call sidebatch
    shlw %bx
    cmp $0xF, %dl
    je norightsq
    noleftsq:
    shlw %bx
    call sidebatch
    norightsq:
    movw %si, %es #I don't care that this is a segment register, it works to store stuff in and I don't need segmentation
    ret
uncover3: #Print correct character for tile at cursor, if it is 0 call the floodfill routine
#Test if uncovered first
    movw %es, %ax
    movb $0x09, %ah
    movw $1, %cx
    test %al, %al
    jnz nonzero
#If we find a zero tile, we need to uncover all non-mine tiles clustered around it
    movb $0x20, %al
    movw $0x70, %bx
    int $0x10
    call floodfill
    movb $2, %ah
    int $0x10
    ret
    nonzero:
    leaw (0x7df6), %bx
    movzx %al, %di
    movb (%bx, %di), %bl
    xorb %bh, %bh
    addb $0x30, %al
    int $0x10
    ret
putmine: #Print mine character at cursor
    movw $0x092A, %ax
    movw $0x74, %bx
    movw $1, %cx
    int $0x10
    ret
putnum: #Run through uncover routine, printing a mine if encountered (not applicable for floodfill except if there is an error)
    pusha
    call uncover1
    jz noputmine
    call putmine
    popa
    ret
    noputmine:
    call uncover2
    popa
    call uncover3
    ret
floodfill:
    xorb %bh, %bh
    movb $-1, %ch
    ffl1:
    movb $-1, %cl
    ffl2:
    pusha
    addb %cl, %dl
    addb %ch, %dh
    movb $0x2, %ah
    int $0x10 #Move cursor to each adjacent tile
    movb $0x8, %ah
    int $0x10
    cmpb $0xB1, %al #If current tile is not unexplored (or is flagged), do not explore/recurse
    jne invalidtile
    call putnum #Floodfill calls putnum, and putnum calls floodfill until all adjacent tiles are explored
    invalidtile:
    popa
    incb %cl
    cmp $2, %cl
    jne ffl2
    incb %ch
    cmp $2, %ch
    jne ffl1
    ret
