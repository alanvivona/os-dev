;
; 	VGA definition 
;	
;	Buffer starts at 0xB8000
;	COLS = 80 = 0x50
;	ROWS = 25 = 0x19
;	SIZE = 80 * 25 = 2000 bytes
;	
;	Some colors (not all of them):
;	black	= 0b00000000 = 0x00
;	green 	= 0b00000001 = 0x01
;	red 	= 0b00000010 = 0x02
;	cyan 	= 0b00000011 = 0x03
;	lgray 	= 0b00000111 = 0x07
;	gray 	= 0b00001000 = 0x08
;	white 	= 0b00001111 = 0x0F
;
;	Characters are written as follows:
;	BBFFCCCC 
;	- 4bits Background color BYTE
;	- 4bits Foreground color
;	- BYTE Character
;
;	Example:
;		A red background, green foreground, 'A'
;		WORD 0x2141
;

BITS 32

GLOBAL _Kernel_Start:function

SECTION .text

; BEGIN - Multiboot Header
MultibootSignature dd 464367618
MultibootFlags dd 3
MultibootChecksum dd -464367621
MultibootGraphicsRuntime_VbeModeInfoAddr dd 2147483647
MultibootGraphicsRuntime_VbeControlInfoAddr dd 2147483647
MultibootGraphicsRuntime_VbeMode dd 2147483647
MultibootInfo_Memory_High dd 0
MultibootInfo_Memory_Low dd 0
; END - Multiboot Header

MultibootInfo_Structure dd 0

; VGA const definitions
VGA_BUFFER equ 0xB8000
VGA_COLS equ 80
VGA_ROWS equ 25
VGA_SIZE equ 2000
VGA_BLOCK_SIZE equ 2

_Kernel_Start:
	
	mov eax, 0x0320 	; 0x0320 = 0 blakc bg, 3 cyan fg, 20 (" " == space)
	call fillScreen
	
	mov eax, 0x1f41 	; 1 green bg, f white fg, 41 A
	; pass address for the 3rd row, four spaces to the right (one tab) 
	lea ebx, [ VGA_BUFFER + (VGA_COLS * 2 * VGA_BLOCK_SIZE) + (VGA_BLOCK_SIZE * 4) ]
	call writeChar

	hlt


fillScreen:
	; ax = char to fill the screen with
	push ebp
	mov ebp, esp
	mov ebx, VGA_BUFFER
	mov ecx, VGA_SIZE
	nextBufferSegment:
	mov word [ebx], ax
	add ebx, VGA_BLOCK_SIZE
	loop nextBufferSegment
	pop ebp
	ret

writeChar:
	; ax 	= char to fill the screen with
	; ebx 	= address 
	push ebp
	mov ebp, esp
	mov [ebx], ax
	pop ebp
	ret

