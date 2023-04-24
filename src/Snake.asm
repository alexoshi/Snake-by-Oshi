;########################################################################
;###########################################################################
; ABOUT SPACE-TRIS:
;
;	This is the main portion of code. It has WinMain and performs all
;	of the management for the game.
;
;		- WinMain()
;		- WndProc()
;		- Game_Init()
;		- Game_Main()
;		- Game_Shutdown()
;
;
;###########################################################################
;###########################################################################


;###########################################################################
;###########################################################################
; THE COMPILER OPTIONS
;###########################################################################
;###########################################################################

	.586
	.model flat, stdcall
	option casemap :none   ; case sensitive

;###########################################################################
;###########################################################################
; THE INCLUDES SECTION
;###########################################################################
;###########################################################################

	;================================================
	; These are the Inlcude files for Window calls
	;================================================
	include \masm32\include\windows.inc
	include \masm32\include\comctl32.inc
	include \masm32\include\comdlg32.inc
	include \masm32\include\shell32.inc
	include \masm32\include\user32.inc
	include \masm32\include\kernel32.inc
	include \masm32\include\gdi32.inc

	;====================================
	; The Direct Draw include file
	;====================================
	include Includes\DDraw.inc

	;====================================
	; The Direct Input include file
	;====================================
	include Includes\DInput.inc

	;====================================
	; The Direct Sound include file
	;====================================
	include Includes\DSound.inc

	;===============================================
	; The Lib's for those included files
	;================================================
	includelib \masm32\lib\comctl32.lib
	includelib \masm32\lib\comdlg32.lib
	includelib \masm32\lib\shell32.lib
	includelib \masm32\lib\gdi32.lib
	includelib \masm32\lib\user32.lib
	includelib \masm32\lib\kernel32.lib


	;=================================================
	; Include the file that has our prototypes
	;=================================================
	include Protos.inc

;###########################################################################
;###########################################################################
; LOCAL MACROS
;###########################################################################
;###########################################################################

	szText MACRO Name, Text:VARARG
		LOCAL lbl
		jmp lbl
		Name db Text,0
		lbl:
	ENDM

	m2m MACRO M1, M2
		push		M2
		pop		M1
	ENDM

	return MACRO arg
		mov	eax, arg
		ret
	ENDM

	RGB MACRO red, green, blue
		xor	eax,eax
		mov	ah,blue
		shl	eax,8
		mov	ah,green
		mov	al,red
	ENDM

;#################################################################################
;#################################################################################
; Variables we want to use in other modules
;#################################################################################
;#################################################################################

	;===========================================
	; The main window handle
	;===========================================
	PUBLIC	hMainWnd
	PUBLIC	hInst

;#################################################################################
;#################################################################################
; External variables
;#################################################################################
;#################################################################################

	;=================================
	; The DirectDraw stuff
	;=================================
	EXTERN	lpddsprimary	:LPDIRECTDRAWSURFACE4
	EXTERN	lpddsback	:LPDIRECTDRAWSURFACE4

	;=========================================
	; The Input Device state variables
	;=========================================
	EXTERN keyboard_state	:BYTE

;#################################################################################
;#################################################################################
; BEGIN INITIALIZED DATA
;#################################################################################
;#################################################################################

    .data
	;==============================
	;Text for the Window Title and
	; the class name
	;==============================
	szDisplayName	db "Snake",0
	szClassName	db "Snake Class",0

	;==============================
	;Windows handles and Misc
	;==============================
	msg  MSG	<?>	; For message handling
	CommandLine	dd 0	; for the commandline params
	hMainWnd	dd 0	; Handle to the main window
	hInst		dd 0	; Handle to an Instance

	;======================================
	; A variable to hold the game state
	;======================================
	GameState	db 0

	;======================================
	; A value to hold lPitch when locking
	;======================================
	lPitch		dd 0

	;===============================
	; Strings for the Loading bitmap
	;===============================
	;===============================
	; PTR to the BMP's
	;===============================
	szIdle	dd 30
	szLoading		dd 6
	szLoadingjpg		   dd 1
	szLoadingtga		   db "loading.tga",0
	ptr_BMP_LOAD	dd 0
	szredback		dd 2
	szredbackjpg		dd 12
	szredbacktga		db "play.tga",0
	ptr_BMP_REDBACK dd 0

	szMainMenu		dd 3
	szMainMenujpg		dd 13
	szMainMenutga		db "main.tga",0
	ptr_MAIN_MENU	dd 0
	szOptionMenu		dd 4
	szOptionMenujpg 	   dd 14
	szOptionMenutga 	   db "options.tga",0
	ptr_OPTION_MENU dd 0
	szblauback		dd 5
	szblaubackjpg		dd 15
	szblaubacktga		db "editor.tga",0
	ptr_EDIT_MENU	dd 0

	snakehd 		db "data\snakehd.sfp",0
	snakehdtga		   db "snake_hd.tga",0
	ptr_BMP_S_hd	dd 0
	snakehl 		db "data\snakehl.sfp",0
	snakehltga		   db "snake_hl.tga",0
	ptr_BMP_S_hl	dd 0
	snakehr 		db "data\snakehr.sfp",0
	snakehrtga		   db "snake_hr.tga",0
	ptr_BMP_S_hr	dd 0
	snakehu 		db "data\snakehu.sfp",0
	snakehutga		   db "snake_hu.tga",0
	ptr_BMP_S_hu	dd 0
	snakeld 		db "data\snakeld.sfp",0
	snakeldtga		   db "snake_ld.tga",0
	ptr_BMP_S_ld	dd 0
	snakelr 		db "data\snakelr.sfp",0
	snakelrtga		   db "snake_lr.tga",0
	ptr_BMP_S_lr	dd 0
	snakelu 		db "data\snakelu.sfp",0
	snakelutga		   db "snake_lu.tga",0
	ptr_BMP_S_lu	dd 0
	snakerd 		db "data\snakerd.sfp",0
	snakerdtga		   db "snake_rd.tga",0
	ptr_BMP_S_rd	dd 0
	snakeru 		db "data\snakeru.sfp",0
	snakerutga		   db "snake_ru.tga",0
	ptr_BMP_S_ru	dd 0
	snaketd 		db "data\snaketd.sfp",0
	snaketdtga		   db "snake_td.tga",0
	ptr_BMP_S_td	dd 0
	snaketl 		db "data\snaketl.sfp",0
	snaketltga		   db "snake_tl.tga",0
	ptr_BMP_S_tl	dd 0
	snaketr 		db "data\snaketr.sfp",0
	snaketrtga		   db "snake_tr.tga",0
	ptr_BMP_S_tr	dd 0
	snaketu 		db "data\snaketu.sfp",0
	snaketutga		   db "snake_tu.tga",0
	ptr_BMP_S_tu	dd 0
	snakeud 		db "data\snakeud.sfp",0
	snakeudtga		   db "snake_ud.tga",0
	ptr_BMP_S_ud	dd 0




	snake2hd		 db "data\snake2hd.sfp",0
	snake2hdtga		    db "snake2_hd.tga",0
	ptr_BMP_S2_hd	 dd 0
	snake2hl		 db "data\snake2hl.sfp",0
	snake2hltga		    db "snake2_hl.tga",0
	ptr_BMP_S2_hl	 dd 0
	snake2hr		 db "data\snake2hr.sfp",0
	snake2hrtga		    db "snake2_hr.tga",0
	ptr_BMP_S2_hr	 dd 0
	snake2hu		 db "data\snake2hu.sfp",0
	snake2hutga		    db "snake2_hu.tga",0
	ptr_BMP_S2_hu	 dd 0
	snake2ld		 db "data\snake2ld.sfp",0
	snake2ldtga		    db "snake2_ld.tga",0
	ptr_BMP_S2_ld	 dd 0
	snake2lr		 db "data\snake2lr.sfp",0
	snake2lrtga		    db "snake2_lr.tga",0
	ptr_BMP_S2_lr	 dd 0
	snake2lu		 db "data\snake2lu.sfp",0
	snake2lutga		    db "snake2_lu.tga",0
	ptr_BMP_S2_lu	 dd 0
	snake2rd		 db "data\snake2rd.sfp",0
	snake2rdtga		    db "snake2_rd.tga",0
	ptr_BMP_S2_rd	 dd 0
	snake2ru		 db "data\snake2ru.sfp",0
	snake2rutga		    db "snake2_ru.tga",0
	ptr_BMP_S2_ru	 dd 0
	snake2td		 db "data\snake2td.sfp",0
	snake2tdtga		    db "snake2_td.tga",0
	ptr_BMP_S2_td	 dd 0
	snake2tl		 db "data\snake2tl.sfp",0
	snake2tltga		    db "snake2_tl.tga",0
	ptr_BMP_S2_tl	 dd 0
	snake2tr		 db "data\snake2tr.sfp",0
	snake2trtga		    db "snake2_tr.tga",0
	ptr_BMP_S2_tr	 dd 0
	snake2tu		 db "data\snake2tu.sfp",0
	snake2tutga		    db "snake2_tu.tga",0
	ptr_BMP_S2_tu	 dd 0
	snake2ud		 db "data\snake2ud.sfp",0
	snake2udtga		    db "snake2_ud.tga",0
	ptr_BMP_S2_ud	 dd 0



	lab1blue		db "data\lab1blue.sfp",0
	lab1bluetga		   db "lab1.tga",0
	ptr_BMP_L_1b	dd 0
	lab2blue		db "data\lab2blue.sfp",0
	lab2bluetga		   db "lab2.tga",0
	ptr_BMP_L_2b	dd 0
	lab3blue		db "data\lab3blue.sfp",0
	lab3bluetga		   db "lab3.tga",0
	ptr_BMP_L_3b	dd 0
	lab4blue		db "data\lab4blue.sfp",0
	lab4bluetga		   db "lab4.tga",0
	ptr_BMP_L_4b	dd 0
	lab5blue		db "data\lab5blue.sfp",0
	lab5bluetga		   db "lab5.tga",0
	ptr_BMP_L_5b	dd 0
	lab6blue		db "data\lab6blue.sfp",0
	lab6bluetga		   db "lab6.tga",0
	ptr_BMP_L_6b	dd 0
	lab7blue		db "data\lab7blue.sfp",0
	lab7bluetga		   db "lab7.tga",0
	ptr_BMP_L_7b	dd 0
	lab8blue		db "data\lab8blue.sfp",0
	lab8bluetga		   db "lab8.tga",0
	ptr_BMP_L_8b	dd 0
	lab9blue		db "data\lab9blue.sfp",0
	lab9bluetga		   db "lab9.tga",0
	ptr_BMP_L_9b	dd 0


	point0			db "data\0.sfp",0
	ptr_BMP_P_0	dd 0
	point1			db "data\1.sfp",0
	ptr_BMP_P_1	dd 0
	point2			db "data\2.sfp",0
	ptr_BMP_P_2	dd 0
	point3			db "data\3.sfp",0
	ptr_BMP_P_3	dd 0
	point4			db "data\4.sfp",0
	ptr_BMP_P_4	dd 0
	point5			db "data\5.sfp",0
	ptr_BMP_P_5	dd 0
	point6			db "data\6.sfp",0
	ptr_BMP_P_6	dd 0
	point7			db "data\7.sfp",0
	ptr_BMP_P_7	dd 0
	point8			db "data\8.sfp",0
	ptr_BMP_P_8	dd 0
	point9			db "data\9.sfp",0
	ptr_BMP_P_9	dd 0




	set1			db "data\point1.sfp",0
	set1tga 		   db "point1.tga",0
	ptr_BMP_SP_1	dd 0
	set2			db "data\point2.sfp",0
	set2tga 		   db "point2.tga",0
	ptr_BMP_SP_2	dd 0
	set3			db "data\point3.sfp",0
	set3tga 		   db "point3.tga",0
	ptr_BMP_SP_3	dd 0


	szselect		db "data\select.sfp",0
	ptr_BMP_G_1	dd 0

	sz3dl1			db "data\3dl1.sfp",0
	ptr_BMP_3d_1	 dd 0
	sz3dl2			db "data\3dl2.sfp",0
	ptr_BMP_3d_2	 dd 0
	sz3dl3			db "data\3dl3.sfp",0
	ptr_BMP_3d_3	 dd 0
	sz3dl4			db "data\3dl4.sfp",0
	ptr_BMP_3d_4	 dd 0
	sz3dl5			db "data\3dl5.sfp",0
	ptr_BMP_3d_5	 dd 0
	sz3dl6			db "data\3dl6.sfp",0
	ptr_BMP_3d_6	 dd 0
	sz3dl7			db "data\3dl7.sfp",0
	ptr_BMP_3d_7	 dd 0
	sz3dl8			db "data\3dl8.sfp",0
	ptr_BMP_3d_8	 dd 0


	ptr_BMP 	dd 0



	;================================
	; Our very cool menu sound
	;================================

	srcbltc 	DDCOLORKEY	<0,0>
	SrcRectROCKET	RECT	<0,0,44,44>
	SrcRect6879	RECT	<0,0,68,79>
	SrcRect800600	RECT	<0,0,800,600>

	;================================
	; Our very cool background music
	;================================
	;===============================
	; ID for the background Music
	;===============================
	szMusicSnd	    db "Data\Music.sna",0
	Music_ID	dd 0

	;===============================
	; ID for the Menu sound
	;===============================
	szMenuSnd	    db "Data\Music.sna",0
	Menu_ID 	dd 0


	;===============================
	; ID for the Snake Eat sound
	;===============================
	szSnakeEat	    db "Data\WHOOSH.sna",0
	SnakeEat_ID	dd 0
	szSnakeMove	    db "Data\m_move.sna",0
	SnakeMove_ID	 dd 0
	szSnakeCrash	     db "Data\explode.sna",0
	SnakeCrash_ID	  dd 0


	szPoints	db "%01d",0
	szPlayer1	db "%01d",0
	szPlayer2	db "%01d",0
	szPAUSE 	db "PAUSE",0
	szSAVE		db "Saving, Press q-p"
	szSavegame	db "Press 1-0 to save"
	szImpact	db "Impact",0
	Version 	db  "1.0"
	ETime		dd 0
	times		dd 0
	timesound	dd 0
	TimeCritic	dd 0
	Problem_Time	dd 0
	first_time	dd 1
	Time_OK 	dd 0
	PAUSE		dd 0
	point_type	dd 0
	music_on	dd 1
	sound_on	dd 1
	Save		dd 0
	;========================================
	; Rectangle structure for caption drawing
	;========================================
	text_rect	RECT <?>

	;========================================
	; A DC for the drawing of the captions
	;========================================
	hDC		dd 0
	Old_Obj 	dd 0
	dwArgs		dd 4 dup (0)	; Array of 4 DWORDS for the wvsprintf call
	szBuffer	db 18 dup (0)	; This creates a buffer of size
				       ; 18 filled with 0's dup = duplicate

	;================================
	;Variables for Game
	;================================

	Grid_ID 	dd 0
	directionb	dd 0
	direction	dd 0
	snakelength	dd 0
	PositionX	dd 0
	PositionY	dd 0
	PositionXo	 dd 0
	PositionYo	 dd 0
	P1_Score	 dd 0
;Player2
	p2directionb	  dd 0
	p2direction	  dd 0
	p2snakelength	  dd 0
	p2PositionX	  dd 0
	p2PositionY	  dd 0
	p2PositionXo	   dd 0
	p2PositionYo	   dd 0
	P2_Score	   dd 0
	p2Pass		   dd 0

	Lab_Number	dd 1
	Points		dd 0
	Level_Points	dd 6


	szLAB1l 	db  "data1\LAB1.sna",0
	szLAB2l 	db  "data1\LAB2.sna",0
	szLAB3l 	db  "data1\LAB3.sna",0
	szLAB4l 	db  "data1\LAB4.sna",0
	szLAB5l 	db  "data1\LAB5.sna",0
	szLAB6l 	db  "data1\LAB6.sna",0
	szLAB7l 	db  "data1\LAB7.sna",0
	szLAB8l 	db  "data1\LAB8.sna",0
	szLAB9l 	db  "data1\LAB9.sna",0
	szLAB0l 	db  "data1\LAB0.sna",0
	szLABCl 	db  "data1\LABc.sna",0
	szLABOl 	db  "data1\LABo.sna",0
	szLABMPl	db  "data1\LABMP.sna",0

	szsave1l	 db  "data1\SAVE1.sna",0
	szsave2l	 db  "data1\SAVE2.sna",0
	szsave3l	 db  "data1\SAVE3.sna",0
	szsave4l	 db  "data1\SAVE4.sna",0
	szsave5l	 db  "data1\SAVE5.sna",0
	szsave6l	 db  "data1\SAVE6.sna",0
	szsave7l	 db  "data1\SAVE7.sna",0
	szsave8l	 db  "data1\SAVE8.sna",0
	szsave9l	 db  "data1\SAVE9.sna",0
	szsave0l	 db  "data1\SAVE0.sna",0
	szsaveol	 db  "data1\SAVEO.sna",0

	ssave1l 	db  "data1\SVE1.sna",0
	ssave2l 	db  "data1\SVE2.sna",0
	ssave3l 	db  "data1\SVE3.sna",0
	ssave4l 	db  "data1\SVE4.sna",0
	ssave5l 	db  "data1\SVE5.sna",0
	ssave6l 	db  "data1\SVE6.sna",0
	ssave7l 	db  "data1\SVE7.sna",0
	ssave8l 	db  "data1\SVE8.sna",0
	ssave9l 	db  "data1\SVE9.sna",0
	ssave0l 	db  "data1\SVE0.sna",0
	ssaveol 	db  "data1\SVEO.sna",0
	ssaveg		db  "data1\SVEG.sna",0

	Hiscore1	dd 0
	Hiscore2	dd 0
	Hiscore3	dd 0
	Hiscore4	dd 0
	Hiscore5	dd 0


szDebug		db "Debug",0




	;================================
	; Timer Variables
	;================================
	Input_Time	dd 0
	Pass		dd 0
	Update_Time	dd 500
	UPDATE_DELAY	dd 50
	hFile		dd 0
	hMemory 	dd 0
	SizeReadWrite	dd 0
	round		dd 0
	roundtime	dd 0
;#################################################################################
;#################################################################################
; BEGIN CONSTANTS
;#################################################################################
;#################################################################################


;#################################################################################
;#################################################################################
; BEGIN EQUATES
;#################################################################################
;#################################################################################

	;=================
	;Utility Equates
	;=================
FALSE		equ	0
TRUE		equ	1

	;=================
	; The Screen BPP
	;=================
screen_bpp	equ	16

	;================
	; resource IDs
	;================
IDI_ICON	equ	01h


	;======================================
	; Set the max sync rate - 100 FPS
	;======================================
sync_time	equ	10	; in Milliseconds

	;=====================
	; For the game state
	;=====================
GS_MENU 	equ	01h
GS_EXIT 	equ	02h
GS_DIE		equ	03h
GS_EDIT 	equ	04h
GS_PLAY 	equ	05h
GS_WON		equ	06h
GS_OPTION	equ	07h
GS_PAUSE	equ	08h
GS_MP_PLAY	equ	09h
GS_MP_IDLE	equ	0Ah
GS_MP_EDIT	equ	0Bh
GS_MP_ENDROUND	equ	0Ch

;=================
; The Menu Codes
;=================
	; Generic
MENU_ERROR	equ	00h
MENU_NOTHING	equ	01h

	; Main Menu
MENU_NEW	equ	02h
MENU_LOAD	equ	03h
MENU_OPTION	equ	04h
MENU_EXIT	equ	05h
MENU_BACK	equ	06h
MENU_EDIT	equ	07h
MENU_MAIN	equ	08h


		;MP Menu
MENU_MP_EDIT	equ	09h
MENU_MP_PLAY	equ	0Ah


	;=================
	; Movement EQU's
	;=================
MOVE_LEFT	equ	1
MOVE_RIGHT	equ	2
MOVE_UP 	equ	3
MOVE_DOWN	equ	4

	;===================
	; Millisecond delays
	;===================
INPUT_DELAY	equ	150


;#################################################################################
;#################################################################################
; BEGIN THE CODE SECTION
;#################################################################################
;#################################################################################

  .code

;_imp__GetEnvironmentStrings proc
;invoke GetEnvironmentStrings
;return eax
;_imp__GetEnvironmentStrings endp


start:
;main proc  c public


	;==================================
	; Obtain the instance for the
	; application
	;==================================
	invoke GetModuleHandle, NULL
	mov	hInst, eax

	;==================================
	; Is there a commandline to parse?
	;==================================
	invoke GetCommandLine
	mov	CommandLine, eax

	;==================================
	; Call the WinMain procedure
	;==================================
	invoke WinMain,hInst,NULL,CommandLine,SW_SHOWDEFAULT

	;==================================
	; Leave the program
	;==================================
	invoke ExitProcess,eax
;main endp

;########################################################################
; WinMain Function
;########################################################################
WinMain proc	hInstance	:DWORD,
		hPrevInst	:DWORD,
		CmdLine 	:DWORD,
		CmdShow 	:DWORD

	;====================
	; Put LOCALs on stack
	;====================
	LOCAL wc		:WNDCLASS

	;==================================================
	; Fill WNDCLASS structure with required variables
	;==================================================
	mov	wc.style, CS_OWNDC
	mov	wc.lpfnWndProc,offset WndProc
	mov	wc.cbClsExtra,NULL
	mov	wc.cbWndExtra,NULL
	m2m	wc.hInstance,hInst   ;<< NOTE: macro not mnemonic
	invoke GetStockObject, BLACK_BRUSH
	mov	wc.hbrBackground, eax
	mov	wc.lpszMenuName,NULL
	mov	wc.lpszClassName,offset szClassName
	invoke LoadIcon, hInst, IDI_ICON ; icon ID
	mov	wc.hIcon,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov	wc.hCursor,eax

	;================================
	; Register our class we created
	;================================
	invoke RegisterClass, ADDR wc

	;===========================================
	; Create the main screen
	;===========================================
	invoke CreateWindowEx,NULL,
			ADDR szClassName,
			ADDR szDisplayName,
			WS_POPUP or WS_CLIPSIBLINGS or \
			WS_MAXIMIZE or WS_CLIPCHILDREN,
			0,0,800,600,
			NULL,NULL,
			hInst,NULL

;			WS_POPUP or WS_CLIPSIBLINGS or \
;			WS_MAXIMIZE or WS_CLIPCHILDREN,

	;===========================================
	; Put the window handle in for future uses
	;===========================================
	mov	hMainWnd, eax

	;====================================
	; Hide the cursor
	;====================================
	invoke ShowCursor, FALSE

	;===========================================
	; Display our Window we created for now
	;===========================================
	invoke ShowWindow, hMainWnd, SW_SHOWDEFAULT

	
	;=================================
	; Intialize the Game
	;=================================
	invoke Game_Init
	
	;========================================
	; Check for an error if so leave
	;========================================
	.if eax != TRUE
		jmp	shutdown
	.endif

	;===================================
	; Loop until PostQuitMessage is sent
	;===================================
	.WHILE TRUE
		invoke	PeekMessage, ADDR msg, NULL, 0, 0, PM_REMOVE
		.if (eax != 0)
			;===================================
			; Break if it was the quit messge
			;===================================
			mov	eax, msg.message
			.IF eax == WM_QUIT
				;======================
				; Break out
				;======================
				jmp	shutdown
			.endif

			;===================================
			; Translate and Dispatch the message
			;===================================
			invoke	TranslateMessage, ADDR msg
			invoke	DispatchMessage, ADDR msg

		.endif

		;================================
		; Call our Main Game Loop
		;
		; NOTE: This is done every loop
		; iteration no matter what
		;================================
		invoke Game_Main

		;=============================
		; Do they want to leave
		;=============================
		.if GameState == GS_EXIT
			jmp	shutdown
		.endif

	.ENDW

shutdown:

	;=================================
	; Shutdown the Game
	;=================================
	invoke Game_Shutdown

	;=================================
	; Show the Cursor
	;=================================
	invoke ShowCursor, TRUE

getout:
	;===========================
	; We are through
	;===========================
	return msg.wParam

WinMain endp
;########################################################################
; End of WinMain Procedure
;########################################################################



;########################################################################
; Main Window Callback Procedure -- WndProc
;########################################################################
WndProc proc	hWin   :DWORD,
		uMsg   :DWORD,
		wParam :DWORD,
		lParam :DWORD

.if uMsg == WM_COMMAND
	;===========================
	; We don't have a menu, but
	; if we did this is where it
	; would go!
	; NOTE: This means an app
	; menu not our bitmap menu!
	;===========================

.elseif uMsg == WM_DESTROY
	;===========================
	; Kill the application
	;===========================
	invoke PostQuitMessage,NULL
	return 0

.endif

;=================================================
; Let the default procedure handle the message
;=================================================
invoke DefWindowProc,hWin,uMsg,wParam,lParam

ret

WndProc endp
;########################################################################
; End of Main Windows Callback Procedure
;########################################################################



;========================================================================
;========================================================================
; THE GAME PROCEDURES
;========================================================================
;========================================================================


