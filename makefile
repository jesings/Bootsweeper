mined: mine
	qemu-system-x86_64 -drive format=raw,file=mine.bin
bochsmine: mine
	bochs -qf bochsrc.txt
dosboxmine: mine
	dosbox
mine:
	as bootsweeper.S -o mine.o
	strip --remove-section=.note.gnu.property mine.o
	ld -o mine.bin --oformat binary mine.o -T miner.ld
