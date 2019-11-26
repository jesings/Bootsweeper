mined: mine
	qemu-system-x86_64 -drive format=raw,file=mine.bin
bochsmine: mine
	bochs -qf bochsrc.txt
mine:
	as bootsweeper.S -o mine.o
	ld -o mine.bin --oformat binary -e _start mine.o -T miner.ld