;########################################################################
; Game_Init Procedure
;########################################################################
Game_Init	proc
 LOCAL StartTime :DWORD
	;=========================================================
	; This function will setup the game
	;=========================================================

	;============================================
	; Initialize Direct Draw -- 800, 600, bpp
	;============================================
	invoke DD_Init, 800, 600, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================
		jmp	err

	.endif



	;======================================
	; Read in the bitmap and create buffer
	;======================================
	invoke Create_From_JPG, ADDR ptr_BMP_LOAD, szLoadingjpg, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================
		;jmp	 err
	;======================================
	; Read in the bitmap and create buffer
	;======================================
	invoke Create_From_TGA, ADDR ptr_BMP_LOAD, ADDR szLoadingtga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================
		;jmp	 err
	;======================================
	; Read in the bitmap and create buffer
	;======================================
	invoke Create_From_JPG, ADDR ptr_BMP_LOAD, szLoading, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================
		jmp	err

	.endif
	.endif
	.endif


	invoke Delay_Time, 10

	;===================================
	; Lock the DirectDraw back buffer
	;===================================
	invoke DD_Lock_Surface, lpddsback, ADDR lPitch

	;============================
	; Check for an error
	;============================
	.if eax == FALSE
		;===================
		; Jump to err
		;===================
		jmp	err

	.endif

	;===================================
	; Draw the bitmap onto the surface
	;===================================
	invoke Draw_Bitmap, eax, ptr_BMP_LOAD, lPitch, 800, 600, screen_bpp

	;===================================
	; Unlock the back buffer
	;===================================
	invoke DD_Unlock_Surface, lpddsback

	;============================
	; Check for an error
	;============================
	.if eax == FALSE
		;===================
		; Jump to err
		;===================
		jmp	err

	.endif

	;=====================================
	; Everything okay so flip displayed
	; surfaces and make loading visible
	;======================================
	invoke DD_Flip

	;============================
	; Check for an error
	;============================
	.if eax == FALSE
		;===================
		; Jump to err
		;===================
		jmp	err

	.endif




	invoke Start_Time, ADDR StartTime


	invoke DD_Create_Surface, 800, 600, NULL
	mov DWORD PTR ptr_BMP_REDBACK, eax
	    .if eax == NULL
		jmp err
	    .endif


      invoke Create_From_JPG, ADDR ptr_BMP, szredbackjpg, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE

      invoke Create_From_TGA, ADDR ptr_BMP, ADDR szredbacktga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE

      invoke Create_From_JPG, ADDR ptr_BMP, szredback, screen_bpp

	 .if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err
	.endif
	.endif
	.endif

	mov ebx, DWORD PTR ptr_BMP_REDBACK
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		800, 600, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10




	;======================================
	; Read in the bitmap and create buffer
	;======================================
	invoke Create_From_JPG, ADDR ptr_MAIN_MENU, szMainMenujpg, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
	;======================================
	; Read in the bitmap and create buffer
	;======================================
	invoke Create_From_TGA, ADDR ptr_MAIN_MENU, ADDR szMainMenutga, screen_bpp

	;====================================
	; Test for an error
	;====================================



	.if eax == FALSE

	invoke Create_From_JPG, ADDR ptr_MAIN_MENU, szMainMenu, screen_bpp

	.if eax == FALSE
		;========================
		; We failed so leave
		;========================
		jmp	err

	.endif
	.endif
	.endif




	;======================================
	; Read in the bitmap and create buffer
	;======================================
		invoke Create_From_JPG, ADDR ptr_OPTION_MENU, szOptionMenujpg, screen_bpp

	;====================================
	; Test for an error
	;====================================

	.if eax == FALSE

	;======================================
	; Read in the bitmap and create buffer
	;======================================
		invoke Create_From_TGA, ADDR ptr_OPTION_MENU, ADDR szOptionMenutga, screen_bpp

	;====================================
	; Test for an error
	;====================================

	.if eax == FALSE

	invoke Create_From_JPG, ADDR ptr_OPTION_MENU, szOptionMenu, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================
		jmp	err

	.endif
	.endif
	.endif
	;======================================
	; Read in the bitmap and create buffer
	;======================================
	invoke Create_From_JPG, ADDR ptr_EDIT_MENU, szblaubackjpg, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
	;======================================
	; Read in the bitmap and create buffer
	;======================================
	invoke Create_From_TGA, ADDR ptr_EDIT_MENU, ADDR szblaubacktga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE

	invoke Create_From_JPG, ADDR ptr_EDIT_MENU,  szblauback, screen_bpp
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================
		jmp	err
	.endif
	.endif
	.endif









	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_S_hd, eax
	    .if eax == NULL
		jmp err
	    .endif

      invoke Create_From_TGA, ADDR ptr_BMP, ADDR snakehdtga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE

	invoke Create_From_SFP, ADDR ptr_BMP, ADDR snakehd, screen_bpp

	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	.endif

	mov ebx, DWORD PTR ptr_BMP_S_hd
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_S_hd, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP



	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_S_hl, eax
	    .if eax == NULL
		jmp err
	    .endif


      invoke Create_From_TGA, ADDR ptr_BMP, ADDR snakehltga, screen_bpp

	;====================================
	; Test for an error
	;====================================

	.if eax == FALSE
	invoke Create_From_SFP, ADDR ptr_BMP, ADDR snakehl, screen_bpp
	.if eax== FALSE

		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	.endif
	mov ebx, DWORD PTR ptr_BMP_S_hl
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_S_hl, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP




	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_S_hr, eax
	    .if eax == NULL
		jmp err
	    .endif


      invoke Create_From_TGA, ADDR ptr_BMP, ADDR snakehrtga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
      invoke Create_From_SFP, ADDR ptr_BMP, ADDR snakehr, screen_bpp
      .if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	.endif
	mov ebx, DWORD PTR ptr_BMP_S_hr
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_S_hr, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP


	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_S_hu, eax
	    .if eax == NULL
		jmp err
	    .endif



      invoke Create_From_TGA, ADDR ptr_BMP, ADDR snakehutga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
	invoke Create_From_SFP, ADDR ptr_BMP, ADDR snakehu, screen_bpp
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err
	.endif
	.endif
	mov ebx, DWORD PTR ptr_BMP_S_hu
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_S_hu, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP

	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_S_ld, eax
	    .if eax == NULL
		jmp err
	    .endif


      invoke Create_From_TGA, ADDR ptr_BMP, ADDR snakeldtga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
      invoke Create_From_SFP, ADDR ptr_BMP, ADDR snakeld, screen_bpp
	 .if eax == FALSE
	  ;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	.endif
	mov ebx, DWORD PTR ptr_BMP_S_ld
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_S_ld, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP

	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_S_lr, eax
	    .if eax == NULL
		jmp err
	    .endif


      invoke Create_From_TGA, ADDR ptr_BMP, ADDR snakelrtga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
      invoke Create_From_SFP, ADDR ptr_BMP, ADDR snakelr, screen_bpp
      .if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	.endif
	mov ebx, DWORD PTR ptr_BMP_S_lr
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_S_lr, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP


	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_S_lu, eax
	    .if eax == NULL
		jmp err
	    .endif


      invoke Create_From_TGA, ADDR ptr_BMP, ADDR snakelutga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
      invoke Create_From_SFP, ADDR ptr_BMP, ADDR snakelu, screen_bpp
      .if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	.endif
	mov ebx, DWORD PTR ptr_BMP_S_lu
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_S_lu, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP


	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_S_rd, eax
	    .if eax == NULL
		jmp err
	    .endif


      invoke Create_From_TGA, ADDR ptr_BMP, ADDR snakerdtga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
	invoke Create_From_SFP, ADDR ptr_BMP, ADDR snakerd, screen_bpp
	.if eax == FALSE
	;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	mov ebx, DWORD PTR ptr_BMP_S_rd
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_S_rd, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP


	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_S_ru, eax
	    .if eax == NULL
		jmp err
	    .endif


      invoke Create_From_TGA, ADDR ptr_BMP, ADDR snakerutga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
      invoke Create_From_SFP, ADDR ptr_BMP, ADDR snakeru, screen_bpp
	     .if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	.endif
	mov ebx, DWORD PTR ptr_BMP_S_ru
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_S_ru, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP


	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_S_td, eax
	    .if eax == NULL
		jmp err
	    .endif


      invoke Create_From_TGA, ADDR ptr_BMP, ADDR snaketdtga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
      invoke Create_From_SFP, ADDR ptr_BMP, ADDR snaketd, screen_bpp
      .if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	.endif
	mov ebx, DWORD PTR ptr_BMP_S_td
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_S_td, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP



	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_S_tl, eax
	    .if eax == NULL
		jmp err
	    .endif


      invoke Create_From_TGA, ADDR ptr_BMP, ADDR snaketltga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
	invoke Create_From_SFP, ADDR ptr_BMP, ADDR snaketl, screen_bpp
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	.endif
	mov ebx, DWORD PTR ptr_BMP_S_tl
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_S_tl, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP



	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_S_tr, eax
	    .if eax == NULL
		jmp err
	    .endif


      invoke Create_From_TGA, ADDR ptr_BMP, ADDR snaketrtga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
	invoke Create_From_SFP, ADDR ptr_BMP, ADDR snaketr, screen_bpp
	.if eax == FALSE
	;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	.endif
	mov ebx, DWORD PTR ptr_BMP_S_tr
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_S_tr, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP

	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_S_tu, eax
	    .if eax == NULL
		jmp err
	    .endif


      invoke Create_From_TGA, ADDR ptr_BMP, ADDR snaketutga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
      invoke Create_From_SFP, ADDR ptr_BMP, ADDR snaketu, screen_bpp
      .if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	.endif
	mov ebx, DWORD PTR ptr_BMP_S_tu
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_S_tu, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP


	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_S_ud, eax
	    .if eax == NULL
		jmp err
	    .endif


      invoke Create_From_TGA, ADDR ptr_BMP, ADDR snakeudtga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
	invoke Create_From_SFP, ADDR ptr_BMP, ADDR snakeud, screen_bpp
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	.endif
	mov ebx, DWORD PTR ptr_BMP_S_ud
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_S_ud, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP






	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_S2_hd, eax
	    .if eax == NULL
		jmp err
	    .endif


      invoke Create_From_TGA, ADDR ptr_BMP, ADDR snake2hdtga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
      invoke Create_From_SFP, ADDR ptr_BMP, ADDR snake2hd, screen_bpp
      .if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	.endif
	mov ebx, DWORD PTR ptr_BMP_S2_hd
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_S2_hd, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP



	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_S2_hl, eax
	    .if eax == NULL
		jmp err
	    .endif


      invoke Create_From_TGA, ADDR ptr_BMP, ADDR snake2hltga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
      invoke Create_From_SFP, ADDR ptr_BMP, ADDR snake2hl, screen_bpp
      .if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	.endif
	mov ebx, DWORD PTR ptr_BMP_S2_hl
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_S2_hl, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP

	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_S2_hr, eax
	    .if eax == NULL
		jmp err
	    .endif


      invoke Create_From_TGA, ADDR ptr_BMP, ADDR snake2hrtga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
      invoke Create_From_SFP, ADDR ptr_BMP, ADDR snake2hr, screen_bpp
      .if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	.endif
	mov ebx, DWORD PTR ptr_BMP_S2_hr
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_S2_hr, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP


	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_S2_hu, eax
	    .if eax == NULL
		jmp err
	    .endif



      invoke Create_From_TGA, ADDR ptr_BMP, ADDR snake2hutga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
      invoke Create_From_SFP, ADDR ptr_BMP, ADDR snake2hu, screen_bpp
      .if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	.endif
	mov ebx, DWORD PTR ptr_BMP_S2_hu
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_S2_hu, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP

	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_S2_ld, eax
	    .if eax == NULL
		jmp err
	    .endif


      invoke Create_From_TGA, ADDR ptr_BMP, ADDR snake2ldtga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
	invoke Create_From_SFP, ADDR ptr_BMP, ADDR snake2ld, screen_bpp
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	.endif
	mov ebx, DWORD PTR ptr_BMP_S2_ld
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_S2_ld, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP

	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_S2_lr, eax
	    .if eax == NULL
		jmp err
	    .endif


      invoke Create_From_TGA, ADDR ptr_BMP, ADDR snake2lrtga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
      invoke Create_From_SFP, ADDR ptr_BMP, ADDR snake2lr, screen_bpp
      .if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	.endif
	mov ebx, DWORD PTR ptr_BMP_S2_lr
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_S2_lr, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP


	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_S2_lu, eax
	    .if eax == NULL
		jmp err
	    .endif


      invoke Create_From_TGA, ADDR ptr_BMP, ADDR snake2lutga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
	invoke Create_From_SFP, ADDR ptr_BMP, ADDR snake2lu, screen_bpp
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	.endif
	mov ebx, DWORD PTR ptr_BMP_S2_lu
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_S2_lu, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP


	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_S2_rd, eax
	    .if eax == NULL
		jmp err
	    .endif


      invoke Create_From_TGA, ADDR ptr_BMP, ADDR snake2rdtga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
	invoke Create_From_SFP, ADDR ptr_BMP, ADDR snake2rd, screen_bpp
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	.endif
	mov ebx, DWORD PTR ptr_BMP_S2_rd
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_S2_rd, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP


	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_S2_ru, eax
	    .if eax == NULL
		jmp err
	    .endif


      invoke Create_From_TGA, ADDR ptr_BMP, ADDR snake2rutga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
	invoke Create_From_SFP, ADDR ptr_BMP, ADDR snake2ru, screen_bpp
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	.endif
	mov ebx, DWORD PTR ptr_BMP_S2_ru
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_S2_ru, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP


	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_S2_td, eax
	    .if eax == NULL
		jmp err
	    .endif


      invoke Create_From_TGA, ADDR ptr_BMP, ADDR snake2tdtga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
      invoke Create_From_SFP, ADDR ptr_BMP, ADDR snake2td, screen_bpp
      .if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	.endif
	mov ebx, DWORD PTR ptr_BMP_S2_td
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_S2_td, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP



	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_S2_tl, eax
	    .if eax == NULL
		jmp err
	    .endif


      invoke Create_From_TGA, ADDR ptr_BMP, ADDR snake2tltga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
	invoke Create_From_SFP, ADDR ptr_BMP, ADDR snake2tl, screen_bpp
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	.endif
	mov ebx, DWORD PTR ptr_BMP_S2_tl
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_S2_tl, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP



	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_S2_tr, eax
	    .if eax == NULL
		jmp err
	    .endif


      invoke Create_From_TGA, ADDR ptr_BMP, ADDR snake2trtga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
	invoke Create_From_SFP, ADDR ptr_BMP, ADDR snake2tr, screen_bpp
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	.endif
	mov ebx, DWORD PTR ptr_BMP_S2_tr
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_S2_tr, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP

	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_S2_tu, eax
	    .if eax == NULL
		jmp err
	    .endif


      invoke Create_From_TGA, ADDR ptr_BMP, ADDR snake2tutga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
	invoke Create_From_SFP, ADDR ptr_BMP, ADDR snake2tu, screen_bpp
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	.endif
	mov ebx, DWORD PTR ptr_BMP_S2_tu
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_S2_tu, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP


	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_S2_ud, eax
	    .if eax == NULL
		jmp err
	    .endif


      invoke Create_From_TGA, ADDR ptr_BMP, ADDR snake2udtga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
	invoke Create_From_SFP, ADDR ptr_BMP, ADDR snake2ud, screen_bpp
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	.endif
	mov ebx, DWORD PTR ptr_BMP_S2_ud
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_S2_ud, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP














	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_P_1, eax
	    .if eax == NULL
		jmp err
	    .endif


	invoke Create_From_SFP, ADDR ptr_BMP, ADDR point1, screen_bpp
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	.endif
	mov ebx, DWORD PTR ptr_BMP_P_1
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_P_1, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP

	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_P_9, eax
	    .if eax == NULL
		jmp err
	    .endif


      invoke Create_From_SFP, ADDR ptr_BMP, ADDR point9, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	mov ebx, DWORD PTR ptr_BMP_P_9
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_P_9, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP

	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_P_8, eax
	    .if eax == NULL
		jmp err
	    .endif


      invoke Create_From_SFP, ADDR ptr_BMP, ADDR point8, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	mov ebx, DWORD PTR ptr_BMP_P_8
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_P_8, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP

	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_P_7, eax
	    .if eax == NULL
		jmp err
	    .endif


      invoke Create_From_SFP, ADDR ptr_BMP, ADDR point7, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	mov ebx, DWORD PTR ptr_BMP_P_7
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_P_7, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP

	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_P_6, eax
	    .if eax == NULL
		jmp err
	    .endif


      invoke Create_From_SFP, ADDR ptr_BMP, ADDR point6, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	mov ebx, DWORD PTR ptr_BMP_P_6
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_P_6, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP

	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_P_5, eax
	    .if eax == NULL
		jmp err
	    .endif


      invoke Create_From_SFP, ADDR ptr_BMP, ADDR point5, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	mov ebx, DWORD PTR ptr_BMP_P_5
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_P_5, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP

	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_P_4, eax
	    .if eax == NULL
		jmp err
	    .endif


      invoke Create_From_SFP, ADDR ptr_BMP, ADDR point4, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	mov ebx, DWORD PTR ptr_BMP_P_4
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_P_4, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP

	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_P_3, eax
	    .if eax == NULL
		jmp err
	    .endif


      invoke Create_From_SFP, ADDR ptr_BMP, ADDR point3, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	mov ebx, DWORD PTR ptr_BMP_P_3
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_P_3, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP

	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_P_2, eax
	    .if eax == NULL
		jmp err
	    .endif


      invoke Create_From_SFP, ADDR ptr_BMP, ADDR point2, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	mov ebx, DWORD PTR ptr_BMP_P_2
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_P_2, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP


	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_P_0, eax
	    .if eax == NULL
		jmp err
	    .endif


      invoke Create_From_SFP, ADDR ptr_BMP, ADDR point0, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	mov ebx, DWORD PTR ptr_BMP_P_0
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_P_0, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP



	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_SP_1, eax
	    .if eax == NULL
		jmp err
	    .endif


      invoke Create_From_TGA, ADDR ptr_BMP, ADDR set1tga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
      invoke Create_From_SFP, ADDR ptr_BMP, ADDR set1, screen_bpp
      .if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	.endif
	mov ebx, DWORD PTR ptr_BMP_SP_1
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_SP_1, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP
	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_SP_2, eax
	    .if eax == NULL
		jmp err
	    .endif


      invoke Create_From_TGA, ADDR ptr_BMP, ADDR set2tga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
	invoke Create_From_SFP, ADDR ptr_BMP, ADDR set2, screen_bpp
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	.endif
	mov ebx, DWORD PTR ptr_BMP_SP_2
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_SP_2, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP



		    invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_SP_3, eax
	    .if eax == NULL
		jmp err
	    .endif


      invoke Create_From_TGA, ADDR ptr_BMP, ADDR set3tga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
	invoke Create_From_SFP, ADDR ptr_BMP, ADDR set3, screen_bpp
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	.endif
	mov ebx, DWORD PTR ptr_BMP_SP_3
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_SP_3, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP

		    invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_G_1, eax
	    .if eax == NULL
		jmp err
	    .endif


      invoke Create_From_SFP, ADDR ptr_BMP, ADDR szselect, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	mov ebx, DWORD PTR ptr_BMP_G_1
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_G_1, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP




	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_L_1b, eax
	    .if eax == NULL
		jmp err
	    .endif

      invoke Create_From_TGA, ADDR ptr_BMP, ADDR lab1bluetga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
	invoke Create_From_SFP, ADDR ptr_BMP, ADDR lab1blue, screen_bpp
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	.endif
	mov ebx, DWORD PTR ptr_BMP_L_1b
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_L_1b, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP
	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_L_2b, eax
	    .if eax == NULL
		jmp err
	    .endif

      invoke Create_From_TGA, ADDR ptr_BMP, ADDR lab2bluetga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
	invoke Create_From_SFP, ADDR ptr_BMP, ADDR lab2blue, screen_bpp
	.if eax == FALSE
	       ;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	.endif
	mov ebx, DWORD PTR ptr_BMP_L_2b
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_L_2b, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP
	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_L_3b, eax
	    .if eax == NULL
		jmp err
	    .endif

      invoke Create_From_TGA, ADDR ptr_BMP, ADDR lab3bluetga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
	invoke Create_From_SFP, ADDR ptr_BMP, ADDR lab3blue, screen_bpp
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	.endif
	mov ebx, DWORD PTR ptr_BMP_L_3b
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_L_3b, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP
	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_L_4b, eax
	    .if eax == NULL
		jmp err
	    .endif

      invoke Create_From_TGA, ADDR ptr_BMP, ADDR lab4bluetga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
	invoke Create_From_SFP, ADDR ptr_BMP, ADDR lab4blue, screen_bpp
	.if eax == FALSE
	       ;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	.endif
	mov ebx, DWORD PTR ptr_BMP_L_4b
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_L_4b, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP
	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_L_5b, eax
	    .if eax == NULL
		jmp err
	    .endif

      invoke Create_From_TGA, ADDR ptr_BMP, ADDR lab5bluetga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
	invoke Create_From_SFP, ADDR ptr_BMP, ADDR lab5blue, screen_bpp
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	.endif
	mov ebx, DWORD PTR ptr_BMP_L_5b
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_L_5b, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP
	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_L_6b, eax
	    .if eax == NULL
		jmp err
	    .endif

      invoke Create_From_TGA, ADDR ptr_BMP, ADDR lab6bluetga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
	invoke Create_From_SFP, ADDR ptr_BMP, ADDR lab6blue, screen_bpp
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	.endif
	mov ebx, DWORD PTR ptr_BMP_L_6b
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_L_6b, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP
	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_L_7b, eax
	    .if eax == NULL
		jmp err
	    .endif

      invoke Create_From_TGA, ADDR ptr_BMP, ADDR lab7bluetga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
	invoke Create_From_SFP, ADDR ptr_BMP, ADDR lab7blue, screen_bpp
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	.endif
	mov ebx, DWORD PTR ptr_BMP_L_7b
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_L_7b, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP
	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_L_8b, eax
	    .if eax == NULL
		jmp err
	    .endif

      invoke Create_From_TGA, ADDR ptr_BMP, ADDR lab8bluetga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
	invoke Create_From_SFP, ADDR ptr_BMP, ADDR lab8blue, screen_bpp
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	.endif
	mov ebx, DWORD PTR ptr_BMP_L_8b
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_L_8b, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP
	invoke DD_Create_Surface, 44, 44, NULL
	mov DWORD PTR ptr_BMP_L_9b, eax
	    .if eax == NULL
		jmp err
	    .endif

      invoke Create_From_TGA, ADDR ptr_BMP, ADDR lab9bluetga, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
	invoke Create_From_SFP, ADDR ptr_BMP, ADDR lab9blue, screen_bpp
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	.endif
	mov ebx, DWORD PTR ptr_BMP_L_9b
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		44, 44, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_L_9b, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP


	invoke DD_Create_Surface, 68, 79, NULL
	mov DWORD PTR ptr_BMP_3d_1, eax
	    .if eax == NULL
		jmp err
	    .endif

      invoke Create_From_SFP, ADDR ptr_BMP, ADDR sz3dl1, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	mov ebx, DWORD PTR ptr_BMP_3d_1
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		68, 79, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_3d_1, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP


	invoke DD_Create_Surface, 68, 79, NULL
	mov DWORD PTR ptr_BMP_3d_2, eax
	    .if eax == NULL
		jmp err
	    .endif

      invoke Create_From_SFP, ADDR ptr_BMP, ADDR sz3dl2, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	mov ebx, DWORD PTR ptr_BMP_3d_2
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		68, 79, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_3d_2, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP


	invoke DD_Create_Surface, 68, 79, NULL
	mov DWORD PTR ptr_BMP_3d_3, eax
	    .if eax == NULL
		jmp err
	    .endif

      invoke Create_From_SFP, ADDR ptr_BMP, ADDR sz3dl3, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	mov ebx, DWORD PTR ptr_BMP_3d_3
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		68, 79, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_3d_3, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP


	invoke DD_Create_Surface, 68, 79, NULL
	mov DWORD PTR ptr_BMP_3d_4, eax
	    .if eax == NULL
		jmp err
	    .endif

      invoke Create_From_SFP, ADDR ptr_BMP, ADDR sz3dl4, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	mov ebx, DWORD PTR ptr_BMP_3d_4
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		68, 79, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_3d_4, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP


	invoke DD_Create_Surface, 68, 79, NULL
	mov DWORD PTR ptr_BMP_3d_5, eax
	    .if eax == NULL
		jmp err
	    .endif

      invoke Create_From_SFP, ADDR ptr_BMP, ADDR sz3dl5, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	mov ebx, DWORD PTR ptr_BMP_3d_5
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		68, 79, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_3d_5, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP


	invoke DD_Create_Surface, 68, 79, NULL
	mov DWORD PTR ptr_BMP_3d_6, eax
	    .if eax == NULL
		jmp err
	    .endif

      invoke Create_From_SFP, ADDR ptr_BMP, ADDR sz3dl6, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	mov ebx, DWORD PTR ptr_BMP_3d_6
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		68, 79, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_3d_6, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP


	invoke DD_Create_Surface, 68, 79, NULL
	mov DWORD PTR ptr_BMP_3d_7, eax
	    .if eax == NULL
		jmp err
	    .endif

      invoke Create_From_SFP, ADDR ptr_BMP, ADDR sz3dl7, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	mov ebx, DWORD PTR ptr_BMP_3d_7
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		68, 79, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_3d_7, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP


	invoke DD_Create_Surface, 68, 79, NULL
	mov DWORD PTR ptr_BMP_3d_8, eax
	    .if eax == NULL
		jmp err
	    .endif

      invoke Create_From_SFP, ADDR ptr_BMP, ADDR sz3dl8, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================

		jmp	err

	.endif
	mov ebx, DWORD PTR ptr_BMP_3d_8
	invoke DD_Load_Bitmap, ebx, ptr_BMP,\
		68, 79, screen_bpp

	    .if eax == FALSE
		jmp err

	    .endif

	invoke Delay_Time, 10

	DDS4INVOKE SetColorKey, ptr_BMP_3d_8, DDCKEY_SRCBLT, ADDR srcbltc

	    invoke GlobalFree, ptr_BMP











	;======================================
	; Initialize Direct Input
	;======================================
	invoke DI_Init

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================
		jmp	err

	.endif




	;======================================
	; Initialize Direct Sound
	;======================================
	invoke DS_Init

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================
		jmp	err

	.endif






	;========================
	; Load in the menu sound
	;========================
	invoke Load_WAV, ADDR szMenuSnd, NULL
	mov	Menu_ID, eax



	;========================
	; Load in the level music
	;========================
	invoke Load_WAV, ADDR szMusicSnd, NULL
	mov	Music_ID, eax

	;========================
	; Load in the SnakeEat music
	;========================
	invoke Load_WAV, ADDR szSnakeEat, NULL
	mov	SnakeEat_ID, eax
	;========================
	; Load in the SnakeMove music
	;========================
	invoke Load_WAV, ADDR szSnakeMove, NULL
	mov	SnakeMove_ID, eax
	;========================
	; Load in the SnakeMove music
	;========================
	invoke Load_WAV, ADDR szSnakeCrash, NULL
	mov	SnakeCrash_ID, eax



	;========================================
	; Initialize the timing system
	;========================================
	invoke Init_Time

	;===================================
	; Set the game state to the menu
	; state since that is our fist stop
	;===================================
	mov	GameState, GS_MENU
	mov	UPDATE_DELAY, 100
	m2m	point_type, ptr_BMP_SP_1

	mov	first_time, TRUE
	mov	sound_on, TRUE
	mov	music_on, TRUE
	mov	PAUSE, FALSE
	mov	direction, MOVE_RIGHT
	mov	directionb, MOVE_RIGHT
	mov	PositionX, 7
	mov	PositionY, 11
	mov	snakelength, 7
	mov	p2direction, MOVE_LEFT
	mov	p2directionb, MOVE_LEFT
	mov	p2PositionX, 10
	mov	p2PositionY, 1
	mov	p2snakelength, 7
	mov	Pass, FALSE
	mov	Points, 0
	mov	Level_Points, 4
	mov	round, 0
	mov	P1_Score, 0
	mov	P2_Score, 0

	invoke GlobalAlloc, GMEM_FIXED, 936
	mov    Grid_ID, eax
	.if eax == 0
	    jmp err
	.endif



	invoke Load_Game, ADDR szsaveol, ADDR ssaveol
	invoke New_Grid
	invoke Load_Data



	;==========================
	; Free the bitmap memory
	;==========================
	invoke GlobalFree, ptr_BMP_LOAD

