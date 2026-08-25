-- видеоскрипт для плейлиста "Beeline TV" https://beeline.tv (25/8/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/NEKTO606/simpleTV-Scripts/
-- ## необходим ##
-- скрапер TVS: beeline-tv_pls.lua
-- расширение дополнения httptimeshift: beeline-timeshift_ext.lua
-- ## открывает подобные ссылки ##
-- https://beeline.tv/sarafan/channel353
	if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
	if not m_simpleTV.Control.CurrentAddress:match('^https?://beeline%.tv')
		then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
	end
	local filter = {535, 479, 523, 480, 501, 495, 494, 484, 524, 492, 491, 504, 489, 490, 517, 496, 493, 503, 521, 502, 580, 579}
	local ids = {{481, 480}, {384 ,580}, {383, 579}}
	local inAdr = m_simpleTV.Control.CurrentAddress
	inAdr = inAdr:gsub('$OPT:.+', '')
	local id = inAdr:match('([^channel]%d*)$')
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	for _, v in pairs(ids) do
		if v[1] == tonumber(id) then
			id = v[2]
			break
		end
	end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:154.0) Gecko/20100101 Firefox/154.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local code = decode64("bG9jYWwgaGVhZGVycyA9IG1fc2ltcGxlVFYuQ29tbW9uLkNyeXB0b2dyYXBoaWNIYXNoKG1fc2ltcGxlVFYuQ29tbW9uLkdldENNb2R1bGVFeHRlbnNpb24oKSwgTWQ1KSAuLiAnOiAnIC4uIG1fc2ltcGxlVFYuQ29tbW9uLkNyeXB0b2dyYXBoaWNIYXNoKG9zLmRhdGUoJyElWXwlbXwlZCcsIG9zLnRpbWUoKSksIE1kNSkgcmV0dXJuIGhlYWRlcnM")
	local headers = loadstring(code)()
	local rc, tok = m_simpleTV.Http.Request(session, {url = decode64('aHR0cDovL285Njg4OW5vLmJlZ2V0LnRlY2gvYmVlbGluZS5waHA/Yz0') .. id, headers = headers})
		if rc ~= 200 or tok == nil then return end
	local url_tpl
	for _, v in pairs(filter) do
		if v == tonumber(id) then
			url_tpl = string.format(decode64('aHR0cHM6Ly92aWRlby5iZWVsaW5lLnR2L2xpdmUvZC9jaGFubmVsJXMuaXNtbC9tYW5pZmVzdC5tcGQ'), id)
			break
		end
	end
	if url_tpl == nil then
		url_tpl = string.format(decode64('aHR0cDovL3ZpZGVvLmJlZWxpbmUudHYvbGl2ZS9kL2NoYW5uZWwlcy5pc21sL21hbmlmZXN0LXN0Yi5tcGQ'), id)
	end
	inAdr = string.format(decode64('JXMkT1BUOmFkYXB0aXZlLXVzZS1hdmRlbXV4JE9QVDphdmRlbXV4LW9wdGlvbnM9e2RlY3J5cHRpb25fa2V5PSVzfQ'), url_tpl, tok)
	url = inAdr:gsub('$OPT:.+', '')
	local rc, answer = m_simpleTV.Http.Request(session, {url = url})
	
		if rc ~= 200 then return end
	local extOpt = string.format(decode64('JE9QVDphZGFwdGl2ZS11c2UtYXZkZW11eCRPUFQ6YXZkZW11eC1vcHRpb25zPXtkZWNyeXB0aW9uX2tleT0lc30'), tok)
	local t = {}
		for w in answer:gmatch('<Represe502, ntation[^>]+frameRate[^>]+>') do
			local bw = w:match('bandwidth="(%d+)')
			local res = w:match('height="(%d+)')
			if res and bw then
				bw = tonumber(bw)
				bw = math.ceil(bw / 100000) * 100
				t[#t + 1] = {}
				t[#t].Id = bw
				t[#t].Name = res .. 'p (' .. bw .. ' кбит/с)'
				t[#t].Address = string.format('%s%s$OPT:adaptive-logic=highest$OPT:adaptive-max-bw=%s', url, extOpt, bw)
			end
		end
		if #t == 0 then
			m_simpleTV.Control.CurrentAddress = inAdr
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('beeline_qlty') or 10000)
	t[#t + 1] = {}
	t[#t].Id = 10000
	t[#t].Name = '▫ всегда высокое'
	t[#t].Address = t[#t - 1].Address
	t[#t + 1] = {}
	t[#t].Id = 20000
	t[#t].Name = '▫ адаптивное'
	t[#t].Address = url .. extOpt
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
		t.ExtParams = {LuaOnOkFunName = 'beelineSaveQuality'}
		m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function beelineSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('beeline_qlty', id)
	end
-- debug_in_file(t[index].Address .. '\n')
