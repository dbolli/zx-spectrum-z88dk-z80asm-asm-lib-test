
SECTION asm_lib_test
PUBLIC OURPIXADD
PUBLIC PAPERG
PUBLIC INKN
PUBLIC SCRLNEWATTR

EXTERN PRCHR16
EXTERN COLCHR16
EXTERN PRCHR08
EXTERN COLCHR08

EXTERN AT_B_C
EXTERN PRSTRNG3
EXTERN GETKEY
EXTERN GETK2
EXTERN GETPRADDR
EXTERN INVERT

EXTERN DELAY0125SEC

EXTERN DRAWBRESLINE
EXTERN DRAWLN2
EXTERN PLOTSUB
EXTERN DRAWBRESCIRCLE

EXTERN OURPIXADD2						; Optional to comment out unused module. Linker will handle it.
EXTERN TABLEPIXADD

EXTERN CLS
EXTERN CLICK

EXTERN PRINTREG
EXTERN PRINTREGTICKER
EXTERN CALCSTACKTICKER					; :dbolli:20211222 17:25:50 Added

EXTERN DETECT128K						; :dbolli:20221101 19:51:51 Added
EXTERN DETECTMACHINETYPE				; :dbolli:20221102 21:16:45 Added
EXTERN PRMACHINETYPE					; :dbolli:20221102 21:29:03 Added

EXTERN MACHINETYPE16OR48K				; :dbolli:20221102 21:19:11 Added

;/*
; . . . . . . . . . . .
; Constants
;
;*/

defc SPRSSSIZE	= 32					; Number of bytes in Sprite screen save buffer

;defc OURPIXADD	= PIXADD				; Define if using ROM PIXADD (max. Y = 175) or comment out if not
;defc OURPIXADD	= OURPIXADD2			; Define if using OURPIXADD (max. Y = 191) or comment out if not
defc OURPIXADD	= TABLEPIXADD			; Define if using TABLEPIXADD pixel address table (max. Y = 191) or comment out if not


INCLUDE "../z88dk-zxspectrum-equates.asm"

;		ORG $6100

defc ORGADDR = $6100

;		IM 1
;		EI
		JR START
		
;/*
; . . . . . . . . . . .
; Spectrum Globals
;
;*/
.INKN		defb	6					; The 'new' INK colour
.PAPERG		defb	1					; The PAPER colour of the background

.SCRLNEWATTR	defb ( $00 * 0x80 ) + ( $01 * 0x40 ) + ( $00 * 0x08 ) + $07 ; Bright Colour white ink on black paper


.START	LD B,21
		LD C,0
		CALL AT_B_C
		LD HL,MESS128KSTR
		CALL PRSTRNG3
;		CALL PRINTREGTICKER				; DEBUG
		CALL DETECT128K
		LD A,'0'
		JR Z,START2
		LD A,'1'

.START2	RST $10
		
		LD A,' '
		RST $10
		
		CALL PRMACHINETYPE

		CALL PRINTREGTICKER				; DEBUG

		LD A,MACHINETYPE16OR48K

		CALL CLICK

		CALL GETPRADDR

		CALL CLS

		CALL CLICK

		LD BC,$0000
		LD DE,$BFFF
		CALL DRAWBRESLINE				; DRAW 0,0 TO 255,191

		LD BC,$BF00
		LD DE,$00FF
		CALL DRAWBRESLINE				; DRAW 0,191 TO 255,0

;		LD BC,$5880						; PLOT 128,88
		LD BC,$6880						; PLOT 128,104
		CALL PLOTSUB

		LD BC,$5800						; PLOT 0,88
		CALL PLOTSUB

		LD BC,$00FF
		LD DE,$0001
		CALL DRAWLN2					; DRAW 255,0 DE = SGN Y SGN X

		LD BC,$5880
		LD A,60
		CALL DRAWBRESCIRCLE				; CIRCLE 128,88,60

		LD BC,$5880
		LD A,80
		CALL DRAWBRESCIRCLE				; CIRCLE 128,88,80

		LD IX,PLY1TBL
		LD (IX+0),128
		LD (IX+1),36					; Coords of player position
		LD HL,PLRMASK1
		LD (IX+3),H
		LD (IX+2),L
		LD DE,PLRSPRITE1
		LD (IX+5),D
		LD (IX+4),E
		CALL PRCHR16
		CALL COLCHR16
;		LD A,1
;		LD (PLY1FLG),A
		LD (IX+6),0				; Not used for Player
		LD (IX+7),0				; Clear collision flag
;
		LD IX,ENEMY1TBL
		LD (IX+0),20
		LD (IX+1),158				; Coords of first enemy position
		LD HL,GALAX1MSK
		LD (IX+3),H
		LD (IX+2),L
		LD DE,GALAXIAN1
		LD (IX+5),D
		LD (IX+4),E
		CALL PRCHR16
		CALL COLCHR16
