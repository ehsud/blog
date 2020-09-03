@echo off
setlocal enabledelayedexpansion

cd /d %~dp1

set /a n=1

mkdir video

for /f "delims=" %%u in (%~nx1) do (
	ffmpeg -i %%u -c copy -f flv video\video-!n!.flv
	set /a n+=1
)

pause
