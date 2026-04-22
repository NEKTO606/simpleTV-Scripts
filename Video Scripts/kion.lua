-- скрапер TVS для загрузки плейлиста "KION" https://kion.ru (21/4/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/NEKTO606/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: kion_pls.lua
-- расширение дополнения httptimeshift: kion-timeshift_ext.lua
-- ## открывает ссылки ##
-- https://kion.ru/PU1UWn3lrVFkw2SURNd12lHTmtG1VE8zSV2dZbVZX2TzRNRE80xSTJN6a0YyWX4hBek4=9
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://kion%.ru') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	inAdr = inAdr:gsub('$OPT:.+', '')
	inAdr = inAdr:match('([^/]+)$')
	local f = inAdr:sub(1, 1)
	local l = inAdr:sub(-1)
	local x = tonumber(f .. l)
	inAdr = inAdr:sub(2):sub(1, -2)
	local d = ''
	local s = ''
	local y = 1
	for i = 1, #inAdr do
		if i % 2 == 0 and y <= x then
			s = s .. inAdr:sub(i, i)
			y = y + 1
		else
			d = d .. inAdr:sub(i, i)
		end
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local inAdr = string.format(decode64('aHR0cHM6Ly9odHYtcnJzLm10cy5ydS9tdHMvb25saW5lL3BsdHYvJXMvJXMubXBkJE9QVDphZGFwdGl2ZS11c2UtYXZkZW11eCRPUFQ6YXZkZW11eC1vcHRpb25zPXtkZWNyeXB0aW9uX2tleT0lc30'), s, s, d)
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:149.0) Gecko/20100101 Firefox/149.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
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