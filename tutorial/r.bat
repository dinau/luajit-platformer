@echo off

set LUA_PATH=;;..\lua\?.lua
set LUA_PATH=%LUA_PATH%;..\luajit-sdl2_image\?.lua
set LUA_PATH=%LUA_PATH%;..\luajit-sdl2_ttf\?.lua

set PATH=..\bin;%PATH%
rem set PATH=..\bin

set OPT=
if "%1"=="" (
  luajit %OPT% platformer_part8.lua
) else (
  luajit %OPT% platformer_part%1.lua
)
