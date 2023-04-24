;===================================================================
;===================================================================
; DINPUT include file
;
;	Author: Chris Hobbs
;		Lightning Software
;		Http://www.fastsoftware.com
;
;===================================================================
;===================================================================

;======================================
; The DI version we support
;======================================
DIRECTINPUT_VERSION	equ	0500h

;======================================
; The GUID Definition
;======================================
GUID	STRUC
    Data1	dd 0
    Data2	dw 0
    Data3	dw 0
    Data4	db 8 dup(0)
GUID	ENDS

;======================================
; The MAKE_HRESULT MACRO
;======================================
MAKE_HRESULT MACRO hres_name,severity,facility,code

	hres_name = (severity SHL 31) OR ((facility AND 0FFFh) SHL 16) OR (code AND 0FFFFh)
ENDM

;=========================================
; The std method calling convention
;=========================================
STDMETHOD	MACRO	name, argl :VARARG
	LOCAL @tmp_a
	LOCAL @tmp_b

	@tmp_a	TYPEDEF PROTO argl
	@tmp_b	TYPEDEF PTR @tmp_a
	name		@tmp_b		?
ENDM

;=========================================
; This will set the struct to zero
;=========================================
DIINITSTRUCT	MACRO	arg1, arg2
	invoke RtlFillMemory, arg1, arg2, 0
ENDM

;=========================================
; A Macro for invoking DInput stuff
;=========================================
DIINVOKE	MACRO	func, this, arglist :VARARG
	mov	eax , [this]
	mov	eax , [eax]

	IFB <arglist>
		INVOKE [IDirectInputVtbl. func][eax], this
	ELSE
		INVOKE [IDirectInputVtbl. func][eax], this, arglist
	ENDIF
ENDM

;=========================================
; A Macro for invoking input device stuff 
; for versions 1 and 2
;=========================================
DIDEVINVOKE	MACRO	func, this, arglist :VARARG
	mov	eax , [this]
	mov	eax , [eax]

	IFB <arglist>
		INVOKE [IDirectInputDeviceVtbl. func][eax], this
	ELSE
		INVOKE [IDirectInputDeviceVtbl. func][eax], this, arglist
	ENDIF
ENDM

DIDEV2INVOKE	MACRO	func, this, arglist :VARARG
	mov	eax , [this]
	mov	eax , [eax]

	IFB <arglist>
		INVOKE [IDirectInputDevice2Vtbl. func][eax], this
	ELSE
		INVOKE [IDirectInputDevice2Vtbl. func][eax], this, arglist
	ENDIF
ENDM

;=========================================
; The main prototypes
;=========================================
DirectInputCreateA PROTO :DWORD,:DWORD,:DWORD,:DWORD
DirectInputCreate equ <DirectInputCreateA>

;========================================
; The GUIDS that need to be defined
;========================================
EXTERNDEF	C CLSID_DirectInput:GUID
EXTERNDEF	C CLSID_DirectInputDevice:GUID

;/****************************************************************************
; *
; *      Interfaces
; *
; ****************************************************************************/

EXTERNDEF	C IID_IDirectInput:GUID
EXTERNDEF	C IID_IDirectInput2:GUID
EXTERNDEF	C IID_IDirectInputDevice:GUID
EXTERNDEF	C IID_IDirectInputDevice2A:GUID
IID_IDirectInputDevice2 equ <IID_IDirectInputDevice2A	>
EXTERNDEF	C IID_IDirectInputEffect:GUID

;/****************************************************************************
; *
; *      Predefined object types
; *
; ****************************************************************************/

EXTERNDEF	C GUID_XAxis:GUID
EXTERNDEF	C GUID_YAxis:GUID
EXTERNDEF	C GUID_ZAxis:GUID
EXTERNDEF	C GUID_RxAxis:GUID
EXTERNDEF	C GUID_RyAxis:GUID
EXTERNDEF	C GUID_RzAxis:GUID
EXTERNDEF	C GUID_Slider:GUID

EXTERNDEF	C GUID_Button:GUID
EXTERNDEF	C GUID_Key:GUID

EXTERNDEF	C GUID_POV:GUID

EXTERNDEF	C GUID_Unknown:GUID

;/****************************************************************************
; *
; *      Predefined product GUIDs
; *
; ****************************************************************************/

EXTERNDEF	C GUID_SysMouse:GUID
EXTERNDEF	C GUID_SysKeyboard:GUID
EXTERNDEF	C GUID_Joystick:GUID

;/****************************************************************************
; *
; *      Predefined force feedback effects
; *
; ****************************************************************************/

EXTERNDEF	C GUID_ConstantForce:GUID
EXTERNDEF	C GUID_RampForce:GUID
EXTERNDEF	C GUID_Square:GUID
EXTERNDEF	C GUID_Sine:GUID
EXTERNDEF	C GUID_Triangle:GUID
EXTERNDEF	C GUID_SawtoothUp:GUID
EXTERNDEF	C GUID_SawtoothDown:GUID
EXTERNDEF	C GUID_Spring:GUID
EXTERNDEF	C GUID_Damper:GUID
EXTERNDEF	C GUID_Inertia:GUID
EXTERNDEF	C GUID_Friction:GUID
EXTERNDEF	C GUID_CustomForce:GUID


;========================================
; just some defines
;========================================
DIEFT_ALL			EQU		000000000h
DIEFT_CONSTANTFORCE		EQU		000000001h
DIEFT_RAMPFORCE			EQU		000000002h
DIEFT_PERIODIC			EQU		000000003h
DIEFT_CONDITION			EQU		000000004h
DIEFT_CUSTOMFORCE		EQU		000000005h
DIEFT_HARDWARE			EQU		0000000ffh
DIEFT_FFATTACK			EQU		000000200h
DIEFT_FFFADE			EQU		000000400h
DIEFT_SATURATION		EQU		000000800h
DIEFT_POSNEGCOEFFICIENTS	EQU		000001000h
DIEFT_POSNEGSATURATION		EQU		000002000h
DIEFT_DEADBAND			EQU		000004000h
DI_DEGREES			EQU		100t
DI_FFNOMINALMAX			EQU		10000t
DI_SECONDS			EQU		1000000t


DICONSTANTFORCE		STRUCT
lMagnitude		DWORD		?
DICONSTANTFORCE		ENDS

LPDICONSTANTFORCE		TYPEDEF		PTR DICONSTANTFORCE
LPCDICONSTANTFORCE		TYPEDEF		PTR DICONSTANTFORCE


DIRAMPFORCE		STRUCT
lStart		DWORD		?
lEnd		DWORD		?
DIRAMPFORCE		ENDS


