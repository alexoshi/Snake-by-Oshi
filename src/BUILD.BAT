@echo off

if exist Build\DD_Stuff.obj del Build\DD_Stuff.obj
if exist Build\DI_Stuff.obj del Build\DI_Stuff.obj
if exist Build\DS_Stuff.obj del Build\DS_Stuff.obj
if exist Build\Bitmap.obj del Build\Bitmap.obj
if exist Build\Timer.obj del Build\Timer.obj
if exist Build\Snake.obj del Build\Snake.obj
if exist Build\rsrc.res del Build\rsrc.res
if exist Build\rsrc.obj del Build\rsrc.obj
if exist Snake.exe del Snake.exe

\masm32\bin\ml /c /coff /FoBuild\Snake.obj Snake.asm 
\masm32\bin\ml /c /coff /FoBuild\DD_Stuff.obj DD_Stuff.asm 
\masm32\bin\ml /c /coff /FoBuild\DI_Stuff.obj DI_Stuff.asm 
\masm32\bin\ml /c /coff /FoBuild\DS_Stuff.obj DS_Stuff.asm 
\masm32\bin\ml /c /coff /FoBuild\Bitmap.obj Bitmap.asm 
\masm32\bin\ml /c /coff /FoBuild\Timer.obj Timer.asm 

\masm32\bin\rc -fo Build\rsrc.res rsrc.rc
\masm32\bin\cvtres /machine:ix86 /out:Build\rsrc.obj Build\rsrc.res

if errorlevel 1 goto errasm

\masm32\bin\Link /DEBUG /SUBSYSTEM:WINDOWS /out:Snake.exe Build\Snake.obj Build\Bitmap.obj Build\Timer.obj Build\DD_Stuff.obj Build\DI_Stuff.obj Build\DS_Stuff.obj Build\Rsrc.obj

if errorlevel 1 goto errlink

dir
goto TheEnd

:errlink
echo _
echo Link error
goto TheEnd

:errasm
echo _
echo Assembly Error
Pause

:TheEnd
Pause