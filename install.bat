@echo off
setlocal EnableDelayedExpansion
set "currentdir=%~dp0"
cd %currentdir%

:ask
echo Install GRUB2? (Y/N)
set /p choice=Your choice: 

if /i "%choice%"=="Y" (
    goto :continue
) else if /i "%choice%"=="N" (
    exit
) else if /i "%choice%"=="y" (
    goto :continue
) else if /i "%choice%"=="n" (
    exit
) else (
    echo Invalid choice
    goto :ask
)

:continue

echo Preparing for install

goto :help2

:fff

set letters=a b c d e f g h i j k l m n o p q r s t u v w x y z

set start=a
set end=z

set "temp=!letters:*%start%=%start%!"
for /F "delims=$" %%a in ("!temp:%end%=%end%$!") do for %%b in (%%a) do (
    set currentLetter=%%b

    IF EXIST "%%b:\" (
            echo Mounted partition: %%b > NUL
    ) else (
            set "letter=%%b"
            echo Unmounted partition: %%b > NUL
            goto :end1
    )

)

:end1

set letters=a b d e f g h i j k l m n o p q r s t u v w x y z

set start=a
set end=z

set "temp=!letters:*%start%=%start%!"
for /F "delims=$" %%a in ("!temp:%end%=%end%$!") do for %%b in (%%a) do (
    set currentLetter=%%b

    IF EXIST "%%b:\" (
            IF EXIST "%%b:\EFI\" (
                mountvol %%b:\ /d
            )
    ) 

)

echo Unmounted partitions (EFI Partitions)

mkdir c:\temp
echo Created C:\temp

winrar\winrar x etc\efi_grub.zip c:\temp\
winrar\winrar x etc\os_grub.zip c:\temp\
echo Unpacked grub: c:\temp\efi_grub, c:\temp\os_grub

mountvol %letter%: /s > NUL

echo Mounted EFI Partition %letter%:\

echo Installing GRUB2 

xcopy c:\temp\efi_grub %letter%:\ /s /e /h /i /y > NUL
echo Copied GRUB2 (EFI, Minimal) To %letter%:\ (EFI Partition)

xcopy c:\temp\os_grub C:\ /s /e /h /i /y  > NUL
echo Copied GRUB2 (OS, Default) To C:\ (OS Partition)

echo Boot entry ID: {bootmgr}
bcdedit /set {bootmgr} path efi\boot\bootx64.efi > NUL
bcdedit /displayorder {bootmgr} /addlast > NUL
bcdedit /timeout 0 > NUL
echo Created GRUB2 Link in BCDEdit

echo "Don`t delete this" > C:\grub\grub2auto.label

del /s/q C:\temp > NUL
rmdir /s/q C:\temp > NUL

echo Done. Press any key to reboot.

pause

shutdown /r /t 0

exit

:help2

for /f "delims=" %%i in ('where /q winauto.label') do (
    del "%%i"
)

goto :fff