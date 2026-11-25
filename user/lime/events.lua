-- ивент для источника "Lime HD" https://limehd.tv  (25/11/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/NEKTO606/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: /luaScr/user/TVSources/scrapers/lime_hd_pls.lua
-- скрипт запуска ивента: /luaScr/user/startup/lime_start.lua
-- скрипт ивента: /luaScr/user/lime/events.lua
-- видеоскрипт: /luaScr/user/video/limeHD.lua
-- расширение дополнения httptimeshift: /luaScr/user/httptimeshift/extensions/limehd-timeshift_ext.lua
-- видоскрипт: vinteratv.lua
if m_simpleTV.Control.EventPlayingInterval then
	local curAdr = m_simpleTV.Control.CurrentAddress or ''
	if not curAdr:match('limehd%.tv')
		and not curAdr:match('127%.0%.0%.1:18080%/stream%.ts')
	then
		return
	end

	local lime = m_simpleTV.User and m_simpleTV.User.lime

	if m_simpleTV.Control.Reason == 'Stopped' or m_simpleTV.Control.Reason == 'Exiting' then
		if lime then
			if lime.tmpName_m3u8 ~= nil then
				os.remove(lime.tmpName_m3u8)
			end
			if lime.client then pcall(function() lime.client:close() end) end
			if lime.server then pcall(function() lime.server:close() end) end
			m_simpleTV.User.lime = nil
		end
		local folderPath = TVSources_var.TVSdir .. 'm3u/cache/lime'
		if lfs and lfs.attributes(folderPath) then
			for file in lfs.dir(folderPath) do
				if file ~= "." and file ~= ".." then
					os.remove(folderPath .. '/' .. file)
				end
			end
			os.remove(folderPath)
		end
		return
	end
	
	if m_simpleTV.Control.Reason == 'Playing' then
		if not lime or not lime.server then return end

		if not lime.client then
			lime.server:settimeout(3)
			local client, err = lime.server:accept()
			lime.server:settimeout(0)
			if client then
				client:settimeout(1)
				client:setoption('tcp-nodelay', true)
				repeat
					local l = client:receive('*l')
				until not l or l == ''
				client:send("HTTP/1.0 200 OK\r\nContent-Type: video/mp2t\r\n\r\n")
				client:settimeout(0)
				lime.client = client
			else
				return
			end
		end
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:160.0) Gecko/20100101 Firefox/160.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		lime.count_event = lime.count_event + 1
		local mono = lime.mono
		local headers = lime.header
		local rc, mono_body = m_simpleTV.Http.Request(session, {url = mono, headers = headers})
		if rc ~= 200 or not mono_body then
			m_simpleTV.Http.Close(session)
			return
		end
		local ts = mono:gsub('mono.ts.m3u8', '')
		local match_new = {}
		local diff = {}
		for w in mono_body:gmatch('%d%d%d%d/.-%.ts') do
			table.insert(match_new, w)
		end
		local t2_lookup = {}
		for _, value in ipairs(lime.mono_ts) do
			t2_lookup[value] = true
		end
		for _, value in ipairs(match_new) do
			if not t2_lookup[value] then
				table.insert(diff, value)
			end
		end
		local mass = (lime.count_event == 1) and match_new or diff
		if lime.client and #mass > 0 then
			for _, w in ipairs(mass) do
				local rc, ts_body = m_simpleTV.Http.Request(session, {url = ts .. w, headers = headers})
				if ts_body then
					local pos = 1
					while pos <= #ts_body do
						local sent, err, last = lime.client:send(ts_body, pos)
						if sent then
							pos = sent + 1
						elseif err == 'timeout' then
							pos = (last or (pos - 1)) + 1
							m_simpleTV.Common.Sleep(5)
						else
							break
						end
					end
				end
			end
		end
		lime.mono_ts = match_new
		m_simpleTV.Http.Close(session)
	end
end

--debug_in_file(token .. '\n', "D:\xxx.txt")
