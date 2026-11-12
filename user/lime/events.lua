-- ивент для источника "Lime HD" https://limehd.tv  (12/11/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/NEKTO606/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: /luaScr/user/TVSources/scrapers/lime_hd_pls.lua
-- скрипт запуска ивента: /luaScr/user/startup/lime_start.lua
-- скрипт ивента: /luaScr/user/lime/events.lua
-- видеоскрипт: /luaScr/user/video/limeHD.lua
-- расширение дополнения httptimeshift: /luaScr/user/httptimeshift/extensions/limehd-timeshift_ext.lua
if m_simpleTV.Control.EventPlayingInterval then
	if not m_simpleTV.Control.CurrentAddress:match('limehd%.tv') 
		 and not (m_simpleTV.Control.CurrentAddress:match('iptv2022%.com') 
		 and m_simpleTV.Control.CurrentAddress:match('mono%.ts%.m3u8'))
	then
	 return
	end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:160.0) Gecko/20100101 Firefox/160.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 10000)
	
	local tmpName = TVSources_var.TVSdir .. 'm3u/cache/lime/lime_'				
	local tmpName_m3u8 = TVSources_var.TVSdir .. 'm3u/cache/lime/lime_out.m3u8'
	local folderPath = TVSources_var.TVSdir .. 'm3u/cache/lime'
	
	if m_simpleTV.Control.Reason == 'Playing' then
		m_simpleTV.Control.EventPlayingInterval = 2000
		local mono = m_simpleTV.User.lime.mono
		local headers = m_simpleTV.User.lime.header
		local rc, mono_body = m_simpleTV.Http.Request(session, {url = mono, headers = headers})
			if rc ~= 200 or not mono_body then return end
		local ts = mono:gsub('mono.ts.m3u8', '')
		local match_old = m_simpleTV.User.lime.mono_ts
		local t2_lookup = {}
		for _, value in ipairs(match_old) do
			t2_lookup[value] = true
		end
		match_new = {}
		for w in mono_body:gmatch('%d%d%d%d/.-%.ts') do
			table.insert(match_new, w)
		end
		local diff = {}
		for _, value in ipairs(match_new) do
			if not t2_lookup[value] then
				table.insert(diff, value)
			end
		end
		
		if next(diff) ~= nil then
			m_simpleTV.User.lime.count = m_simpleTV.User.lime.count + #diff
		end
		
		if #diff > 0 then
			local fhandle = io.open(tmpName_m3u8, 'r')
			local content
			if fhandle then
				content = fhandle:read('*a')
				fhandle:close()
			end
			local result = {}
			local current_line = 1
			local start_line = 5
			local count = #diff * 2
			local end_line = start_line + count - 1
			for line in content:gmatch("[^\r\n]+") do
				if current_line < start_line or current_line > end_line then
					table.insert(result, line)
				end
				current_line = current_line + 1
			end
			local text = table.concat(result, "\n")
			text = text:gsub('#EXT%-X%-MEDIA%-SEQUENCE:%d*', '#EXT%-X%-MEDIA%-SEQUENCE:' .. m_simpleTV.User.lime.count)
			local fhandle = io.open(tmpName_m3u8, 'w+')
			if fhandle then
				fhandle:write(text)
				fhandle:close()
			end
			for _, w in ipairs(diff) do
				m_simpleTV.User.lime.count_ts = m_simpleTV.User.lime.count_ts + 1
				
				local fhandle = io.open(tmpName .. m_simpleTV.User.lime.count_ts .. '.ts', 'wb')
				local rc, answer = m_simpleTV.Http.Request(session, {url = ts .. w, headers = headers})
				if answer then
					if fhandle then
						fhandle:setvbuf('no')
						fhandle:write(answer)
						fhandle:flush()
						fhandle:close()
					end
				end
				m_simpleTV.Common.Sleep(1000)
				local fhandle = io.open(tmpName_m3u8, 'a')
					if fhandle then
						fhandle:write('\n#EXTINF:3.000,\n' .. 'lime_' .. m_simpleTV.User.lime.count_ts ..'.ts')
						fhandle:close()
					end
			end
			local files = {}
			local count_files = 0
			for file in lfs.dir(folderPath) do
				if file ~= "." and file ~= ".." and not file:match('%.m3u8') then
					table.insert(files, file)
					count_files = count_files + 1
				end
			end
			table.sort(files, function(a, b)
				local numA = tonumber(a:match("%d+")) or 0
				local numB = tonumber(b:match("%d+")) or 0
				return numA < numB
			end)
			if count_files >= 10 then
				local count = 0
				for _, file in ipairs(files) do
					if count >= 4 then break end
					local filePath = folderPath .. '/' .. file
					if lfs.attributes(filePath, 'mode') == 'file' then
						os.remove(filePath)
						count = count + 1
					end
				end
			end
			m_simpleTV.User.lime.mono_ts = match_new
		end
	end
	if m_simpleTV.Control.Reason == 'Stopped' or m_simpleTV.Control.Reason == 'Exiting' then
		for file in lfs.dir(folderPath) do
			if file ~= "." and file ~= ".." then
				 local file_path = folderPath .. '/' .. file
				os.remove(file_path)
			end
		end
		os.remove(folderPath)
	end
	m_simpleTV.Http.Close(session)
end