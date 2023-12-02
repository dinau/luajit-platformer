@echo off

set LUA_PATH=;;..\lua\?.lua
set LUA_PATH=%LUA_PATH%;..\luajit-sdl2_image\?.lua

rem set PATH=..\bin;%PATH%
set PATH=..\bin

luajit platformer_part%1%.lua
