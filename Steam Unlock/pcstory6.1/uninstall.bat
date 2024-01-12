@echo off

echo ======================================
echo 停用pcstory进程、服务、自动更新
echo 确定 请按任意键
echo 取消 请关闭此窗口
echo ======================================
pause >nul

taskkill /f /im pcstory.exe
net stop fp2psrv
ping 127.1 -n 1 >nul
sc delete fp2psrv 
echo.

echo ======================================
echo 停用pcstory完成...
echo 如需再次启用，请直接运行pcstory.exe
echo ======================================


pause