-- видеоскрипт для плейлиста "Lime HD" https://limehd.tv (16/8/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/NEKTO606/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: lime_hd_pls.lua
-- расширение дополнения httptimeshift: limehd-timeshift_ext.lua
-- ## открывает подобные ссылки ##
-- https://limehd.tv/129
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://limehd%.tv/') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.limehd then
		m_simpleTV.User.limehd = {}
	end
	inAdr = inAdr:gsub('$OPT:.+', '')
	local id = tonumber(inAdr:match('([^/]%d*)$'))
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:153.0) Gecko/20100101 Firefox/153.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 20000)
	
	local function CheckToken(token)
		if token then
			local header = string.format('x-lhd-agent: {"platform":"web","app":"limehd.tv","device_id":"194973.63324970874-1785414641196"}\nx-token: %s', token)
			local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly9wbC5pcHR2MjAyMS5jb20vYXBpL3Y0L2NoYW5uZWwva2lub2NvbWVkaWE/ZXBnPTA'),  headers = header})
				if rc ~= 200 or not answer then return end
			answer = answer:gsub('\\', '\\\\')
			answer = answer:gsub('\\"', '\\\\"')
			answer = answer:gsub('\\/', '/')
			answer = answer:gsub('%[%]', '""')
			require 'json'
			local err, tab = pcall(json.decode, answer)
				if not tab then return end
			if tab.url and tab.url ~= '' then
				return 200
			else
				return 'error'
			end
		end
	end
	
	local function GetToken()
		local token = m_simpleTV.Config.GetValue('lime_token')
		if not token or CheckToken(token) ~= 200 then
			local code = decode64("bG9jYWwgaGVhZGVycyA9IG1fc2ltcGxlVFYuQ29tbW9uLkNyeXB0b2dyYXBoaWNIYXNoKG1fc2ltcGxlVFYuQ29tbW9uLkdldENNb2R1bGVFeHRlbnNpb24oKSwgTWQ1KSAuLiAnOiAnIC4uIG1fc2ltcGxlVFYuQ29tbW9uLkNyeXB0b2dyYXBoaWNIYXNoKG9zLmRhdGUoJyElWXwlbXwlZCcsIG9zLnRpbWUoKSksIE1kNSkgcmV0dXJuIGhlYWRlcnM")
			local headers = loadstring(code)()
			local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cDovL285Njg4OW5vLmJlZ2V0LnRlY2gvbGltZS5waHA'), headers = headers})
				if rc ~= 200 or not answer then return end
			if CheckToken(answer) == 200 then
				m_simpleTV.Config.SetValue('lime_token', answer)
				token = answer
			else
				token = 'error'
			end
		end
	 return token
	end
	
	local tok = GetToken()
	local tok_str
	if tok and tok ~= 'error' then
		tok_str = '\nx-token: ' .. tok
	else 
		tok_str = ''
	end

	local header = 'x-lhd-agent: {"platform":"web","app":"limehd.tv","device_id":"194973.63324970874-1785414641196"}' .. tok_str
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
			m_simpleTV.User.limehd.url_archive = tab.channels[i].url_archive
		 break
		end
	end
		if not retAdr then return end
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