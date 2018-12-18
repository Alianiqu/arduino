.PHONY=all

all:
	avr-gcc -mmcu=atmega328p -c main.c   -o main.o
	avr-gcc -mmcu=atmega328p -o main.elf    main.o
	avr-objcopy -j .text -j .data -O ihex main.elf main.hex
	avrdude -v -patmega328p -carduino -P/dev/ttyACM1 -b115200 -D -Uflash:w:main.hex:i