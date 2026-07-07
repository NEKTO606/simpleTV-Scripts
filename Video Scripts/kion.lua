-- скрапер TVS для загрузки плейлиста "KION" https://kion.ru (7/7/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/NEKTO606/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: kion_pls.lua
-- расширение дополнения httptimeshift: kion-timeshift_ext.lua
-- ## открывает ссылки ##
-- https://kion.ru/ru-tv/604
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://kion%.ru') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	inAdr = inAdr:gsub('$OPT:.+', '')
	local id = inAdr:match('([^/]%d*)$')

	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'

	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:152.0) Gecko/20100101 Firefox/152.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local code = decode64("bG9jYWwgaGVhZGVycyA9IG1fc2ltcGxlVFYuQ29tbW9uLkNyeXB0b2dyYXBoaWNIYXNoKG1fc2ltcGxlVFYuQ29tbW9uLkdldENNb2R1bGVFeHRlbnNpb24oKSwgTWQ1KSAuLiAnOiAnIC4uIG1fc2ltcGxlVFYuQ29tbW9uLkNyeXB0b2dyYXBoaWNIYXNoKG9zLmRhdGUoJyElWXwlbXwlZCcsIG9zLnRpbWUoKSksIE1kNSkgcmV0dXJuIGhlYWRlcnM")
	local headers = loadstring(code)()
	local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cDovL285Njg4OW5vLmJlZ2V0LnRlY2gva2lvbi5waHA/Yz0') .. id, headers = headers})
		if rc ~= 200 or answer == 'null' then return end
	require 'json'
	local err, tab = pcall(json.decode, answer)
		if not tab then return end
		for _, v in pairs(tab) do
			inAdr = string.format(decode64('aHR0cHM6Ly9odHYtcnJzLm10cy5ydS9tdHMvb25saW5lL3BsdHYvJXMvJXMubXBkJE9QVDphZGFwdGl2ZS11c2UtYXZkZW11eCRPUFQ6YXZkZW11eC1vcHRpb25zPXtkZWNyeXB0aW9uX2tleT0lc30'), v[1], v[1], v[2])
		end
	url = inAdr:gsub('$OPT:.+', '')
	local rc, answer = m_simpleTV.Http.Request(session, {url = url})
		if rc ~= 200 then return end
	local t = {}
		for w in answer:gmatch('<Representation[^>]+frameRate[^>]+>') do
				local bw = w:match('bandwidth="(%d+)')
				local res = w:match('height="(%d+)')
				if bw and res then
					bw = tonumber(bw)
					bw = math.ceil(bw / 100000) * 100
					t[#t + 1] = {}
					t[#t].Id = bw
					t[#t].Name = res .. 'p (' .. bw .. ' кбит/с)'
					t[#t].Address = string.format('%s$OPT:adaptive-logic=highest$OPT:adaptive-max-bw=%s', inAdr, bw)
				end
		end
		if #t == 0 then
			m_simpleTV.Control.CurrentAddress = inAdr
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('kion_qlty') or 8000)
	t[#t + 1] = {}
	t[#t].Id = 100000
	t[#t].Name = '▫ всегда высокое'
	t[#t].Address = t[#t - 1].Address
	t[#t + 1] = {}
	t[#t].Id = 500000
	t[#t].Name = '▫ адаптивное'
	t[#t].Address = inAdr
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
		t.ExtParams = {LuaOnOkFunName = 'kionSaveQuality'}
		m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function kionSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('kion_qlty', tostring(id))
	end

-- debug_in_file(t[index].Address .. '\n')