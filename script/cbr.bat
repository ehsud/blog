cd /d %~dp1

:: 原文件名称
set in=%~nx1
:: 输出文件名称
set out=%~n1-cbr.mp4
:: 码率控制参数
set vb=-vb 5000k -minrate 5000k -maxrate 5000k -bufsize 5000k
:: 通用参数选项
set opt=-preset slow -pix_fmt yuv420p -movflags faststart

:: 调用 ffmpeg 进行编码
ffmpeg -y -i %in% -vcodec libx264 %vb% %opt% -acodec aac -ab 320k %out%

pause