;		LD A,1
;		LD (ENEMY1FLG),A
		LD (IX+6),1				; Set active enemy flag
		LD (IX+7),0				; Clear collision flag
;
		LD IX,MISS1TBL
		LD (IX+0),22
		LD (IX+1),48				; Coords of first missile position
		LD HL,MISSSPRITE1
		LD (IX+3),H
		LD (IX+2),L
		LD DE,MISSSPRITE1
		LD (IX+5),D
		LD (IX+4),E
		CALL PRCHR08
		CALL COLCHR08
;		LD A,1
;		LD (ENEMY1FLG),A
		LD (IX+6),0				; Not used for Missiles
		LD (IX+7),0				; Clear collision flag

		LD B,30
.INVTLP1 PUSH BC
		HALT
		CALL INVERT				; :dbolli:20211130 19:35:05 Invert the screen ATTRs
		CALL DELAY0125SEC		; :dbolli:20211130 19:41:28 Delay 0.125s
		POP BC
		DJNZ INVTLP1

;		CALL GETKEY

		CALL PRINTREG

		CALL GETK2

		CALL PRINTREGTICKER

		CALL GETK2

		LD BC,$1234
		CALL STACKBC
		LD BC,$3456
		CALL STACKBC
		LD A,$78
		CALL STACKA

		CALL CALCSTACKTICKER

		CALL FPTOBC				; Get number off stack

		CALL CALCSTACKTICKER

		CALL FPTOBC				; Get number off stack

		CALL CALCSTACKTICKER

		CALL FPTOBC				; Get number off stack

		CALL CALCSTACKTICKER	; Should be empty stack	; :dbolli:20211222 17:25:50 Added

		CALL GETK2

		LD HL,$2758				; :dbolli:20140401 10:15:05 Restore HL' to the address in SCANNING of the 'end-calc' instruction (as CIRCLE ROM Calls alter it) as per The Complete Spectrum ROM Disassembly (p201) http://www.worldofspectrum.org/infoseekid.cgi?id=2000076
		EXX

;ASSERT ( GETK2 > DFILE )	; :dbolli:20211227 09:43:27 ASSERT directive test
;ASSERT ( ASMPC > DFILE )	; :dbolli:20211227 10:58:55 Will fail as ASPC starts at 0 for linked .asm
ASSERT ( ASMPC + $6100 > DFILE )
ASSERT ( $ + $6100 >= START )
ASSERT ( $ + ORGADDR <= $8000 )

		RET

SECTION asm_lib_data

;DEFGROUP										; :dbolli:20221102 20:49:45 Added. enum equivalent
;{
;	MACHINETYPE16OR48K = 165
;	MACHINETYPE128KORPLUS2 = 159
;	MACHINETYPE2A2BORPLUS3 = 126
;}

		DEFB $12, $34			; Data goes here...
		DEFW $3456, $789A
		DEFS $10, $AA

.MESS128KSTR
if 0
;;		DEFB AT_CONTROL, 21, 0
;		DEFB AT_CONTROL, 0, 0
;;		DEFM "128K "
;;		DEFB $00
		DEFB "128K ", $00
else
;		DEFB AT_CONTROL, 0, 0
		DEFM "128K ", $00
endif

;
;.PLAYER1
.PLY1TBL		defw 0					; Player 1 x coord y coord
			defw PLRMASK1
			defw PLRSPRITE1
.PLY1FLG		defb 0
									; Monster flag (not used for Player)
									; 0 = Disabled
									; 1 = Enabled
.PLY1CFLG	defb 0
									; Collision flag for Monster (not used for Player)
									; 0 = Has not collided with player
									; 1 = Is currently collided with player
.PLY1DEFS	defw 0					; Definitions for sprites for Monster direction (not used for Player)
			defw 0
			defw 0
			defw 0
.PLY1FGC		defb 2
.PLY1COLS	defb 0,0,0				; Saved attribute definitions (6 bytes)
			defb 0,0,0
.PLY1CMSK	defw 0					; This is the current mask selected from the masks defined below
.PLY1MSKS	defw PLRMASK1
			defw PLRMASK1
			defw PLRMASK1
			defw PLRMASK1
.PLY1SSPTR	defw PLY1SS
.PLY1TBLEND							; End of Player 1 table
;
;.ENEMY1
.ENEMY1TBL	defw 0					; Enemy 1 x coord y coord
			defw GALAX1MSK
			defw GALAXIAN1
.ENEMY1FLG		defb 0
									; Monster flag (not used for Player)
									; 0 = Disabled
									; 1 = Enabled
