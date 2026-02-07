-- видеоскрипт для плейлиста "Voka" https://voka.tv (7/2/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: voka_pls.lua
-- ## открывает подобные ссылки ##
-- https://voka.tv/9489
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://voka%.tv/')
		then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	inAdr = inAdr:gsub('$OPT.+', '')
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local id = inAdr:match('([^/]%d*)$')
	
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	
	local function showMsg(str, color)
		local t = {text = str, showTime = 1000 * 2, color = color, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	
	local function GetToken()
		local headers = m_simpleTV.Common.CryptographicHash(m_simpleTV.Common.GetCModuleExtension(), Md5) .. ': ' .. m_simpleTV.Common.CryptographicHash(os.date("!%Y|%m|%d", os.time()), Md5)
		local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cDovL285Njg4OW5vLmJlZ2V0LnRlY2gvdm9rYS5waHA'), headers = headers})
			if rc ~= 200 or not answer then return end
		return answer
	end
	
	local x
	local y = 0
	local function GetStream()
		y = y + 1
		local token = m_simpleTV.Config.GetValue('voka_token')
			if not token then
				token = GetToken()
				m_simpleTV.Config.SetValue('voka_token', token)
			end
		local cache = {'01t', '02t', '03t', '04i', '05i', '06i', '07t'}
		local t = {}
		for i = 1, #cache do
			local adress = string.format(decode64('aHR0cHM6Ly9taW5zay1jYWNoZSVzLnZva2EudHYvdG9rXyVzL2xpdmUvcHJveHkvJXMvZGFzaC8lcy5tcGQ'), cache[i], token, id, id)
			local rc, answer = m_simpleTV.Http.Request(session, {url = adress})
			if rc == 200 then
				x = adress
			break
			end
		end
		if not x and y < 3 then
			m_simpleTV.Config.Remove('voka_token')
			GetStream()
		end
		if x then
			return x
		end
	end
	
	local adr = GetStream()
		if not adr then return end
	local rc, answer = m_simpleTV.Http.Request(session, {url = adr})
		if rc ~= 200 then return end
		
	local t = {}
		for w in answer:gmatch('<Representation id="vid(.-)>') do
				local bw = w:match('bandwidth="([^"]%d+)')
				local res = w:match('height="([^"]%d+)')
				bw = tonumber(bw)
				if bw and res and bw > 1000 then
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
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('voka_qlty') or 8000)
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
		t.ExtParams = {LuaOnOkFunName = 'vokaSaveQuality'}
		m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function vokaSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('voka_qlty', tostring(id))
	end
-- debug_in_file(retAdr .. '\n')
