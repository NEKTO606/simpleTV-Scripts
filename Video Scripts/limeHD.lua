-- видеоскрипт для плейлиста "Lime HD" https://limehd.tv (26/6/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/NEKTO606/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: lime_hd_pls.lua
-- ## открывает подобные ссылки ##
-- https://limehd.tv/129
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://limehd%.tv/') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	inAdr = inAdr:gsub('$OPT:.+', '')
	local id = tonumber(inAdr:match('([^/]%d*)$'))
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('LimeHDTV/5.0.0 (com.infolink.LimeHDTV; build:1; iOS 16.2.0) Alamofire/5.0.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 12000)
	local header = decode64('WC1MSEQtQWdlbnQ6IHsidmVyc2lvbl9uYW1lIjoiNS4wLjAiLCJ2ZXJzaW9uX2NvZGUiOiI1MDAwMCIsInBsYXRmb3JtIjoiaW9zIiwibmFtZSI6ImlQaG9uZSIsImRldmljZV9pZCI6IjE0MzJGNzhFLUY4NzctNEY3OS1BRUE4LUQzRUJBRDBBQTBCMyIsImFwcCI6ImNvbS5pbmZvbGluay5MaW1lSERUViJ9')
	local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly9wbC5pcHR2MjAyMS5jb20vYXBpL3YxL3BsYXlsaXN0'), headers = header})
		if rc ~= 200 or not answer then return end
	answer = answer:gsub('\\', '\\\\')
	answer = answer:gsub('\\"', '\\\\"')
	answer = answer:gsub('\\/', '/')
	answer = answer:gsub('%[%]', '""')
	require 'json'
	local err, tab = pcall(json.decode, answer)
		if not tab then return end
	local retAdr
	for i = 1, #tab.channels do
		if tab.channels[i].id == id then
			retAdr = tab.channels[i].url
		 break
		end
	end
	m_simpleTV.Http.Close(session)
		if not retAdr then return end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:152.0) Gecko/20100101 Firefox/152.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local t = {}
		for w in answer:gmatch('EXT%-X%-STREAM%-INF(.-)\n') do
			local bw = w:match('[^%-]BANDWIDTH=(%d+)')
			local res = w:match('RESOLUTION=%d+x(%d+)')
			if bw and res then
				bw = tonumber(bw)
				bw = bw / 1000
				t[#t + 1] = {}
				t[#t].Id = tonumber(res)
				t[#t].Name = res .. 'p (' .. bw .. ' кбит/с)'
				t[#t].Address = string.format('%s$OPT:adaptive-logic=highest$OPT:adaptive-max-bw=%s', retAdr, bw)
			end
		end
		if #t == 0 then
			m_simpleTV.Control.CurrentAddress = retAdr
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('limehd_qlty') or 30000)
	t[#t + 1] = {}
	t[#t].Id = 50000
	t[#t].Name = '▫ всегда высокое'
	t[#t].Address = t[#t - 1].Address
	t[#t + 1] = {}
	t[#t].Id = 100000
	t[#t].Name = '▫ адаптивное'
	t[#t].Address = retAdr
	local index = #t
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
		t.ExtParams = {LuaOnOkFunName = 'limehdSaveQuality'}
		m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function limehdSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('limehd_qlty', id)
	end
-- debug_in_file(t[index].Address .. '\n')