done:
	;===================
	; We completed
	;===================

;	invoke Wait_Time, StartTime, 5000

	return TRUE

err:
	;===================
	; We didn't make it
	;===================
	return FALSE

Game_Init	ENDP
;########################################################################
; END Game_Init
;########################################################################



;########################################################################
; Game_Main Procedure
;########################################################################
Game_Main	proc

	;============================================================
	; This is the heart of the game it gets called over and over
	; and even if we process a message!
	;============================================================

	;=========================================
	; Local Variables
	;=========================================
	LOCAL	StartTime	:DWORD
	LOCAL	StartTime1	 :DWORD
	LOCAL	hFont		:DWORD
	LOCAL	CorrectTime	:DWORD
	LOCAL	UpdateMP	:DWORD
	LOCAL	Place1		:DWORD
	LOCAL	Place2		:DWORD


	;====================================
	; Get the starting time for the loop
	;====================================
	invoke Start_Time, ADDR StartTime
	invoke Get_Time
	mov StartTime1, eax
	mov UpdateMP, FALSE
	mov Place1, FALSE
	mov Place2, FALSE


	;==============================================================
	; Take the proper action(s) based on the GameState variable
	;==============================================================
	.if GameState == GS_MENU
		;=================================
		; We are in the main menu state
		;=================================
		invoke Process_Main_Menu
		  mov P1_Score, 0
		  mov P2_Score, 0
		;=================================
		; What did they want to do
		;=================================
		.if eax == MENU_NOTHING
			;=================================
			; They didn't select anything yet
			; so don't do anything
			;=================================

		.elseif eax == MENU_ERROR
			;==================================
			; This is where error code would go
			;==================================

		.elseif eax == MENU_NEW
			;==================================
			; They want to start a new game
			;==================================
			mov	GameState, GS_PLAY
			mov	PAUSE, FALSE
	mov	PAUSE, FALSE
	mov	direction, MOVE_RIGHT
	mov	directionb, MOVE_RIGHT
	mov	PositionX, 7
	mov	PositionY, 11
	mov	snakelength, 7

	mov	Points, 0
	invoke	New_Grid
		.elseif eax == MENU_LOAD
			;==================================
			; They want the file menu
			;==================================
			invoke Stop_Sound, Menu_ID
			mov	GameState, GS_PLAY
			mov	PAUSE, TRUE



	       .elseif eax == MENU_OPTION
			;==================================
			; They want to return to the game
			;==================================

			;===============================
			; Set the Game state to playing
			;===============================
			mov	GameState, GS_OPTION

	       .elseif eax == MENU_MP_EDIT
			;==================================
			; They want to return to the game
			;==================================

			;===============================
			; Set the Game state to playing
			;===============================
			invoke Load_Grid, ADDR szLABMPl
			mov	GameState, GS_MP_EDIT

		.elseif eax == MENU_EXIT
			;==================================
			; Transition to black
			;==================================
			invoke DD_Fill_Surface, lpddsback, 0, 0, 0
			invoke DD_Flip

			;==================================
			; They want to exit the game
			;==================================
			;invoke ExitProcess,NULL
			mov GameState, GS_EXIT


		.endif


	.elseif GameState == GS_EDIT
		;=================================
		; We are in the file menu state
		;=================================
		invoke Process_Edit_Menu

		;=================================
		; What did they want to do
		;=================================
		.if eax == MENU_NOTHING
			;=================================
			; They didn't select anything yet
			; so don't do  anything
			;=================================

		.elseif eax == MENU_ERROR
			;==================================
			; This is where error code would go
			;==================================
		.elseif eax == MENU_BACK

			mov GameState, GS_OPTION

		.elseif eax == MENU_MAIN
			;==================================
			; They want to return to main menu
			;==================================
			mov	GameState, GS_MENU

		.endif

	.elseif GameState == GS_MP_EDIT
		;=================================
		; We are in the file menu state
		;=================================
		invoke Process_MP_Edit_Menu

		;=================================
		; What did they want to do
		;=================================
		.if eax == MENU_NOTHING
			;=================================
			; They didn't select anything yet
			; so don't do  anything
			;=================================

		.elseif eax == MENU_ERROR
			;==================================
			; This is where error code would go
			;==================================
		.elseif eax == MENU_BACK
			invoke Save_Grid, ADDR szLABMPl

			mov GameState, GS_OPTION

		.elseif eax == MENU_MP_PLAY
			invoke Save_Grid, ADDR szLABMPl
					invoke Stop_Sound, Menu_ID
			mov GameState, GS_MP_IDLE

		.elseif eax == MENU_MAIN
			;==================================
			; They want to return to main menu
			;==================================
			invoke Save_Grid, ADDR szLABMPl
			mov	GameState, GS_MENU

		.endif

	 .elseif GameState == GS_OPTION
		;=================================
		; We are in the file menu state
		;=================================
		invoke Process_Option_Menu

		;=================================
		; What did they want to do
		;=================================
		.if eax == MENU_NOTHING
			;=================================
			; They didn't select anything yet
			; so don't do  anything
			;=================================

		.elseif eax == MENU_ERROR
			;==================================
			; This is where error code would go
			;==================================
		.elseif eax == MENU_EDIT

			mov GameState, GS_EDIT

	       .elseif eax == MENU_MP_EDIT
			;==================================
			; They want to return to the game
			;==================================

			;===============================
			; Set the Game state to playing
			;===============================
			invoke Load_Grid, ADDR szLABMPl
			mov	GameState, GS_MP_EDIT

		.elseif eax == MENU_MAIN
			;==================================
			; They want to return to main menu
			;==================================
			mov	GameState, GS_MENU

		.endif


	.elseif GameState == GS_MP_PLAY
		;=================================
		; We are in the gameplay mode
		;=================================
		.if music_on == TRUE
		;======================================
		; Make sure the level music is playing
		;======================================
		invoke Status_Sound, Music_ID
		.if !(eax & DSBSTATUS_PLAYING)
			;===================
			; Play the sound
			;===================
			invoke Play_Sound, Music_ID, DSBPLAY_LOOPING

		.endif
		.endif
		;===============================
		; Load the main bitmap into the
		; back buffer
		;===============================
		    DDS4INVOKE BltFast, lpddsback, 0, 0, ptr_BMP_REDBACK, ADDR SrcRect800600, \
			DDBLTFAST_NOCOLORKEY or DDBLTFAST_WAIT

			;========================================
			; Read the Keyboard
			;========================================
			invoke DI_Read_Keyboard
			;================================
			; What do they want to do
			;================================
			.if keyboard_state[DIK_ESCAPE]
				;=========================
				; Stop the music
				;=========================
				invoke Stop_Sound, Music_ID

				;========================
				; The return to menu key
				;========================
				invoke	New_Grid
	mov	direction, MOVE_RIGHT
	mov	directionb, MOVE_RIGHT
	mov	PositionX, 7
	mov	PositionY, 11
	mov	snakelength, 7
	mov	p2direction, MOVE_LEFT
	mov	p2directionb, MOVE_LEFT
	mov	p2PositionX, 10
	mov	p2PositionY, 1
	mov	p2snakelength, 7
	mov	Pass, FALSE
	mov	p2Pass, FALSE

				mov	GameState, GS_MENU
				invoke Hiscore, Points
				mov	PAUSE, FALSE

		     .elseif keyboard_state[DIK_M]
				;=========================
				; Stop the music
				;=========================
				invoke Stop_Sound, Music_ID

				;========================
				; The return to menu key
				;========================
				invoke	New_Grid
					mov	direction, MOVE_RIGHT
	mov	directionb, MOVE_RIGHT
	mov	PositionX, 7
	mov	PositionY, 11
	mov	snakelength, 7
	mov	p2direction, MOVE_LEFT
	mov	p2directionb, MOVE_LEFT
	mov	p2PositionX, 10
	mov	p2PositionY, 1
	mov	p2snakelength, 7
	mov	Pass, FALSE

				mov	GameState, GS_MENU
				invoke Hiscore, Points
				mov	PAUSE, FALSE

			.endif





			.if keyboard_state[DIK_UP]

				.if direction == MOVE_DOWN
				.elseif direction == MOVE_UP
				.else
				m2m directionb, direction
				mov direction, MOVE_UP
				mov Pass, FALSE
				.endif
				mov	PAUSE, FALSE

			.elseif keyboard_state[DIK_DOWN]
				.if direction == MOVE_DOWN
				.elseif direction == MOVE_UP
				.else
				m2m directionb, direction
				mov direction, MOVE_DOWN
				mov Pass, FALSE
				.endif
				mov	PAUSE, FALSE

			.elseif keyboard_state[DIK_LEFT]
				.if direction == MOVE_LEFT
				.elseif direction == MOVE_RIGHT
				.else
				m2m directionb, direction
				mov direction, MOVE_LEFT
				mov Pass, FALSE
				.endif
				mov	PAUSE, FALSE

			.elseif keyboard_state[DIK_RIGHT]
				.if direction == MOVE_LEFT
				.elseif direction == MOVE_RIGHT

				.else
				m2m directionb, direction
				mov direction, MOVE_RIGHT
				mov Pass, FALSE
				.endif
				mov	PAUSE, FALSE

			.endif





			.if keyboard_state[DIK_W]

				.if p2direction == MOVE_DOWN
				.elseif p2direction == MOVE_UP
				.else
				m2m p2directionb, p2direction
				mov p2direction, MOVE_UP
				mov p2Pass, FALSE
				.endif
				mov	PAUSE, FALSE

			.elseif keyboard_state[DIK_S]
				.if p2direction == MOVE_DOWN
				.elseif p2direction == MOVE_UP
				.else
				m2m p2directionb, p2direction
				mov p2direction, MOVE_DOWN
				mov p2Pass, FALSE
				.endif
				mov	PAUSE, FALSE

			.elseif keyboard_state[DIK_A]
				.if p2direction == MOVE_LEFT
				.elseif p2direction == MOVE_RIGHT
				.else
				m2m p2directionb, p2direction
				mov p2direction, MOVE_LEFT
				mov p2Pass, FALSE
				.endif
				mov	PAUSE, FALSE

			.elseif keyboard_state[DIK_D]
				.if p2direction == MOVE_LEFT
				.elseif p2direction == MOVE_RIGHT

				.else
				m2m p2directionb, p2direction
				mov p2direction, MOVE_RIGHT
				mov p2Pass, FALSE
				.endif
				mov	PAUSE, FALSE

			.endif






	   invoke Get_Time
	   sub	   eax, UPDATE_DELAY
	   .if eax  > Update_Time


	   .if Pass == TRUE
	    m2m directionb, direction
	   .endif
	   mov Pass, TRUE
	   m2m PositionXo, PositionX
	   m2m PositionYo, PositionY

	     .if direction == MOVE_LEFT
	       .if PositionX == 0
		   mov PositionX, 17
	       .else
		   sub PositionX, 1
	       .endif
	       .endif

	       .if direction == MOVE_RIGHT
	       .if PositionX == 17
		   mov PositionX, 0
	       .else
		   add PositionX, 1
	       .endif
	       .endif

	       .if direction == MOVE_UP
	       .if PositionY == 0
		   mov PositionY, 12
	       .else
		   sub PositionY, 1
	       .endif
	       .endif

	       .if direction == MOVE_DOWN
	       .if PositionY == 12
		   mov PositionY, 0
	       .else
		   add PositionY, 1
	       .endif
	       .endif


	       mov eax, 18
	       mov ebx, PositionY
	       mul ebx
	       add eax, PositionX
	       mov ecx, 4
	       mul ecx
	       mov ebx, Grid_ID
	       add eax, ebx
	       mov ebx, [eax]
	       mov ecx, [eax]
	    .if ebx != 0
	       mov ax, bx
	       shr ebx, 16
	       .if ax == 10		 ;They made a point
		   add snakelength, 1
		.if sound_on == TRUE

		   invoke Play_Sound, SnakeEat_ID, 0

		.endif
		   mov Place1, TRUE
	       .elseif ebx == 1 	 ;They are about to go by the Tail
		   mov UpdateMP, TRUE
	       .else
				    ;They crash give some time to correct
	     invoke Get_Time
	     mov CorrectTime, eax
	     mov    ebx, UPDATE_DELAY
	     shl    ebx, 1
	     add    CorrectTime, ebx
	     invoke Get_Time

	     .while eax < CorrectTime


			;========================================
			; Read the Keyboard
			;========================================
			invoke DI_Read_Keyboard



			.if keyboard_state[DIK_UP]

				.if direction == MOVE_DOWN
				.elseif direction == MOVE_UP
				.else
				m2m directionb, direction
				mov direction, MOVE_UP
				.endif
				mov	PAUSE, FALSE
			.elseif keyboard_state[DIK_DOWN]
				.if direction == MOVE_DOWN
				.elseif direction == MOVE_UP
				.else
				m2m directionb, direction
				mov direction, MOVE_DOWN
				.endif
				mov	PAUSE, FALSE

			.elseif keyboard_state[DIK_LEFT]
				.if direction == MOVE_LEFT
				.elseif direction == MOVE_RIGHT
				.else
				m2m directionb, direction
				mov direction, MOVE_LEFT
				.endif
				mov	PAUSE, FALSE

			.elseif keyboard_state[DIK_RIGHT]
				.if direction == MOVE_LEFT
				.elseif direction == MOVE_RIGHT

				.else
				m2m directionb, direction
				mov direction, MOVE_RIGHT
				.endif
				mov	PAUSE, FALSE

			.endif

	       .if direction == MOVE_LEFT
	       .if PositionXo == 0
		   mov PositionX, 17
		   m2m PositionY, PositionYo
	       .else
		   mov eax, PositionXo
		   sub eax, 1
		   mov PositionX, eax
		   m2m PositionY, PositionYo
	       .endif
	       .endif

	       .if direction == MOVE_RIGHT
	       .if PositionXo == 17
		   mov PositionX, 0
		   m2m PositionY, PositionYo
	       .else
		    mov eax, PositionXo
		   add eax, 1
		   mov PositionX, eax
		   m2m PositionY, PositionYo
	       .endif
	       .endif

	       .if direction == MOVE_UP
	       .if PositionYo == 0
		   mov PositionY, 12
		   m2m PositionX, PositionXo
	       .else
		    mov eax, PositionYo
		    sub eax, 1
		    mov PositionY, eax
		   m2m PositionX, PositionXo
	       .endif
	       .endif

	       .if direction == MOVE_DOWN
	       .if PositionYo == 12
		   mov PositionY, 0
		   m2m PositionX, PositionXo
	       .else
		    mov eax, PositionYo
		    add eax, 1
		    mov PositionY, eax
		   m2m PositionX, PositionXo
	       .endif
	       .endif


	       mov eax, 18
	       mov ebx, PositionY
	       mul ebx
	       add eax, PositionX
	       mov ecx, 4
	       mul ecx
	       mov ebx, Grid_ID
	       add eax, ebx
	       mov ebx, [eax]
	       mov ecx, [eax]
	    .if ebx != 0
	       mov ax, bx
	       shr ebx, 16
	       .if ax == 10		 ;They made a point
		   add snakelength, 1
		.if sound_on == TRUE

		   invoke Play_Sound, SnakeEat_ID, 0

		.endif
		   mov Place1, TRUE
		   jmp MPsolved
	       .elseif ebx == 1
		       mov UpdateMP, TRUE	   ;They are about to go by the Tail
		   jmp MPsolved
	       .endif
	    .elseif ebx == 0
		    mov UpdateMP, TRUE
		   jmp MPsolved
	    .endif


	     invoke Get_Time
	     .endw

	     mov eax, PositionX
	     .if eax == p2PositionX
		 mov eax, PositionY
		 .if eax == p2PositionY
		     jmp draw2
		 .endif
	     .endif
		 add P2_Score, 1

	     draw2:




		;=================================
		; We died so perform that code
		;=================================

		;=================================
		; Stop all sounds from playing
		;=================================
		invoke Stop_All_Sounds
		.if sound_on == TRUE

		   invoke Play_Sound, SnakeCrash_ID, 0

		.endif
		invoke New_MP_Grid
	mov	direction, MOVE_RIGHT
	mov	directionb, MOVE_RIGHT
	mov	PositionX, 7
	mov	PositionY, 11
	mov	snakelength, 7
	mov	Pass, FALSE
	mov	p2direction, MOVE_LEFT
	mov	p2directionb, MOVE_LEFT
	mov	p2PositionX, 10
	mov	p2PositionY, 1
	mov	p2snakelength, 7
	mov	p2Pass, FALSE

		;=================================
		; Wait for a couple of seconds so
		; they know that they have died
		;=================================
		invoke Sleep, 1500


	       mov GameState, GS_MP_IDLE
	       jmp crash

	       MPsolved:
	       .endif
	       .endif









	   .if p2Pass == TRUE
	    m2m p2directionb, p2direction
	   .endif
	   mov p2Pass, TRUE
	   m2m p2PositionXo, p2PositionX
	   m2m p2PositionYo, p2PositionY

	     .if p2direction == MOVE_LEFT
	       .if p2PositionX == 0
		   mov p2PositionX, 17
	       .else
		   sub p2PositionX, 1
	       .endif
	       .endif

	       .if p2direction == MOVE_RIGHT
	       .if p2PositionX == 17
		   mov p2PositionX, 0
	       .else
		   add p2PositionX, 1
	       .endif
	       .endif

	       .if p2direction == MOVE_UP
	       .if p2PositionY == 0
		   mov p2PositionY, 12
	       .else
		   sub p2PositionY, 1
	       .endif
	       .endif

	       .if p2direction == MOVE_DOWN
	       .if p2PositionY == 12
		   mov p2PositionY, 0
	       .else
		   add p2PositionY, 1
	       .endif
	       .endif


	       mov eax, 18
	       mov ebx, p2PositionY
	       mul ebx
	       add eax, p2PositionX
	       mov ecx, 4
	       mul ecx
	       mov ebx, Grid_ID
	       add eax, ebx
	       mov ebx, [eax]
	       mov ecx, [eax]
	    .if ebx != 0
	       mov ax, bx
	       shr ebx, 16
	       .if ax == 10		 ;They made a point
		   add p2snakelength, 1
		.if sound_on == TRUE

		   invoke Play_Sound, SnakeEat_ID, 0

		.endif
		   mov Place2, TRUE
	       .elseif ebx == 1 	 ;They are about to go by the Tail
		   mov UpdateMP, TRUE
	       .else
				    ;They crash give some time to correct
	     invoke Get_Time
	     mov CorrectTime, eax
	     mov    ebx, UPDATE_DELAY
	     shl    ebx, 1
	     add    CorrectTime, ebx
	     invoke Get_Time

	     .while eax < CorrectTime


			;========================================
			; Read the Keyboard
			;========================================
			invoke DI_Read_Keyboard



			.if keyboard_state[DIK_W]

				.if p2direction == MOVE_DOWN
				.elseif p2direction == MOVE_UP
				.else
				m2m p2directionb, p2direction
				mov p2direction, MOVE_UP
				.endif

			.elseif keyboard_state[DIK_S]
				.if p2direction == MOVE_DOWN
				.elseif p2direction == MOVE_UP
				.else
				m2m p2directionb, p2direction
				mov p2direction, MOVE_DOWN
				.endif

			.elseif keyboard_state[DIK_A]
				.if p2direction == MOVE_LEFT
				.elseif p2direction == MOVE_RIGHT
				.else
				m2m p2directionb, p2direction
				mov p2direction, MOVE_LEFT
				.endif

			.elseif keyboard_state[DIK_D]
				.if p2direction == MOVE_LEFT
				.elseif p2direction == MOVE_RIGHT

				.else
				m2m p2directionb, p2direction
				mov p2direction, MOVE_RIGHT
				.endif

			.endif

	       .if p2direction == MOVE_LEFT
	       .if p2PositionXo == 0
		   mov p2PositionX, 17
		   m2m p2PositionY, p2PositionYo
	       .else
		   mov eax, p2PositionXo
		   sub eax, 1
		   mov p2PositionX, eax
		   m2m p2PositionY, p2PositionYo
	       .endif
	       .endif

	       .if p2direction == MOVE_RIGHT
	       .if p2PositionXo == 17
		   mov p2PositionX, 0
		   m2m p2PositionY, p2PositionYo
	       .else
		    mov eax, p2PositionXo
		   add eax, 1
		   mov p2PositionX, eax
		   m2m p2PositionY, p2PositionYo
	       .endif
	       .endif

	       .if p2direction == MOVE_UP
	       .if p2PositionYo == 0
		   mov p2PositionY, 12
		   m2m p2PositionX, p2PositionXo
	       .else
		    mov eax, p2PositionYo
		    sub eax, 1
		    mov p2PositionY, eax
		   m2m p2PositionX, p2PositionXo
	       .endif
	       .endif

	       .if p2direction == MOVE_DOWN
	       .if p2PositionYo == 12
		   mov p2PositionY, 0
		   m2m p2PositionX, p2PositionXo
	       .else
		    mov eax, p2PositionYo
		    add eax, 1
		    mov p2PositionY, eax
		   m2m p2PositionX, p2PositionXo
	       .endif
	       .endif


	       mov eax, 18
	       mov ebx, p2PositionY
	       mul ebx
	       add eax, p2PositionX
	       mov ecx, 4
	       mul ecx
	       mov ebx, Grid_ID
	       add eax, ebx
	       mov ebx, [eax]
	       mov ecx, [eax]
	    .if ebx != 0
	       mov ax, bx
	       shr ebx, 16
	       .if ax == 10		 ;They made a point
		   add p2snakelength, 1
		.if sound_on == TRUE

		   invoke Play_Sound, SnakeEat_ID, 0

		.endif
		   mov Place2, TRUE
		   jmp solved2
	       .elseif ebx == 1
		       mov UpdateMP, TRUE	   ;They are about to go by the Tail
		   jmp solved2
	       .endif
	    .elseif ebx == 0
		   jmp solved2
	    .endif


	     invoke Get_Time
	     .endw


	     mov eax, PositionX
	     .if eax == p2PositionX
		 mov eax, PositionY
		 .if eax == p2PositionY
		     jmp draw1
		 .endif
	     .endif
		 add P1_Score, 1

	     draw1:
		;=================================
		; We died so perform that code
		;=================================

		;=================================
		; Stop all sounds from playing
		;=================================
		invoke Stop_All_Sounds
		.if sound_on == TRUE

		   invoke Play_Sound, SnakeCrash_ID, 0

		.endif
		invoke New_MP_Grid
	mov	direction, MOVE_RIGHT
	mov	directionb, MOVE_RIGHT
	mov	PositionX, 7
	mov	PositionY, 11
	mov	snakelength, 7
	mov	Pass, FALSE
	mov	p2direction, MOVE_LEFT
	mov	p2directionb, MOVE_LEFT
	mov	p2PositionX, 10
	mov	p2PositionY, 1
	mov	p2snakelength, 7
	mov	p2Pass, FALSE

		;=================================
		; Wait for a couple of seconds so
		; they know that they have died
		;=================================
		invoke Sleep, 1500


	       mov GameState, GS_MP_IDLE
	       jmp MPcrash

	       solved2:



		    mov UpdateMP, TRUE
		    mov first_time, TRUE
	    .endif
	    .else

		    mov UpdateMP, TRUE
		    mov first_time, TRUE
	    .endif


		 invoke Get_Time
		   mov	   Update_Time, eax
	  .endif


	  .if Place1 == TRUE
	      invoke Place_New_Point
	  .elseif Place2 == TRUE
	      invoke Place_New_Point2
	  .elseif UpdateMP == TRUE
	      invoke Update_MP_Grid
	  .endif


		      invoke Draw_Grid

		      .if eax == FALSE
			  jmp err
		      .endif

				 invoke Draw_MP_Score
	       ;===============================
		; Flip the buffers
		;===============================
		invoke DD_Flip







