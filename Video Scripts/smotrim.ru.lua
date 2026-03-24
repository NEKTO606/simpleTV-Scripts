-- видеоскрипт для сайта https://smotrim.ru (24/3/26)
-- Copyright © 2017-2026 NEKTO666 | https://github.com/NEKTO606/simpleTV-Scripts
-- ## Необходим ##
-- видеоскприпт: mediavitrina.lua
-- ## открывает подобные ссылки ##
-- https://smotrim.ru/channel/3
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://smotrim%.ru') then return end

	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = logo, TypeBackColor = 0, UseLogo = UseLogo, Once = 1})
	end

	local inAdr = m_simpleTV.Control.CurrentAddress
	inAdr = inAdr:gsub('$OPT.+', '')
	local id = inAdr:match('([^/]%d*)$')
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:148.0) Gecko/20100101 Firefox/148.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	
	local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly9wbGF5ZXItYXBpLnNtb3RyaW0ucnUvYXBpL3YxL2NoYW5uZWwv') .. id})
		if rc ~= 200 or not answer then return end
	local adr = answer:match('m3u8":%s?"([^"]+)')

	rc, answer = m_simpleTV.Http.Request(session, {url = adr})
		if rc ~= 200 then return end
	
	local t, i = {}, 1
		for w in answer:gmatch('EXT%-X%-STREAM%-INF(.-)\n') do
			local res = w:match('RESOLUTION=%d+x(%d+)')
			local bw = w:match('BANDWIDTH=(%d+)')
			if bw then
				bw = tonumber(bw)
				bw = math.ceil(bw / 10000) * 10
				t[#t + 1] = {}
				if res then
					t[#t].Name = res .. 'p (' .. bw .. ' кбит/с)'
				else
					t[#t].Name = bw .. ' кбит/с'
				end
				t[#t].Id = bw
				t[#t].Address = string.format('%s$OPT:adaptive-logic=highest$OPT:adaptive-max-bw=%s', adr, bw)
				end
			end
		if #t == 0 then
			m_simpleTV.Control.CurrentAddress = adr
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('smotrim_ru_qlty') or 30000)
	local index = #t
	if #t > 1 then
		t[#t + 1] = {}
		t[#t].Id = 30000
		t[#t].Name = '▫ всегда высокое'
		t[#t].Address = t[#t - 1].Address
		t[#t + 1] = {}
		t[#t].Id = 50000
		t[#t].Name = '▫ адаптивное'
		t[#t].Address = adr
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
			t.ExtParams = {LuaOnOkFunName = 'smotrim_ru_SaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function smotrim_ru_SaveQuality(obj, id)
		m_simpleTV.Config.SetValue('smotrim_ru_qlty', tostring(id))
	end

-- debug_in_file(retAdr .. '\n')