LPDIRAMPFORCE		TYPEDEF		PTR DIRAMPFORCE
LPCDIRAMPFORCE		TYPEDEF		PTR DIRAMPFORCE


DIPERIODIC		STRUCT
dwMagnitude		DWORD		?
lOffset			DWORD		?
dwPhase			DWORD		?
dwPeriod		DWORD		?
DIPERIODIC		ENDS

LPDIPERIODIC		TYPEDEF		PTR DIPERIODIC
LPCDIPERIODIC		TYPEDEF		PTR DIPERIODIC


DICONDITION		STRUCT
lOffset				DWORD		?
lPositiveCoefficient		DWORD		?
lNegativeCoefficient		DWORD		?
dwPositiveSaturation		DWORD		?
dwNegativeSaturation		DWORD		?
lDeadBand			DWORD		?
DICONDITION		ENDS

LPDICONDITION		TYPEDEF		PTR DICONDITION
LPCDICONDITION		TYPEDEF		PTR DICONDITION


DICUSTOMFORCE		STRUCT
cChannels		DWORD		?
dwSamplePeriod		DWORD		?
cSamples		DWORD		?
rglForceData		DWORD		?
DICUSTOMFORCE		ENDS

LPDICUSTOMFORCE		TYPEDEF		PTR DICUSTOMFORCE
LPCDICUSTOMFORCE	TYPEDEF		PTR DICUSTOMFORCE


DIENVELOPE		STRUCT
dwSize			DWORD		?
dwAttackLevel		DWORD		?
dwAttackTime		DWORD		?
dwFadeLevel		DWORD		?
dwFadeTime		DWORD		?
DIENVELOPE		ENDS

LPDIENVELOPE		TYPEDEF		PTR DIENVELOPE
LPCDIENVELOPE		TYPEDEF		PTR DIENVELOPE



DIEFFECT		STRUCT
dwSize				DWORD		?
dwFlags				DWORD		?
dwDuration			DWORD		?
dwSamplePeriod			DWORD		?
dwGain				DWORD		?
dwTriggerButton			DWORD		?
dwTriggerRepeatInterval		DWORD		?
cAxes				DWORD		?
rgdwAxes			DWORD		?
rglDirection			DWORD		?
lpEnvelope			LPDIENVELOPE	?
cbTypeSpecificParams		DWORD		?
lpvTypeSpecificParams		DWORD		?
DIEFFECT		ENDS

LPDIEFFECT		TYPEDEF		PTR DIEFFECT
LPCDIEFFECT		TYPEDEF		PTR DIEFFECT

DIEFF_OBJECTIDS			EQU		000000001h
DIEFF_OBJECTOFFSETS		EQU		000000002h
DIEFF_CARTESIAN			EQU		000000010h
DIEFF_POLAR			EQU		000000020h
DIEFF_SPHERICAL			EQU		000000040h
DIEP_DURATION			EQU		000000001h
DIEP_SAMPLEPERIOD		EQU		000000002h
DIEP_GAIN			EQU		000000004h
DIEP_TRIGGERBUTTON		EQU		000000008h
DIEP_TRIGGERREPEATINTERVAL	EQU		000000010h
DIEP_AXES			EQU		000000020h
DIEP_DIRECTION			EQU		000000040h
DIEP_ENVELOPE			EQU		000000080h
DIEP_TYPESPECIFICPARAMS		EQU		000000100h
DIEP_ALLPARAMS			EQU		0000001ffh
DIEP_START			EQU		020000000h
DIEP_NORESTART			EQU		040000000h
DIEP_NODOWNLOAD			EQU		080000000h
DIEB_NOTRIGGER			EQU		0ffffffffh
DIES_SOLO			EQU		000000001h
DIES_NODOWNLOAD			EQU		080000000h
DIEGES_PLAYING			EQU		000000001h
DIEGES_EMULATED			EQU		000000002h

DIEFFESCAPE		STRUCT
dwSize			DWORD		?
dwCommand		DWORD		?
lpvInBuffer		DWORD		?
cbInBuffer		DWORD		?
lpvOutBuffer		DWORD		?
cbOutBuffer		DWORD		?
DIEFFESCAPE		ENDS

LPDIEFFESCAPE		TYPEDEF		PTR DIEFFESCAPE

;****************************************************************************
;*
;*      IDirectInputDevice
;*
;****************************************************************************

DIDEVTYPE_DEVICE		EQU		1
DIDEVTYPE_MOUSE			EQU		2
DIDEVTYPE_KEYBOARD		EQU		3
DIDEVTYPE_JOYSTICK		EQU		4
DIDEVTYPE_HID			EQU		000010000h
DIDEVTYPEMOUSE_UNKNOWN		EQU		1
DIDEVTYPEMOUSE_TRADITIONAL	EQU		2
DIDEVTYPEMOUSE_FINGERSTICK	EQU		3
DIDEVTYPEMOUSE_TOUCHPAD		EQU		4
DIDEVTYPEMOUSE_TRACKBALL	EQU		5
DIDEVTYPEKEYBOARD_UNKNOWN	EQU		0
DIDEVTYPEKEYBOARD_PCXT		EQU		1
DIDEVTYPEKEYBOARD_OLIVETTI	EQU		2
DIDEVTYPEKEYBOARD_PCAT		EQU		3
DIDEVTYPEKEYBOARD_PCENH		EQU		4
DIDEVTYPEKEYBOARD_NOKIA1050	EQU		5
DIDEVTYPEKEYBOARD_NOKIA9140	EQU		6
DIDEVTYPEKEYBOARD_NEC98		EQU		7
DIDEVTYPEKEYBOARD_NEC98LAPTOP	EQU		8
DIDEVTYPEKEYBOARD_NEC98106	EQU		9
DIDEVTYPEKEYBOARD_JAPAN106	EQU		10t
DIDEVTYPEKEYBOARD_JAPANAX	EQU		11t
DIDEVTYPEKEYBOARD_J3100		EQU		12t
DIDEVTYPEJOYSTICK_UNKNOWN	EQU		1
DIDEVTYPEJOYSTICK_TRADITIONAL	EQU		2
DIDEVTYPEJOYSTICK_FLIGHTSTICK	EQU		3
DIDEVTYPEJOYSTICK_GAMEPAD	EQU		4
DIDEVTYPEJOYSTICK_RUDDER	EQU		5
DIDEVTYPEJOYSTICK_WHEEL		EQU		6
DIDEVTYPEJOYSTICK_HEADTRACKER	EQU		7