MPcrash:










	.elseif GameState == GS_MP_IDLE
		;=================================
		; We are in the gameplay mode
		;=================================
		.if music_on == TRUE
		;======================================
		; Make sure the level music is playing
		;======================================
		invoke Status_Sound, Music_ID
		.if !(eax & DSBSTATUS_PLAYING)
			;===================
			; Play the sound
			;===================
			invoke Play_Sound, Music_ID, DSBPLAY_LOOPING

		.endif
		.endif
		;===============================
		; Load the main bitmap into the
		; back buffer
		;===============================
		    DDS4INVOKE BltFast, lpddsback, 0, 0, ptr_BMP_REDBACK, ADDR SrcRect800600, \
			DDBLTFAST_NOCOLORKEY or DDBLTFAST_WAIT

			;========================================
			; Read the Keyboard
			;========================================
			invoke DI_Read_Keyboard
			;================================
			; What do they want to do
			;================================
			.if keyboard_state[DIK_ESCAPE]
				;=========================
				; Stop the music
				;=========================
				invoke Stop_Sound, Music_ID

				;========================
				; The return to menu key
				;========================
				invoke	New_Grid
	mov	direction, MOVE_RIGHT
	mov	directionb, MOVE_RIGHT
	mov	PositionX, 7
	mov	PositionY, 11
	mov	snakelength, 7
	mov	p2direction, MOVE_LEFT
	mov	p2directionb, MOVE_LEFT
	mov	p2PositionX, 10
	mov	p2PositionY, 1
	mov	p2snakelength, 7
	mov	Pass, FALSE
	mov	p2Pass, FALSE

				mov	GameState, GS_MENU
				invoke Hiscore, Points
				mov	PAUSE, FALSE

		     .elseif keyboard_state[DIK_M]
				;=========================
				; Stop the music
				;=========================
				invoke Stop_Sound, Music_ID

				;========================
				; The return to menu key
				;========================
				invoke	New_Grid
					mov	direction, MOVE_RIGHT
	mov	directionb, MOVE_RIGHT
	mov	PositionX, 7
	mov	PositionY, 11
	mov	snakelength, 7
	mov	p2direction, MOVE_LEFT
	mov	p2directionb, MOVE_LEFT
	mov	p2PositionX, 10
	mov	p2PositionY, 1
	mov	p2snakelength, 7
	mov	Pass, FALSE

				mov	GameState, GS_MENU
				invoke Hiscore, Points
				mov	PAUSE, FALSE

		     .elseif keyboard_state[DIK_SPACE]
				;=========================
				; Stop the music
				;=========================
				invoke Stop_Sound, Music_ID

				;========================
				; The return to menu key
				;========================
				invoke	New_Grid
					mov	direction, MOVE_RIGHT
	mov	directionb, MOVE_RIGHT
	mov	PositionX, 7
	mov	PositionY, 11
	mov	snakelength, 7
	mov	p2direction, MOVE_LEFT
	mov	p2directionb, MOVE_LEFT
	mov	p2PositionX, 10
	mov	p2PositionY, 1
	mov	p2snakelength, 7
	mov	Pass, FALSE

				mov	GameState, GS_MP_EDIT
				invoke Hiscore, Points
				mov	PAUSE, FALSE

			   .elseif keyboard_state[DIK_A]
				   .if keyboard_state[DIK_UP]
				       mov GameState, GS_MP_PLAY
				   .elseif  keyboard_state[DIK_DOWN]
				       mov GameState, GS_MP_PLAY
				   .elseif  keyboard_state[DIK_RIGHT]
				       mov GameState, GS_MP_PLAY
				   .elseif  keyboard_state[DIK_LEFT]
				       mov GameState, GS_MP_PLAY
				   .endif
			   .elseif keyboard_state[DIK_S]
				   .if keyboard_state[DIK_UP]
				       mov GameState, GS_MP_PLAY
				   .elseif  keyboard_state[DIK_DOWN]
				       mov GameState, GS_MP_PLAY
				   .elseif  keyboard_state[DIK_RIGHT]
				       mov GameState, GS_MP_PLAY
				   .elseif  keyboard_state[DIK_LEFT]
				       mov GameState, GS_MP_PLAY
				   .endif
			   .elseif keyboard_state[DIK_W]
				   .if keyboard_state[DIK_UP]
				       mov GameState, GS_MP_PLAY
				   .elseif  keyboard_state[DIK_DOWN]
				       mov GameState, GS_MP_PLAY
				   .elseif  keyboard_state[DIK_RIGHT]
				       mov GameState, GS_MP_PLAY
				   .elseif  keyboard_state[DIK_LEFT]
				       mov GameState, GS_MP_PLAY
				   .endif
			   .elseif keyboard_state[DIK_D]
				   .if keyboard_state[DIK_UP]
				       mov GameState, GS_MP_PLAY
				   .elseif  keyboard_state[DIK_DOWN]
				       mov GameState, GS_MP_PLAY
				   .elseif  keyboard_state[DIK_RIGHT]
				       mov GameState, GS_MP_PLAY
				   .elseif  keyboard_state[DIK_LEFT]
				       mov GameState, GS_MP_PLAY
				   .endif

			   .endif
		invoke Draw_Grid
		invoke Draw_MP_Score
	       ;===============================
		; Flip the buffers
		;===============================
		invoke DD_Flip


	.elseif GameState == GS_PLAY
		;=================================
		; We are in the gameplay mode
		;=================================
		.if music_on == TRUE
		;======================================
		; Make sure the level music is playing
		;======================================
		invoke Status_Sound, Music_ID
		.if !(eax & DSBSTATUS_PLAYING)
			;===================
			; Play the sound
			;===================
			invoke Play_Sound, Music_ID, DSBPLAY_LOOPING

		.endif
		.endif
		;===============================
		; Load the main bitmap into the
		; back buffer
		;===============================
		    DDS4INVOKE BltFast, lpddsback, 0, 0, ptr_BMP_REDBACK, ADDR SrcRect800600, \
			DDBLTFAST_NOCOLORKEY or DDBLTFAST_WAIT

			;========================================
			; Read the Keyboard
			;========================================
			invoke DI_Read_Keyboard

			;================================
			; What do they want to do
			;================================
			.if keyboard_state[DIK_ESCAPE]
				;=========================
				; Stop the music
				;=========================
				invoke Stop_Sound, Music_ID

				;========================
				; The return to menu key
				;========================
				invoke	New_Grid
		      mov     direction, MOVE_RIGHT
	mov	directionb, MOVE_RIGHT
	mov	PositionX, 7
	mov	PositionY, 11
	mov	snakelength, 7
	mov	Pass, FALSE
	mov	p2direction, MOVE_LEFT
	mov	p2directionb, MOVE_LEFT
	mov	p2PositionX, 10
	mov	p2PositionY, 1
	mov	p2snakelength, 7
	mov	p2Pass, FALSE


				mov	GameState, GS_MENU
				invoke Hiscore, Points
				mov	PAUSE, FALSE
			.elseif keyboard_state[DIK_M]
				;=========================
				; Stop the music
				;=========================
				invoke Stop_Sound, Music_ID

				;========================
				; The return to menu key
				;========================
				invoke New_Grid

	mov	direction, MOVE_RIGHT
	mov	directionb, MOVE_RIGHT
	mov	PositionX, 7
	mov	PositionY, 11
	mov	snakelength, 7
	mov	Pass, FALSE
	mov	p2direction, MOVE_LEFT
	mov	p2directionb, MOVE_LEFT
	mov	p2PositionX, 10
	mov	p2PositionY, 1
	mov	p2snakelength, 7
	mov	p2Pass, FALSE

				mov	GameState, GS_MENU
				invoke Hiscore, Points
				mov	PAUSE, FALSE

			.elseif keyboard_state[DIK_P]
				;========================
				; Pause
				;========================
				mov	PAUSE, TRUE

			.elseif keyboard_state[DIK_SPACE]
				;========================
				; Pause
				;========================
				mov	PAUSE, TRUE

			.elseif keyboard_state[DIK_UP]

				.if direction == MOVE_DOWN
				.elseif direction == MOVE_UP
				.else
				m2m directionb, direction
				mov direction, MOVE_UP
				mov Pass, FALSE
				.endif
				mov	PAUSE, FALSE

			.elseif keyboard_state[DIK_1]
				.if PAUSE==TRUE
				    invoke Save_Game, ADDR szsave1l, ADDR ssave1l
				    .if eax==FALSE
					jmp err
				    .endif
				 .endif

			.elseif keyboard_state[DIK_2]
				.if PAUSE==TRUE
				    invoke Save_Game, ADDR szsave2l, ADDR ssave2l
				    .if eax==FALSE
					jmp err
				    .endif
				 .endif

			.elseif keyboard_state[DIK_3]
				.if PAUSE==TRUE
				    invoke Save_Game, ADDR szsave3l, ADDR ssave3l
				    .if eax==FALSE
					jmp err
				    .endif
				 .endif

			.elseif keyboard_state[DIK_4]
				.if PAUSE==TRUE
				    invoke Save_Game, ADDR szsave4l, ADDR ssave4l
				    .if eax==FALSE
					jmp err
				    .endif
				 .endif

			.elseif keyboard_state[DIK_5]
				.if PAUSE==TRUE
				    invoke Save_Game, ADDR szsave5l, ADDR ssave5l
				    .if eax==FALSE
					jmp err
				    .endif
				 .endif

			.elseif keyboard_state[DIK_6]
				.if PAUSE==TRUE
				    invoke Save_Game, ADDR szsave6l, ADDR ssave6l
				    .if eax==FALSE
					jmp err
				    .endif
				 .endif

			.elseif keyboard_state[DIK_7]
				.if PAUSE==TRUE
				    invoke Save_Game, ADDR szsave7l, ADDR ssave7l
				    .if eax==FALSE
					jmp err
				    .endif
				 .endif

			.elseif keyboard_state[DIK_8]
				.if PAUSE==TRUE
				    invoke Save_Game, ADDR szsave8l, ADDR ssave8l
				    .if eax==FALSE
					jmp err
				    .endif
				 .endif

			.elseif keyboard_state[DIK_9]
				.if PAUSE==TRUE
				    invoke Save_Game, ADDR szsave9l, ADDR ssave9l
				    .if eax==FALSE
					jmp err
				    .endif
				 .endif

			.elseif keyboard_state[DIK_0]
				.if PAUSE==TRUE
				    invoke Save_Game, ADDR szsave0l, ADDR ssave0l
				    .if eax==FALSE
					jmp err
				    .endif
				 .endif

			.elseif keyboard_state[DIK_DOWN]
				.if direction == MOVE_DOWN
				.elseif direction == MOVE_UP
				.else
				m2m directionb, direction
				mov direction, MOVE_DOWN
				mov Pass, FALSE
				.endif
				mov	PAUSE, FALSE

			.elseif keyboard_state[DIK_LEFT]
				.if direction == MOVE_LEFT
				.elseif direction == MOVE_RIGHT
				.else
				m2m directionb, direction
				mov direction, MOVE_LEFT
				mov Pass, FALSE
				.endif
				mov	PAUSE, FALSE

			.elseif keyboard_state[DIK_RIGHT]
				.if direction == MOVE_LEFT
				.elseif direction == MOVE_RIGHT

				.else
				m2m directionb, direction
				mov direction, MOVE_RIGHT
				mov Pass, FALSE
				.endif
				mov	PAUSE, FALSE

			.endif

.if PAUSE != TRUE
	   invoke Get_Time
	   sub	   eax, UPDATE_DELAY
	   .if eax  > Update_Time


	   .if Pass == TRUE
	    m2m directionb, direction
	   .endif
	   mov Pass, TRUE
	   m2m PositionXo, PositionX
	   m2m PositionYo, PositionY

	     .if direction == MOVE_LEFT
	       .if PositionX == 0
		   mov PositionX, 17
	       .else
		   sub PositionX, 1
	       .endif
	       .endif

	       .if direction == MOVE_RIGHT
	       .if PositionX == 17
		   mov PositionX, 0
	       .else
		   add PositionX, 1
	       .endif
	       .endif

	       .if direction == MOVE_UP
	       .if PositionY == 0
		   mov PositionY, 12
	       .else
		   sub PositionY, 1
	       .endif
	       .endif

	       .if direction == MOVE_DOWN
	       .if PositionY == 12
		   mov PositionY, 0
	       .else
		   add PositionY, 1
	       .endif
	       .endif


	       mov eax, 18
	       mov ebx, PositionY
	       mul ebx
	       add eax, PositionX
	       mov ecx, 4
	       mul ecx
	       mov ebx, Grid_ID
	       add eax, ebx
	       mov ebx, [eax]
	       mov ecx, [eax]
	    .if ebx != 0
	       mov ax, bx
	       shr ebx, 16
	       .if ax == 10		 ;They made a point
		   add snakelength, 1
		   mov eax, Level_Points
		   add Points, eax
		.if sound_on == TRUE

		   invoke Play_Sound, SnakeEat_ID, 0

		.endif
		   invoke Place_New_Point
	       .elseif ebx == 1 	 ;They are about to go by the Tail
		   invoke Update_Grid
	       .else
				    ;They crash give some time to correct
	     invoke Get_Time
	     mov CorrectTime, eax
	     mov    ebx, UPDATE_DELAY
	     shl    ebx, 1
	     add    CorrectTime, ebx
	     invoke Get_Time

	     .while eax < CorrectTime


			;========================================
			; Read the Keyboard
			;========================================
			invoke DI_Read_Keyboard



			.if keyboard_state[DIK_UP]

				.if direction == MOVE_DOWN
				.elseif direction == MOVE_UP
				.else
				m2m directionb, direction
				mov direction, MOVE_UP
				.endif
				mov	PAUSE, FALSE
			.elseif keyboard_state[DIK_DOWN]
				.if direction == MOVE_DOWN
				.elseif direction == MOVE_UP
				.else
				m2m directionb, direction
				mov direction, MOVE_DOWN
				.endif
				mov	PAUSE, FALSE

			.elseif keyboard_state[DIK_LEFT]
				.if direction == MOVE_LEFT
				.elseif direction == MOVE_RIGHT
				.else
				m2m directionb, direction
				mov direction, MOVE_LEFT
				.endif
				mov	PAUSE, FALSE

			.elseif keyboard_state[DIK_RIGHT]
				.if direction == MOVE_LEFT
				.elseif direction == MOVE_RIGHT

				.else
				m2m directionb, direction
				mov direction, MOVE_RIGHT
				.endif
				mov	PAUSE, FALSE

			.endif

	       .if direction == MOVE_LEFT
	       .if PositionXo == 0
		   mov PositionX, 17
		   m2m PositionY, PositionYo
	       .else
		   mov eax, PositionXo
		   sub eax, 1
		   mov PositionX, eax
		   m2m PositionY, PositionYo
	       .endif
	       .endif

	       .if direction == MOVE_RIGHT
	       .if PositionXo == 17
		   mov PositionX, 0
		   m2m PositionY, PositionYo
	       .else
		    mov eax, PositionXo
		   add eax, 1
		   mov PositionX, eax
		   m2m PositionY, PositionYo
	       .endif
	       .endif

	       .if direction == MOVE_UP
	       .if PositionYo == 0
		   mov PositionY, 12
		   m2m PositionX, PositionXo
	       .else
		    mov eax, PositionYo
		    sub eax, 1
		    mov PositionY, eax
		   m2m PositionX, PositionXo
	       .endif
	       .endif

	       .if direction == MOVE_DOWN
	       .if PositionYo == 12
		   mov PositionY, 0
		   m2m PositionX, PositionXo
	       .else
		    mov eax, PositionYo
		    add eax, 1
		    mov PositionY, eax
		   m2m PositionX, PositionXo
	       .endif
	       .endif


	       mov eax, 18
	       mov ebx, PositionY
	       mul ebx
	       add eax, PositionX
	       mov ecx, 4
	       mul ecx
	       mov ebx, Grid_ID
	       add eax, ebx
	       mov ebx, [eax]
	       mov ecx, [eax]
	    .if ebx != 0
	       mov ax, bx
	       shr ebx, 16
	       .if ax == 10		 ;They made a point
		   add snakelength, 1
		   mov eax, Level_Points
		   add Points, eax
		.if sound_on == TRUE

		   invoke Play_Sound, SnakeEat_ID, 0

		.endif
		   invoke Place_New_Point
		   jmp solved
	       .elseif ebx == 1 	 ;They are about to go by the Tail
		   jmp solved
	       .endif
	    .elseif ebx == 0
		   jmp solved
	    .endif


	     invoke Get_Time
	     .endw




	       mov GameState, GS_DIE
	       jmp crash

	       solved:
		    invoke Update_Grid
		    mov first_time, TRUE
	     .endif
	    .else

		    invoke Update_Grid
		    mov first_time, TRUE
	    .endif


		 invoke Get_Time
		   mov	   Update_Time, eax
	  .endif









		      invoke Draw_Grid

		      .if eax == FALSE
			  jmp err
		      .endif


.elseif PAUSE == TRUE
		      invoke Draw_Grid

		      .if eax == FALSE
			  jmp err
		      .endif



	;=====================================
	; Get the DC for the back buffer
	;=====================================
	invoke DD_GetDC, lpddsback
	mov	hDC, eax



       invoke DD_Select_Font, hDC, -60, NULL, ADDR szImpact, ADDR Old_Obj
	mov	hFont, eax

	;=============================
	; Setup rect for PAUSE text
	;=============================
	mov	text_rect.top, 290
	mov	text_rect.left, 0
	mov	text_rect.right, 800
	mov	text_rect.bottom, 600

	;=============================
	; Draw the Score Text
	;=============================
	RGB 255, 255, 255

	invoke DD_Draw_Text, hDC, ADDR szPAUSE, 5, ADDR text_rect,\
		DT_CENTER, eax

	;=============================
	; Unselect the font
	;=============================
	invoke DD_UnSelect_Font, hDC, hFont, Old_Obj


       invoke DD_Select_Font, hDC, -20, NULL, ADDR szImpact, ADDR Old_Obj
	mov	hFont, eax

	;=============================
	; Setup rect for PAUSE text
	;=============================
	mov	text_rect.top, 380
	mov	text_rect.left, 0
	mov	text_rect.right, 800
	mov	text_rect.bottom, 600

	;=============================
	; Draw the Score Text
	;=============================
	RGB 255, 255, 255

	invoke DD_Draw_Text, hDC, ADDR szSavegame, 17, ADDR text_rect,\
		DT_CENTER, eax

	;=============================
	; Unselect the font
	;=============================
	invoke DD_UnSelect_Font, hDC, hFont, Old_Obj

	;============================
	; Release the DC
	;============================
	invoke DD_ReleaseDC, lpddsback, hDC
.endif
  invoke Draw_Captions
	 .if eax==FALSE
	     jmp err
	 .endif
	       ;===============================
		; Flip the buffers
		;===============================
		invoke DD_Flip







crash:

	.elseif GameState == GS_DIE
		;=================================
		; We died so perform that code
		;=================================

		;=================================
		; Stop all sounds from playing
		;=================================
		invoke Stop_All_Sounds
		.if sound_on == TRUE

		   invoke Play_Sound, SnakeCrash_ID, 0

		.endif
		invoke New_Grid
	mov	direction, MOVE_RIGHT
	mov	directionb, MOVE_RIGHT
	mov	PositionX, 7
	mov	PositionY, 11
	mov	snakelength, 7
	mov	Pass, FALSE
		  invoke Hiscore, Points

		;=================================
		; Wait for a couple of seconds so
		; they know that they have died
		;=================================
		invoke Sleep, 2000

		mov	GameState, GS_MENU

	.elseif GameState == GS_WON
		;=================================
		; We won so perform that code
		;=================================

		;=================================
		; Stop all sounds from playing
		;=================================
		invoke Stop_All_Sounds

		invoke New_Grid
	mov	direction, MOVE_RIGHT
	mov	directionb, MOVE_RIGHT
	mov	PositionX, 7
	mov	PositionY, 11
	mov	snakelength, 7
	mov	Pass, FALSE
			  invoke Hiscore, Points

		;=================================
		; Wait for a couple of seconds so
		; they know that they have won
		;=================================
		invoke Sleep, 2000


		;=================================
		; Back to the Main Menu
		;=================================
		mov	GameState, GS_MENU

	.endif
invoke Get_Time
mov ecx, StartTime1
sub eax, ecx
mov ETime, eax

	;===================================
	; Wait to synchronize the time
	;===================================
	invoke Wait_Time, StartTime, sync_time

done:
	;===================
	; We completed
	;===================
	return TRUE

err:
	;===================
	; We didn't make it
	;===================
	return FALSE

Game_Main	ENDP
;########################################################################
; END Game_Main
;########################################################################

;########################################################################
; Process_Main_Menu Procedure
;########################################################################
Process_Main_Menu	proc

	;===========================================================
	; This function will process the main menu for the game
	;===========================================================

	;====================
	; Local Variables
	;====================
	LOCAL	hFont		:DWORD
	;===================================
	; Lock the DirectDraw back buffer
	;===================================
	invoke DD_Lock_Surface, lpddsback, ADDR lPitch

	;============================
	; Check for an error
	;============================
	.if eax == FALSE
		;===================
		; Jump to err
		;===================
		jmp	err

	.endif

	;===================================
	; Draw the bitmap onto the surface
	;===================================
	invoke Draw_Bitmap, eax, ptr_MAIN_MENU, lPitch, 800, 600, screen_bpp

	;===================================
	; Unlock the back buffer
	;===================================
	invoke DD_Unlock_Surface, lpddsback

	;============================
	; Check for an error
	;============================
	.if eax == FALSE
		;===================
		; Jump to err
		;===================
		jmp	err

	.endif
.if	music_on == TRUE
	;======================================
	; Make sure the Menu sound is playing
	;======================================
	invoke Status_Sound, Menu_ID
	.if !(eax & DSBSTATUS_PLAYING)
		;===================
		; Play the sound
		;===================
		invoke Play_Sound, Menu_ID, DSBPLAY_LOOPING

	.endif
.endif
;Draw Picture and HiScore
invoke Get_Time
sub eax, 150
.if eax > roundtime
    add round, 1
    invoke Get_Time
    mov roundtime, eax
.endif
.if round==0
	DDS4INVOKE BltFast, lpddsback, 670, 490, \
					ptr_BMP_3d_1, ADDR SrcRect6879, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT

.elseif round==1
	DDS4INVOKE BltFast, lpddsback, 670, 490, \
					ptr_BMP_3d_2, ADDR SrcRect6879, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
.elseif round==2
	DDS4INVOKE BltFast, lpddsback, 670, 490, \
					ptr_BMP_3d_3, ADDR SrcRect6879, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
.elseif round==3
	DDS4INVOKE BltFast, lpddsback, 670, 490, \
					ptr_BMP_3d_4, ADDR SrcRect6879, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
.elseif round==4
	DDS4INVOKE BltFast, lpddsback, 670, 490, \
					ptr_BMP_3d_5, ADDR SrcRect6879, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
.elseif round==5
	DDS4INVOKE BltFast, lpddsback, 670, 490, \
					ptr_BMP_3d_6, ADDR SrcRect6879, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
.elseif round==6
	DDS4INVOKE BltFast, lpddsback, 670, 490, \
					ptr_BMP_3d_7, ADDR SrcRect6879, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
.elseif round==7
	DDS4INVOKE BltFast, lpddsback, 670, 490, \
					ptr_BMP_3d_8, ADDR SrcRect6879, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	mov round, 0

.else
	mov round, 0
.endif
	;=======================================================
	; This function will draw our captions, such as the
	; score and the current level they are on
	;=======================================================



	;=====================================
	; Get the DC for the back buffer
	;=====================================
	invoke DD_GetDC, lpddsback
	mov	hDC, eax

	;====================================
	; Set the font to "IMPACT" at the
	; size that we need it
	;====================================
	invoke DD_Select_Font, hDC, -25, FW_BOLD, ADDR szImpact, ADDR Old_Obj
	mov	hFont, eax

	;=============================
	; Setup rect for score text
	;=============================
	mov	text_rect.top, 430
	mov	text_rect.left, 370
	mov	text_rect.right, 800
	mov	text_rect.bottom, 600

	;=============================
	; Draw the Score Text
	;=============================
	RGB 109, 142, 35
	push	eax
	mov	eax, Hiscore1
	mov	dwArgs, eax
	invoke wvsprintfA, ADDR szBuffer, ADDR szPoints, Offset dwArgs
	pop	ebx
	invoke DD_Draw_Text, hDC, ADDR szBuffer, eax, ADDR text_rect,\
		DT_LEFT, ebx


	;=============================
	; Setup rect for score text
	;=============================
	mov	text_rect.top, 450
	mov	text_rect.left, 430
	mov	text_rect.right, 800
	mov	text_rect.bottom, 600

	;=============================
	; Draw the Score Text
	;=============================
	RGB 109, 142, 35
	push	eax
	mov	eax, Hiscore2
	mov	dwArgs, eax
	invoke wvsprintfA, ADDR szBuffer, ADDR szPoints, Offset dwArgs
	pop	ebx
	invoke DD_Draw_Text, hDC, ADDR szBuffer, eax, ADDR text_rect,\
		DT_LEFT, ebx

	;=============================
	; Setup rect for score text
	;=============================
	mov	text_rect.top, 470
	mov	text_rect.left, 490
	mov	text_rect.right, 800
	mov	text_rect.bottom, 600

	;=============================
	; Draw the Score Text
	;=============================
	RGB 109, 142, 35
	push	eax
	mov	eax, Hiscore3
	mov	dwArgs, eax
	invoke wvsprintfA, ADDR szBuffer, ADDR szPoints, Offset dwArgs
	pop	ebx
	invoke DD_Draw_Text, hDC, ADDR szBuffer, eax, ADDR text_rect,\
		DT_LEFT, ebx

	;=============================
	; Setup rect for score text
	;=============================
	mov	text_rect.top, 490
	mov	text_rect.left, 550
	mov	text_rect.right, 800
	mov	text_rect.bottom, 600

	;=============================
	; Draw the Score Text
	;=============================
	RGB 109, 142, 35
	push	eax
	mov	eax, Hiscore4
	mov	dwArgs, eax
	invoke wvsprintfA, ADDR szBuffer, ADDR szPoints, Offset dwArgs
	pop	ebx
	invoke DD_Draw_Text, hDC, ADDR szBuffer, eax, ADDR text_rect,\
		DT_LEFT, ebx



	;=============================
	; Setup rect for score text
	;=============================
	mov	text_rect.top, 510
	mov	text_rect.left, 610
	mov	text_rect.right, 800
	mov	text_rect.bottom, 600

	;=============================
	; Draw the Score Text
	;=============================
	RGB 109, 142, 35
	push	eax
	mov	eax, Hiscore5
	mov	dwArgs, eax
	invoke wvsprintfA, ADDR szBuffer, ADDR szPoints, Offset dwArgs
	pop	ebx
	invoke DD_Draw_Text, hDC, ADDR szBuffer, eax, ADDR text_rect,\
		DT_LEFT, ebx


	;=============================
	; Setup rect for version text
	;=============================
	mov	text_rect.top, 5
	mov	text_rect.left, 5
	mov	text_rect.right, 800
	mov	text_rect.bottom, 600

	;=============================
	; Draw the Score Text
	;=============================
	RGB 255, 255, 55
	invoke DD_Draw_Text, hDC, ADDR Version, 3, ADDR text_rect,\
		DT_LEFT, eax



	;=============================
	; Unselect the font
	;=============================
	invoke DD_UnSelect_Font, hDC, hFont, Old_Obj

	;============================
	; Release the DC
	;============================
	invoke DD_ReleaseDC, lpddsback, hDC


	;=====================================
	; Everything okay so flip displayed
	; surfaces and make loading visible
	; or call transition if needed
	;======================================
		invoke DD_Flip

	;============================
	; Check for an error
	;============================
	.if eax == FALSE
		;===================
		; Jump to err
		;===================
		jmp	err

	.endif

	;========================================================
	; Now read the keyboard to see if they have presses
	; any keys corresponding to our menu
	;========================================================
	invoke DI_Read_Keyboard

	;=============================
	; Did they press a valid key
	;=============================
	.if keyboard_state[DIK_N]
		;======================
		; Stop the menu music
		;======================
		invoke Stop_Sound, Menu_ID


		;======================
		; The new game key
		;======================
		return	MENU_NEW

	.elseif keyboard_state[DIK_1]
		;======================
		; The game files key
		;======================
				 invoke Load_Game, ADDR szsave1l, ADDR ssave1l
				    .if eax==FALSE
					jmp err
				    .endif

		return MENU_LOAD
	.elseif keyboard_state[DIK_2]
		;======================
		; The game files key
		;======================
				 invoke Load_Game, ADDR szsave2l, ADDR ssave2l
				    .if eax==FALSE
					jmp err
				    .endif

		return MENU_LOAD
	.elseif keyboard_state[DIK_3]
		;======================
		; The game files key
		;======================
				 invoke Load_Game, ADDR szsave3l, ADDR ssave3l
				    .if eax==FALSE
					jmp err
				    .endif

		return MENU_LOAD
	.elseif keyboard_state[DIK_4]
		;======================
		; The game files key
		;======================
				 invoke Load_Game, ADDR szsave4l, ADDR ssave4l
				    .if eax==FALSE
					jmp err
				    .endif

		return MENU_LOAD
	.elseif keyboard_state[DIK_5]
		;======================
		; The game files key
		;======================
				 invoke Load_Game, ADDR szsave5l, ADDR ssave5l
				    .if eax==FALSE
					jmp err
				    .endif

		return MENU_LOAD
	.elseif keyboard_state[DIK_6]
		;======================
		; The game files key
		;======================
				 invoke Load_Game, ADDR szsave6l, ADDR ssave6l
				    .if eax==FALSE
					jmp err
				    .endif

		return MENU_LOAD
	.elseif keyboard_state[DIK_7]
		;======================
		; The game files key
		;======================
				 invoke Load_Game, ADDR szsave7l, ADDR ssave7l
				    .if eax==FALSE
					jmp err
				    .endif

		return MENU_LOAD
	.elseif keyboard_state[DIK_8]
		;======================
		; The game files key
		;======================
				 invoke Load_Game, ADDR szsave8l, ADDR ssave8l
				    .if eax==FALSE
					jmp err
				    .endif

		return MENU_LOAD
	.elseif keyboard_state[DIK_9]
		;======================
		; The game files key
		;======================
				 invoke Load_Game, ADDR szsave9l, ADDR ssave9l
				    .if eax==FALSE
					jmp err
				    .endif

		return MENU_LOAD
	.elseif keyboard_state[DIK_0]
		;======================
		; The game files key
		;======================
				 invoke Load_Game, ADDR szsave0l, ADDR ssave0l
				    .if eax==FALSE
					jmp err
				    .endif

		return MENU_LOAD
	.elseif keyboard_state[DIK_G]
		;======================
		; The game files key
		;======================
		return MENU_OPTION

	.elseif keyboard_state[DIK_L]
		;======================
		; The game files key
		;======================
		return MENU_MP_EDIT


	.elseif keyboard_state[DIK_E]
		;======================
		; Stop the menu music
		;======================
		invoke Stop_All_Sounds

		;======================
		; The exit game key
		;======================

		return MENU_EXIT

	.endif

