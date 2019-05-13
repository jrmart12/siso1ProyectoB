
#define ROWS 80
#define COLS 25
#define BKSP 0x08
#define RTRN 0x0D
#define CLR 0x20

extern void printChar(chr);
char chr; 

extern void clearScreen(void);

extern void readString(line);
char line[ROWS];

extern char readChar(void);

extern int min( x , y);
int x; int y;

extern int max( x , y);
int x; int y;

extern void hang(void);
extern void printString(char *str);
extern void makeInterrupt21(void);
extern void loadProgram(void);


void main() {
	/*
	char *str = "Hello world \0";
	char *enter = "Enter a line:\0";
	char *espacio = "\r\n";
	char *listo = "done \0";
	char buffer[ROWS];
	char buffers[512];
	//Reading from the keyboard
	printString(enter);
 	readString(buffer);
	printString(espacio);
	printString(buffer);

	//Read a sector from the disk
	printString(espacio);
	readSector(buffers,30);
	printString(buffers);
*/
	makeInterrupt21();
	loadProgram();

	hang();
}



void hang(void) {
    while(1);
}

void clearScreen(void) {
	int i;
	for (i = 0 ; i < ROWS * COLS ; i++ ) {
		printChar(BKSP);
		printChar(CLR);
		printChar(BKSP);
	}
}

void printString(char *str) {
	int i = 0;
	while(str[i] != '\0') {
		printChar(str[i]);
		i++;
	}
}

void readString(char line[ROWS]) {
	char chr;
	int i;
	char end_flag = 0;
	for( i = 0; i < ROWS - 1 ;)
	{
		chr = readChar();
		switch(chr){
			case BKSP:
				printChar(BKSP);
				printChar(CLR);
				i--;
				i = max(0,i);
				break;
			case RTRN:
				end_flag = 1;
				break;
			default:
				line[i] = chr;
				i++;
		}
		printChar(chr);
		line[i] = '\0';
		if(end_flag)
			break;
	}
}

int min(int x , int y) {
	return x < y ? x : y;
}

int max(int x , int y) {
	return x > y ? x : y;
}
/*
 bcc -ansi -c -o kernel.o kernel.c
 as86 kernel.asm -o kernel_asm.o
ld86 -o kernel -d kernel.o kernel_asm.o
dd if=kernel of=floppya.img bs=512 conv=notrunc seek=3
sudo bochs -f opsys.bxrc
*/