GET_DIDEVICE_TYPE MACRO reg,dwDevType      ;;    LOBYTE(dwDevType)
 mov reg,dwDevType
 and reg,0FFh
ENDM

GET_DIDEVICE_SUBTYPE MACRO reg,dwDevType   ;; HIBYTE(dwDevType)
 mov reg,dwDevType
 shr reg,8
 and reg,0FFh
ENDM


;/* This structure is defined for DirectX 3.0 compatibility */
DIDEVCAPS_DX3	STRUCT
dwSize		DWORD		?
dwFlags		DWORD		?
dwDevType	DWORD		?
dwAxes		DWORD		?
dwButtons	DWORD		?
dwPOVs		DWORD		?
DIDEVCAPS_DX3	ENDS

LPDIDEVCAPS_DX3	TYPEDEF	PTR DIDEVCAPS_DX3

DIDEVCAPS	STRUCT
dwSize		DWORD		?
dwFlags		DWORD		?
dwDevType	DWORD		?
dwAxes		DWORD		?
dwButtons	DWORD		?
dwPOVs		DWORD		?
DIDEVCAPS	ENDS

LPDIDEVCAPS		TYPEDEF		PTR DIDEVCAPS



DIDC_ATTACHED		EQU		000000001h
DIDC_POLLEDDEVICE	EQU		000000002h
DIDC_EMULATED		EQU		000000004h
DIDC_POLLEDDATAFORMAT	EQU		000000008h
DIDC_FORCEFEEDBACK	EQU		000000100h
DIDC_FFATTACK		EQU		000000200h
DIDC_FFFADE		EQU		000000400h
DIDC_SATURATION		EQU		000000800h
DIDC_POSNEGCOEFFICIENTS	EQU		000001000h
DIDC_POSNEGSATURATION	EQU		000002000h
DIDC_DEADBAND		EQU		000004000h
DIDFT_ALL		EQU		000000000h
DIDFT_RELAXIS		EQU		000000001h
DIDFT_ABSAXIS		EQU		000000002h
DIDFT_AXIS		EQU		000000003h
DIDFT_PSHBUTTON		EQU		000000004h
DIDFT_TGLBUTTON		EQU		000000008h
DIDFT_BUTTON		EQU		00000000ch
DIDFT_POV		EQU		000000010h
DIDFT_COLLECTION	EQU		000000040h
DIDFT_NODATA		EQU		000000080h
DIDFT_ANYINSTANCE	EQU		000ffff00h
DIDFT_INSTANCEMASK	EQU		000ffff00h
DIDFT_FFACTUATOR	EQU		001000000h
DIDFT_FFEFFECTTRIGGER	EQU		002000000h
DIDFT_NOCOLLECTION	EQU		000ffff00h

DIDFT_MAKEINSTANCE MACRO reg,n  ;; ((WORD)(n) << 8)
 mov reg,n
 and reg,0FFFFh
 shl reg,8
ENDM

DIDFT_GETTYPE MACRO reg,n    ;; LOBYTE(n)
 mov reg,n
 and eax,0FFh
ENDM

DIDFT_GETINSTANCE MACRO reg,n       ;; LOWORD((n) >> 8)
 mov reg,n
 and reg,0FFFFh
 shr reg,8
ENDM

DIDFT_ENUMCOLLECTION MACRO reg,n  ;; ((WORD)(n) << 8)
 mov reg,n
 and reg,0FFFFh
 shl reg,8
ENDM



_DIOBJECTDATAFORMAT		STRUCT
pguid		DWORD		?
dwOfs		DWORD		?
dwType		DWORD		?
dwFlags		DWORD		?
_DIOBJECTDATAFORMAT		ENDS

DIOBJECTDATAFORMAT		TYPEDEF		_DIOBJECTDATAFORMAT
LPDIOBJECTDATAFORMAT		TYPEDEF		PTR _DIOBJECTDATAFORMAT
LPCDIOBJECTDATAFORMAT		TYPEDEF		PTR _DIOBJECTDATAFORMAT

_DIDATAFORMAT	STRUCT
dwSize		DWORD		?
dwObjSize	DWORD		?
dwFlags		DWORD		?
dwDataSize	DWORD		?
dwNumObjs	DWORD		?
rgodf		LPDIOBJECTDATAFORMAT		?
_DIDATAFORMAT	ENDS

DIDATAFORMAT		TYPEDEF		_DIDATAFORMAT
LPDIDATAFORMAT		TYPEDEF		PTR _DIDATAFORMAT
LPCDIDATAFORMAT		TYPEDEF		PTR _DIDATAFORMAT

DIDF_ABSAXIS		EQU		000000001h
DIDF_RELAXIS		EQU		000000002h

EXTERNDEF	C c_dfDIMouse:_DIDATAFORMAT
EXTERNDEF	C c_dfDIKeyboard:_DIDATAFORMAT
EXTERNDEF	C c_dfDIJoystick:_DIDATAFORMAT
EXTERNDEF	C c_dfDIJoystick2:_DIDATAFORMAT

;Ansi
DIDEVICEOBJECTINSTANCE_DX3A	STRUCT
dwSize		DWORD		?
guidType	GUID		<>
dwOfs		DWORD		?
dwType		DWORD		?
dwFlags		DWORD		?
tszName         BYTE  MAX_PATH dup (?)
DIDEVICEOBJECTINSTANCE_DX3A		ENDS

LPDIDEVICEOBJECTINSTANCE_DX3A		TYPEDEF		PTR DIDEVICEOBJECTINSTANCE_DX3A

;Unicode
DIDEVICEOBJECTINSTANCE_DX3W	STRUCT
dwSize		DWORD		?
guidType	GUID		<>
dwOfs		DWORD		?
dwType		DWORD		?
dwFlags		DWORD		?
tszName         BYTE  MAX_PATH dup (?)
DIDEVICEOBJECTINSTANCE_DX3W		ENDS

LPDIDEVICEOBJECTINSTANCE_DX3W		TYPEDEF		PTR DIDEVICEOBJECTINSTANCE_DX3W


; Ansi
DIDEVICEOBJECTINSTANCEA	STRUCT
dwSize			DWORD		?
guidType		GUID		<>
dwOfs			DWORD		?
dwType			DWORD		?
dwFlags			DWORD		?
tszName 	        BYTE  MAX_PATH dup (?)
; for DIRECTINPUT_VERSION >= 0x0500
dwFFMaxForce		DWORD		?
dwFFForceResolution	DWORD		?
wCollectionNumber	WORD		?
wDesignatorIndex	WORD		?
wUsagePage		WORD		?
wUsage			WORD		?
dwDimension		DWORD		?
wExponent		WORD		?
wReserved		WORD		?
DIDEVICEOBJECTINSTANCEA	ENDS

