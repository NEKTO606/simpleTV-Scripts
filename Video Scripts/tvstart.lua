-- видеоскрипт для плейлиста "ТВ Старт" https://tvstart.ru (2/11/25)
-- Copyright © 2017-2025 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: tvstart_pls.lua
-- ## открывает подобные ссылки ##
-- https://tvstart.ru/ZnJlZV82MjFkMTY5ZTVjNjMxYzYzODEzNmRmM2NiMTM2YzVjOS8zM182ODg4MTY3Ni9iMzJlYWFlNWZiZjFkMmI4MjExNTQzNTY2YTFkOWE3OC80OTE0MzkyNzY5
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://tvstart%.ru')
		then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local id = inAdr:match('([^/]+)$')
	local retAdr = decode64('aHR0cHM6Ly9ibC53ZWJjYXN0ZXIucHJvL21lZGlhL3N0YXJ0Lw') .. decode64(id) .. '.m3u8'
	
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:144.0) Gecko/20100101 Firefox/144.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		
		local rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
		if rc ~= 200 then return end
		
		local t = {}
		for w in string.gmatch(answer, 'EXT%-X%-STREAM%-INF.-m3u8') do
			local bw = w:match('BANDWIDTH=(%d+)')
			local res = w:match('X%-NAME="([^"]+)')
			local track = w:match('https://.-%.m3u8')
	
			if bw and res then
				bw = math.ceil(tonumber(bw) / 10000) * 10
				t[#t + 1] = {}
				t[#t].Id = bw
				t[#t].Name = res .. ' (' .. bw .. ' кбит/с)'
				t[#t].Address = track
			end
		end
		if #t == 0 then
			m_simpleTV.Control.CurrentAddress = retAdr
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('tvstart_qlty') or 20000)
	local index = #t
	if #t > 1 then
		t[#t + 1] = {}
		t[#t].Id = 20000
		t[#t].Name = '▫ всегда высокое'
		t[#t].Address = t[#t - 1].Address
		t[#t + 1] = {}
		t[#t].Id = 50000
		t[#t].Name = '▫ адаптивное'
		t[#t].Address = retAdr
		index = #t
			for i = 1, #t do
				if t[i].Id >= lastQuality then
					index = i
				 break
				end
			end
		if index > 1 then
			if t[index].Id > lastQuality then
				index = index - 1
			end
		end
		if m_simpleTV.Control.MainMode == 0 then
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
			t.ExtParams = {LuaOnOkFunName = 'tvstartSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128 + 8)
		end
	end
	
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function tvstartSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('tvstart_qlty', id)
	end
-- debug_in_file(retAdr .. '\n')
