-- скрапер TVS для загрузки плейлиста "НТВ+" https://ntvplus.tv (20/12/25)
-- Copyright © 2017-2025 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: ntvplus_pls.lua
-- видеоскприпт: mediavitrina.lua
-- ## открывает ссылки ##
-- https://ntvplus.tv/44
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://ntvplus%.tv') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	inAdr = inAdr:gsub('$OPT.+', '')
	local id = inAdr:match('([^/]%d+)$')
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'

	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local headers = m_simpleTV.Common.CryptographicHash(m_simpleTV.Common.GetCModuleExtension(), Md5) .. ': ' .. m_simpleTV.Common.CryptographicHash(os.date("!%Y|%m|%d", os.time()), Md5)
	local rc, url = m_simpleTV.Http.Request(session, {url = decode64('aHR0cDovL285Njg4OW5vLmJlZ2V0LnRlY2gvbnR2LnBocD9jPQ') .. id, headers = headers})
	
	if url and url:match('mediavitrina') then
		m_simpleTV.Control.ChangeAddress = 'No'
		m_simpleTV.Control.CurrentAddress = url .. '$OPT:INT-SCRIPT-PARAMS=ntvplus.tv'
		dofile(m_simpleTV.MainScriptDir .. 'user/video/video.lua')
	 return
	end
	
		if rc ~= 200 or not url then return end
	local rc, answer = m_simpleTV.Http.Request(session, {url = url})
		if rc ~= 200 then return end
	adr = answer:match('"videoUrl":%s"([^"]+)')
	
	local rc, answer = m_simpleTV.Http.Request(session, {url = adr})
	if rc ~= 200 then return end
		
	local s = {}
		for w in answer:gmatch('EXT%-X%-STREAM%-INF(.-).m3u8') do
				local bw = w:match('BANDWIDTH=([^,]%d+)')
				local res = w:match('([^-]%d+)p$')
				bw = tonumber(bw)
				if bw and res and bw > 1000 then
					bw = math.ceil(bw / 100000) * 100
					s[#s + 1] = {}
					s[#s].Id = bw
					s[#s].Name = res .. 'p (' .. bw .. ' кбит/с)'
					s[#s].Address = string.format('%s$OPT:adaptive-logic=highest$OPT:adaptive-max-bw=%s', adr, bw)
				end
		end
		if #s == 0 then
			m_simpleTV.Control.CurrentAddress = adr
		 return
		end
		
	local hash = {}
	local t = {}
	for _,v in ipairs(s) do
	   if (not hash[v.Id]) then
		   t[#t + 1] = v
		   hash[v.Id] = true
	   end
	end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('ntv_qlty') or 8000)
	t[#t + 1] = {}
	t[#t].Id = 100000
	t[#t].Name = '▫ всегда высокое'
	t[#t].Address = t[#t - 1].Address
	t[#t + 1] = {}
	t[#t].Id = 500000
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
		t.ExtParams = {LuaOnOkFunName = 'ntvSaveQuality'}
		m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function ntvSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('ntv_qlty', tostring(id))
	end

-- debug_in_file(t[index].Address .. '\n')