LPDIDEVICEOBJECTINSTANCEA	TYPEDEF		PTR DIDEVICEOBJECTINSTANCEA

; Unicode
DIDEVICEOBJECTINSTANCEW	STRUCT
dwSize			DWORD		?
guidType		GUID		<>
dwOfs			DWORD		?
dwType			DWORD		?
dwFlags			DWORD		?
tszName         	BYTE  MAX_PATH dup (?)
; for DIRECTINPUT_VERSION >= 0x0500
dwFFMaxForce		DWORD		?
dwFFForceResolution	DWORD		?
wCollectionNumber	WORD		?
wDesignatorIndex	WORD		?
wUsagePage		WORD		?
wUsage			WORD		?
dwDimension		DWORD		?
wExponent		WORD		?
wReserved		WORD		?
DIDEVICEOBJECTINSTANCEW	ENDS

LPDIDEVICEOBJECTINSTANCEW		TYPEDEF		PTR DIDEVICEOBJECTINSTANCEW


DIDOI_FFACTUATOR		EQU		000000001h
DIDOI_FFEFFECTTRIGGER		EQU		000000002h
DIDOI_POLLED			EQU		000008000h
DIDOI_ASPECTPOSITION		EQU		000000100h
DIDOI_ASPECTVELOCITY		EQU		000000200h
DIDOI_ASPECTACCEL		EQU		000000300h
DIDOI_ASPECTFORCE		EQU		000000400h
DIDOI_ASPECTMASK		EQU		000000f00h


DIPROPHEADER	STRUCT
dwSize		DWORD		?
dwHeaderSize	DWORD		?
dwObj		DWORD		?
dwHow		DWORD		?
DIPROPHEADER	ENDS

LPDIPROPHEADER		TYPEDEF		PTR DIPROPHEADER
LPCDIPROPHEADER		TYPEDEF		PTR DIPROPHEADER


DIPH_DEVICE		EQU		0
DIPH_BYOFFSET		EQU		1
DIPH_BYID		EQU		2

DIPROPDWORD	STRUCT
diph		DIPROPHEADER	<>
dwData		DWORD		?
DIPROPDWORD	ENDS

LPDIPROPDWORD		TYPEDEF		PTR DIPROPDWORD
LPCDIPROPDWORD		TYPEDEF		PTR DIPROPDWORD

DIPROPRANGE	STRUCT
diph		DIPROPHEADER	<>
lMin		DWORD		?
lMax		DWORD		?
DIPROPRANGE	ENDS

LPDIPROPRANGE		TYPEDEF		PTR DIPROPRANGE
LPCDIPROPRANGE		TYPEDEF		PTR DIPROPRANGE

DIPROPRANGE_NOMIN   EQU 80000000h
DIPROPRANGE_NOMAX   EQU 7FFFFFFFh


; Predefined properties for Get/Set Property methods, which are used instead of GUID ptr
DIPROP_BUFFERSIZE  EQU 1

DIPROP_AXISMODE    EQU 2

DIPROPAXISMODE_ABS EQU 0
DIPROPAXISMODE_REL EQU 1

DIPROP_GRANULARITY EQU 3

DIPROP_RANGE       EQU 4

DIPROP_DEADZONE    EQU 5

DIPROP_SATURATION  EQU 6

DIPROP_FFGAIN      EQU 7

DIPROP_FFLOAD      EQU 8

DIPROP_AUTOCENTER  EQU 9

DIPROPAUTOCENTER_OFF  EQU 0
DIPROPAUTOCENTER_ON   EQU 1

DIPROP_CALIBRATIONMODE  EQU 10

DIPROPCALIBRATIONMODE_COOKED  EQU  0
DIPROPCALIBRATIONMODE_RAW     EQU  1



DIDEVICEOBJECTDATA	STRUCT
dwOfs		DWORD		?
dwData		DWORD		?
dwTimeStamp	DWORD		?
dwSequence	DWORD		?
DIDEVICEOBJECTDATA	ENDS

LPDIDEVICEOBJECTDATA	TYPEDEF		PTR DIDEVICEOBJECTDATA

LPCDIDEVICEOBJECTDATA	TYPEDEF		PTR DIDEVICEOBJECTDATA

DISEQUENCE_COMPARE MACRO reg, dwSequence1, dwSequence2
 mov reg,dwSequence1
 sub reg,dwSequence2
 test reg,reg
ENDM


DIGDD_PEEK		EQU		000000001h
DISCL_EXCLUSIVE		EQU		000000001h
DISCL_NONEXCLUSIVE	EQU		000000002h
DISCL_FOREGROUND	EQU		000000004h
DISCL_BACKGROUND	EQU		000000008h


DIDEVICEINSTANCE_DX3A	STRUCT
dwSize		DWORD		?
guidInstance	GUID		<>
guidProduct	GUID		<>
dwDevType	DWORD		?
tszInstanceName BYTE MAX_PATH dup (?)
tszProductName  BYTE MAX_PATH dup (?)
DIDEVICEINSTANCE_DX3A	ENDS

LPDIDEVICEINSTANCE_DX3A		TYPEDEF		PTR DIDEVICEINSTANCE_DX3A

DIDEVICEINSTANCE_DX3W	STRUCT
dwSize			DWORD		?
guidInstance		GUID		<>
guidProduct		GUID		<>
dwDevType		DWORD		?
tszInstanceName 	BYTE MAX_PATH dup (?)
tszProductName  	BYTE MAX_PATH dup (?)
DIDEVICEINSTANCE_DX3W	ENDS

LPDIDEVICEINSTANCE_DX3W		TYPEDEF		PTR DIDEVICEINSTANCE_DX3W

DIDEVICEINSTANCEA	STRUCT
dwSize			DWORD		?
guidInstance		GUID		<>
guidProduct		GUID		<>
dwDevType		DWORD		?
tszInstanceName 	BYTE MAX_PATH dup (?)
tszProductName  	BYTE MAX_PATH dup (?)
; New for version 5
guidFFDriver		GUID		<>
wUsagePage		WORD		?
wUsage			WORD		?
DIDEVICEINSTANCEA	ENDS

LPDIDEVICEINSTANCEA		TYPEDEF		PTR DIDEVICEINSTANCEA

