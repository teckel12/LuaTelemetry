local modes, labels, data, FILE_PATH = ...
local config2

if data.lang ~= "en" then
	local tmp = FILE_PATH .. "lang_" .. data.lang .. ".luac"
	local fh = io.open(tmp)
	if fh ~= nil then
		io.close(fh)
		loadfile(tmp)(modes, labels, config2, false)
		collectgarbage()
	end
end

if data.voice ~= "en" then
	local fh = io.open(FILE_PATH .. data.voice .. "/on.wav")
	if fh ~= nil then
		io.close(fh)
	else
		data.voice = "en"
	end
end

return 0