.ENEMY1CFLG		defb 0
									; Collision flag for Monster (not used for Player)
									; 0 = Has not collided with player
									; 1 = Is currently collided with player
.ENEMY1DEFS	defw GALAXIAN1				; Definitions for sprites for Monster direction (not used for Player)
			defw GALAXIAN1
			defw GALAXIAN1
			defw GALAXIAN1
.ENEMY1FGC		defb 3
.ENEMY1COLS		defb 0,0,0					; Saved attribute definitions
			defb 0,0,0
.ENEMY1CMSK		defw 0					; This is the current mask selected from the masks defined below
.ENEMY1MSKS		defw GALAX1MSK
			defw GALAX1MSK
			defw GALAX1MSK
			defw GALAX1MSK
.ENEMY1SSPTR		defw ENEMY1SS
.ENEMY1TBLEND						; End of Enemy 1 table
;
defc ENEMYRECLENGTH	= ENEMY1TBLEND - ENEMY1TBL	; Length of Enemy record
;
.MISS1TBL	defw 0					; Missile 1 x coord y coord
			defw MISSMASK1
			defw MISSSPRITE1
.MISS1FLG	defb 0
									; Monster flag (not used for Missile)
									; 0 = Disabled
									; 1 = Enabled
.MISS1CFLG	defb 0
									; Collision flag for Monster (not used for Missile)
									; 0 = Has not collided with player
									; 1 = Is currently collided with player
.MISS1DEFS	defw 0					; Definitions for sprites for Monster direction (not used for Player)
			defw 0
			defw 0
			defw 0
.MISS1FGC	defb 4
.MISS1COLS	defb 0,0				; Saved attribute definitions (2 bytes)
.MISS1CMSK	defw 0					; This is the current mask selected from the masks defined below
.MISS1MSKS	defw MISSMASK1
			defw MISSMASK1
			defw MISSMASK1
			defw MISSMASK1
.MISS1SSPTR	defw MISS1SS
.MISS1TBLEND						; End of Missile table
;
defc MISSRECLENGTH	= MISS1TBLEND - MISS1TBL	; Length of Missile record
;
;/*
; . . . . . . . . . . .
; Sprite definitions
;
;*/
.PLRSPRITE1	defb @00000000,@00000000
			defb @00000000,@00000000
			defb @00000000,@00000000
			defb @00000000,@00000000
			defb @00000000,@00000000
			defb @00000001,@10000000
			defb @00000111,@11100000
			defb @00001100,@00110000
			defb @00011001,@10011000
			defb @00110011,@11001100
			defb @01100110,@01100110
			defb @01001111,@11110010
			defb @01100000,@00000110
			defb @01111111,@11111110
			defb @00000000,@00000000
			defb @00000000,@00000000
;
.PLRMASK1	defb @00000000,@00000000
			defb @00000000,@00000000
			defb @00000000,@00000000
			defb @00000000,@00000000
			defb @00000000,@00000000
			defb @00000001,@10000000
			defb @00000111,@11100000
			defb @00001111,@11110000
			defb @00011111,@11111000
			defb @00111111,@11111100
			defb @01111111,@11111110
			defb @01111111,@11111110
			defb @01111111,@11111110
			defb @01111111,@11111110
			defb @00000000,@00000000
			defb @00000000,@00000000
;
.GALAXIAN1	defb @00000000,@00000000
			defb @00000000,@00000000
			defb @00000000,@00000000
			defb @00000010,@01000000
			defb @00000010,@01000000
			defb @01000010,@01000010
			defb @01000111,@11100010
			defb @01111101,@10111110
			defb @00000111,@11100000
			defb @00000111,@11100000
			defb @00011111,@11111000
			defb @00111001,@10011100
			defb @01110001,@10001110
			defb @01100000,@00000110
			defb @00000000,@00000000
			defb @00000000,@00000000
;
.GALAX1MSK	defb @00000000,@00000000
			defb @00000000,@00000000
			defb @00000000,@00000000
			defb @00000010,@01000000
			defb @00000010,@01000000
			defb @01000010,@01000010
			defb @01000111,@11100010
			defb @01111111,@11111110
			defb @00000111,@11100000
			defb @00000111,@11100000
			defb @00011111,@11111000
			defb @00111001,@10011100
			defb @01110001,@10001110
			defb @01100000,@00000110
			defb @00000000,@00000000
			defb @00000000,@00000000
;
.MISSSPRITE1 defb @00000000
			defb @00000000
			defb @00000000
			defb @00010000
			defb @00010000
			defb @00000000
			defb @00000000
			defb @00000000
;
defc MISSMASK1	= MISSSPRITE1
;
.PLY1SS		defs SPRSSSIZE
;
.ENEMY1SS		defs SPRSSSIZE
;
.MISS1SS		defs SPRSSSIZE
;