done:
	;===================
	; We completed w/o
	; doing anything
	;===================
	return MENU_NOTHING

err:
	;===================
	; We didn't make it
	;===================
	return MENU_ERROR

Process_Main_Menu	ENDP
;########################################################################
; END Process_Main_Menu
;########################################################################

;########################################################################
; Process_File_Menu Procedure
;########################################################################
Process_Option_Menu	  PROC

	;===========================================================
	; This function will process the file menu for the gane
	;===========================================================

	;=================================
	; Local Variables
	;=================================

	;===================================
	; Lock the DirectDraw back buffer
	;===================================
	invoke DD_Lock_Surface, lpddsback, ADDR lPitch

	;============================
	; Check for an error
	;============================
	.if eax == FALSE
		;===================
		; Jump to err
		;===================
		jmp	err

	.endif

	;===================================
	; Draw the bitmap onto the surface
	;===================================
	invoke Draw_Bitmap, eax, ptr_OPTION_MENU, lPitch, 800, 600, screen_bpp

	;===================================
	; Unlock the back buffer
	;===================================
	invoke DD_Unlock_Surface, lpddsback

	;============================
	; Check for an error
	;============================
	.if eax == FALSE
		;===================
		; Jump to err
		;===================
		jmp	err

	.endif



.if music_on == TRUE
	;======================================
	; Make sure the Menu sound is playing
	;======================================
	invoke Status_Sound, Menu_ID
	.if !(eax & DSBSTATUS_PLAYING)
		;===================
		; Play the sound
		;===================
		invoke Play_Sound, Menu_ID, DSBPLAY_LOOPING

	.endif
.endif
       ;======================================
	; Point bitten?
       ;======================================


.if times <= 16

		  DDS4INVOKE BltFast, lpddsback, 528, 168, \
					point_type, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT

.elseif times >= 35

		  DDS4INVOKE BltFast, lpddsback, 528, 168, \
					point_type, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT


.endif
.if times == 0
	DDS4INVOKE BltFast, lpddsback, 0, 300, \
					ptr_BMP_S_hr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT

.elseif times == 1
	DDS4INVOKE BltFast, lpddsback, 44, 300, \
					ptr_BMP_S_hr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 0, 300, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT


.elseif times == 2
	DDS4INVOKE BltFast, lpddsback, 88, 300, \
					ptr_BMP_S_hr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 44, 300, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 0, 300, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT


.elseif times == 3
.if sound_on == TRUE
	      .if timesound == 0
		invoke Play_Sound, SnakeMove_ID, 0
		mov timesound, 1
	      .endif
.endif
	DDS4INVOKE BltFast, lpddsback, 88, 256, \
					ptr_BMP_S_hu, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 44, 300, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 0, 300, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 88, 300, \
					ptr_BMP_S_lu, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT


.elseif times == 4
	DDS4INVOKE BltFast, lpddsback, 88, 212, \
					ptr_BMP_S_hu, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 44, 300, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 0, 300, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 88, 300, \
					ptr_BMP_S_lu, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 88, 256, \
					ptr_BMP_S_ud, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT


.elseif times == 5
.if sound_on == TRUE
	      .if timesound == 0
		invoke Play_Sound, SnakeMove_ID, 0
		mov timesound, 1
	      .endif
.endif
	DDS4INVOKE BltFast, lpddsback, 132, 212, \
					ptr_BMP_S_hr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 44, 300, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 0, 300, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 88, 300, \
					ptr_BMP_S_lu, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 88, 256, \
					ptr_BMP_S_ud, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 88, 212, \
					ptr_BMP_S_rd, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT


.elseif times == 6
	DDS4INVOKE BltFast, lpddsback, 176, 212, \
					ptr_BMP_S_hr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 44, 300, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 0, 300, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 88, 300, \
					ptr_BMP_S_lu, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 88, 256, \
					ptr_BMP_S_ud, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 88, 212, \
					ptr_BMP_S_rd, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 132, 212, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT


.elseif times == 7
	DDS4INVOKE BltFast, lpddsback, 220, 212, \
					ptr_BMP_S_hr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 44, 300, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 0, 300, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 88, 300, \
					ptr_BMP_S_lu, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 88, 256, \
					ptr_BMP_S_ud, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 88, 212, \
					ptr_BMP_S_rd, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 132, 212, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 176, 212, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT


.elseif times == 8
	DDS4INVOKE BltFast, lpddsback, 264, 212, \
					ptr_BMP_S_hr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 44, 300, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 0, 300, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 88, 300, \
					ptr_BMP_S_lu, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 88, 256, \
					ptr_BMP_S_ud, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 88, 212, \
					ptr_BMP_S_rd, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 132, 212, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 176, 212, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 220, 212, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT


.elseif times == 9
.if sound_on == TRUE
	      .if timesound == 0
		invoke Play_Sound, SnakeMove_ID, 0
		mov timesound, 1
	      .endif
.endif
	DDS4INVOKE BltFast, lpddsback, 264, 256, \
					ptr_BMP_S_hd, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 44, 300, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 0, 300, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 88, 300, \
					ptr_BMP_S_lu, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 88, 256, \
					ptr_BMP_S_ud, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 88, 212, \
					ptr_BMP_S_rd, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 132, 212, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 176, 212, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 220, 212, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 264, 212, \
					ptr_BMP_S_ld, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT


.elseif times == 10
.if sound_on == TRUE
	      .if timesound == 0
		invoke Play_Sound, SnakeMove_ID, 0
		mov timesound, 1
	      .endif
.endif
	DDS4INVOKE BltFast, lpddsback, 308, 256, \
					ptr_BMP_S_hr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 44, 300, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 0, 300, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 88, 300, \
					ptr_BMP_S_lu, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 88, 256, \
					ptr_BMP_S_ud, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 88, 212, \
					ptr_BMP_S_rd, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 132, 212, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 176, 212, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 220, 212, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 264, 212, \
					ptr_BMP_S_ld, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 264, 256, \
					ptr_BMP_S_ru, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT


.elseif times == 11
	DDS4INVOKE BltFast, lpddsback, 352, 256, \
					ptr_BMP_S_hr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 44, 300, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 0, 300, \
					ptr_BMP_S_tl, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 88, 300, \
					ptr_BMP_S_lu, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 88, 256, \
					ptr_BMP_S_ud, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 88, 212, \
					ptr_BMP_S_rd, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 132, 212, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 176, 212, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 220, 212, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 264, 212, \
					ptr_BMP_S_ld, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 264, 256, \
					ptr_BMP_S_ru, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 308, 256, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT

.elseif times == 12
	DDS4INVOKE BltFast, lpddsback, 396, 256, \
					ptr_BMP_S_hr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 44, 300, \
					ptr_BMP_S_tl, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 88, 300, \
					ptr_BMP_S_lu, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 352, 256, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 88, 212, \
					ptr_BMP_S_rd, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 88, 256, \
					ptr_BMP_S_ud, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 132, 212, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 176, 212, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 220, 212, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 264, 212, \
					ptr_BMP_S_ld, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 264, 256, \
					ptr_BMP_S_ru, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 308, 256, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT

.elseif times == 13
.if sound_on == TRUE
	      .if timesound == 0
		invoke Play_Sound, SnakeMove_ID, 0
		mov timesound, 1
	      .endif
.endif
	DDS4INVOKE BltFast, lpddsback, 396, 212, \
					ptr_BMP_S_hu, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 352, 256, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 396, 256, \
					ptr_BMP_S_lu, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 88, 300, \
					ptr_BMP_S_td, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 88, 256, \
					ptr_BMP_S_ud, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 88, 212, \
					ptr_BMP_S_rd, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 132, 212, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 176, 212, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 220, 212, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 264, 212, \
					ptr_BMP_S_ld, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 264, 256, \
					ptr_BMP_S_ru, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 308, 256, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
.elseif times == 14
	DDS4INVOKE BltFast, lpddsback, 396, 168, \
					ptr_BMP_S_hu, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 352, 256, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 396, 256, \
					ptr_BMP_S_lu, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 396, 212, \
					ptr_BMP_S_ud, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 88, 256, \
					ptr_BMP_S_td, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 88, 212, \
					ptr_BMP_S_rd, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 132, 212, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 176, 212, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 220, 212, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 264, 212, \
					ptr_BMP_S_ld, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 264, 256, \
					ptr_BMP_S_ru, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 308, 256, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
.elseif times == 15
.if sound_on == TRUE
	      .if timesound == 0
		invoke Play_Sound, SnakeMove_ID, 0
		mov timesound, 1
	      .endif
.endif
	DDS4INVOKE BltFast, lpddsback, 440, 168, \
					ptr_BMP_S_hr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 352, 256, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 396, 256, \
					ptr_BMP_S_lu, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 396, 212, \
					ptr_BMP_S_ud, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 396, 168, \
					ptr_BMP_S_rd, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 88, 212, \
					ptr_BMP_S_tl, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 132, 212, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 176, 212, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 220, 212, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 264, 212, \
					ptr_BMP_S_ld, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 264, 256, \
					ptr_BMP_S_ru, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 308, 256, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
.elseif times == 16
	DDS4INVOKE BltFast, lpddsback, 484, 168, \
					ptr_BMP_S_hr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 352, 256, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 396, 256, \
					ptr_BMP_S_lu, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 396, 212, \
					ptr_BMP_S_ud, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 396, 168, \
					ptr_BMP_S_rd, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 440, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 132, 212, \
					ptr_BMP_S_tl, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 176, 212, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 220, 212, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 264, 212, \
					ptr_BMP_S_ld, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 264, 256, \
					ptr_BMP_S_ru, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 308, 256, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
.elseif times == 17
.if sound_on == TRUE
	      .if timesound == 0
		invoke Play_Sound, SnakeEat_ID, 0
		mov timesound, 1
	      .endif
.endif
	DDS4INVOKE BltFast, lpddsback, 528, 168, \
					ptr_BMP_S_hr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 352, 256, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 396, 256, \
					ptr_BMP_S_lu, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 396, 212, \
					ptr_BMP_S_ud, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 396, 168, \
					ptr_BMP_S_rd, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 440, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 484, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 176, 212, \
					ptr_BMP_S_tl, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 220, 212, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 264, 212, \
					ptr_BMP_S_ld, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 264, 256, \
					ptr_BMP_S_ru, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 308, 256, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
.elseif times == 18
	DDS4INVOKE BltFast, lpddsback, 572, 168, \
					ptr_BMP_S_hr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 352, 256, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 396, 256, \
					ptr_BMP_S_lu, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 396, 212, \
					ptr_BMP_S_ud, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 396, 168, \
					ptr_BMP_S_rd, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 440, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 484, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 528, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 220, 212, \
					ptr_BMP_S_tl, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 264, 212, \
					ptr_BMP_S_ld, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 264, 256, \
					ptr_BMP_S_ru, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 308, 256, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
.elseif times == 19
	DDS4INVOKE BltFast, lpddsback, 616, 168, \
					ptr_BMP_S_hr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 352, 256, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 396, 256, \
					ptr_BMP_S_lu, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 396, 212, \
					ptr_BMP_S_ud, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 396, 168, \
					ptr_BMP_S_rd, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 440, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 484, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 528, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 572, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 264, 212, \
					ptr_BMP_S_tu, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 264, 256, \
					ptr_BMP_S_ru, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 308, 256, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
.elseif times == 20
	DDS4INVOKE BltFast, lpddsback, 660, 168, \
					ptr_BMP_S_hr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 352, 256, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 396, 256, \
					ptr_BMP_S_lu, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 396, 212, \
					ptr_BMP_S_ud, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 396, 168, \
					ptr_BMP_S_rd, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 440, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 484, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 528, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 572, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 616, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 264, 256, \
					ptr_BMP_S_tl, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 308, 256, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
.elseif times == 21
	DDS4INVOKE BltFast, lpddsback, 704, 168, \
					ptr_BMP_S_hr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 352, 256, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 396, 256, \
					ptr_BMP_S_lu, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 396, 212, \
					ptr_BMP_S_ud, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 396, 168, \
					ptr_BMP_S_rd, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 440, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 484, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 528, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 572, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 616, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 660, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 308, 256, \
					ptr_BMP_S_tl, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
.elseif times == 22
	DDS4INVOKE BltFast, lpddsback, 748, 168, \
					ptr_BMP_S_hr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 352, 256, \
					ptr_BMP_S_tl, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 396, 256, \
					ptr_BMP_S_lu, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 396, 212, \
					ptr_BMP_S_ud, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 396, 168, \
					ptr_BMP_S_rd, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 440, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 484, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 528, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 572, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 616, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 660, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 704, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
.elseif times == 23
	DDS4INVOKE BltFast, lpddsback, 748, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 396, 256, \
					ptr_BMP_S_td, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 396, 212, \
					ptr_BMP_S_ud, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 396, 168, \
					ptr_BMP_S_rd, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 440, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 484, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 528, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 572, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 616, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 660, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 704, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT


.elseif times == 24
	DDS4INVOKE BltFast, lpddsback, 748, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 396, 168, \
					ptr_BMP_S_tl, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 440, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 484, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 528, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 572, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 616, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 660, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 704, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
.elseif times == 25
	DDS4INVOKE BltFast, lpddsback, 748, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 396, 168, \
					ptr_BMP_S_tl, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 440, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 484, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 528, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 572, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 616, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 660, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 704, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
.elseif times == 26
	DDS4INVOKE BltFast, lpddsback, 748, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 440, 168, \
					ptr_BMP_S_tl, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 484, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 528, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 572, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 616, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 660, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 704, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
.elseif times == 27
	DDS4INVOKE BltFast, lpddsback, 748, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 484, 168, \
					ptr_BMP_S_tl, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 528, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 572, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 616, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 660, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 704, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
.elseif times == 28
	DDS4INVOKE BltFast, lpddsback, 748, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 528, 168, \
					ptr_BMP_S_tl, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 572, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 616, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 660, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 704, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
.elseif times == 29
	DDS4INVOKE BltFast, lpddsback, 748, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 572, 168, \
					ptr_BMP_S_tl, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 616, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 660, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 704, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
.elseif times == 30
	DDS4INVOKE BltFast, lpddsback, 748, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 616, 168, \
					ptr_BMP_S_tl, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 660, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 704, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
.elseif times == 31
	DDS4INVOKE BltFast, lpddsback, 748, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 660, 168, \
					ptr_BMP_S_tl, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 704, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
.elseif times == 32
	DDS4INVOKE BltFast, lpddsback, 748, 168, \
					ptr_BMP_S_lr, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 704, 168, \
					ptr_BMP_S_tl, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
.elseif times == 33
	DDS4INVOKE BltFast, lpddsback, 748, 168, \
					ptr_BMP_S_tl, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
.else
	mov times, 0
.endif

invoke Get_Time
		sub	eax, UPDATE_DELAY
		.if eax  > Update_Time
add times, 1
mov timesound, 0

.if times >= 40
    mov times, 0
.endif

 invoke Get_Time
	mov	Update_Time, eax
		.endif




	;=====================================
	; Everything okay so flip displayed
	; surfaces and make loading visible
	; or call transition if needed
	;======================================
		invoke DD_Flip

	;============================
	; Check for an error
	;============================
	.if eax == FALSE
		;===================
		; Jump to err
		;===================
		jmp	err

	.endif


	;========================================================
	; Now read the keyboard to see if they have presses
	; any keys corresponding to our menu
	;========================================================
	invoke DI_Read_Keyboard

	;=============================
	; Did they press a valid key
	;=============================
	.if keyboard_state[DIK_C]
		;======================
		; The load game key
		;======================
		return	MENU_EDIT

	.elseif keyboard_state[DIK_Q]

		invoke Load_Grid, ADDR szLAB1l

	.elseif keyboard_state[DIK_W]

		invoke Load_Grid, ADDR szLAB2l

	.elseif keyboard_state[DIK_E]

		invoke Load_Grid, ADDR szLAB3l

	.elseif keyboard_state[DIK_R]

		invoke Load_Grid, ADDR szLAB4l

	.elseif keyboard_state[DIK_T]

		invoke Load_Grid, ADDR szLAB5l

	.elseif keyboard_state[DIK_Y]

		 invoke Load_Grid, ADDR szLAB6l

	.elseif keyboard_state[DIK_U]

		invoke Load_Grid, ADDR szLAB7l

	.elseif keyboard_state[DIK_I]

		invoke Load_Grid, ADDR szLAB8l

	.elseif keyboard_state[DIK_O]

		invoke Load_Grid, ADDR szLAB9l

	.elseif keyboard_state[DIK_P]

		invoke Load_Grid, ADDR szLAB0l



	.elseif keyboard_state[DIK_L]
		return MENU_MP_EDIT


	.elseif keyboard_state[DIK_M]
	       invoke Save_Game, ADDR szsaveol, ADDR ssaveol
		;======================
		; Return to main key
		;======================
		return MENU_MAIN

	.elseif keyboard_state[DIK_9]
		mov UPDATE_DELAY, 10
		mov Level_Points, 15


	.elseif keyboard_state[DIK_X]
		mov UPDATE_DELAY, 0
		mov Level_Points, 20


	.elseif keyboard_state[DIK_8]
		mov UPDATE_DELAY, 20
		mov Level_Points, 10


	.elseif keyboard_state[DIK_7]
		mov UPDATE_DELAY, 30
		mov Level_Points, 15
		mov Level_Points, 8


	.elseif keyboard_state[DIK_6]
		mov UPDATE_DELAY, 50
		mov Level_Points, 6


	.elseif keyboard_state[DIK_5]
		mov UPDATE_DELAY, 75
		mov Level_Points, 5


	.elseif keyboard_state[DIK_4]
		mov UPDATE_DELAY, 100
		mov Level_Points, 4


	.elseif keyboard_state[DIK_3]
		mov UPDATE_DELAY, 150
		mov Level_Points, 3


	.elseif keyboard_state[DIK_2]
		mov UPDATE_DELAY, 250
		mov Level_Points, 2


	.elseif keyboard_state[DIK_1]
		mov UPDATE_DELAY, 500
		mov Level_Points, 1

	.elseif keyboard_state[DIK_J]
		m2m point_type, ptr_BMP_SP_1

	.elseif keyboard_state[DIK_K]
		m2m point_type, ptr_BMP_SP_2

	.elseif keyboard_state[DIK_H]
		m2m point_type, ptr_BMP_SP_3

	.elseif keyboard_state[DIK_F]
		invoke Get_Time
		sub	eax, INPUT_DELAY
		.if eax  > TimeCritic

	       .if sound_on == TRUE
		   mov sound_on, FALSE
	       .else
		    mov sound_on, TRUE
	       .endif
			;============================
			; Get a New Input Time
			;============================
			invoke Get_Time
			mov	TimeCritic, eax
	       .endif

	.elseif keyboard_state[DIK_S]
		invoke Get_Time
		sub	eax, INPUT_DELAY
		.if eax  > TimeCritic

	       .if music_on == TRUE
		   mov music_on, FALSE
		   invoke Stop_Sound, Menu_ID
	       .else
		    mov music_on, TRUE
	       .endif
			;============================
			; Get a New Input Time
			;============================
			invoke Get_Time
			mov	TimeCritic, eax
		.endif

	.endif

done:
	;===================
	; We completed w/o
	; doing anything
	;===================
	return MENU_NOTHING

err:
	;===================
	; We didn't make it
	;===================
	return MENU_ERROR

Process_Option_Menu	  ENDP
;########################################################################
; END Process_Option_Menu
;########################################################################
; Process_File_Menu Procedure
;########################################################################
Process_Edit_Menu	PROC

	;===========================================================
	; This function will process the file menu for the gane
	;===========================================================

	;=================================
	; Local Variables
	;=================================
	LOCAL	DRAWX	    :DWORD
	LOCAL	DRAWY	    :DWORD
	LOCAL	hFont		:DWORD

	;===================================
	; Lock the DirectDraw back buffer
	;===================================
	invoke DD_Lock_Surface, lpddsback, ADDR lPitch

	;============================
	; Check for an error
	;============================
	.if eax == FALSE
		;===================
		; Jump to err
		;===================
		jmp	err

	.endif

	;===================================
	; Draw the bitmap onto the surface
	;===================================
	invoke Draw_Bitmap, eax, ptr_EDIT_MENU, lPitch, 800, 600, screen_bpp

	;===================================
	; Unlock the back buffer
	;===================================
	invoke DD_Unlock_Surface, lpddsback

	;============================
	; Check for an error
	;============================
	.if eax == FALSE
		;===================
		; Jump to err
		;===================
		jmp	err

	.endif


.if music_on == TRUE

	;======================================
	; Make sure the Menu sound is playing
	;======================================
	invoke Status_Sound, Menu_ID
	.if !(eax & DSBSTATUS_PLAYING)
		;===================
		; Play the sound
		;===================
		invoke Play_Sound, Menu_ID, DSBPLAY_LOOPING

	.endif
.endif
	invoke New_Grid
	invoke Draw_Grid
	;============================
	; Check for an error
	;============================
	.if eax == FALSE
		;===================
		; Jump to err
		;===================
		jmp	err

	.endif

	DDS4INVOKE BltFast, lpddsback, 10, 556, \
					ptr_BMP_L_1b, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 10, 520, \
					ptr_BMP_P_1, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT

	DDS4INVOKE BltFast, lpddsback, 55, 556, \
					ptr_BMP_L_2b, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 55, 520, \
					ptr_BMP_P_2, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT

	DDS4INVOKE BltFast, lpddsback, 100, 556, \
					ptr_BMP_L_3b, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 100, 520, \
					ptr_BMP_P_3, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT

	DDS4INVOKE BltFast, lpddsback, 145, 556, \
					ptr_BMP_L_4b, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 145, 520, \
					ptr_BMP_P_4, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT

	DDS4INVOKE BltFast, lpddsback, 190, 556, \
					ptr_BMP_L_5b, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 190, 520, \
					ptr_BMP_P_5, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT

	DDS4INVOKE BltFast, lpddsback, 235, 556, \
					ptr_BMP_L_6b, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 235, 520, \
					ptr_BMP_P_6, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT

	DDS4INVOKE BltFast, lpddsback, 270, 556, \
					ptr_BMP_L_7b, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 270, 520, \
					ptr_BMP_P_7, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT

	DDS4INVOKE BltFast, lpddsback, 315, 556, \
					ptr_BMP_L_8b, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 315, 520, \
					ptr_BMP_P_8, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT

	DDS4INVOKE BltFast, lpddsback, 360, 556, \
					ptr_BMP_L_9b, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 360, 520, \
					ptr_BMP_P_9, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT

	DDS4INVOKE BltFast, lpddsback, 405, 556, \
					point_type, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 405, 520, \
					ptr_BMP_P_0, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT


	       mov eax, PositionX
	       mov ebx, 44
	       mul ebx
	       add eax, 4
	       mov DRAWX, eax
	       mov eax, PositionY
	       mov ebx, 44
	       mul ebx
	       add eax, 10
	       mov DRAWY, eax


		       DDS4INVOKE BltFast, lpddsback, DRAWX, DRAWY, \
					ptr_BMP_G_1, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT


.if  Save == TRUE
		       ;=====================================
	; Get the DC for the back buffer
	;=====================================
	invoke DD_GetDC, lpddsback
	mov	hDC, eax



       invoke DD_Select_Font, hDC, -60, NULL, ADDR szImpact, ADDR Old_Obj
	mov	hFont, eax

	;=============================
	; Setup rect for PAUSE text
	;=============================
	mov	text_rect.top, 290
	mov	text_rect.left, 0
	mov	text_rect.right, 800
	mov	text_rect.bottom, 600

	;=============================
	; Draw the Score Text
	;=============================
	RGB 255, 255, 255

	invoke DD_Draw_Text, hDC, ADDR szSAVE, 17, ADDR text_rect,\
		DT_CENTER, eax

	;=============================
	; Unselect the font
	;=============================
	invoke DD_UnSelect_Font, hDC, hFont, Old_Obj

	;============================
	; Release the DC
	;============================
	invoke DD_ReleaseDC, lpddsback, hDC
.endif
	;=====================================
	; Everything okay so flip displayed
	; surfaces and make loading visible
	; or call transition if needed
	;======================================
		invoke DD_Flip

	;============================
	; Check for an error
	;============================
	.if eax == FALSE
		;===================
		; Jump to err
		;===================
		jmp	err

	.endif


	;========================================================
	; Now read the keyboard to see if they have presses
	; any keys corresponding to our menu
	;========================================================
	invoke DI_Read_Keyboard