DIDEVICEINSTANCEW	STRUCT
dwSize			DWORD		?
guidInstance		GUID		<>
guidProduct		GUID		<>
dwDevType		DWORD		?
tszInstanceName 	BYTE MAX_PATH dup (?)
tszProductName  	BYTE MAX_PATH dup (?)
; New for version 5
guidFFDriver		GUID		<>
wUsagePage		WORD		?
wUsage			WORD		?
DIDEVICEINSTANCEW		ENDS

LPDIDEVICEINSTANCEW		TYPEDEF		PTR DIDEVICEINSTANCEW

LPDIRECTINPUTDEVICEA typedef PTR
LPDIRECTINPUTDEVICE EQU <LPDIRECTINPUTDEVICEA>


DISFFC_RESET		EQU		000000001h
DISFFC_STOPALL		EQU		000000002h
DISFFC_PAUSE		EQU		000000004h
DISFFC_CONTINUE		EQU		000000008h
DISFFC_SETACTUATORSON	EQU		000000010h
DISFFC_SETACTUATORSOFF	EQU		000000020h
DIGFFS_EMPTY		EQU		000000001h
DIGFFS_STOPPED		EQU		000000002h
DIGFFS_PAUSED		EQU		000000004h
DIGFFS_ACTUATORSON	EQU		000000010h
DIGFFS_ACTUATORSOFF	EQU		000000020h
DIGFFS_POWERON		EQU		000000040h
DIGFFS_POWEROFF		EQU		000000080h
DIGFFS_SAFETYSWITCHON	EQU		000000100h
DIGFFS_SAFETYSWITCHOFF	EQU		000000200h
DIGFFS_USERFFSWITCHON	EQU		000000400h
DIGFFS_USERFFSWITCHOFF	EQU		000000800h
DIGFFS_DEVICELOST	EQU		080000000h

; Ansi
DIEFFECTINFOA	STRUCT
dwSize		DWORD		?
guid		GUID		<>
dwEffType	DWORD		?
dwStaticParams	DWORD		?
dwDynamicParams	DWORD		?
tszName		BYTE MAX_PATH dup (?)
DIEFFECTINFOA	ENDS

LPDIEFFECTINFOA		TYPEDEF		PTR DIEFFECTINFOA

; Unicode
DIEFFECTINFOW	STRUCT
dwSize		DWORD		?
guid		GUID		<>
dwEffType	DWORD		?
dwStaticParams	DWORD		?
dwDynamicParams	DWORD		?
tszName		BYTE MAX_PATH dup (?)
DIEFFECTINFOW	ENDS

LPDIEFFECTINFOW		TYPEDEF		PTR DIEFFECTINFOW

LPDIRECTINPUTDEVICE2A typedef PTR
LPDIRECTINPUTDEVICE2 EQU <LPDIRECTINPUTDEVICE2A>



_DIMOUSESTATE	STRUCT
lX		DWORD		?
lY		DWORD		?
lZ		DWORD		?
rgbButtons	BYTE		4 DUP (?)
_DIMOUSESTATE	ENDS

DIMOUSESTATE		TYPEDEF		_DIMOUSESTATE
LPDIMOUSESTATE		TYPEDEF		PTR _DIMOUSESTATE

DIMOFS_X   EQU <lX>
DIMOFS_Y   EQU <lY>
DIMOFS_Z   EQU <lZ>
DIMOFS_BUTTON0 EQU <rgbButtons[0]>
DIMOFS_BUTTON1 EQU <rgbButtons[1]>
DIMOFS_BUTTON2 EQU <rgbButtons[2]>
DIMOFS_BUTTON3 EQU <rgbButtons[3]>


;****************************************************************************
;*
;*      Keyboard
;*
;****************************************************************************


;****************************************************************************
;*
;*      DirectInput keyboard scan codes
;*
;****************************************************************************

DIK_ESCAPE	EQU		000000001h
DIK_1		EQU		000000002h
DIK_2		EQU		000000003h
DIK_3		EQU		000000004h
DIK_4		EQU		000000005h
DIK_5		EQU		000000006h
DIK_6		EQU		000000007h
DIK_7		EQU		000000008h
DIK_8		EQU		000000009h
DIK_9		EQU		00000000ah
DIK_0		EQU		00000000bh
DIK_MINUS	EQU		00000000ch ; /* - on main keyboard */
DIK_EQUALS	EQU		00000000dh
DIK_BACK	EQU		00000000eh ; /* backspace */
DIK_TAB		EQU		00000000fh
DIK_Q		EQU		000000010h
DIK_W		EQU		000000011h
DIK_E		EQU		000000012h
DIK_R		EQU		000000013h
DIK_T		EQU		000000014h
DIK_Y		EQU		000000015h
DIK_U		EQU		000000016h
DIK_I		EQU		000000017h
DIK_O		EQU		000000018h
DIK_P		EQU		000000019h
DIK_LBRACKET	EQU		00000001ah
DIK_RBRACKET	EQU		00000001bh
DIK_RETURN	EQU		00000001ch  ; ENTER on main keyboard
DIK_LCONTROL	EQU		00000001dh
DIK_A		EQU		00000001eh
DIK_S		EQU		00000001fh
DIK_D		EQU		000000020h
DIK_F		EQU		000000021h
DIK_G		EQU		000000022h
DIK_H		EQU		000000023h
DIK_J		EQU		000000024h
DIK_K		EQU		000000025h
DIK_L		EQU		000000026h
DIK_SEMICOLON	EQU		000000027h
DIK_APOSTROPHE	EQU		000000028h
DIK_GRAVE	EQU		000000029h ; accent grave
DIK_LSHIFT	EQU		00000002ah
DIK_BACKSLASH	EQU		00000002bh
DIK_Z		EQU		00000002ch
DIK_X		EQU		00000002dh
DIK_C		EQU		00000002eh
DIK_V		EQU		00000002fh
DIK_B		EQU		000000030h
DIK_N		EQU		000000031h
DIK_M		EQU		000000032h
DIK_COMMA	EQU		000000033h
DIK_PERIOD	EQU		000000034h ; . on main keyboard
DIK_SLASH	EQU		000000035h ; / on main keyboard
DIK_RSHIFT	EQU		000000036h
DIK_MULTIPLY	EQU		000000037h ; * on numeric keypad
DIK_LMENU	EQU		000000038h ; left Alt
DIK_SPACE	EQU		000000039h
DIK_CAPITAL	EQU		00000003ah
DIK_F1		EQU		00000003bh
DIK_F2		EQU		00000003ch
DIK_F3		EQU		00000003dh
DIK_F4		EQU		00000003eh
DIK_F5		EQU		00000003fh
DIK_F6		EQU		000000040h
DIK_F7		EQU		000000041h
DIK_F8		EQU		000000042h
DIK_F9		EQU		000000043h
DIK_F10		EQU		000000044h
DIK_NUMLOCK	EQU		000000045h
DIK_SCROLL	EQU		000000046h
DIK_NUMPAD7	EQU		000000047h
DIK_NUMPAD8	EQU		000000048h
DIK_NUMPAD9	EQU		000000049h
DIK_SUBTRACT	EQU		00000004ah
DIK_NUMPAD4	EQU		00000004bh
DIK_NUMPAD5	EQU		00000004ch
DIK_NUMPAD6	EQU		00000004dh
DIK_ADD		EQU		00000004eh
DIK_NUMPAD1	EQU		00000004fh
DIK_NUMPAD2	EQU		000000050h
DIK_NUMPAD3	EQU		000000051h
DIK_NUMPAD0	EQU		000000052h
DIK_DECIMAL	EQU		000000053h
DIK_F11		EQU		000000057h
DIK_F12		EQU		000000058h

