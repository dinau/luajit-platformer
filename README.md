<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [luajit-platformer](#luajit-platformer)
  - [Support OS](#support-os)
  - [Install and run](#install-and-run)
  - [Tutorial](#tutorial)
  - [Reference](#reference)
  - [Tool versions](#tool-versions)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

### luajit-platformer

---

Writing a 2D Platform Game in LuaJIT with SDL2.

This repository has been inherited from  
- [nim-platformer](https://github.com/def-/nim-platformer) project.
   - Document  
   English:  https://hookrace.net/blog/writing-a-2d-platform-game-in-nim-with-sdl2/  
   Japanese: https://postd.cc/writing-a-2d-platform-game-in-nim-with-sdl2/  


![alt](img/t4.png)

#### Support OS

---

Windows10 or later

#### Install and run

---

```sh
git clone --recursive https://github.com/dinau/luajit-platformer
cd tutorial
r.bat 5          --- Example, execute platformer_part5.lua
```

#### Tutorial

---

- Key operation 

   | Key         | function |
   | :---:       | :---     |
   | Space, J, K | Jump     |
   | A, H        | Left     |
   | D, L        | Right    |
   | R           | Restart  |
   | Q           | Quit     |

- Sources  
[platformer_part1.lua](tutorial/platformer_part1.lua)  
[platformer_part2.lua](tutorial/platformer_part2.lua)  
[platformer_part3.lua](tutorial/platformer_part3.lua)  
[platformer_part4.lua](tutorial/platformer_part4.lua)  
[platformer_part5.lua](tutorial/platformer_part5.lua) (2023/12) It can move an item with key input.  
[platformer_part6.lua](tutorial/platformer_part6.lua)  
[platformer_part7.lua](tutorial/platformer_part7.lua)  
[platformer_part8.lua](tutorial/platformer_part8.lua)  

- In progress  
platformer_part9.lua

#### Reference

---

- SDL2.dll  
https://github.com/libsdl-org/SDL/releases/tag/release-2.28.5
- SDL2_image.dll  
https://github.com/libsdl-org/SDL_image/releases/tag/release-2.6.3
- SDL2_ttf.dll  
https://github.com/libsdl-org/SDL_ttf/releases/tag/release-2.20.2
- LuaJIT-SDL2  
https://github.com/sonoro1234/LuaJIT-SDL2


#### Tool versions

---

- LuaJIT 2.1.1697887905 -- Copyright (C) 2005-2023 Mike Pall.
- SDL2 v2.28.5
- SDL2_image v2.6.3
- SDL2_ttf v2.20.2
- gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
- nim-1.6.14 
