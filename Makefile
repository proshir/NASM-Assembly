all: project

project: project.o
	ld -o project -e _start project.o

project.o: project.asm
	nasm -f elf64 project.asm

clean:
	rm -f project.o project