DIK_F13		EQU		000000064h  ; (NEC PC98)
DIK_F14		EQU		000000065h  ; (NEC PC98)
DIK_F15		EQU		000000066h  ; (NEC PC98)

; Japanese keyboard
DIK_KANA	EQU		000000070h
DIK_CONVERT	EQU		000000079h
DIK_NOCONVERT	EQU		00000007bh
DIK_YEN		EQU		00000007dh

DIK_NUMPADEQUALS	EQU		00000008dh ; = on numkdb (NEC PC98)

DIK_CIRCUMFLEX		EQU		000000090h
DIK_AT		EQU		000000091h
DIK_COLON	EQU		000000092h
DIK_UNDERLINE	EQU		000000093h
DIK_KANJI	EQU		000000094h
DIK_STOP	EQU		000000095h
DIK_AX		EQU		000000096h
DIK_UNLABELED	EQU		000000097h
DIK_NUMPADENTER	EQU		00000009ch
DIK_RCONTROL	EQU		00000009dh
DIK_NUMPADCOMMA	EQU		0000000b3h
DIK_DIVIDE	EQU		0000000b5h
DIK_SYSRQ	EQU		0000000b7h
DIK_RMENU	EQU		0000000b8h
DIK_HOME	EQU		0000000c7h
DIK_UP		EQU		0000000c8h
DIK_PRIOR	EQU		0000000c9h
DIK_LEFT	EQU		0000000cbh
DIK_RIGHT	EQU		0000000cdh
DIK_END		EQU		0000000cfh
DIK_DOWN	EQU		0000000d0h
DIK_NEXT	EQU		0000000d1h
DIK_INSERT	EQU		0000000d2h
DIK_DELETE	EQU		0000000d3h
DIK_LWIN	EQU		0000000dbh
DIK_RWIN	EQU		0000000dch
DIK_APPS	EQU		0000000ddh

;  Alternate names for some keys, to facilitate transition from DOS.
DIK_BACKSPACE		EQU		00000000eh
DIK_NUMPADSTAR		EQU		000000037h
DIK_LALT		EQU		000000038h
DIK_CAPSLOCK		EQU		00000003ah
DIK_NUMPADMINUS		EQU		00000004ah
DIK_NUMPADPLUS		EQU		00000004eh
DIK_NUMPADPERIOD	EQU		000000053h
DIK_NUMPADSLASH		EQU		0000000b5h
DIK_RALT		EQU		0000000b8h
DIK_UPARROW		EQU		0000000c8h
DIK_PGUP		EQU		0000000c9h
DIK_LEFTARROW		EQU		0000000cbh
DIK_RIGHTARROW		EQU		0000000cdh
DIK_DOWNARROW		EQU		0000000d0h
DIK_PGDN		EQU		0000000d1h



DIJOYSTATE	STRUCT
lX		DWORD	?           ; x-axis position
lY		DWORD	?           ; y-axis position
lZ		DWORD	?           ; z-axis position
lRx		DWORD	?           ; x-axis rotation
lRy		DWORD	?           ; y-axis rotation
lRz		DWORD	?           ; z-axis rotation
rglSlider	DWORD	2 DUP (?)   ; extra axes positions
rgdwPOV		DWORD	4 DUP (?)   ; POV directions
rgbButtons	BYTE	32t DUP (?) ; place for 32 buttons
DIJOYSTATE	ENDS

LPDIJOYSTATE		TYPEDEF		PTR DIJOYSTATE


DIJOYSTATE2	STRUCT
lX		DWORD	?            ; x-axis position
lY		DWORD	?            ; y-axis position
lZ		DWORD	?            ; z-axis position
lRx		DWORD	?            ; x-axis rotation
lRy		DWORD	?            ; y-axis rotation
lRz		DWORD	?            ; z-axis rotation
rglSlider	DWORD	2 DUP (?)    ; extra axes positions
rgdwPOV		DWORD	4 DUP (?)    ; POV directions
rgbButtons	BYTE	128t DUP (?) ; place for 128 buttons
lVX		DWORD		?
lVY		DWORD		?
lVZ		DWORD		?
lVRx		DWORD		?
lVRy		DWORD		?
lVRz		DWORD		?
rglVSlider	DWORD		2 DUP (?)
lAX		DWORD		?
lAY		DWORD		?
lAZ		DWORD		?
lARx		DWORD		?
lARy		DWORD		?
lARz		DWORD		?
rglASlider	DWORD		2 DUP (?)
lFX		DWORD		?
lFY		DWORD		?
lFZ		DWORD		?
lFRx		DWORD		?
lFRy		DWORD		?
lFRz		DWORD		?
rglFSlider	DWORD		2 DUP (?)
DIJOYSTATE2	ENDS

LPDIJOYSTATE2		TYPEDEF		PTR DIJOYSTATE2



;****************************************************************************
;*
;*  IDirectInput
;*
;****************************************************************************

DIENUM_STOP        EQU     0
DIENUM_CONTINUE    EQU     1


DIEDFL_ALLDEVICES    EQU    00000000h
DIEDFL_ATTACHEDONLY  EQU    00000001h
DIEDFL_FORCEFEEDBACK EQU    00000100h

LPDIRECTINPUTA typedef PTR
LPDIRECTINPUT EQU <LPDIRECTINPUTA>

LPDIRECTINPUT2A typedef PTR
LPDIRECTINPUT2 EQU <LPDIRECTINPUT2A>

; * * *  Return Codes * * *

; *  The operation completed successfully.
DI_OK			EQU	S_OK