.if Save == TRUE
	.if keyboard_state[DIK_Q]
	   invoke Save_Grid, ADDR szLAB1l
	   .if eax == FALSE
	       jmp err
	   .endif
	   mov Save, FALSE
	.elseif keyboard_state[DIK_W]
	   invoke Save_Grid, ADDR szLAB2l
	   .if eax == FALSE
	       jmp err
	   .endif
	   mov Save, FALSE
	.elseif keyboard_state[DIK_E]
	   invoke Save_Grid, ADDR szLAB3l
	   .if eax == FALSE
	       jmp err
	   .endif
	   mov Save, FALSE
	.elseif keyboard_state[DIK_R]
	   invoke Save_Grid, ADDR szLAB4l
	   .if eax == FALSE
	       jmp err
	   .endif
	   mov Save, FALSE
	.elseif keyboard_state[DIK_T]
	   invoke Save_Grid, ADDR szLAB5l
	   .if eax == FALSE
	       jmp err
	   .endif
	   mov Save, FALSE
	.elseif keyboard_state[DIK_Y]
	   invoke Save_Grid, ADDR szLAB6l
	   .if eax == FALSE
	       jmp err
	   .endif
	   mov Save, FALSE
	.elseif keyboard_state[DIK_U]
	   invoke Save_Grid, ADDR szLAB7l
	   .if eax == FALSE
	       jmp err
	   .endif
	   mov Save, FALSE
	.elseif keyboard_state[DIK_I]
	   invoke Save_Grid, ADDR szLAB8l
	   .if eax == FALSE
	       jmp err
	   .endif
	   mov Save, FALSE
	.elseif keyboard_state[DIK_O]
	   invoke Save_Grid, ADDR szLAB9l
	   .if eax == FALSE
	       jmp err
	   .endif
	   mov Save, FALSE
	.elseif keyboard_state[DIK_P]
	   invoke Save_Grid, ADDR szLAB0l
	   .if eax == FALSE
	       jmp err
	   .endif
	   mov Save, FALSE
	.elseif keyboard_state[DIK_ESCAPE]
	   mov Save, FALSE
	.endif

.else
	;=============================
	; Did they press a valid key
	;=============================
	.if keyboard_state[DIK_B]
		;======================
		; The load game key
		;======================
		return	MENU_BACK


	.elseif keyboard_state[DIK_M]
	       invoke Save_Game, ADDR szsaveol, ADDR ssaveol

		;======================
		; Return to main key
		;======================
		return MENU_MAIN

	.elseif keyboard_state[DIK_1]
		mov Lab_Number, 1
	.elseif keyboard_state[DIK_2]
		mov Lab_Number, 2
	.elseif keyboard_state[DIK_3]
		mov Lab_Number, 3
	.elseif keyboard_state[DIK_4]
		mov Lab_Number, 4
	.elseif keyboard_state[DIK_5]
		mov Lab_Number, 5
	.elseif keyboard_state[DIK_6]
		mov Lab_Number, 6
	.elseif keyboard_state[DIK_7]
		mov Lab_Number, 7
	.elseif keyboard_state[DIK_8]
		mov Lab_Number, 8
	.elseif keyboard_state[DIK_9]
		mov Lab_Number, 9
	.elseif keyboard_state[DIK_0]
		mov Lab_Number, 10
	.elseif keyboard_state[DIK_S]
		mov Save, TRUE

	.elseif keyboard_state[DIK_UPARROW]
		invoke Get_Time
		sub	eax, INPUT_DELAY
		.if eax  > TimeCritic
		.if PositionY == 0
		    mov PositionY, 12
		.else
		     sub PositionY, 1
		.endif

			 ;============================
			; Get a New Input Time
			;============================
			invoke Get_Time
			mov	TimeCritic, eax

		.endif
	.elseif keyboard_state[DIK_DOWNARROW]
		invoke Get_Time
		sub	eax, INPUT_DELAY
		.if eax  > TimeCritic
		.if PositionY == 12
		    mov PositionY, 0
		.else
		     add PositionY, 1
		.endif

			 ;============================
			; Get a New Input Time
			;============================
			invoke Get_Time
			mov	TimeCritic, eax
		.endif
	.elseif keyboard_state[DIK_RIGHTARROW]
		invoke Get_Time
		sub	eax, INPUT_DELAY
		.if eax  > TimeCritic
		.if PositionX == 17
		    mov PositionX, 0
		.else
		     add PositionX, 1
		.endif

			 ;============================
			; Get a New Input Time
			;============================
			invoke Get_Time
			mov	TimeCritic, eax
		  .endif
	.elseif keyboard_state[DIK_LEFTARROW]
		invoke Get_Time
		sub	eax, INPUT_DELAY
		.if eax  > TimeCritic
		.if PositionX == 0
		    mov PositionX, 17
		.else
		     sub PositionX, 1
		.endif

			 ;============================
			; Get a New Input Time
			;============================
			invoke Get_Time
			mov	TimeCritic, eax
		 .endif
	.elseif keyboard_state[DIK_SPACE]
		invoke Get_Time
		sub	eax, INPUT_DELAY
		.if eax  > TimeCritic
	       mov eax, 18
	       mov ebx, PositionY
	       mul ebx
	       add eax, PositionX
	       mov ecx, 4
	       mul ecx
	       add eax, Grid_ID
	       mov ebx, [eax]
	       .if ebx != 0
	       mov DWORD PTR [eax], 0
	       .elseif ebx == 0
	       mov ecx, Lab_Number
	       mov DWORD PTR [eax], ecx
	       .endif
			;============================
			; Get a New Input Time
			;============================
			invoke Get_Time
			mov	TimeCritic, eax
	       .endif

	.endif
.endif
done:
	;===================
	; We completed w/o
	; doing anything
	;===================
	return MENU_NOTHING

err:
	;===================
	; We didn't make it
	;===================
	return MENU_ERROR

Process_Edit_Menu	ENDP
;########################################################################
; Process_File_Menu Procedure
;########################################################################
Process_MP_Edit_Menu	   PROC

	;===========================================================
	; This function will process the file menu for the gane
	;===========================================================

	;=================================
	; Local Variables
	;=================================
	LOCAL	DRAWX	    :DWORD
	LOCAL	DRAWY	    :DWORD
	LOCAL	hFont		:DWORD

	;===================================
	; Lock the DirectDraw back buffer
	;===================================
	invoke DD_Lock_Surface, lpddsback, ADDR lPitch

	;============================
	; Check for an error
	;============================
	.if eax == FALSE
		;===================
		; Jump to err
		;===================
		jmp	err

	.endif

	;===================================
	; Draw the bitmap onto the surface
	;===================================
	invoke Draw_Bitmap, eax, ptr_EDIT_MENU, lPitch, 800, 600, screen_bpp

	;===================================
	; Unlock the back buffer
	;===================================
	invoke DD_Unlock_Surface, lpddsback

	;============================
	; Check for an error
	;============================
	.if eax == FALSE
		;===================
		; Jump to err
		;===================
		jmp	err

	.endif


.if music_on == TRUE

	;======================================
	; Make sure the Menu sound is playing
	;======================================
	invoke Status_Sound, Menu_ID
	.if !(eax & DSBSTATUS_PLAYING)
		;===================
		; Play the sound
		;===================
		invoke Play_Sound, Menu_ID, DSBPLAY_LOOPING

	.endif
.endif
	invoke New_MP_Grid
	invoke Draw_Grid
	;============================
	; Check for an error
	;============================
	.if eax == FALSE
		;===================
		; Jump to err
		;===================
		jmp	err

	.endif

	DDS4INVOKE BltFast, lpddsback, 10, 556, \
					ptr_BMP_L_1b, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 10, 520, \
					ptr_BMP_P_1, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT

	DDS4INVOKE BltFast, lpddsback, 55, 556, \
					ptr_BMP_L_2b, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 55, 520, \
					ptr_BMP_P_2, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT

	DDS4INVOKE BltFast, lpddsback, 100, 556, \
					ptr_BMP_L_3b, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 100, 520, \
					ptr_BMP_P_3, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT

	DDS4INVOKE BltFast, lpddsback, 145, 556, \
					ptr_BMP_L_4b, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 145, 520, \
					ptr_BMP_P_4, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT

	DDS4INVOKE BltFast, lpddsback, 190, 556, \
					ptr_BMP_L_5b, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 190, 520, \
					ptr_BMP_P_5, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT

	DDS4INVOKE BltFast, lpddsback, 235, 556, \
					ptr_BMP_L_6b, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 235, 520, \
					ptr_BMP_P_6, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT

	DDS4INVOKE BltFast, lpddsback, 270, 556, \
					ptr_BMP_L_7b, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 270, 520, \
					ptr_BMP_P_7, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT

	DDS4INVOKE BltFast, lpddsback, 315, 556, \
					ptr_BMP_L_8b, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 315, 520, \
					ptr_BMP_P_8, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT

	DDS4INVOKE BltFast, lpddsback, 360, 556, \
					ptr_BMP_L_9b, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 360, 520, \
					ptr_BMP_P_9, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT

	DDS4INVOKE BltFast, lpddsback, 405, 556, \
					point_type, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	DDS4INVOKE BltFast, lpddsback, 405, 520, \
					ptr_BMP_P_0, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT


	       mov eax, PositionX
	       mov ebx, 44
	       mul ebx
	       add eax, 4
	       mov DRAWX, eax
	       mov eax, PositionY
	       mov ebx, 44
	       mul ebx
	       add eax, 10
	       mov DRAWY, eax


		       DDS4INVOKE BltFast, lpddsback, DRAWX, DRAWY, \
					ptr_BMP_G_1, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT


	;=====================================
	; Everything okay so flip displayed
	; surfaces and make loading visible
	; or call transition if needed
	;======================================
		invoke DD_Flip

	;============================
	; Check for an error
	;============================
	.if eax == FALSE
		;===================
		; Jump to err
		;===================
		jmp	err

	.endif


	;========================================================
	; Now read the keyboard to see if they have presses
	; any keys corresponding to our menu
	;========================================================
	invoke DI_Read_Keyboard
	;=============================
	; Did they press a valid key
	;=============================
	.if keyboard_state[DIK_B]
		;======================
		; The load game key
		;======================
		return	MENU_BACK


	.elseif keyboard_state[DIK_M]
	       invoke Save_Grid, ADDR szLABMPl

		;======================
		; Return to main key
		;======================
		return MENU_MAIN

	.elseif keyboard_state[DIK_1]
		mov Lab_Number, 1
	.elseif keyboard_state[DIK_2]
		mov Lab_Number, 2
	.elseif keyboard_state[DIK_3]
		mov Lab_Number, 3
	.elseif keyboard_state[DIK_4]
		mov Lab_Number, 4
	.elseif keyboard_state[DIK_5]
		mov Lab_Number, 5
	.elseif keyboard_state[DIK_6]
		mov Lab_Number, 6
	.elseif keyboard_state[DIK_7]
		mov Lab_Number, 7
	.elseif keyboard_state[DIK_8]
		mov Lab_Number, 8
	.elseif keyboard_state[DIK_9]
		mov Lab_Number, 9
	.elseif keyboard_state[DIK_0]
		mov Lab_Number, 10
	.elseif keyboard_state[DIK_RETURN]
	       invoke Save_Grid, ADDR szLABMPl
	mov	direction, MOVE_RIGHT
	mov	directionb, MOVE_RIGHT
	mov	PositionX, 7
	mov	PositionY, 11
	mov	snakelength, 7
	mov	Pass, FALSE
	mov	p2direction, MOVE_LEFT
	mov	p2directionb, MOVE_LEFT
	mov	p2PositionX, 10
	mov	p2PositionY, 1
	mov	p2snakelength, 7
	mov	p2Pass, FALSE

		;======================
		; Return to main key
		;======================
		return MENU_MP_PLAY


	.elseif keyboard_state[DIK_UPARROW]
		invoke Get_Time
		sub	eax, INPUT_DELAY
		.if eax  > TimeCritic
		.if PositionY == 0
		    mov PositionY, 12
		.else
		     sub PositionY, 1
		.endif

			 ;============================
			; Get a New Input Time
			;============================
			invoke Get_Time
			mov	TimeCritic, eax

		.endif
	.elseif keyboard_state[DIK_DOWNARROW]
		invoke Get_Time
		sub	eax, INPUT_DELAY
		.if eax  > TimeCritic
		.if PositionY == 12
		    mov PositionY, 0
		.else
		     add PositionY, 1
		.endif

			 ;============================
			; Get a New Input Time
			;============================
			invoke Get_Time
			mov	TimeCritic, eax
		.endif
	.elseif keyboard_state[DIK_RIGHTARROW]
		invoke Get_Time
		sub	eax, INPUT_DELAY
		.if eax  > TimeCritic
		.if PositionX == 17
		    mov PositionX, 0
		.else
		     add PositionX, 1
		.endif

			 ;============================
			; Get a New Input Time
			;============================
			invoke Get_Time
			mov	TimeCritic, eax
		  .endif
	.elseif keyboard_state[DIK_LEFTARROW]
		invoke Get_Time
		sub	eax, INPUT_DELAY
		.if eax  > TimeCritic
		.if PositionX == 0
		    mov PositionX, 17
		.else
		     sub PositionX, 1
		.endif

			 ;============================
			; Get a New Input Time
			;============================
			invoke Get_Time
			mov	TimeCritic, eax
		 .endif
	.elseif keyboard_state[DIK_SPACE]
		invoke Get_Time
		sub	eax, INPUT_DELAY
		.if eax  > TimeCritic
	       mov eax, 18
	       mov ebx, PositionY
	       mul ebx
	       add eax, PositionX
	       mov ecx, 4
	       mul ecx
	       add eax, Grid_ID
	       mov ebx, [eax]
	       .if ebx != 0
	       mov DWORD PTR [eax], 0
	       .elseif ebx == 0
	       mov ecx, Lab_Number
	       mov DWORD PTR [eax], ecx
	       .endif
			;============================
			; Get a New Input Time
			;============================
			invoke Get_Time
			mov	TimeCritic, eax
	       .endif

	.endif
done:
	;===================
	; We completed w/o
	; doing anything
	;===================
	return MENU_NOTHING

err:
	;===================
	; We didn't make it
	;===================
	return MENU_ERROR

Process_MP_Edit_Menu	   ENDP
;########################################################################
; END Process_Option_Menu
;########################################################################
Load_Grid  PROC      File:DWORD

	invoke CreateFile, File, GENERIC_READ,\
		    FILE_SHARE_READ,\
		    NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL,\
		    NULL
	mov hFile, eax

	.if eax == INVALID_HANDLE_VALUE
	    jmp err
	.endif

	invoke GetFileSize, hFile, NULL

	.if eax < 936
	    jmp err
	.endif

	invoke ReadFile, hFile, Grid_ID, 936, offset SizeReadWrite, NULL

	.if eax == FALSE
	    jmp err
	.endif
	invoke CloseHandle, hFile


	return TRUE


err:
	return FALSE

Load_Grid ENDP


Save_Grid  PROC      File:DWORD

	invoke CreateFile, File, GENERIC_WRITE,\
		    FILE_SHARE_READ,\
		    NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL,\
		    NULL
	mov hFile, eax

	.if eax == INVALID_HANDLE_VALUE
	    jmp err
	.endif

	invoke GetFileSize, hFile, NULL

	.if eax < 936
	    jmp err
	.endif

	invoke WriteFile, hFile, Grid_ID, 936, offset SizeReadWrite, NULL

	.if eax == FALSE
	    jmp err
	.endif
	invoke CloseHandle, hFile


	return TRUE


err:
	return FALSE

Save_Grid ENDP

Draw_Grid PROC
	  LOCAL pos	  :DWORD
	  LOCAL line	  :DWORD
	  LOCAL ID	  :DWORD
	  LOCAL DRAWX	  :DWORD
	  LOCAL DRAWY	  :DWORD

	mov pos, 0
	mov line, 0
	.while line <= 12

	       .while pos <= 17

	       mov eax, 18
	       mov ebx, line
	       mul ebx
	       add eax, pos
	       mov ecx, 4
	       mul ecx
	       mov ebx, Grid_ID
	       add eax, ebx
	       mov ebx, [eax]
	       .if ebx != 0
	       mov ax, bx
	       shr ebx, 16
	       .if ax == 1
		   m2m ID, ptr_BMP_L_1b
	       .elseif ax == 2
		   m2m ID, ptr_BMP_L_2b
	       .elseif ax == 3
		   m2m ID, ptr_BMP_L_3b
	       .elseif ax == 4
		   m2m ID, ptr_BMP_L_4b
	       .elseif ax == 5
		   m2m ID, ptr_BMP_L_5b
	       .elseif ax == 6
		   m2m ID, ptr_BMP_L_6b
	       .elseif ax == 7
		   m2m ID, ptr_BMP_L_7b
	       .elseif ax == 8
		   m2m ID, ptr_BMP_L_8b
	       .elseif ax == 9
		   m2m ID, ptr_BMP_L_9b
	       .elseif ax == 10
		   m2m ID, point_type
	       .elseif ax == 11
	       .if ebx == snakelength
		   m2m ID, ptr_BMP_S_hd
		   .elseif ebx == 1
		   m2m ID, ptr_BMP_S_tu
		   .else
		       m2m ID, ptr_BMP_S_ud
	       .endif
	       .elseif ax == 12
	       .if ebx == snakelength
		   m2m ID, ptr_BMP_S_hu
		   .elseif ebx == 1
		   m2m ID, ptr_BMP_S_td
		   .else
		       m2m ID, ptr_BMP_S_ud
		   .endif
	       .elseif ax == 13
	       .if ebx == snakelength
		   m2m ID, ptr_BMP_S_hr
		   .elseif ebx == 1
		   m2m ID, ptr_BMP_S_tl
		   .else
		       m2m ID, ptr_BMP_S_lr
	       .endif
	       .elseif ax == 14
	       .if ebx == snakelength
		   m2m ID, ptr_BMP_S_hl
		   .elseif ebx == 1
		   m2m ID, ptr_BMP_S_tr
		   .else
		       m2m ID, ptr_BMP_S_lr
	       .endif
	       .elseif ax == 15
	       .if ebx == snakelength
		   m2m ID, ptr_BMP_S_hu
		   .elseif ebx == 1
		   m2m ID, ptr_BMP_S_tr
		   .else
		       m2m ID, ptr_BMP_S_lu
	       .endif
	       .elseif ax == 16
	       .if ebx == snakelength
		   m2m ID, ptr_BMP_S_hd
		   .elseif ebx == 1
		   m2m ID, ptr_BMP_S_tr
		   .else
		       m2m ID, ptr_BMP_S_ld
	       .endif
	       .elseif ax == 17
	       .if ebx == snakelength
		   m2m ID, ptr_BMP_S_hu
		   .elseif ebx == 1
		   m2m ID, ptr_BMP_S_tl
		   .else
		       m2m ID, ptr_BMP_S_ru
		.endif
	       .elseif ax == 18
	       .if ebx == snakelength
		   m2m ID, ptr_BMP_S_hd
		   .elseif ebx == 1
		   m2m ID, ptr_BMP_S_tl
		   .else
		       m2m ID, ptr_BMP_S_rd
	       .endif
	       .elseif ax == 19
	       .if ebx == snakelength
		   m2m ID, ptr_BMP_S_hl
		   .elseif ebx == 1
		   m2m ID, ptr_BMP_S_td
		   .else
		       m2m ID, ptr_BMP_S_lu
	       .endif
	       .elseif ax == 21
	       .if ebx == snakelength
		   m2m ID, ptr_BMP_S_hl
		   .elseif ebx == 1
		   m2m ID, ptr_BMP_S_tu
		   .else
		       m2m ID, ptr_BMP_S_ld
	       .endif
	       .elseif ax == 20
	       .if ebx == snakelength
		   m2m ID, ptr_BMP_S_hr
		   .elseif ebx == 1
		   m2m ID, ptr_BMP_S_td
		   .else
		       m2m ID, ptr_BMP_S_ru
	       .endif
	       .elseif ax == 22
	       .if ebx == snakelength
		   m2m ID, ptr_BMP_S_hr
		   .elseif ebx == 1
		   m2m ID, ptr_BMP_S_tu
		   .else
		       m2m ID, ptr_BMP_S_rd
	       .endif
	       .elseif ax == 31
	       .if ebx == p2snakelength
		   m2m ID, ptr_BMP_S2_hd
		   .elseif ebx == 1
		   m2m ID, ptr_BMP_S2_tu
		   .else
		       m2m ID, ptr_BMP_S2_ud
	       .endif
	       .elseif ax == 32
	       .if ebx == p2snakelength
		   m2m ID, ptr_BMP_S2_hu
		   .elseif ebx == 1
		   m2m ID, ptr_BMP_S2_td
		   .else
		       m2m ID, ptr_BMP_S2_ud
		   .endif
	       .elseif ax == 33
	       .if ebx == p2snakelength
		   m2m ID, ptr_BMP_S2_hr
		   .elseif ebx == 1
		   m2m ID, ptr_BMP_S2_tl
		   .else
		       m2m ID, ptr_BMP_S2_lr
	       .endif
	       .elseif ax == 34
	       .if ebx == p2snakelength
		   m2m ID, ptr_BMP_S2_hl
		   .elseif ebx == 1
		   m2m ID, ptr_BMP_S2_tr
		   .else
		       m2m ID, ptr_BMP_S2_lr
	       .endif
	       .elseif ax == 35
	       .if ebx == p2snakelength
		   m2m ID, ptr_BMP_S2_hu
		   .elseif ebx == 1
		   m2m ID, ptr_BMP_S2_tr
		   .else
		       m2m ID, ptr_BMP_S2_lu
	       .endif
	       .elseif ax == 36
	       .if ebx == p2snakelength
		   m2m ID, ptr_BMP_S2_hd
		   .elseif ebx == 1
		   m2m ID, ptr_BMP_S2_tr
		   .else
		       m2m ID, ptr_BMP_S2_ld
	       .endif
	       .elseif ax == 37
	       .if ebx == p2snakelength
		   m2m ID, ptr_BMP_S2_hu
		   .elseif ebx == 1
		   m2m ID, ptr_BMP_S2_tl
		   .else
		       m2m ID, ptr_BMP_S2_ru
		.endif
	       .elseif ax == 38
	       .if ebx == p2snakelength
		   m2m ID, ptr_BMP_S2_hd
		   .elseif ebx == 1
		   m2m ID, ptr_BMP_S2_tl
		   .else
		       m2m ID, ptr_BMP_S2_rd
	       .endif
	       .elseif ax == 39
	       .if ebx == p2snakelength
		   m2m ID, ptr_BMP_S2_hl
		   .elseif ebx == 1
		   m2m ID, ptr_BMP_S2_td
		   .else
		       m2m ID, ptr_BMP_S2_lu
	       .endif
	       .elseif ax == 41
	       .if ebx == p2snakelength
		   m2m ID, ptr_BMP_S2_hl
		   .elseif ebx == 1
		   m2m ID, ptr_BMP_S2_tu
		   .else
		       m2m ID, ptr_BMP_S2_ld
	       .endif
	       .elseif ax == 40
	       .if ebx == p2snakelength
		   m2m ID, ptr_BMP_S2_hr
		   .elseif ebx == 1
		   m2m ID, ptr_BMP_S2_td
		   .else
		       m2m ID, ptr_BMP_S2_ru
	       .endif
	       .elseif ax == 42
	       .if ebx == p2snakelength
		   m2m ID, ptr_BMP_S2_hr
		   .elseif ebx == 1
		   m2m ID, ptr_BMP_S2_tu
		   .else
		       m2m ID, ptr_BMP_S2_rd
	       .endif
	       .else
		       m2m ID, ptr_BMP_P_1
	       .endif


	       mov eax, pos
	       mov ebx, 44
	       mul ebx
	       add eax, 4
	       mov DRAWX, eax
	       mov eax, line
	       mov ebx, 44
	       mul ebx
	       add eax, 10
	       mov DRAWY, eax


		       DDS4INVOKE BltFast, lpddsback, DRAWX, DRAWY, \
					ID, ADDR SrcRectROCKET, \
					DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT
	       .endif
	       add pos, 1
	       .endw
	mov pos, 0
	add line, 1
	.endw



	return TRUE
err:
	return FALSE

Draw_Grid ENDP

Update_Grid   PROC

     LOCAL   line  :DWORD
     LOCAL   pos   :DWORD
     LOCAL   ADress	 :DWORD



     mov pos, 0
     mov line, 0
	.while line <= 12
	     .while pos <= 17

	       mov eax, 18
	       mov ebx, line
	       mul ebx
	       add eax, pos
	       mov ecx, 4
	       mul ecx
	       mov ebx, Grid_ID
	       add eax, ebx
	       mov ADress, eax
	       mov ebx, [eax]

	       .if ebx != 0


	       mov ax, bx
	       shr ebx, 16
	       .if ax >= 11

		   .if ebx == 1

		       mov ebx, 0
		       mov eax, ADress
		       mov DWORD PTR [eax], ebx
		   .else


			sub ebx, 1
			shl ebx, 16
			mov bx, ax
			mov eax, ADress
		       mov DWORD PTR [eax], ebx
		    .endif

	       .endif
	       .endif
	       add pos, 1
	       .endw
	mov pos, 0
	add line, 1
	.endw

	       mov eax, 18
	       mov ebx, PositionY
	       mul ebx
	       add eax, PositionX
	       mov ecx, 4
	       mul ecx
	       mov ebx, Grid_ID
	       add eax, ebx
	       push eax
	       mov eax, 18
	       mov ebx, PositionYo
	       mul ebx
	       add eax, PositionXo
	       mov ecx, 4
	       mul ecx
	       mov ebx, Grid_ID
	       add eax, ebx
	       mov ecx, eax
	       pop eax
.if direction == MOVE_UP
    .if directionb == MOVE_UP
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 12
	       mov DWORD PTR [eax], ebx
    .elseif directionb == MOVE_RIGHT
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 12
	       mov DWORD PTR [eax], ebx
	       mov ebx, snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 19
	       mov DWORD PTR [ecx], ebx
    .elseif directionb == MOVE_LEFT
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 12
	       mov DWORD PTR [eax], ebx
	       mov ebx, snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 20
	       mov DWORD PTR [ecx], ebx
    .endif
.elseif direction == MOVE_DOWN
    .if directionb == MOVE_DOWN
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 11
	       mov DWORD PTR [eax], ebx
    .elseif directionb == MOVE_RIGHT
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 11
	       mov DWORD PTR [eax], ebx
	       mov ebx, snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 21
	       mov DWORD PTR [ecx], ebx
    .elseif directionb == MOVE_LEFT
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 11
	       mov DWORD PTR [eax], ebx
	       mov ebx, snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 22
	       mov DWORD PTR [ecx], ebx
    .endif
.elseif direction == MOVE_RIGHT
    .if directionb == MOVE_DOWN
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 13
	       mov DWORD PTR [eax], ebx
	       mov ebx, snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 17
	       mov DWORD PTR [ecx], ebx
    .elseif directionb == MOVE_UP
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 13
	       mov DWORD PTR [eax], ebx
	       mov ebx, snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 18
	       mov DWORD PTR [ecx], ebx
    .elseif directionb == MOVE_RIGHT
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 13
	       mov DWORD PTR [eax], ebx
    .endif
.elseif direction == MOVE_LEFT
    .if directionb == MOVE_DOWN
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 14
	       mov DWORD PTR [eax], ebx
	       mov ebx, snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 15
	       mov DWORD PTR [ecx], ebx
    .elseif directionb == MOVE_UP
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 14
	       mov DWORD PTR [eax], ebx
	       mov ebx, snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 16
	       mov DWORD PTR [ecx], ebx
    .elseif directionb == MOVE_LEFT
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 14
	       mov DWORD PTR [eax], ebx
    .endif
