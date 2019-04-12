cd /d %~dp1

set in=%~nx1
set out=%~n1-2pass.mp4

:: 视频码率
set bitrate=5000k

:: 通用参数选项
set opt=-preset veryslow -pix_fmt yuv420p -movflags faststart

:: 第 1 遍分析
ffmpeg -y -i %in% -c:v libx264 %opt% -vb %bitrate% -pass 1 -c:a aac -ab 320k -f mp4 nul

:: 第 2 遍转码
ffmpeg -y -i %in% -c:v libx264 %opt% -vb %bitrate% -pass 2 -c:a aac -ab 320k -f mp4 %out%

:: 清理临时文件
del /a /f /q *.log *.temp *.mbtree
pause
