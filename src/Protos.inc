;===================================================================
; Protos.inc
;
;	This contains all of the prototypes that we need to use the
;	functions in this program.
;
;	Any procedure we define will have its prototype placed here.
;
;===================================================================

;#################################################################################
;#################################################################################
; THE PROTOTYPES
;#################################################################################
;#################################################################################

	;==================================
	; Main Program Procedures
	;==================================
	WinMain PROTO		:DWORD,:DWORD,:DWORD,:DWORD
	WndProc PROTO		:DWORD,:DWORD,:DWORD,:DWORD

	;===================================
	; Main Game procedures
	;===================================
	Game_Init PROTO
	Game_Main PROTO
	Game_Shutdown PROTO

	;=========================================
	; The DirectDraw Procedures
	;=========================================
	DD_Init PROTO		:DWORD, :DWORD, :DWORD
	DD_ShutDown PROTO
	DD_Lock_Surface PROTO	:DWORD, :DWORD
	DD_Unlock_Surface PROTO :DWORD
	DD_Create_Surface PROTO :DWORD, :DWORD, :DWORD
	DD_Flip PROTO
	DD_Fill_Surface PROTO	:DWORD, :DWORD, :DWORD, :DWORD
	DD_GetDC PROTO		:DWORD
	DD_ReleaseDC PROTO	:DWORD, :DWORD
	DD_Draw_Text PROTO	:DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
	DD_Load_Bitmap PROTO	:DWORD, :DWORD, :DWORD, :DWORD, :DWORD
	DD_Get_RGB_Format PROTO :DWORD
	DD_Select_Font PROTO	:DWORD, :DWORD, :DWORD, :DWORD, :DWORD
	DD_UnSelect_Font PROTO	:DWORD, :DWORD, :DWORD

	;========================================
	; The bitmap routines
	;========================================
	Create_From_SFP PROTO	:DWORD, :DWORD, :DWORD
	Create_From_TGA PROTO	:DWORD, :DWORD, :DWORD
	Create_From_JPG PROTO	:DWORD, :DWORD, :DWORD
	read_JPEG_file PROTO 	:DWORD, :DWORD
	Draw_Bitmap PROTO	:DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD


	;=====================================
	; Direct Input Procedures
	;=====================================
	DI_Init PROTO
	DI_ShutDown PROTO
	DI_Init_Mouse PROTO
	DI_Init_Keyboard PROTO
	DI_Read_Mouse PROTO
	DI_Read_Keyboard PROTO

	;=====================================
	; Menu Procedures
	;=====================================

	Process_Main_Menu PROTO
	Process_Option_Menu PROTO
	Process_Edit_Menu PROTO

	;========================================
	; Our Timer routines
	;========================================
	Init_Time PROTO
	Start_Time PROTO	:DWORD
	Wait_Time PROTO 	:DWORD, :DWORD
	Get_Time PROTO
	Delay_Time PROTO	:DWORD


	;=====================================
	; Direct Sound Procedures
	;=====================================
	DS_Init PROTO
	DS_ShutDown PROTO
	Play_Sound PROTO	:DWORD, :DWORD
	Set_Sound_Volume PROTO	:DWORD, :DWORD
	Set_Sound_Freq PROTO	:DWORD, :DWORD
	Set_Sound_Pan PROTO	:DWORD, :DWORD
	Stop_Sound PROTO	:DWORD
	Stop_All_Sounds PROTO
	Delete_Sound PROTO	:DWORD
	Delete_All_Sounds PROTO
	Status_Sound PROTO	:DWORD
	Load_WAV PROTO		:DWORD, :DWORD


	;======================================
	;Game Procedures
	;======================================
	Load_Grid PROTO 	:DWORD
	Calc_New_Position PROTO :DWORD, :DWORD
	Check_For_Hit PROTO	:DWORD, :DWORD
	Update_Grid PROTO
	Update_MP_Grid PROTO
	Place_New_Point PROTO
	Place_New_Point2 PROTO
	Get_New_Point	PROTO
	Draw_Grid PROTO
	Save_Grid PROTO 	:DWORD
	New_Grid PROTO
	Save_Game PROTO 	:DWORD, :DWORD
	Load_Game PROTO 	:DWORD, :DWORD
	Draw_Captions PROTO
	Draw_MP_Score PROTO
	Load_Data PROTO
	Save_Data PROTO
	Hiscore   PROTO 	:DWORD
	Process_MP_Edit_Menu	PROTO
	New_MP_Grid PROTO