.endif




	return TRUE
err:
	return FALSE

Update_Grid   ENDP





Update_MP_Grid	 PROC

     LOCAL   line  :DWORD
     LOCAL   pos   :DWORD
     LOCAL   ADress	 :DWORD



     mov pos, 0
     mov line, 0
	.while line <= 12
	     .while pos <= 17

	       mov eax, 18
	       mov ebx, line
	       mul ebx
	       add eax, pos
	       mov ecx, 4
	       mul ecx
	       mov ebx, Grid_ID
	       add eax, ebx
	       mov ADress, eax
	       mov ebx, [eax]

	       .if ebx != 0


	       mov ax, bx
	       shr ebx, 16
	       .if ax >= 11

		   .if ebx == 1

		       mov ebx, 0
		       mov eax, ADress
		       mov DWORD PTR [eax], ebx
		   .else


			sub ebx, 1
			shl ebx, 16
			mov bx, ax
			mov eax, ADress
		       mov DWORD PTR [eax], ebx
		    .endif

	       .endif
	       .endif
	       add pos, 1
	       .endw
	mov pos, 0
	add line, 1
	.endw

	       mov eax, 18
	       mov ebx, PositionY
	       mul ebx
	       add eax, PositionX
	       mov ecx, 4
	       mul ecx
	       mov ebx, Grid_ID
	       add eax, ebx
	       push eax
	       mov eax, 18
	       mov ebx, PositionYo
	       mul ebx
	       add eax, PositionXo
	       mov ecx, 4
	       mul ecx
	       mov ebx, Grid_ID
	       add eax, ebx
	       mov ecx, eax
	       pop eax
.if direction == MOVE_UP
    .if directionb == MOVE_UP
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 12
	       mov DWORD PTR [eax], ebx
    .elseif directionb == MOVE_RIGHT
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 12
	       mov DWORD PTR [eax], ebx
	       mov ebx, snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 19
	       mov DWORD PTR [ecx], ebx
    .elseif directionb == MOVE_LEFT
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 12
	       mov DWORD PTR [eax], ebx
	       mov ebx, snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 20
	       mov DWORD PTR [ecx], ebx
    .endif
.elseif direction == MOVE_DOWN
    .if directionb == MOVE_DOWN
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 11
	       mov DWORD PTR [eax], ebx
    .elseif directionb == MOVE_RIGHT
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 11
	       mov DWORD PTR [eax], ebx
	       mov ebx, snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 21
	       mov DWORD PTR [ecx], ebx
    .elseif directionb == MOVE_LEFT
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 11
	       mov DWORD PTR [eax], ebx
	       mov ebx, snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 22
	       mov DWORD PTR [ecx], ebx
    .endif
.elseif direction == MOVE_RIGHT
    .if directionb == MOVE_DOWN
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 13
	       mov DWORD PTR [eax], ebx
	       mov ebx, snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 17
	       mov DWORD PTR [ecx], ebx
    .elseif directionb == MOVE_UP
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 13
	       mov DWORD PTR [eax], ebx
	       mov ebx, snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 18
	       mov DWORD PTR [ecx], ebx
    .elseif directionb == MOVE_RIGHT
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 13
	       mov DWORD PTR [eax], ebx
    .endif
.elseif direction == MOVE_LEFT
    .if directionb == MOVE_DOWN
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 14
	       mov DWORD PTR [eax], ebx
	       mov ebx, snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 15
	       mov DWORD PTR [ecx], ebx
    .elseif directionb == MOVE_UP
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 14
	       mov DWORD PTR [eax], ebx
	       mov ebx, snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 16
	       mov DWORD PTR [ecx], ebx
    .elseif directionb == MOVE_LEFT
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 14
	       mov DWORD PTR [eax], ebx
    .endif
.endif







	       mov eax, 18
	       mov ebx, p2PositionY
	       mul ebx
	       add eax, p2PositionX
	       mov ecx, 4
	       mul ecx
	       mov ebx, Grid_ID
	       add eax, ebx
	       push eax
	       mov eax, 18
	       mov ebx, p2PositionYo
	       mul ebx
	       add eax, p2PositionXo
	       mov ecx, 4
	       mul ecx
	       mov ebx, Grid_ID
	       add eax, ebx
	       mov ecx, eax
	       pop eax
.if p2direction == MOVE_UP
    .if p2directionb == MOVE_UP
	       mov ebx, p2snakelength
	       shl ebx, 16
	       mov bx, 32
	       mov DWORD PTR [eax], ebx
    .elseif p2directionb == MOVE_RIGHT
	       mov ebx, p2snakelength
	       shl ebx, 16
	       mov bx, 32
	       mov DWORD PTR [eax], ebx
	       mov ebx, p2snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 39
	       mov DWORD PTR [ecx], ebx
    .elseif p2directionb == MOVE_LEFT
	       mov ebx, p2snakelength
	       shl ebx, 16
	       mov bx, 32
	       mov DWORD PTR [eax], ebx
	       mov ebx, p2snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 40
	       mov DWORD PTR [ecx], ebx
    .endif
.elseif p2direction == MOVE_DOWN
    .if p2directionb == MOVE_DOWN
	       mov ebx, p2snakelength
	       shl ebx, 16
	       mov bx, 31
	       mov DWORD PTR [eax], ebx
    .elseif p2directionb == MOVE_RIGHT
	       mov ebx, p2snakelength
	       shl ebx, 16
	       mov bx, 31
	       mov DWORD PTR [eax], ebx
	       mov ebx, p2snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 41
	       mov DWORD PTR [ecx], ebx
    .elseif p2directionb == MOVE_LEFT
	       mov ebx, p2snakelength
	       shl ebx, 16
	       mov bx, 31
	       mov DWORD PTR [eax], ebx
	       mov ebx, p2snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 42
	       mov DWORD PTR [ecx], ebx
    .endif
.elseif p2direction == MOVE_RIGHT
    .if p2directionb == MOVE_DOWN
	       mov ebx, p2snakelength
	       shl ebx, 16
	       mov bx, 33
	       mov DWORD PTR [eax], ebx
	       mov ebx, p2snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 37
	       mov DWORD PTR [ecx], ebx
    .elseif p2directionb == MOVE_UP
	       mov ebx, p2snakelength
	       shl ebx, 16
	       mov bx, 33
	       mov DWORD PTR [eax], ebx
	       mov ebx, p2snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 38
	       mov DWORD PTR [ecx], ebx
    .elseif p2directionb == MOVE_RIGHT
	       mov ebx, p2snakelength
	       shl ebx, 16
	       mov bx, 33
	       mov DWORD PTR [eax], ebx
    .endif
.elseif p2direction == MOVE_LEFT
    .if p2directionb == MOVE_DOWN
	       mov ebx, p2snakelength
	       shl ebx, 16
	       mov bx, 34
	       mov DWORD PTR [eax], ebx
	       mov ebx, p2snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 35
	       mov DWORD PTR [ecx], ebx
    .elseif p2directionb == MOVE_UP
	       mov ebx, p2snakelength
	       shl ebx, 16
	       mov bx, 34
	       mov DWORD PTR [eax], ebx
	       mov ebx, p2snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 36
	       mov DWORD PTR [ecx], ebx
    .elseif p2directionb == MOVE_LEFT
	       mov ebx, p2snakelength
	       shl ebx, 16
	       mov bx, 34
	       mov DWORD PTR [eax], ebx
    .endif
.endif




	return TRUE
err:
	return FALSE

Update_MP_Grid	 ENDP

Place_New_Point   PROC
LOCAL		  xint :DWORD
LOCAL		  yint :DWORD
LOCAL		  ADress :DWORD



	       mov eax, 18
	       mov ebx, PositionY
	       mul ebx
	       add eax, PositionX
	       mov ecx, 4
	       mul ecx
	       mov ebx, Grid_ID
	       add eax, ebx
	       push eax
	       mov eax, 18
	       mov ebx, PositionYo
	       mul ebx
	       add eax, PositionXo
	       mov ecx, 4
	       mul ecx
	       mov ebx, Grid_ID
	       add eax, ebx
	       mov ecx, eax
	       pop eax
.if direction == MOVE_UP
    .if directionb == MOVE_UP
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 12
	       mov DWORD PTR [eax], ebx
    .elseif directionb == MOVE_RIGHT
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 12
	       mov DWORD PTR [eax], ebx
	       mov ebx, snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 19
	       mov DWORD PTR [ecx], ebx
    .elseif directionb == MOVE_LEFT
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 12
	       mov DWORD PTR [eax], ebx
	       mov ebx, snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 20
	       mov DWORD PTR [ecx], ebx
    .endif
.elseif direction == MOVE_DOWN
    .if directionb == MOVE_DOWN
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 11
	       mov DWORD PTR [eax], ebx
    .elseif directionb == MOVE_RIGHT
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 11
	       mov DWORD PTR [eax], ebx
	       mov ebx, snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 21
	       mov DWORD PTR [ecx], ebx
    .elseif directionb == MOVE_LEFT
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 11
	       mov DWORD PTR [eax], ebx
	       mov ebx, snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 22
	       mov DWORD PTR [ecx], ebx
    .endif
.elseif direction == MOVE_RIGHT
    .if directionb == MOVE_DOWN
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 13
	       mov DWORD PTR [eax], ebx
	       mov ebx, snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 17
	       mov DWORD PTR [ecx], ebx
    .elseif directionb == MOVE_UP
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 13
	       mov DWORD PTR [eax], ebx
	       mov ebx, snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 18
	       mov DWORD PTR [ecx], ebx
    .elseif directionb == MOVE_RIGHT
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 13
	       mov DWORD PTR [eax], ebx
    .endif
.elseif direction == MOVE_LEFT
    .if directionb == MOVE_DOWN
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 14
	       mov DWORD PTR [eax], ebx
	       mov ebx, snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 15
	       mov DWORD PTR [ecx], ebx
    .elseif directionb == MOVE_UP
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 14
	       mov DWORD PTR [eax], ebx
	       mov ebx, snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 16
	       mov DWORD PTR [ecx], ebx
    .elseif directionb == MOVE_LEFT
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 14
	       mov DWORD PTR [eax], ebx
    .endif
.endif

.if GameState == GS_MP_PLAY
	       mov eax, 18
	       mov ebx, p2PositionY
	       mul ebx
	       add eax, p2PositionX
	       mov ecx, 4
	       mul ecx
	       mov ebx, Grid_ID
	       add eax, ebx
	       push eax
	       mov eax, 18
	       mov ebx, p2PositionYo
	       mul ebx
	       add eax, p2PositionXo
	       mov ecx, 4
	       mul ecx
	       mov ebx, Grid_ID
	       add eax, ebx
	       mov ecx, eax
	       pop eax
.if p2direction == MOVE_UP
    .if p2directionb == MOVE_UP
	       mov ebx, p2snakelength
	       shl ebx, 16
	       mov bx, 32
	       mov DWORD PTR [eax], ebx
	       mov ebx, p2snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 32
	       mov DWORD PTR [ecx], ebx
    .elseif p2directionb == MOVE_RIGHT
	       mov ebx, p2snakelength
	       shl ebx, 16
	       mov bx, 32
	       mov DWORD PTR [eax], ebx
	       mov ebx, p2snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 39
	       mov DWORD PTR [ecx], ebx
    .elseif p2directionb == MOVE_LEFT
	       mov ebx, p2snakelength
	       shl ebx, 16
	       mov bx, 32
	       mov DWORD PTR [eax], ebx
	       mov ebx, p2snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 40
	       mov DWORD PTR [ecx], ebx
    .endif
.elseif p2direction == MOVE_DOWN
    .if p2directionb == MOVE_DOWN
	       mov ebx, p2snakelength
	       shl ebx, 16
	       mov bx, 31
	       mov DWORD PTR [eax], ebx
	       mov ebx, p2snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 31
	       mov DWORD PTR [ecx], ebx
    .elseif p2directionb == MOVE_RIGHT
	       mov ebx, p2snakelength
	       shl ebx, 16
	       mov bx, 31
	       mov DWORD PTR [eax], ebx
	       mov ebx, p2snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 41
	       mov DWORD PTR [ecx], ebx
    .elseif p2directionb == MOVE_LEFT
	       mov ebx, p2snakelength
	       shl ebx, 16
	       mov bx, 31
	       mov DWORD PTR [eax], ebx
	       mov ebx, p2snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 42
	       mov DWORD PTR [ecx], ebx
    .endif
.elseif p2direction == MOVE_RIGHT
    .if p2directionb == MOVE_DOWN
	       mov ebx, p2snakelength
	       shl ebx, 16
	       mov bx, 33
	       mov DWORD PTR [eax], ebx
	       mov ebx, p2snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 37
	       mov DWORD PTR [ecx], ebx
    .elseif p2directionb == MOVE_UP
	       mov ebx, p2snakelength
	       shl ebx, 16
	       mov bx, 33
	       mov DWORD PTR [eax], ebx
	       mov ebx, p2snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 38
	       mov DWORD PTR [ecx], ebx
    .elseif p2directionb == MOVE_RIGHT
	       mov ebx, p2snakelength
	       shl ebx, 16
	       mov bx, 33
	       mov DWORD PTR [eax], ebx
	       mov ebx, p2snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 33
	       mov DWORD PTR [ecx], ebx
    .endif
.elseif p2direction == MOVE_LEFT
    .if p2directionb == MOVE_DOWN
	       mov ebx, p2snakelength
	       shl ebx, 16
	       mov bx, 34
	       mov DWORD PTR [eax], ebx
	       mov ebx, p2snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 35
	       mov DWORD PTR [ecx], ebx
    .elseif p2directionb == MOVE_UP
	       mov ebx, p2snakelength
	       shl ebx, 16
	       mov bx, 34
	       mov DWORD PTR [eax], ebx
	       mov ebx, p2snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 36
	       mov DWORD PTR [ecx], ebx
    .elseif p2directionb == MOVE_LEFT
	       mov ebx, p2snakelength
	       shl ebx, 16
	       mov bx, 34
	       mov DWORD PTR [eax], ebx
	       mov ebx, p2snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 34
	       mov DWORD PTR [ecx], ebx
    .endif
.endif


.endif
;Get new point

invoke Get_New_Point

	return TRUE
err:
	return FALSE


Place_New_Point   ENDP


Place_New_Point2   PROC
LOCAL		  xint :DWORD
LOCAL		  yint :DWORD
LOCAL		  ADress :DWORD

	       mov eax, 18
	       mov ebx, PositionY
	       mul ebx
	       add eax, PositionX
	       mov ecx, 4
	       mul ecx
	       mov ebx, Grid_ID
	       add eax, ebx
	       push eax
	       mov eax, 18
	       mov ebx, PositionYo
	       mul ebx
	       add eax, PositionXo
	       mov ecx, 4
	       mul ecx
	       mov ebx, Grid_ID
	       add eax, ebx
	       mov ecx, eax
	       pop eax
.if direction == MOVE_UP
    .if directionb == MOVE_UP
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 12
	       mov DWORD PTR [eax], ebx
	       mov ebx, snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 12
	       mov DWORD PTR [ecx], ebx
    .elseif directionb == MOVE_RIGHT
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 12
	       mov DWORD PTR [eax], ebx
	       mov ebx, snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 19
	       mov DWORD PTR [ecx], ebx
    .elseif directionb == MOVE_LEFT
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 12
	       mov DWORD PTR [eax], ebx
	       mov ebx, snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 20
	       mov DWORD PTR [ecx], ebx
    .endif
.elseif direction == MOVE_DOWN
    .if directionb == MOVE_DOWN
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 11
	       mov DWORD PTR [eax], ebx
	       mov ebx, snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 11
	       mov DWORD PTR [ecx], ebx
    .elseif directionb == MOVE_RIGHT
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 11
	       mov DWORD PTR [eax], ebx
	       mov ebx, snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 21
	       mov DWORD PTR [ecx], ebx
    .elseif directionb == MOVE_LEFT
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 11
	       mov DWORD PTR [eax], ebx
	       mov ebx, snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 22
	       mov DWORD PTR [ecx], ebx
    .endif
.elseif direction == MOVE_RIGHT
    .if directionb == MOVE_DOWN
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 13
	       mov DWORD PTR [eax], ebx
	       mov ebx, snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 17
	       mov DWORD PTR [ecx], ebx
    .elseif directionb == MOVE_UP
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 13
	       mov DWORD PTR [eax], ebx
	       mov ebx, snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 18
	       mov DWORD PTR [ecx], ebx
    .elseif directionb == MOVE_RIGHT
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 13
	       mov DWORD PTR [eax], ebx
	       mov ebx, snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 13
	       mov DWORD PTR [ecx], ebx
    .endif
.elseif direction == MOVE_LEFT
    .if directionb == MOVE_DOWN
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 14
	       mov DWORD PTR [eax], ebx
	       mov ebx, snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 15
	       mov DWORD PTR [ecx], ebx
    .elseif directionb == MOVE_UP
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 14
	       mov DWORD PTR [eax], ebx
	       mov ebx, snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 16
	       mov DWORD PTR [ecx], ebx
    .elseif directionb == MOVE_LEFT
	       mov ebx, snakelength
	       shl ebx, 16
	       mov bx, 14
	       mov DWORD PTR [eax], ebx
	       mov ebx, snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 14
	       mov DWORD PTR [ecx], ebx
    .endif
.endif


	       mov eax, 18
	       mov ebx, p2PositionY
	       mul ebx
	       add eax, p2PositionX
	       mov ecx, 4
	       mul ecx
	       mov ebx, Grid_ID
	       add eax, ebx
	       push eax
	       mov eax, 18
	       mov ebx, p2PositionYo
	       mul ebx
	       add eax, p2PositionXo
	       mov ecx, 4
	       mul ecx
	       mov ebx, Grid_ID
	       add eax, ebx
	       mov ecx, eax
	       pop eax
.if p2direction == MOVE_UP
    .if p2directionb == MOVE_UP
	       mov ebx, p2snakelength
	       shl ebx, 16
	       mov bx, 32
	       mov DWORD PTR [eax], ebx
	       mov ebx, p2snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 32
	       mov DWORD PTR [ecx], ebx
    .elseif p2directionb == MOVE_RIGHT
	       mov ebx, p2snakelength
	       shl ebx, 16
	       mov bx, 32
	       mov DWORD PTR [eax], ebx
	       mov ebx, p2snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 39
	       mov DWORD PTR [ecx], ebx
    .elseif p2directionb == MOVE_LEFT
	       mov ebx, p2snakelength
	       shl ebx, 16
	       mov bx, 32
	       mov DWORD PTR [eax], ebx
	       mov ebx, p2snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 40
	       mov DWORD PTR [ecx], ebx
    .endif
.elseif p2direction == MOVE_DOWN
    .if p2directionb == MOVE_DOWN
	       mov ebx, p2snakelength
	       shl ebx, 16
	       mov bx, 31
	       mov DWORD PTR [eax], ebx
	       mov ebx, p2snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 31
	       mov DWORD PTR [ecx], ebx
    .elseif p2directionb == MOVE_RIGHT
	       mov ebx, p2snakelength
	       shl ebx, 16
	       mov bx, 31
	       mov DWORD PTR [eax], ebx
	       mov ebx, p2snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 41
	       mov DWORD PTR [ecx], ebx
    .elseif p2directionb == MOVE_LEFT
	       mov ebx, p2snakelength
	       shl ebx, 16
	       mov bx, 31
	       mov DWORD PTR [eax], ebx
	       mov ebx, p2snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 42
	       mov DWORD PTR [ecx], ebx
    .endif
.elseif p2direction == MOVE_RIGHT
    .if p2directionb == MOVE_DOWN
	       mov ebx, p2snakelength
	       shl ebx, 16
	       mov bx, 33
	       mov DWORD PTR [eax], ebx
	       mov ebx, p2snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 37
	       mov DWORD PTR [ecx], ebx
    .elseif p2directionb == MOVE_UP
	       mov ebx, p2snakelength
	       shl ebx, 16
	       mov bx, 33
	       mov DWORD PTR [eax], ebx
	       mov ebx, p2snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 38
	       mov DWORD PTR [ecx], ebx
    .elseif p2directionb == MOVE_RIGHT
	       mov ebx, p2snakelength
	       shl ebx, 16
	       mov bx, 33
	       mov DWORD PTR [eax], ebx
	       mov ebx, p2snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 33
	       mov DWORD PTR [ecx], ebx
    .endif
.elseif p2direction == MOVE_LEFT
    .if p2directionb == MOVE_DOWN
	       mov ebx, p2snakelength
	       shl ebx, 16
	       mov bx, 34
	       mov DWORD PTR [eax], ebx
	       mov ebx, p2snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 35
	       mov DWORD PTR [ecx], ebx
    .elseif p2directionb == MOVE_UP
	       mov ebx, p2snakelength
	       shl ebx, 16
	       mov bx, 34
	       mov DWORD PTR [eax], ebx
	       mov ebx, p2snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 36
	       mov DWORD PTR [ecx], ebx
    .elseif p2directionb == MOVE_LEFT
	       mov ebx, p2snakelength
	       shl ebx, 16
	       mov bx, 34
	       mov DWORD PTR [eax], ebx
	       mov ebx, p2snakelength
	       sub ebx, 1
	       shl ebx, 16
	       mov bx, 34
	       mov DWORD PTR [ecx], ebx
    .endif
.endif

;Get new point

invoke Get_New_Point

	return TRUE
err:
	return FALSE


Place_New_Point2   ENDP

Get_New_Point	PROC
LOCAL		  xint :DWORD
LOCAL		  yint :DWORD
LOCAL		  ADress :DWORD
LOCAL		  turns  :DWORD
;Get new point
mov turns, 1
invoke Get_Time

mov ecx, 13
xor edx, edx
div ecx
mov xint, edx


invoke Get_Time
mov ecx, 18
xor edx, edx
div ecx
mov yint, edx
newround:
;test if already something
	       mov eax, 18
	       mov ebx, xint
	       mul ebx
	       add eax, yint
	       shl eax, 2
	       mov ebx, Grid_ID
	       add eax, ebx
	       mov ADress, eax
	       mov ebx, [eax]

	       .if ebx != 0
invoke Get_Time
mov ecx, turns
xor edx, edx
div ecx
mov ecx, 13
xor edx, edx
div ecx
mov xint, edx


invoke Get_Time
mov ecx, turns
xor edx, edx
div ecx
mov ecx, 18
xor edx, edx
div ecx
mov yint, edx
add turns, 1
	       jmp newround

	       .else
		    xor ebx, ebx
		    mov bx, 10
		    mov eax, ADress
		    mov DWORD PTR [eax], ebx
	       .endif

	return TRUE
err:
	return FALSE
Get_New_Point ENDP

New_Grid	  PROC
     LOCAL   line  :DWORD
     LOCAL   pos   :DWORD
     LOCAL   ADress	 :DWORD
     LOCAL   NumPOINT	 :DWORD


     mov pos, 0
     mov line, 0
	.while line <= 12
	     .while pos <= 17

	       mov eax, 18
	       mov ebx, line
	       mul ebx
	       add eax, pos
	       mov ecx, 4
	       mul ecx
	       mov ebx, Grid_ID
	       add eax, ebx
	       mov ADress, eax
	       mov ebx, [eax]

	       .if ebx != 0


	       mov ax, bx
	       shr ebx, 16
	       .if ax >= 11

		       mov ebx, 0
		       mov eax, ADress
		       mov DWORD PTR [eax], ebx

	       .endif
	       .endif
	       add pos, 1
	       .endw
	mov pos, 0
	add line, 1
	.endw
mov NumPOINT, 0
	       mov eax, 18
	       mov ebx, 11
	       mul ebx
	       add eax, 1
	       mov ecx, 4
	       mul ecx
	       mov ebx, Grid_ID
	       add eax, ebx
	       mov ADress, eax

	       mov ecx, ADress
	       mov eax, DWORD PTR[ecx]
	    .if eax != 0
	       mov ebx, eax
	       shr ebx, 16
	       .if ax == 10		 ;They made a point
		 mov NumPOINT, 1
	       .endif
	     .endif
	       mov ebx, 1
	       shl ebx, 16
	       mov bx, 13
	       mov ecx, ADress
	       mov DWORD PTR[ecx], ebx
	       add ADress, 4

	       mov ecx, ADress
	       mov eax, DWORD PTR[ecx]
	    .if eax != 0
	       mov ebx, eax
	       shr ebx, 16
	       .if ax == 10		 ;They made a point
		 mov NumPOINT, 1
	       .endif
	     .endif

	       mov ebx, 2
	       shl ebx, 16
	       mov bx, 13
	       mov ecx, ADress
	       mov DWORD PTR[ecx], ebx
	       add ADress, 4

	       mov ecx, ADress
	       mov eax, DWORD PTR[ecx]
	    .if eax != 0
	       mov ebx, eax
	       shr ebx, 16
	       .if ax == 10		 ;They made a point
		 mov NumPOINT, 1
	       .endif
	     .endif

	       mov ebx, 3
	       shl ebx, 16
	       mov bx, 13
	       mov ecx, ADress
	       mov DWORD PTR[ecx], ebx
	       add ADress, 4

	       mov ecx, ADress
	       mov eax, DWORD PTR[ecx]
	    .if eax != 0
	       mov ebx, eax
	       shr ebx, 16
	       .if ax == 10		 ;They made a point
		 mov NumPOINT, 1
	       .endif
	     .endif

	       mov ebx, 4
	       shl ebx, 16
	       mov bx, 13
	       mov ecx, ADress
	       mov DWORD PTR[ecx], ebx
	       add ADress, 4

	       mov ecx, ADress
	       mov eax, DWORD PTR[ecx]
	    .if eax != 0
	       mov ebx, eax
	       shr ebx, 16
	       .if ax == 10		 ;They made a point
		 mov NumPOINT, 1
	       .endif
	     .endif

	       mov ebx, 5
	       shl ebx, 16
	       mov bx, 13
	       mov ecx, ADress
	       mov DWORD PTR[ecx], ebx
	       add ADress, 4

	       mov ecx, ADress
	       mov eax, DWORD PTR[ecx]
	    .if eax != 0
	       mov ebx, eax
	       shr ebx, 16
	       .if ax == 10		 ;They made a point
		 mov NumPOINT, 1
	       .endif
	     .endif

	       mov ebx, 6
	       shl ebx, 16
	       mov bx, 13
	       mov ecx, ADress
	       mov DWORD PTR[ecx], ebx
	       add ADress, 4

	       mov ecx, ADress
	       mov eax, DWORD PTR[ecx]
	    .if eax != 0
	       mov ebx, eax
	       shr ebx, 16
	       .if ax == 10		 ;They made a point
		 mov NumPOINT, 1
	       .endif
	     .endif

	       mov ebx, 7
	       shl ebx, 16
	       mov bx, 13
	       mov ecx, ADress
	       mov DWORD PTR[ecx], ebx
	       add ADress, 4

	       mov ecx, ADress
	       mov eax, DWORD PTR[ecx]
	    .if eax != 0
	       mov ebx, eax
	       shr ebx, 16
	       .if ax == 10		 ;They made a point
		 mov NumPOINT, 1
	       .else
	       mov ebx, 0
	       mov ecx, ADress
	       mov DWORD PTR[ecx], ebx
	       .endif
	     .endif

	       add ADress, 4

	       mov ecx, ADress
	       mov eax, DWORD PTR[ecx]
	    .if eax != 0
	       mov ebx, eax
	       shr ebx, 16
	       .if ax == 10		 ;They made a point
		 mov NumPOINT, 1
	       .else
	       mov ebx, 0
	       mov ecx, ADress
	       mov DWORD PTR[ecx], ebx
	       .endif
	     .endif

	       add ADress, 4

	       mov ecx, ADress
	       mov eax, DWORD PTR[ecx]
	    .if eax != 0
	       mov ebx, eax
	       shr ebx, 16
	       .if ax == 10		 ;They made a point
		 mov NumPOINT, 1
	       .else
	       mov ebx, 0
	       mov ecx, ADress
	       mov DWORD PTR[ecx], ebx
	       .endif
	     .endif
