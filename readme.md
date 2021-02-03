# Bootsweeper

Minesweeper clone that plays without an OS!

## What is it?

Bootsweeper is a boot sector program, which means that if you put it in the 512 byte region that is specified as the boot sector in your storage medium then instead of running a bootloader to load your operating system, it runs this minesweeper game. That does mean that everything in this program is fit into 512 bytes--the data and all of the code have to fit into 512 bytes. It is written in 16 bit real mode assembly, and should work on any \*86 processor (although it's only been tested on 386 and up it should work on 286 and perhaps even 8086 if there were BIOSes that support it [I have no knowledge on whether or not this is the case]). If you'd like to test it on untested hardware/processors, definitely let me know your results.

The game features stunning 16 color text mode graphics, colored numbers, cursor wraparound, empty square floodfill, the ability to toggle whether a mine is flagged or not, a time-seeded xorshift random number generator for endless board regeneration, complete board reveal on loss, and so much more! (*Disclaimer: Not actually that much more*)

## How do I play?

In order to run the program, you must have the qemu, bochs, or DOSBox emulator installed (if you want to use a different emulator, feel free to configure that on your own). To run with qemu, simply use `make` and the program will compile and run! To run with bochs, use `make bochsmine` and then type `c` into the bottom input on the debug window. For DOSBox, run `dosboxmine` and then in the DOSBox command prompt type `boot mine.bin`.

NOTE: In order to get arrow keys support on DOSBox (on my linux system), I needed to change usescancodes to false in ~/.dosbox/dosbox-0.74-3.conf (replace 0.74-3 with your version number).


### Keyboard Controls (case insensitive)

| Key        | Action           |
| :-------------: |:-------------:|
| R | `R`estart game (Generate New Board)|
| F | Toggle `F`lag on tile |
| Arrow Keys | Move cursor |
| Any other key | Uncover tile |

## Also check out 

https://gitlab.com/blevy/boot-sector-minesweeper

This is another minesweeper clone in the bootsector, it's got some interesting differences to this version, please check it out!

https://github.com/nanochess/bootOS

This is a program that runs other boot sector programs, and at the bottom of the readme there is a list of other boot sector games.

https://www.youtube.com/watch?v=1UzTf0Qo37A

Great video on boot sector games
