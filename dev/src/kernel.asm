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
;	blue 	= 0b00000001 = 0x01
;	green	= 0b00000010 = 0x02
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

GLOBAL _Kernel.Start:function

SECTION .text

; BEGIN - Multiboot Header
Multiboot.Signature dd 464367618
Multiboot.Flags dd 3
Multiboot.Checksum dd -464367621
Multiboot.GraphicsRuntime_VbeModeInfoAddr dd 2147483647
Multiboot.GraphicsRuntime_VbeControlInfoAddr dd 2147483647
Multiboot.GraphicsRuntime_VbeMode dd 2147483647
Multiboot.Info_Memory_High dd 0
Multiboot.Info_Memory_Low dd 0
; END - Multiboot Header

Multiboot.Info_Structure dd 0

; VGA const definitions
VGA.Buffer equ 0x0B8000
VGA.Cols equ 80
VGA.Rows equ 25
VGA.Lenght equ 2000
VGA.BlockSize equ 2

Text.Whitespace equ 0x0020 ; 0x0320 = 0 blakc bg, 3 black fg, 20 (" " == space)

_Kernel.Start:
	mov eax, Text.Whitespace 	
	call _fillScreen

	_Kernel.Start.loop.set:
		lea ecx, [VGA.Lenght-1]

	_Kernel.Start.loop:
		
		call _getSequenceChar
		or eax, 0x0200		; char is now on eax, let's add the colors: 0 black bg, 2 green fg

		; pass address for the 3rd row, four spaces to the right (one tab) 
		lea ebx, [ VGA.Buffer ];+ (VGA.Cols * 2 * VGA.BlockSize) + (VGA.BlockSize * 4) ]
		call _writeChar
		
		push ecx
		call _scroll.vertical
		pop ecx
		dec ecx

	jnz _Kernel.Start.loop

	jmp _Kernel.Start.loop.set ; infinite loop for an infinite matrix

	hlt

_fillScreen:
	; ax = char to fill the screen with
	mov ebx, VGA.Buffer
	mov ecx, VGA.Lenght
	_fillScreen.loop:
		mov word [ebx], ax
		add ebx, VGA.BlockSize
	loop _fillScreen.loop
	ret

_writeChar:
	; ax 	= char to fill the screen with
	; ebx 	= address 
	mov [ebx], ax
	ret

_scroll.horizontal:
	; start looping throught the buffer in reverse order to replace
	; each byte with the content of the previous one
	mov ecx, VGA.Lenght
	_scroll.horizontal.loop:
		mov eax, [ VGA.Buffer + ((ecx-2)*VGA.BlockSize) ]
		mov [ VGA.Buffer + ((ecx-1)*VGA.BlockSize) ], eax
		dec ecx
		cmp ecx, 1
	jne _scroll.horizontal.loop
	
	ret

_scroll.vertical:
	; start looping throught the buffer in reverse order to replace
	; each byte with the content of the previous one
	
	lea ecx, [VGA.Lenght - VGA.Cols] ; skip the last row, it'll be overriden
	_scroll.vertical.loop:
		mov eax, [ VGA.Buffer + ((ecx-2)*VGA.BlockSize) ]
		mov [ VGA.Buffer + ((ecx-2+ VGA.Cols)*VGA.BlockSize) ], eax
		dec ecx
		cmp ecx, 1
	jne _scroll.vertical.loop
	
	ret

_getSequenceChar:
	; returns the next char of a repetitive pattern
	; receives the pattern index in ecx
	; returns the character in eax

	; calc modulo 3 of ecx
	mov dx, 0     
	mov eax, ecx
	mov ebx, 3
	div bx			; divides ecx by 3. dx = modulo and ax = division result

	; edx = modulo result
	mov eax, 0x20		; 20 == " "
	cmp edx, 1
	jg _getSequenceChar.return
	lea eax, [0x30 + edx] 	; 0x30 + edx = could be 0x30 ("0") or 0x31 ("1")
	_getSequenceChar.return:
	ret



