.PHONY=all
# github.com/tuupola/avr_demo
# CC_ARGS=-I. -gdwarf-2 -DF_CPU=16000000UL    -Os -funsigned-char -funsigned-bitfields -fpack-struct -fshort-enums -Wall -Wstrict-prototypes

all:
#	avr-gcc $(CC_ARGS) -mmcu=atmega328p -c uart.c -o uart.o
#	avr-gcc $(CC_ARGS) -mmcu=atmega328p -c main.c -o main.o
#	avr-gcc $(CC_ARGS) -mmcu=atmega328p -o main.elf uart.o main.o
#	avr-objcopy -j .text -j .data -O ihex main.elf main.hex
#	avrdude -v -patmega328p -carduino -P/dev/ttyACM1 -b115200 -D -Uflash:w:main.hex:i
	mkdir -p .dep
	avr-gcc -c -mmcu=atmega328p -I. -gdwarf-2 -DF_CPU=16000000UL    -Os -funsigned-char -funsigned-bitfields -fpack-struct -fshort-enums -Wall -Wstrict-prototypes -Wa,-adhlns=main.lst  -std=gnu99 -MD -MP -MF .dep/main.o.d main.c -o main.o
	avr-gcc -c -mmcu=atmega328p -I. -gdwarf-2 -DF_CPU=16000000UL    -Os -funsigned-char -funsigned-bitfields -fpack-struct -fshort-enums -Wall -Wstrict-prototypes -Wa,-adhlns=uart.lst  -std=gnu99 -MD -MP -MF .dep/uart.o.d uart.c -o uart.o
	avr-gcc -mmcu=atmega328p -I. -gdwarf-2 -DF_CPU=16000000UL    -Os -funsigned-char -funsigned-bitfields -fpack-struct -fshort-enums -Wall -Wstrict-prototypes -Wa,-adhlns=main.o  -std=gnu99 -MD -MP -MF .dep/main.elf.d main.o uart.o --output main.elf -Wl,-Map=main.map,--cref    -lm
	avr-objcopy -O ihex -R .eeprom main.elf main.hex
	avr-objcopy -j .eeprom --set-section-flags=.eeprom="alloc,load" --change-section-lma .eeprom=0 -O ihex main.elf main.eep
	avr-objdump -h -S main.elf > main.lss
	avr-nm -n main.elf > main.sym
	avrdude -p atmega328p -P /dev/ttyACM1     -c arduino -b 115200    -U flash:w:main.hex


