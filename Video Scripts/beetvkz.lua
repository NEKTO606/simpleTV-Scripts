-- видеоскрипт для плейлиста "BeeTV KZ" https://beetv.kz (26/4/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: beetvkz_pls.lua
-- ## открывает подобные ссылки ##
-- https://beetv.kz/77-tv/000002851
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('https?://beetv%.kz') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	inAdr = inAdr:gsub('$OPT:.+', '')
	local id = inAdr:match('([^/]%d+)$')
	--local prx = 'http://2.78.60.10:3129'
	local prx = ''
	inAdr = string.format(decode64('aHR0cHM6Ly9jb3JzLWVuZG9yc2FsLmhlcm9rdWFwcC5jb20vMTc2LjIyMi4xOTAuMTU2L2Jway10di8lcy90dmUvaW5kZXgubXBk'), id)
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0', prx, true)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 30000)
	m_simpleTV.Http.SetRedirectAllow(session, false)
	local headers = 'Origin: https://1.mediamaniya.site'
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr, headers = headers})
		if rc ~= 307 then return end
	local head = m_simpleTV.Http.GetRawHeader(session)
	local adr = head:match('Location:%shttps://cors%-endorsal.herokuapp.com/(.-)\n')
		if not adr then return end
	local rc, answer = m_simpleTV.Http.Request(session, {url = adr})
		if rc ~= 200 then return end
	m_simpleTV.Http.Close(session)
	local gm, rs, bn
	if adr:match('.m3u8') then
		gm = 'EXT%-X%-STREAM%-INF.-\n'
		rs = 'resolution=%d+x(%d+)'
		bn = ':bandwidth=(%d+)'
	else
		gm = '<Representation id="video(.-)>'
		rs = 'height="([^"]+)'
		bn = 'bandwidth="([^"]%d+)'
	end
	local t = {}
		for w in answer:gmatch(gm) do
			w = w:lower()
			local bw = w:match(bn)
			local res = w:match(rs)
			if bw and res then
				bw = tonumber(bw)
				bw = math.ceil(bw / 100000) * 100
				t[#t + 1] = {}
				t[#t].Id = bw
				t[#t].Name = res .. 'p (' .. bw .. ' кбит/с)'
				t[#t].Address = string.format('%s$OPT:adaptive-logic=highest$OPT:adaptive-max-bw=%s', adr, bw)
			end
		end
		if #t == 0 then
			m_simpleTV.Control.CurrentAddress = adr
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('beetvkz_qlty') or 30000)
	t[#t + 1] = {}
	t[#t].Id = 30000
	t[#t].Name = '▫ всегда высокое'
	t[#t].Address = t[#t - 1].Address
	t[#t + 1] = {}
	t[#t].Id = 50000
	t[#t].Name = '▫ адаптивное'
	t[#t].Address = adr
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
		t.ExtParams = {LuaOnOkFunName = 'beetvkzSaveQuality'}
		m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128 + 8)
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function beetvkzSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('beetvkz_qlty', id)
	end
-- debug_in_file(m_simpleTV.Control.CurrentAddress .. '\n')
