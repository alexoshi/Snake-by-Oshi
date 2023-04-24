;###########################################################################
;###########################################################################
; ABOUT Timer:
;
;	This code module contains all of the functions that relate to 
;	the timer. We use timeGetTime if the HP timer isn't available for
;	us to use to manage them.
;
;	All functions use and return millisecond values. That means that
;	so far as you are concerned they have a resolution of 1/1000 of a
;	second. Even if you use the High Performance Timer, which has a 
;	resolution far greater than this, the functions expect and convert
;	to millisecond values. In a game, I highly doubt your frame rate or 
;	anything else will need to be updated more than 1,000 times per 
;	second.
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
	; These are the Inlcude files for Window stuff
	;================================================
	include \masm32\include\windows.inc
	include \masm32\include\comctl32.inc
	include \masm32\include\comdlg32.inc
	include \masm32\include\shell32.inc
	include \masm32\include\user32.inc
	include \masm32\include\kernel32.inc
	include \masm32\include\gdi32.inc
	include \masm32\include\winmm.inc
	
	;===============================================
	; The Lib's for those included files
	;================================================
	includelib \masm32\lib\comctl32.lib
	includelib \masm32\lib\comdlg32.lib
	includelib \masm32\lib\shell32.lib
	includelib \masm32\lib\gdi32.lib
	includelib \masm32\lib\user32.lib
	includelib \masm32\lib\kernel32.lib
	includelib \masm32\lib\winmm.lib

	;=================================================
	; Include the file that has our protos
	;=================================================
	include Protos.inc

;###########################################################################
;###########################################################################
; LOCAL MACROS
;###########################################################################
;###########################################################################

	m2m MACRO M1, M2
		push		M2
		pop		M1
	ENDM

	return MACRO arg
		mov	eax, arg
		ret
	ENDM

;#################################################################################
; The DATA Section
;#################################################################################
;#################################################################################

  .data
	
	;=============================
	; Is the HP timer available
	;=============================
	UseHP		db 0

	;===============================
	; A 64-bit var for calls to
	; the HP timer if we can use it
	;
	; NOTE: This is 2, 32-bit 
	; variables in a row to form
	; a 64-bit variable
	;===============================
	HPTimerVar	dd 2 dup (0)

	;====================================
	; A 32-bit var to hold the HP
	; timer frequency and ticks per MS
	;====================================
	HPTimerFreq	dd 0
	HPTicksPerMS	dd 0
	
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

;#################################################################################
;#################################################################################
; BEGIN THE CODE SECTION
;#################################################################################
;#################################################################################

  .code

;########################################################################
; Init_Time Procedure
;########################################################################
Init_Time	proc	

	;=======================================================
	; This function will find out if we can use the HP timer
	; and will set the needed vars to use it
	;=======================================================

	;=============================================
	; Get the timer Frequency, at least try to.
	;=============================================
	invoke QueryPerformanceFrequency, ADDR HPTimerVar

	.if eax == FALSE
		;===================
		; Set to use no HP
		;====================
		mov	UseHP, FALSE
		jmp	done

	.endif

	;========================================
	; We can use it so set the Var and Freq
	;========================================
	mov	UseHP, TRUE
	mov	eax, HPTimerVar
	mov	HPTimerFreq, eax
	mov	ecx, 1000
	xor	edx, edx
	div	ecx
	mov	HPTicksPerMS, eax

done:
	;===================
	; We completed
	;===================
	return TRUE

Init_Time	ENDP
;########################################################################
; END Init_Time
;########################################################################

;########################################################################
; Start_Time Procedure
;########################################################################
Start_Time	proc	ptr_time_var:DWORD

	;=======================================================
	; This function will start our timer going and store
	; the value in	a variable that you pass it the ADDR of
	;=======================================================

	;========================================
	; Are we using the Highperformance timer
	;========================================
	.if UseHP == TRUE
		;==================================
		; Yes. We are using the HP timer
		;==================================
		invoke QueryPerformanceCounter, ADDR HPTimerVar
		mov	eax, HPTimerVar
		mov	ebx, ptr_time_var
		mov	DWORD PTR [ebx], eax

	.else
		;==================================
		; No. Use timeGetTime instead.
		;==================================

		;==================================
		; Get our starting time
		;==================================
		invoke timeGetTime

		;=================================
		; Set our variable
		;=================================
		mov	ebx, ptr_time_var
		mov	DWORD PTR [ebx], eax
	
	.endif

done:
	;===================
	; We completed
	;===================
	return TRUE

Start_Time	ENDP
;########################################################################
; END Start_Time
;########################################################################

