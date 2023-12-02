local ffi = require"ffi"
local sdl = require"sdl2_ffi"
local r = ffi.new("SDL_Rect",{0,1,2,3})

print(r.x,r.y,r.w,r.h)
function sdlFailIf(cond,reason)
  if not cond then
    print(string.format("Error: %s :: %s\n", sdl.getError(),reason))
  end
end

if sdlFailIf(0 == sdl.init(sdl.INIT_VIDEO + sdl.INIT_TIMER + sdl.INIT_EVENTS),
                           "SDL2 initialization failed") then
  return -1
end
if sdlFailIf(sdl.TRUE == sdl.SetHint("SDL_RENDER_SCALE_QUALITY", "2"),
             "Linear texture filtering could not be enabled") then return -1
end
local window = sdl.CreateWindow("Our own 2D platformer",
    sdl.WINDOWPOS_CENTERED, sdl.WINDOWPOS_CENTERED,
    1280, 720, sdl.WINDOW_SHOWN)
if sdlFailIf(0 ~= window,"Window could not be created") then return -1 end

local renderer = sdl.CreateRenderer(window,-1,
  sdl.RENDERER_ACCELERATED or sdl.RENDERER_PRESENTVSYNC)
if sdlFailIf(0 ~= renderer,"Renderer could not be created") then return -1 end

sdl.SetRenderDrawColor(renderer,110,132,174,255)
ffi.cdef[[
int _kbhit(void);
]]
sdl.RenderSetVSync(renderer,1)
while true do
  sdl.RenderClear(renderer)
  sdl.RenderPresent(renderer)
  local res = ffi.C._kbhit()
  print(res)
  if 0 ~= res  then break end
end
----------------
--- end program
----------------
sdl.DestroyRenderer(renderer)
sdl.DestroyWindow(window)
sdl.quit()