; *  The device exists but is not currently attached.
DI_NOTATTACHED		EQU	S_FALSE

; *  The device buffer overflowed.  Some input was lost.
DI_BUFFEROVERFLOW	EQU	S_FALSE

; *  The change in device properties had no effect.
DI_PROPNOEFFECT		EQU	S_FALSE

; *  The operation had no effect.
DI_NOEFFECT		EQU	S_FALSE

; *  The device is a polled device.  As a result, device buffering
; *  will not collect any data and event notifications will not be
; *  signalled until GetDeviceState is called.
DI_POLLEDDEVICE		=	2

; *  The parameters of the effect were successfully updated by
; *  IDirectInputEffect_SetParameters, but the effect was not
; *  downloaded because the device is not exclusively acquired
; *  or because the DIEP_NODOWNLOAD flag was passed.
DI_DOWNLOADSKIPPED	=	3

; *  The parameters of the effect were successfully updated by
; *  IDirectInputEffect_SetParameters, but in order to change
; *  the parameters, the effect needed to be restarted.
DI_EFFECTRESTARTED	=	4

; *  The parameters of the effect were successfully updated by
; *  IDirectInputEffect_SetParameters, but some of them were
; *  beyond the capabilities of the device and were truncated.
DI_TRUNCATED		=	8

; *  Equal to DI_EFFECTRESTARTED | DI_TRUNCATED.
DI_TRUNCATEDANDRESTARTED  = 0Ch

;********************* FIXME!!! ****
IFNDEF FACILITY_WIN32
 FACILITY_WIN32 = 7
ENDIF

IFNDEF ERROR_OLD_WIN_VERSION
 ERROR_OLD_WIN_VERSION = 1150
ENDIF

IFNDEF ERROR_RMODE_APP
 ERROR_RMODE_APP = 1153
ENDIF

IFNDEF ERROR_ALREADY_INITIALIZED
 ERROR_ALREADY_INITIALIZED = 1247
ENDIF
;***********************************

; *  The application requires a newer version of DirectInput.
 MAKE_HRESULT DIERR_OLDDIRECTINPUTVERSION,SEVERITY_ERROR,FACILITY_WIN32,ERROR_OLD_WIN_VERSION

; *  The application was written for an unsupported prerelease version
; *  of DirectInput.
    MAKE_HRESULT DIERR_BETADIRECTINPUTVERSION,SEVERITY_ERROR,FACILITY_WIN32,ERROR_RMODE_APP

; *  The object could not be created due to an incompatible driver version
; *  or mismatched or incomplete driver components.
    MAKE_HRESULT DIERR_BADDRIVERVER,SEVERITY_ERROR,FACILITY_WIN32,ERROR_BAD_DRIVER_LEVEL

; * The device or device instance or effect is not registered with DirectInput.
DIERR_DEVICENOTREG	EQU	REGDB_E_CLASSNOTREG

; * The requested object does not exist.
    MAKE_HRESULT DIERR_NOTFOUND,SEVERITY_ERROR,FACILITY_WIN32,ERROR_FILE_NOT_FOUND

; * The requested object does not exist.
    MAKE_HRESULT DIERR_OBJECTNOTFOUND,SEVERITY_ERROR,FACILITY_WIN32,ERROR_FILE_NOT_FOUND

; * An invalid parameter was passed to the returning function,
; * or the object was not in a state that admitted the function
; * to be called.
DIERR_INVALIDPARAM	EQU	E_INVALIDARG

; * The specified interface is not supported by the object
DIERR_NOINTERFACE	EQU	E_NOINTERFACE

; * An undetermined error occured inside the DInput subsystem
DIERR_GENERIC		EQU	E_FAIL

; * The DInput subsystem couldn't allocate sufficient memory to complete the
; * caller's request.
DIERR_OUTOFMEMORY	EQU	E_OUTOFMEMORY

; * The function called is not supported at this time
DIERR_UNSUPPORTED	EQU	E_NOTIMPL

; * This object has not been initialized
    MAKE_HRESULT DIERR_NOTINITIALIZED,SEVERITY_ERROR,FACILITY_WIN32,ERROR_NOT_READY

; * This object is already initialized
    MAKE_HRESULT DIERR_ALREADYINITIALIZED,SEVERITY_ERROR,FACILITY_WIN32,ERROR_ALREADY_INITIALIZED

; * This object does not support aggregation
DIERR_NOAGGREGATION	EQU	CLASS_E_NOAGGREGATION

; * Another app has a higher priority level, preventing this call from
; * succeeding.
DIERR_OTHERAPPHASPRIO	EQU	E_ACCESSDENIED

; * Access to the device has been lost.  It must be re-acquired.
    MAKE_HRESULT DIERR_INPUTLOST,SEVERITY_ERROR,FACILITY_WIN32,ERROR_READ_FAULT

; * The operation cannot be performed while the device is acquired.
    MAKE_HRESULT DIERR_ACQUIRED,SEVERITY_ERROR,FACILITY_WIN32,ERROR_BUSY

; * The operation cannot be performed unless the device is acquired.
    MAKE_HRESULT DIERR_NOTACQUIRED,SEVERITY_ERROR,FACILITY_WIN32,ERROR_INVALID_ACCESS

; * The specified property cannot be changed.
DIERR_READONLY		EQU	E_ACCESSDENIED

; * The device already has an event notification associated with it.
DIERR_HANDLEEXISTS	EQU	E_ACCESSDENIED

; * Data is not yet available.
IFNDEF E_PENDING
 E_PENDING  =    80070007h
ENDIF

; * Unable to IDirectInputJoyConfig_Acquire because the user
; * does not have sufficient privileges to change the joystick
; * configuration.
DIERR_INSUFFICIENTPRIVS		=	80040200h

; * The device is full.
DIERR_DEVICEFULL		=	80040201h

; * Not all the requested information fit into the buffer.
DIERR_MOREDATA			=	80040202h

; * The effect is not downloaded.
DIERR_NOTDOWNLOADED		=	80040203h

; *  The device cannot be reinitialized because there are still effects
; *  attached to it.
DIERR_HASEFFECTS		=	80040204h

; *  The operation cannot be performed unless the device is acquired
; *  in DISCL_EXCLUSIVE mode.
DIERR_NOTEXCLUSIVEACQUIRED	=	80040205h

; *  The effect could not be downloaded because essential information
; *  is missing.  For example, no axes have been associated with the
; *  effect, or no type-specific information has been created.
DIERR_INCOMPLETEEFFECT		=	80040206h

; *  Attempted to read buffered device data from a device that is
; *  not buffered.
DIERR_NOTBUFFERED		=	80040207h

