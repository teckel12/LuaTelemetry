local modes, config, labels, data, FILE_PATH = ...

if data.lang ~= "en" then
	local tmp = FILE_PATH .. "lang_" .. data.lang .. ".luac"
	local fh = io.open(tmp)
	if fh ~= nil then
		io.close(fh)
		loadfile(tmp)(modes, config, labels)
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