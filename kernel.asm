;kernel.asm
;Michael Black, 2007

;kernel.asm contains assembly functions that you can use in your kernel

	.global _putInMemory
	.global _interrupt
	.global _makeInterrupt21
	.global _printChar
	.global _readChar
	.global _readSector
	.global _loadProgram 
	.extern _printString
	.extern _readString

;	.extern _handleInterrupt21

_printChar:
	push bp
	mov bp,sp
	mov al,[bp + 4]
	mov ah,#0x0e
	int #0x10
	pop bp
	ret
_readChar:
	mov ax,#0x00
	int #0x16
	ret

_readSector:
	push bp 
	mov bp, sp 
	sub sp, #8
	mov bx, [bp + 4] 			;bx = buffer*
	mov ax, [bp + 6] 			;ax = sector
	mov dx,ax 					;dx = sector
	mov cl, #36
	div cl
	mov [bp - 2],al 			;[bp-2] = track
	mov ax,dx 					;ax = sector
	mov cl, #18
	div cl
	add ah, #1
	mov [bp - 4],ah 			; [bp - 4] = relative sector
	xor ah,ah
	mov cl, #2
	div cl
	mov [bp - 6],ah 			;[bp - 6] = head
	mov ah,#0x2
	mov al,#0x1
	mov ch,[bp - 2] 			;track
	mov cl,[bp - 4] 			;relative sector
	mov dh,[bp - 6] 			; head
	mov dl,#0 					; 0 is the floppy disk
	int #0x13
	add sp, #8
	pop bp
	ret

_loadProgram:
	mov ax, #0x2000
	mov ds, ax
	mov ss, ax
	mov es, ax
	

	mov ax, #0xfff0
	mov sp, ax
	mov bp, ax
	

	mov cl, #12 
	mov dh, #0 
	mov ch, #0 
	mov ah, #2 
	mov al, #1 
	mov dl, #0 
	mov bx, #0 
	int #0x13 
	

	jmp #0x2000:#0

;void putInMemory (int segment, int address, char character)
_putInMemory:
	push bp
	mov bp,sp
	push ds
	mov ax,[bp+4]
	mov si,[bp+6]
	mov cl,[bp+8]
	mov ds,ax
	mov [si],cl
	pop ds
	pop bp
	ret

;int interrupt (int number, int AX, int BX, int CX, int DX)
_interrupt:
	push bp
	mov bp,sp
	mov ax,[bp+4]	;get the interrupt number in AL
	push ds		;use self-modifying code to call the right interrupt
	mov bx,cs
	mov ds,bx
	mov si,#intr
	mov [si+1],al	;change the 00 below to the contents of AL
	pop ds
	mov ax,[bp+6]	;get the other parameters AX, BX, CX, and DX
	mov bx,[bp+8]
	mov cx,[bp+10]
	mov dx,[bp+12]

intr:	int #0x00	;call the interrupt (00 will be changed above)

	mov ah,#0	;we only want AL returned
	pop bp
	ret

;void makeInterrupt21()
;this sets up the interrupt 0x21 vector
;when an interrupt 0x21 is called in the future, 
;_interrupt21ServiceRoutine will run

_makeInterrupt21:
	;get the address of the service routine
	mov dx,#_interrupt21ServiceRoutine
	push ds
	mov ax, #0	;interrupts are in lowest memory
	mov ds,ax
	mov si,#0x84	;interrupt 0x21 vector (21 * 4 = 84)
	mov ax,cs	;have interrupt go to the current segment
	mov [si+2],ax
	mov [si],dx	;set up our vector
	pop ds
	ret

;this is called when interrupt 21 happens
;it will call your function:
;void handleInterrupt21 (int AX, int BX, int CX, int DX)
_interrupt21ServiceRoutine:
	cmp ax,#0
	je call_printString
	cmp ax,#1
	je call_readString
	cmp ax,#2
	je call_readSector
	call call_unknown_service_error
	
call_printString:
	push bx
	call _printString
	add sp, #0x2
	jmp finished
call_readString:
	push cx
	push bx
	call _readString
	add sp, #4
	jmp finished
call_readSector:
	push cx
	push bx
	call _readSector
	add sp, #4
	jmp finished
call_unknown_service_error:
	;call _unknown_service_error
	jmp finished
finished:
	iret