;########################################################################
; Wait_Time Procedure
;########################################################################
Wait_Time	proc	time_var:DWORD, time:DWORD

	;=========================================================
	; This function will wait for the passed time in MS based
	; on the distance from the passed start time. It returns 
	; time it took the loop to complete in MS
	;=========================================================
	
	;========================================
	; Are we using the Highperformance timer
	;========================================
	.if UseHP == TRUE
		;==================================
		; Yes. We are using the HP timer
		;==================================
	
		;==================================
		; Adjust time for frequency
		;==================================
		mov	eax, 1000
		mov	ecx, time
		xor	edx, edx
		div	ecx
		mov	ecx, eax
		mov	eax, HPTimerFreq
		xor	edx, edx
		div	ecx
		mov	time, eax

		;================================
		; A push so we can pop evenly
		;================================
		push	eax

	again1:
		;================================
		; Pop last time or misc push off
		;================================
		pop	eax

		;======================================
		; Get the current time
		;======================================
		invoke QueryPerformanceCounter, ADDR HPTimerVar
		mov	eax, HPTimerVar

		;======================================
		; Subtract from start time
		;======================================
		mov	ecx, time_var
		mov	ebx, time
		sub	eax, ecx

		;======================================
		; Save how long it took
		;======================================
		push	eax

		;======================================
		; Go up and do it again if we were not
		; yet to zero or less than the time
		;======================================
		sub	eax, ebx
		jle	again1

		;========================================
		; Pop the final time off of the stack
		;========================================
		pop	eax

		;========================================
		; Adjust it to MS
		;========================================
		mov	ecx, HPTicksPerMS
		xor	edx, edx
		div	ecx

	.else
		;==================================
		; No. Use timeGetTime instead.
		;==================================

		;================================
		; A push so we can pop evenly
		;================================
		push	eax

	again:
		;================================
		; Pop last time or misc push off
		;================================
		pop	eax

		;======================================
		; Get the current time
		;======================================
		invoke timeGetTime

		;======================================
		; Subtract from start time
		;======================================
		mov	ecx, time_var
		mov	ebx, time
		sub	eax, ecx

		;======================================
		; Save how long it took
		;======================================
		push	eax

		;======================================
		; Go up and do it again if we were not
		; yet to zero or less than the time
		;======================================
		sub	eax, ebx
		jle	again
	
		;========================================
		; Pop the final time off of the stack
		;========================================
		pop	eax

	.endif

	;=======================
	; return from here
	;=======================
	ret	

Wait_Time	ENDP
;########################################################################
; END Wait_Time
;########################################################################

;########################################################################
; Get_Time Procedure
;########################################################################
Get_Time	proc	

	;===========================================================
	; This function will simply retrieve the time and return it
	;===========================================================

	;========================================
	; Are we using the Highperformance timer
	;========================================
	.if UseHP == TRUE
		;==================================
		; Yes. We are using the HP timer
		;==================================
		invoke QueryPerformanceCounter, ADDR HPTimerVar
		mov	eax, HPTimerVar
		mov	ecx, HPTicksPerMS
		xor	edx, edx
		div	ecx
		
	.else
		;==================================
		; No. Use timeGetTime instead.
		;==================================
		invoke timeGetTime
	
	.endif

	;===================
	; Return it
	;===================
	return eax

Get_Time	ENDP
;########################################################################
; END Get_Time
;########################################################################

;########################################################################
; Delay_Time Procedure
;########################################################################
Delay_Time	proc	wait_time:DWORD

	;===========================================================
	; This function will delay for the given amount of time
	;===========================================================

	;========================================
	; Local variable to hold starting time
	;========================================
	LOCAL	start_time	:DWORD

	;========================================
	; Are we using the Highperformance timer
	;========================================
	.if UseHP == TRUE
		;==================================
		; Yes. We are using the HP timer
		;==================================
		invoke QueryPerformanceCounter, ADDR HPTimerVar
		mov	eax, HPTimerVar
		mov	start_time, eax

		;=======================================
		; Now adjust the time we need to wait
		;=======================================
		mov	eax, 1000
		mov	ecx, wait_time
		xor	edx, edx
		div	ecx
		mov	ecx, eax
		mov	eax, HPTimerFreq
		xor	edx, edx
		div	ecx
		mov	wait_time, eax

	again1:
		;======================================
		; Get the current time
		;======================================
		invoke QueryPerformanceCounter, ADDR HPTimerVar
		mov	eax, HPTimerVar

		;======================================
		; Subtract from start time
		;======================================
		mov	ecx, start_time
		mov	ebx, wait_time
		sub	eax, ecx

		;======================================
		; Go up and do it again if we were not
		; yet to zero or less than the time
		;======================================
		sub	eax, ebx
		jle	again1

	.else
		;==================================
		; No. Use timeGetTime instead.
		;==================================
		invoke timeGetTime
		mov	start_time, eax
	again:
		;======================================
		; Get the current time
		;======================================
		invoke timeGetTime

		;======================================
		; Subtract from start time
		;======================================
		mov	ecx, start_time
		mov	ebx, wait_time
		sub	eax, ecx

		;======================================
		; Go up and do it again if we were not
		; yet to zero or less than the time
		;======================================
		sub	eax, ebx
		jle	again

	.endif

	;===================
	; Return good
	;===================
	return TRUE

Delay_Time	ENDP
;########################################################################
; END Delay_Time
;########################################################################

;######################################
; THIS IS THE END OF THE PROGRAM CODE #
;######################################
end 

