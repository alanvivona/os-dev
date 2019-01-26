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

GLOBAL _Kernel_Start:function

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

Text.Whitespace equ 0x0320 ; 0x0320 = 0 blakc bg, 3 cyan fg, 20 (" " == space)

_Kernel_Start:
	mov eax, Text.Whitespace 	
	call _fillScreen

	lea ecx, [VGA.Lenght-1]
	_Kernel_Start.loop:
		
		; calc modulo 3 of ecx
		mov dx, 0     
		mov eax, ecx
		mov ebx, 3
		div bx       ; Divides ecx by 3. DX = modulo and AX = result

		; edx = modulo result
		mov eax, 0x0220		; base value = 0 black bg, 2 green fg, 20 " "
		cmp edx, 1
		jg _Kernel_Start.pushNextChar
		; if edx > 1
		;	jmp to _writeChar
		; else
		lea eax, [eax + 0x0010 + edx] 	; eax was 0x0120 + 0x0010 + edx = could be 0x0130 ("0") or 0x0131 ("1")

		_Kernel_Start.pushNextChar:
		; pass address for the 3rd row, four spaces to the right (one tab) 
		lea ebx, [ VGA.Buffer ];+ (VGA.Cols * 2 * VGA.BlockSize) + (VGA.BlockSize * 4) ]
		call _writeChar
		
		push ecx
		call _scroll
		pop ecx
		dec ecx

	jnz _Kernel_Start.loop

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

_scroll:
	; start looping throught the buffer in reverse order to replace
	; each byte with the content of the previous one
	mov ecx, VGA.Lenght
	_scroll.loop:
		mov eax, [ VGA.Buffer + ((ecx-2)*VGA.BlockSize) ]
		mov [ VGA.Buffer + ((ecx-1)*VGA.BlockSize) ], eax
		dec ecx
		cmp ecx, 1
	jne _scroll.loop
	
	mov eax, Text.Whitespace
	; pass address for the 1st square to fill it with an empty space
	lea ebx, [ VGA.Buffer ]
	call _writeChar
	
	ret
		



