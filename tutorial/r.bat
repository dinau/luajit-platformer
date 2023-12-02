@echo off

set PREFIX_DIR=%USERPROFILE%\work

set LUA_PATH=;;%PREFIX_DIR%\luajit-platformer\lua\?.lua
set LUA_PATH=%LUA_PATH%;%PREFIX_DIR%\luajit-sdl2_image\?.lua

rem set luaRoot=..\..\..\anima_data\full_data\luaImGui_full
rem %luaRoot%\luajit platformer_part2.lua

luajit platformer_part%1%.lua