; *  An attempt was made to modify parameters of an effect while it is
; *  playing.  Not all hardware devices support altering the parameters
; *  of an effect while it is playing.
DIERR_EFFECTPLAYING		=	80040208h

;===================================================================
; The Virtual Table -- This is used for all the DirectX functions
;===================================================================
	;=======================================
	; The main DirectInput interface
	;=======================================
IDirectInputVtbl	STRUC
	; IUnknown methods
	STDMETHOD	QueryInterface, :PTR IDirectInput, :PTR, :PTR PTR
	STDMETHOD	AddRef, :PTR IDirectInput
	STDMETHOD	Release, :PTR IDirectInput
	; IDirectInput methods
	STDMETHOD	CreateDevice, :PTR IDirectInput, :PTR, :PTR, :PTR
	STDMETHOD	EnumDevices, :PTR IDirectInput, :DWORD, :PTR, :PTR, :DWORD
	STDMETHOD	GetDeviceStatus, :PTR IDirectInput, :PTR
	STDMETHOD	RunControlPanel, :PTR IDirectInput, :PTR, :DWORD
	STDMETHOD	Initialize, :PTR IDirectInput, :PTR, :DWORD
IDirectInputVtbl	ENDS

	;=======================================
	; The DirectInputDevice interface
	;=======================================
IDirectInputDeviceVtbl	STRUC
	; IUnknown methods
	STDMETHOD	QueryInterface, :PTR IDirectInputDevice, :PTR, :PTR PTR
	STDMETHOD	AddRef, :PTR IDirectInputDevice
	STDMETHOD	Release, :PTR IDirectInputDevice
	; IDirectInputDevice methods
	STDMETHOD	GetCapabilities, :PTR IDirectInputDevice, :PTR
	STDMETHOD	EnumObjects, :PTR IDirectInputDevice, :PTR, :PTR, :DWORD
	STDMETHOD	GetProperty, :PTR IDirectInputDevice, :PTR, :PTR 
	STDMETHOD	SetProperty, :PTR IDirectInputDevice, :PTR, :PTR
	STDMETHOD	Acquire, :PTR IDirectInputDevice
	STDMETHOD	Unacquire, :PTR IDirectInputDevice
	STDMETHOD	GetDeviceState, :PTR IDirectInputDevice, :PTR, :PTR
	STDMETHOD	GetDeviceData, :PTR IDirectInputDevice, :PTR, :PTR, :PTR, :PTR
	STDMETHOD	SetDataFormat, :PTR IDirectInputDevice, :PTR
	STDMETHOD	SetEventNotification, :PTR IDirectInputDevice, :PTR
	STDMETHOD	SetCooperativeLevel, :PTR IDirectInputDevice, :PTR, :DWORD
	STDMETHOD	GetObjectInfo, :PTR IDirectInputDevice, :PTR, :DWORD, :DWORD
	STDMETHOD	GetDeviceInfo, :PTR IDirectInputDevice, :PTR
	STDMETHOD	RunControlPanel, :PTR IDirectInputDevice, :PTR, :DWORD
	STDMETHOD	Initialize, :PTR IDirectInputDevice, :PTR, :DWORD , :PTR
IDirectInputDeviceVtbl	ENDS

	;=======================================
	; The DirectInputDevice2 interface
	;=======================================
IDirectInputDevice2Vtbl	STRUC
	; IUnknown methods
	STDMETHOD	QueryInterface, :PTR IDirectInputDevice2, :PTR, :PTR PTR
	STDMETHOD	AddRef, :PTR IDirectInputDevice2
	STDMETHOD	Release, :PTR IDirectInputDevice2
	; IDirectInputDevice methods
	STDMETHOD	GetCapabilities, :PTR IDirectInputDevice2, :PTR
	STDMETHOD	EnumObjects, :PTR IDirectInputDevice2, :PTR, :PTR, :DWORD
	STDMETHOD	GetProperty, :PTR IDirectInputDevice2, :PTR, :PTR 
	STDMETHOD	SetProperty, :PTR IDirectInputDevice2, :PTR, :PTR
	STDMETHOD	Acquire, :PTR IDirectInputDevice2
	STDMETHOD	Unacquire, :PTR IDirectInputDevice2
	STDMETHOD	GetDeviceState, :PTR IDirectInputDevice2, :PTR, :PTR
	STDMETHOD	GetDeviceData, :PTR IDirectInputDevice2, :PTR, :PTR, :PTR, :PTR
	STDMETHOD	SetDataFormat, :PTR IDirectInputDevice2, :PTR
	STDMETHOD	SetEventNotification, :PTR IDirectInputDevice2, :PTR
	STDMETHOD	SetCooperativeLevel, :PTR IDirectInputDevice2, :PTR, :DWORD
	STDMETHOD	GetObjectInfo, :PTR IDirectInputDevice2, :PTR, :DWORD, :DWORD
	STDMETHOD	GetDeviceInfo, :PTR IDirectInputDevice2, :PTR
	STDMETHOD	RunControlPanel, :PTR IDirectInputDevice2, :PTR, :DWORD
	STDMETHOD	Initialize, :PTR IDirectInputDevice2, :PTR, :DWORD , :PTR
	; The new version 2 methods
	STDMETHOD	CreateEffect, :PTR IDirectInputDevice2, :PTR, :PTR, :PTR, :PTR, :PTR
	STDMETHOD	EnumEffects, :PTR IDirectInputDevice2, :PTR, :PTR, :DWORD
	STDMETHOD	GetEffectInfo, :PTR IDirectInputDevice2, :PTR, :PTR
	STDMETHOD	GetForceFeedbackState, :PTR IDirectInputDevice2, :PTR
	STDMETHOD	SendForceFeedbackCommand, :PTR IDirectInputDevice2, :DWORD
	STDMETHOD	EnumCreatedEffectObjects, :PTR IDirectInputDevice2, :PTR, :PTR, :DWORD
	STDMETHOD	Escape, :PTR IDirectInputDevice2, :PTR
	STDMETHOD	Poll, :PTR IDirectInputDevice2 
	STDMETHOD	SendDeviceData, :PTR IDirectInputDevice2, :DWORD, :PTR, :PTR, :DWORD

IDirectInputDevice2Vtbl	ENDS

;=======================================
; The DirectInput Vtbl addresses
;=======================================
IDirectInput		STRUC
	lpVtbl		DWORD		?
IDirectInput		ENDS

IDirectInputDevice	STRUC
	lpVtbl		DWORD		?
IDirectInputDevice	ENDS
