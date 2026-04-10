-- видеоскрипт для плейлиста "Beeline TV" https://beeline.tv (9/4/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/NEKTO606/simpleTV-Scripts/
-- ## необходим ##
-- скрапер TVS: beeline-tv_pls.lua
-- расширение дополнения httptimeshift: beeline-timeshift_ext.lua
-- ## открывает подобные ссылки ##
-- http://video.beeline.tv/live/d/channel056.isml/manifest-stb.mpd/051d258f0f94443c1f16409274228eca3ae2344ece22d0d13a74c260272747ac
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://video%.beeline%.tv/live/')
		then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	local x  = inAdr:match('([^/]+)$')
		if #x ~= 64 or x:match('[={$:-_%u]') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
	end
	inAdr = inAdr:gsub('$OPT:.+', '')
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:149.0) Gecko/20100101 Firefox/149.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local url = inAdr:gsub('/([^/]+)$', '')
	local d = ''
	for i = 0, #x do
		if i % 2 ~= 0 then
			d = d .. x:sub(i, i)
		end
	end
	local rc, answer = m_simpleTV.Http.Request(session, {url = url})
		if rc ~= 200 then return end
	local extOpt = string.format(decode64('JE9QVDphZGFwdGl2ZS11c2UtYXZkZW11eCRPUFQ6YXZkZW11eC1vcHRpb25zPXtkZWNyeXB0aW9uX2tleT0lc30'), d)
	local t = {}
		for w in answer:gmatch('<Representation[^>]+frameRate[^>]+>') do
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
		if #t == 0 then return end
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
