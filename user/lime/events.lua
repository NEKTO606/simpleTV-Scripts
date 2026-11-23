-- ивент для источника "Lime HD" https://limehd.tv  (23/11/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/NEKTO606/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: /luaScr/user/TVSources/scrapers/lime_hd_pls.lua
-- скрипт запуска ивента: /luaScr/user/startup/lime_start.lua
-- скрипт ивента: /luaScr/user/lime/events.lua
-- видеоскрипт: /luaScr/user/video/limeHD.lua
-- расширение дополнения httptimeshift: /luaScr/user/httptimeshift/extensions/limehd-timeshift_ext.lua

if m_simpleTV.Control.EventPlayingInterval then
	if not m_simpleTV.Control.CurrentAddress:match('limehd%.tv')
		and not m_simpleTV.Control.CurrentAddress:match('localhost:18080%/stream%.ts')	
	then
	 return
	end

	if m_simpleTV.Control.Reason == 'Playing' or m_simpleTV.Control.Reason == 'addressready' then
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:160.0) Gecko/20100101 Firefox/160.0')
			if not session  then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
	
		local lime = m_simpleTV.User.lime
		if not lime or not lime.server then return end

		if m_simpleTV.Control.Reason == 'Stopped' or m_simpleTV.Control.Reason == 'Exiting' then
			if lime.client then lime.client:close() end
			if lime.server then lime.server:close() end
			m_simpleTV.User.lime = nil
			return
		end

		if not lime.client then
			local client = lime.server:accept()
			if not client then return end
			client:settimeout(2)
			repeat local l = client:receive('*l') until not l or l == ''
			client:send("HTTP/1.0 200 OK\r\nContent-Type: video/mp2t\r\n\r\n")
			lime.client = client
		end
		
		m_simpleTV.User.lime.count_event =  m_simpleTV.User.lime.count_event + 1
		
		local mono = m_simpleTV.User.lime.mono
		local headers = m_simpleTV.User.lime.header
		local rc, mono_body = m_simpleTV.Http.Request(session, {url = mono, headers = headers})
			if rc ~= 200 or not mono_body then return end
		local ts = mono:gsub('mono.ts.m3u8', '')
		local match_new = {}
		local match_old = {}
		local diff = {}
		for w in mono_body:gmatch('%d%d%d%d/.-%.ts') do
			table.insert(match_new, w)
		end
		if m_simpleTV.User.lime.count_event == 1 then
			match_old = match_new
		else
			match_old = m_simpleTV.User.lime.mono_ts
		end
		local t2_lookup = {}
		for _, value in ipairs(match_old) do
			t2_lookup[value] = true
		end
		for _, value in ipairs(match_new) do
			if not t2_lookup[value] then
				table.insert(diff, value)
			end
		end
		local mass = {}
		if m_simpleTV.User.lime.count_event == 1 then
			mass = match_new
		elseif m_simpleTV.User.lime.count_event > 1 and #diff > 0  then
			mass = diff
		end
		for _, w in ipairs(mass) do
			local rc, ts_body = m_simpleTV.Http.Request(session, {url = ts .. w, headers = headers})
			local pos = 1
			if ts_body then
				while pos <= #ts_body do
					local sent, err, last = lime.client:send(ts_body, pos)
					pos = (sent or last or pos) + 1
					if not sent and err ~= 'timeout' then break end
				end
			end
		end
		m_simpleTV.User.lime.mono_ts = match_new
		m_simpleTV.Http.Close(session)
	end
	if m_simpleTV.Control.Reason == 'Stopped' or m_simpleTV.Control.Reason == 'Exiting' then
		local folderPath = TVSources_var.TVSdir .. 'm3u/cache/lime'
		for file in lfs.dir(folderPath) do
			if file ~= "." and file ~= ".." then
				 local file_path = folderPath .. '/' .. file
				os.remove(file_path)
			end
		end
		os.remove(folderPath)
	end
end
