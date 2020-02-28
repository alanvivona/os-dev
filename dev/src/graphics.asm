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
;	BFCCCC 
;	- 4bits Background color
;	- 4bits Foreground color
;	- 8bits Character
;
;	Example:
;		A red background, green foreground, 'A'
;		WORD 0x2141
;

BITS 32

SECTION .text

; VGA const definitions
VGA.Buffer equ 0x0B8000
VGA.Cols equ 80
VGA.Rows equ 25
VGA.Lenght equ 2000
VGA.BlockSize equ 2

VGA.Text.Whitespace equ 0x0020 ; 0 blakc bg, 3 black fg, char 20 (" " == space)

VGA._fillScreen:
	; ax = char to fill the screen with
	mov ebx, VGA.Buffer
	mov ecx, VGA.Lenght
	_fillScreen.loop:
		mov word [ebx], ax
		add ebx, VGA.BlockSize
	loop _fillScreen.loop
	ret

VGA._scroll.horizontal:
	; start looping throught the buffer in reverse order to replace
	; each byte with the content of the previous one
	lea ecx, [ VGA.Lenght - 1 ]
	_scroll.horizontal.loop:
		mov eax, [ VGA.Buffer + ((ecx - 1) * VGA.BlockSize) ]
		mov [ VGA.Buffer + (ecx * VGA.BlockSize) ], eax
		dec ecx
		cmp ecx, -1
	jne _scroll.horizontal.loop
	
	ret

VGA._scroll.vertical:
	; start looping throught the buffer in reverse order to replace
	; each byte with the content of the previous one
	lea ecx, [VGA.Lenght - 2 - VGA.Cols] ; skip the last row, it'll be overriden
	_scroll.vertical.loop:
		mov eax, [ VGA.Buffer + (ecx * VGA.BlockSize) ]
		mov [ VGA.Buffer + (ecx + VGA.Cols) * VGA.BlockSize ], eax
		dec ecx
		cmp ecx, -1
	jne _scroll.vertical.loop
	
	mov ecx, VGA.Cols-1
	_scroll.vertical.emptyFirstRow.loop:
		mov BYTE [ VGA.Buffer + (ecx * VGA.BlockSize) ], 0x0020 ; put empty space
		dec ecx
		cmp ecx, -1
		jne _scroll.vertical.emptyFirstRow.loop	

	ret
