
function dprint(...)
  if Debug then print(...) end
end

function sdlFailIf(cond,reason)
  if not cond then
    print(string.format("Error: %s :: %s\n", sdl.getError(),reason))
  end
end


--https://stackoverflow.com/questions/72386387/lua-split-string-to-table
function string:split(sep)
   local sep = sep or ","
   local result = {}
   local pattern = string.format("([^%s]+)", sep)
   local i = 1
   self:gsub(pattern, function (c) result[i] = c i = i + 1 end)
   return result
end