;	      .if NumPOINT != 0
 ;	invoke Get_New_Point
  ;	       .endif
mov NumPOINT, 0
return TRUE


New_Grid     ENDP

New_MP_Grid	     PROC
     LOCAL   line  :DWORD
     LOCAL   pos   :DWORD
     LOCAL   ADress	 :DWORD
     LOCAL   NumPOINT	 :DWORD


     mov pos, 0
     mov line, 0
	.while line <= 12
	     .while pos <= 17

	       mov eax, 18
	       mov ebx, line
	       mul ebx
	       add eax, pos
	       mov ecx, 4
	       mul ecx
	       mov ebx, Grid_ID
	       add eax, ebx
	       mov ADress, eax
	       mov ebx, [eax]

	       .if ebx != 0


	       mov ax, bx
	       shr ebx, 16
	       .if ax >= 11

		       mov ebx, 0
		       mov eax, ADress
		       mov DWORD PTR [eax], ebx

	       .endif
	       .endif
	       add pos, 1
	       .endw
	mov pos, 0
	add line, 1
	.endw
mov NumPOINT, 0
	       mov eax, 18
	       mov ebx, 11
	       mul ebx
	       add eax, 1
	       mov ecx, 4
	       mul ecx
	       mov ebx, Grid_ID
	       add eax, ebx
	       mov ADress, eax

	       mov ecx, ADress
	       mov eax, DWORD PTR[ecx]
	    .if eax != 0
	       mov ebx, eax
	       shr ebx, 16
	       .if ax == 10		 ;They made a point
		 mov NumPOINT, 1
	       .endif
	     .endif
	       mov ebx, 1
	       shl ebx, 16
	       mov bx, 13
	       mov ecx, ADress
	       mov DWORD PTR[ecx], ebx
	       add ADress, 4

	       mov ecx, ADress
	       mov eax, DWORD PTR[ecx]
	    .if eax != 0
	       mov ebx, eax
	       shr ebx, 16
	       .if ax == 10		 ;They made a point
		 mov NumPOINT, 1
	       .endif
	     .endif

	       mov ebx, 2
	       shl ebx, 16
	       mov bx, 13
	       mov ecx, ADress
	       mov DWORD PTR[ecx], ebx
	       add ADress, 4

	       mov ecx, ADress
	       mov eax, DWORD PTR[ecx]
	    .if eax != 0
	       mov ebx, eax
	       shr ebx, 16
	       .if ax == 10		 ;They made a point
		 mov NumPOINT, 1
	       .endif
	     .endif

	       mov ebx, 3
	       shl ebx, 16
	       mov bx, 13
	       mov ecx, ADress
	       mov DWORD PTR[ecx], ebx
	       add ADress, 4

	       mov ecx, ADress
	       mov eax, DWORD PTR[ecx]
	    .if eax != 0
	       mov ebx, eax
	       shr ebx, 16
	       .if ax == 10		 ;They made a point
		 mov NumPOINT, 1
	       .endif
	     .endif

	       mov ebx, 4
	       shl ebx, 16
	       mov bx, 13
	       mov ecx, ADress
	       mov DWORD PTR[ecx], ebx
	       add ADress, 4

	       mov ecx, ADress
	       mov eax, DWORD PTR[ecx]
	    .if eax != 0
	       mov ebx, eax
	       shr ebx, 16
	       .if ax == 10		 ;They made a point
		 mov NumPOINT, 1
	       .endif
	     .endif

	       mov ebx, 5
	       shl ebx, 16
	       mov bx, 13
	       mov ecx, ADress
	       mov DWORD PTR[ecx], ebx
	       add ADress, 4

	       mov ecx, ADress
	       mov eax, DWORD PTR[ecx]
	    .if eax != 0
	       mov ebx, eax
	       shr ebx, 16
	       .if ax == 10		 ;They made a point
		 mov NumPOINT, 1
	       .endif
	     .endif

	       mov ebx, 6
	       shl ebx, 16
	       mov bx, 13
	       mov ecx, ADress
	       mov DWORD PTR[ecx], ebx
	       add ADress, 4

	       mov ecx, ADress
	       mov eax, DWORD PTR[ecx]
	    .if eax != 0
	       mov ebx, eax
	       shr ebx, 16
	       .if ax == 10		 ;They made a point
		 mov NumPOINT, 1
	       .endif
	     .endif

	       mov ebx, 7
	       shl ebx, 16
	       mov bx, 13
	       mov ecx, ADress
	       mov DWORD PTR[ecx], ebx
	       add ADress, 4

	       mov ecx, ADress
	       mov eax, DWORD PTR[ecx]
	    .if eax != 0
	       mov ebx, eax
	       shr ebx, 16
	       .if ax == 10		 ;They made a point
		 mov NumPOINT, 1
	       .else
	       mov ebx, 0
	       mov ecx, ADress
	       mov DWORD PTR[ecx], ebx
	       .endif
	     .endif

	       add ADress, 4

	       mov ecx, ADress
	       mov eax, DWORD PTR[ecx]
	    .if eax != 0
	       mov ebx, eax
	       shr ebx, 16
	       .if ax == 10		 ;They made a point
		 mov NumPOINT, 1
	       .else
	       mov ebx, 0
	       mov ecx, ADress
	       mov DWORD PTR[ecx], ebx
	       .endif
	     .endif

	       add ADress, 4

	       mov ecx, ADress
	       mov eax, DWORD PTR[ecx]
	    .if eax != 0
	       mov ebx, eax
	       shr ebx, 16
	       .if ax == 10		 ;They made a point
		 mov NumPOINT, 1
	       .else
	       mov ebx, 0
	       mov ecx, ADress
	       mov DWORD PTR[ecx], ebx
	       .endif
	     .endif




	       mov eax, 18
	       mov ebx, 1
	       mul ebx
	       add eax, 16
	       mov ecx, 4
	       mul ecx
	       mov ebx, Grid_ID
	       add eax, ebx
	       mov ADress, eax

	       mov ecx, ADress
	       mov eax, DWORD PTR[ecx]
	    .if eax != 0
	       mov ebx, eax
	       shr ebx, 16
	       .if ax == 10		 ;They made a point
		 mov NumPOINT, 1
	       .endif
	     .endif
	       mov ebx, 1
	       shl ebx, 16
	       mov bx, 34
	       mov ecx, ADress
	       mov DWORD PTR[ecx], ebx
	       sub ADress, 4

	       mov ecx, ADress
	       mov eax, DWORD PTR[ecx]
	    .if eax != 0
	       mov ebx, eax
	       shr ebx, 16
	       .if ax == 10		 ;They made a point
		 mov NumPOINT, 1
	       .endif
	     .endif

	       mov ebx, 2
	       shl ebx, 16
	       mov bx, 34
	       mov ecx, ADress
	       mov DWORD PTR[ecx], ebx
	       sub ADress, 4

	       mov ecx, ADress
	       mov eax, DWORD PTR[ecx]
	    .if eax != 0
	       mov ebx, eax
	       shr ebx, 16
	       .if ax == 10		 ;They made a point
		 mov NumPOINT, 1
	       .endif
	     .endif

	       mov ebx, 3
	       shl ebx, 16
	       mov bx, 34
	       mov ecx, ADress
	       mov DWORD PTR[ecx], ebx
	       sub ADress, 4

	       mov ecx, ADress
	       mov eax, DWORD PTR[ecx]
	    .if eax != 0
	       mov ebx, eax
	       shr ebx, 16
	       .if ax == 10		 ;They made a point
		 mov NumPOINT, 1
	       .endif
	     .endif

	       mov ebx, 4
	       shl ebx, 16
	       mov bx, 34
	       mov ecx, ADress
	       mov DWORD PTR[ecx], ebx
	       sub ADress, 4

	       mov ecx, ADress
	       mov eax, DWORD PTR[ecx]
	    .if eax != 0
	       mov ebx, eax
	       shr ebx, 16
	       .if ax == 10		 ;They made a point
		 mov NumPOINT, 1
	       .endif
	     .endif

	       mov ebx, 5
	       shl ebx, 16
	       mov bx, 34
	       mov ecx, ADress
	       mov DWORD PTR[ecx], ebx
	       sub ADress, 4

	       mov ecx, ADress
	       mov eax, DWORD PTR[ecx]
	    .if eax != 0
	       mov ebx, eax
	       shr ebx, 16
	       .if ax == 10		 ;They made a point
		 mov NumPOINT, 1
	       .endif
	     .endif

	       mov ebx, 6
	       shl ebx, 16
	       mov bx, 34
	       mov ecx, ADress
	       mov DWORD PTR[ecx], ebx
	       sub ADress, 4

	       mov ecx, ADress
	       mov eax, DWORD PTR[ecx]
	    .if eax != 0
	       mov ebx, eax
	       shr ebx, 16
	       .if ax == 10		 ;They made a point
		 mov NumPOINT, 1
	       .endif
	     .endif

	       mov ebx, 7
	       shl ebx, 16
	       mov bx, 34
	       mov ecx, ADress
	       mov DWORD PTR[ecx], ebx
	       sub ADress, 4

	       mov ecx, ADress
	       mov eax, DWORD PTR[ecx]
	    .if eax != 0
	       mov ebx, eax
	       shr ebx, 16
	       .if ax == 10		 ;They made a point
		 mov NumPOINT, 1
	       .else
	       mov ebx, 0
	       mov ecx, ADress
	       mov DWORD PTR[ecx], ebx
	       .endif
	     .endif

	       sub ADress, 4

	       mov ecx, ADress
	       mov eax, DWORD PTR[ecx]
	    .if eax != 0
	       mov ebx, eax
	       shr ebx, 16
	       .if ax == 10		 ;They made a point
		 mov NumPOINT, 1
	       .else
	       mov ebx, 0
	       mov ecx, ADress
	       mov DWORD PTR[ecx], ebx
	       .endif
	     .endif

	       sub ADress, 4

	       mov ecx, ADress
	       mov eax, DWORD PTR[ecx]
	    .if eax != 0
	       mov ebx, eax
	       shr ebx, 16
	       .if ax == 10		 ;They made a point
		 mov NumPOINT, 1
	       .else
	       mov ebx, 0
	       mov ecx, ADress
	       mov DWORD PTR[ecx], ebx
	       .endif
	     .endif
;	      .if NumPOINT != 0
 ;	invoke Get_New_Point
  ;	       .endif
mov NumPOINT, 0
return TRUE


New_MP_Grid	ENDP

Load_Game  PROC      File1:DWORD, File2:DWORD
	LOCAL	     hmemory:DWORD

	invoke CreateFile, File1, GENERIC_READ,\
		    FILE_SHARE_READ,\
		    NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL,\
		    NULL
	mov hFile, eax

	.if eax == INVALID_HANDLE_VALUE
	    jmp err
	.endif

	invoke GetFileSize, hFile, NULL

	.if eax < 936
	    jmp err
	.endif

	invoke ReadFile, hFile, Grid_ID, 936, offset SizeReadWrite, NULL

	.if eax == FALSE
	    jmp err
	.endif
	invoke CloseHandle, hFile






	invoke CreateFile, File2, GENERIC_READ,\
		    FILE_SHARE_READ,\
		    NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL,\
		    NULL
	mov hFile, eax

	.if eax == INVALID_HANDLE_VALUE
	    jmp err
	.endif

	invoke GetFileSize, hFile, NULL

	.if eax < 40
	    jmp err
	.endif

	invoke GlobalAlloc, GMEM_FIXED, eax

	mov hmemory, eax

	.if eax == 0
	    jmp err
	.endif


	invoke ReadFile, hFile, hmemory, 40, offset SizeReadWrite, NULL

	.if eax == FALSE
	    jmp err
	.endif

	mov ebx, hmemory
	m2m directionb, DWORD PTR[ebx]
	add ebx, 4
	m2m direction, DWORD PTR[ebx]
	add ebx, 4
	m2m snakelength, DWORD PTR[ebx]
	add ebx, 4
	m2m PositionX, DWORD PTR[ebx]
	add ebx, 4
	m2m PositionY, DWORD PTR[ebx]
	add ebx, 4
	m2m PositionXo, DWORD PTR[ebx]
	add ebx, 4
	m2m PositionYo, DWORD PTR[ebx]
	add ebx, 4
	m2m Points, DWORD PTR[ebx]
	add ebx, 4
	m2m Level_Points, DWORD PTR[ebx]
	add ebx, 4
	m2m UPDATE_DELAY, DWORD PTR[ebx]

	invoke CloseHandle, hFile
	invoke GlobalFree, hmemory

	return TRUE


err:
	return FALSE

Load_Game ENDP

Load_Data    PROC
	 LOCAL hmemory :DWORD
	invoke CreateFile, ADDR ssaveg, GENERIC_READ,\
		    FILE_SHARE_READ,\
		    NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL,\
		    NULL
	mov hFile, eax

	.if eax == INVALID_HANDLE_VALUE
	    jmp err
	.endif

	invoke GetFileSize, hFile, NULL

	.if eax < 20
	    jmp err
	.endif

	invoke GlobalAlloc, GMEM_FIXED, 20

	mov hmemory, eax

	.if eax == 0
	    jmp err
	.endif


	invoke ReadFile, hFile, hmemory, 20, offset SizeReadWrite, NULL

	.if eax == FALSE
	    jmp err
	.endif

	mov ebx, hmemory
	m2m Hiscore1, DWORD PTR[ebx]
	add ebx, 4
	m2m Hiscore2, DWORD PTR[ebx]
	add ebx, 4
	m2m Hiscore3, DWORD PTR[ebx]
	add ebx, 4
	m2m Hiscore4, DWORD PTR[ebx]
	add ebx, 4
	m2m Hiscore5, DWORD PTR[ebx]

	invoke CloseHandle, hFile
	invoke GlobalFree, hmemory

	return TRUE


err:
	return FALSE

Load_Data ENDP


Save_Game  PROC      File1:DWORD, File2:DWORD
	LOCAL hmemory:DWORD
	invoke CreateFile, File1, GENERIC_WRITE,\
		    FILE_SHARE_READ,\
		    NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL,\
		    NULL
	mov hFile, eax

	.if eax == INVALID_HANDLE_VALUE
	    jmp err
	.endif

	invoke GetFileSize, hFile, NULL


	invoke WriteFile, hFile, Grid_ID, 936, offset SizeReadWrite, NULL

	.if eax == FALSE
	    jmp err
	.endif
	invoke CloseHandle, hFile





	invoke CreateFile, File2, GENERIC_WRITE,\
		    FILE_SHARE_READ,\
		    NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL,\
		    NULL
	mov hFile, eax

	.if eax == INVALID_HANDLE_VALUE
	    jmp err
	.endif

	invoke GetFileSize, hFile, NULL

	.if eax == -1
	    jmp err
	.endif
	invoke GlobalAlloc, GMEM_FIXED, 40
	mov hmemory, eax

	.if eax == 0
	    jmp err
	.endif

	mov ebx, hmemory

	m2m DWORD PTR[ebx], directionb
	add ebx, 4
	m2m DWORD PTR[ebx], direction
	add ebx, 4
	m2m DWORD PTR[ebx], snakelength
	add ebx, 4
	m2m DWORD PTR[ebx], PositionX
	add ebx, 4
	m2m DWORD PTR[ebx], PositionY
	add ebx, 4
	m2m DWORD PTR[ebx], PositionXo
	add ebx, 4
	m2m DWORD PTR[ebx], PositionYo
	add ebx, 4
	m2m DWORD PTR[ebx], Points
	add ebx, 4
	m2m DWORD PTR[ebx], Level_Points
	add ebx, 4
	m2m DWORD PTR[ebx], UPDATE_DELAY



	invoke WriteFile, hFile, hmemory, 40, offset SizeReadWrite, NULL

	.if eax == FALSE
	    jmp err
	.endif
	invoke CloseHandle, hFile

	invoke GlobalFree, hmemory



	return TRUE


err:
	return FALSE

Save_Game ENDP

Save_Data PROC
	LOCAL hmemory:DWORD

	invoke CreateFile, ADDR ssaveg, GENERIC_WRITE,\
		    FILE_SHARE_READ,\
		    NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL,\
		    NULL
	mov hFile, eax

	.if eax == INVALID_HANDLE_VALUE
	    jmp err
	.endif

	invoke GetFileSize, hFile, NULL

	.if eax == -1
	    jmp err
	.endif
	invoke GlobalAlloc, GMEM_FIXED, 20
	mov hmemory, eax

	.if eax == 0
	    jmp err
	.endif

	mov ebx, hmemory

	m2m DWORD PTR[ebx], Hiscore1
	add ebx, 4
	m2m DWORD PTR[ebx], Hiscore2
	add ebx, 4
	m2m DWORD PTR[ebx], Hiscore3
	add ebx, 4
	m2m DWORD PTR[ebx], Hiscore4
	add ebx, 4
	m2m DWORD PTR[ebx], Hiscore5
	add ebx, 4



	invoke WriteFile, hFile, hmemory, 20, offset SizeReadWrite, NULL

	.if eax == FALSE
	    jmp err
	.endif
	invoke CloseHandle, hFile

	invoke GlobalFree, hmemory



	return TRUE


err:
	return FALSE

Save_Data ENDP





Draw_Captions	proc

	;=======================================================
	; This function will draw our captions, such as the
	; score and the current level they are on
	;=======================================================

	;====================
	; Local Variables
	;====================
	LOCAL	hFont		:DWORD

	;=====================================
	; Get the DC for the back buffer
	;=====================================
	invoke DD_GetDC, lpddsback
	mov	hDC, eax

	;====================================
	; Set the font to "IMPACT" at the
	; size that we need it
	;====================================
	invoke DD_Select_Font, hDC, -32, FW_BOLD, ADDR szImpact, ADDR Old_Obj
	mov	hFont, eax

	;=============================
	; Setup rect for score text
	;=============================
	mov	text_rect.top, 30
	mov	text_rect.left, 30
	mov	text_rect.right, 800
	mov	text_rect.bottom, 600

	;=============================
	; Draw the Score Text
	;=============================
	RGB 255, 255, 255
	push	eax
	mov	eax, Points
	mov	dwArgs, eax
	invoke wvsprintfA, ADDR szBuffer, ADDR szPoints, Offset dwArgs
	pop	ebx
	invoke DD_Draw_Text, hDC, ADDR szBuffer, eax, ADDR text_rect,\
		DT_LEFT, ebx


	;=============================
	; Unselect the font
	;=============================
	invoke DD_UnSelect_Font, hDC, hFont, Old_Obj

	;============================
	; Release the DC
	;============================
	invoke DD_ReleaseDC, lpddsback, hDC

done:
	;===================
	; We completed
	;===================
	return TRUE

err:
	;===================
	; We didn't make it
	;===================
	return FALSE

Draw_Captions	ENDP
Draw_MP_Score	proc

	;=======================================================
	; This function will draw our captions, such as the
	; score and the current level they are on
	;=======================================================

	;====================
	; Local Variables
	;====================
	LOCAL	hFont		:DWORD

	;=====================================
	; Get the DC for the back buffer
	;=====================================
	invoke DD_GetDC, lpddsback
	mov	hDC, eax

	;====================================
	; Set the font to "IMPACT" at the
	; size that we need it
	;====================================
	invoke DD_Select_Font, hDC, -32, FW_BOLD, ADDR szImpact, ADDR Old_Obj
	mov	hFont, eax

	;=============================
	; Setup rect for score text
	;=============================
	mov	text_rect.top, 30
	mov	text_rect.left, 30
	mov	text_rect.right, 800
	mov	text_rect.bottom, 600

	;=============================
	; Draw the Score Text
	;=============================
	RGB 255, 255, 255
	push	eax
	mov	eax, P1_Score
	mov	dwArgs, eax
	invoke wvsprintfA, ADDR szBuffer, ADDR szPoints, Offset dwArgs
	pop	ebx
	invoke DD_Draw_Text, hDC, ADDR szBuffer, eax, ADDR text_rect,\
		DT_LEFT, ebx

	;=============================
	; Setup rect for score text
	;=============================
	mov	text_rect.top, 30
	mov	text_rect.left, 0
	mov	text_rect.right, 770
	mov	text_rect.bottom, 600

	;=============================
	; Draw the Score Text
	;=============================
	RGB 255, 255, 255
	push	eax
	mov	eax, P2_Score
	mov	dwArgs, eax
	invoke wvsprintfA, ADDR szBuffer, ADDR szPoints, Offset dwArgs
	pop	ebx
	invoke DD_Draw_Text, hDC, ADDR szBuffer, eax, ADDR text_rect,\
		DT_RIGHT, ebx


	;=============================
	; Unselect the font
	;=============================
	invoke DD_UnSelect_Font, hDC, hFont, Old_Obj

	;============================
	; Release the DC
	;============================
	invoke DD_ReleaseDC, lpddsback, hDC

done:
	;===================
	; We completed
	;===================
	return TRUE

err:
	;===================
	; We didn't make it
	;===================
	return FALSE

Draw_MP_Score	ENDP

Hiscore PROC Pointes :DWORD
mov eax, Pointes
.if eax >= Hiscore1
    m2m Hiscore5, Hiscore4
    m2m Hiscore4, Hiscore3
    m2m Hiscore3, Hiscore2
    m2m Hiscore2, Hiscore1
    m2m Hiscore1, Pointes
.elseif eax >= Hiscore2
    m2m Hiscore5, Hiscore4
    m2m Hiscore4, Hiscore3
    m2m Hiscore3, Hiscore2
    m2m Hiscore2, Pointes
.elseif eax >= Hiscore3
    m2m Hiscore5, Hiscore4
    m2m Hiscore4, Hiscore3
    m2m Hiscore3, Pointes
.elseif eax >= Hiscore4
    m2m Hiscore5, Hiscore4
    m2m Hiscore4, Pointes
.elseif eax >= Hiscore5
    m2m Hiscore5, Pointes
.endif

done:
return TRUE

err:
return FALSE

Hiscore ENDP
;########################################################################
; Game_Shutdown Procedure
;########################################################################
Game_Shutdown	PROC

	;============================================================
	; This shuts our game down and frees memory we allocated
	;============================================================

	;===========================
	; Shutdown Direct Sound
	;===========================
	invoke DS_ShutDown

	;===========================
	; Shutdown Direct Input
	;===========================
	invoke DI_ShutDown

	;===========================
	; Shutdown DirectDraw
	;===========================
	invoke DD_ShutDown


	invoke Save_Data
	;==========================
	; Free the bitmap memory
	;==========================
	invoke GlobalFree, ptr_BMP_REDBACK
	invoke GlobalFree, ptr_BMP_S_hd
	invoke GlobalFree, ptr_BMP_S_hl
	invoke GlobalFree, ptr_BMP_S_hr
	invoke GlobalFree, ptr_BMP_S_hu
	invoke GlobalFree, ptr_BMP_S_ld
	invoke GlobalFree, ptr_BMP_S_lr
	invoke GlobalFree, ptr_BMP_S_lu
	invoke GlobalFree, ptr_BMP_S_rd
	invoke GlobalFree, ptr_BMP_S_ru
	invoke GlobalFree, ptr_BMP_S_td
	invoke GlobalFree, ptr_BMP_S_tl
	invoke GlobalFree, ptr_BMP_S_tr
	invoke GlobalFree, ptr_BMP_S_tu
	invoke GlobalFree, ptr_BMP_S_ud
	invoke GlobalFree, ptr_BMP_S2_hd
	invoke GlobalFree, ptr_BMP_S2_hl
	invoke GlobalFree, ptr_BMP_S2_hr
	invoke GlobalFree, ptr_BMP_S2_hu
	invoke GlobalFree, ptr_BMP_S2_ld
	invoke GlobalFree, ptr_BMP_S2_lr
	invoke GlobalFree, ptr_BMP_S2_lu
	invoke GlobalFree, ptr_BMP_S2_rd
	invoke GlobalFree, ptr_BMP_S2_ru
	invoke GlobalFree, ptr_BMP_S2_td
	invoke GlobalFree, ptr_BMP_S2_tl
	invoke GlobalFree, ptr_BMP_S2_tr
	invoke GlobalFree, ptr_BMP_S2_tu
	invoke GlobalFree, ptr_BMP_S2_ud
	invoke GlobalFree, ptr_BMP_L_1b
	invoke GlobalFree, ptr_BMP_L_2b
	invoke GlobalFree, ptr_BMP_L_3b
	invoke GlobalFree, ptr_BMP_L_4b
	invoke GlobalFree, ptr_BMP_L_5b
	invoke GlobalFree, ptr_BMP_L_6b
	invoke GlobalFree, ptr_BMP_L_7b
	invoke GlobalFree, ptr_BMP_L_8b
	invoke GlobalFree, ptr_BMP_L_9b
	invoke GlobalFree, ptr_BMP
	invoke GlobalFree, ptr_MAIN_MENU
	invoke GlobalFree, ptr_OPTION_MENU
	invoke GlobalFree, ptr_EDIT_MENU
	invoke GlobalFree, Menu_ID
	invoke GlobalFree, Music_ID
	invoke GlobalFree, SnakeMove_ID
	invoke GlobalFree, SnakeEat_ID
	invoke GlobalFree, SnakeCrash_ID



done:
	;===================
	; We completed
	;===================
	return TRUE

err:
	;===================
	; We didn't make it
	;===================
	return FALSE

Game_Shutdown	ENDP
;########################################################################
; END Game_Shutdown
;########################################################################


;######################################
; THIS IS THE END OF THE PROGRAM CODE #
;######################################
end start
