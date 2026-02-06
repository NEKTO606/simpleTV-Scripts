-- скрапер TVS для загрузки плейлиста "Splay UZ" https://splay.uz (6/2/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: splayuz_pls.lua
-- ## открывает подобные ссылки ##
-- https://vod.splay.uz/live_splay/original/Star_Cinema/tracks-v1a1/mono.m3u8
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://vod%.splay%.uz')
		then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	inAdr = inAdr:gsub('$OPT:.+', '')
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	
	local function GetToken()
		local headers = m_simpleTV.Common.CryptographicHash(m_simpleTV.Common.GetCModuleExtension(), Md5) .. ': ' .. m_simpleTV.Common.CryptographicHash(os.date("!%Y|%m|%d", os.time()), Md5)
		local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cDovL285Njg4OW5vLmJlZ2V0LnRlY2gvc3BsYXkucGhw'), headers = headers})
			if rc ~= 200 or not answer then return end
		return answer
	end
	
	local i = 0
	local function GetUrl(inAdr)
	i = i + 1
		local token = m_simpleTV.Config.GetValue('splay_token')
			if not token then
				token = GetToken()
				m_simpleTV.Config.SetValue('splay_token', token)
			end
		local adr = string.format(decode64('aHR0cHM6Ly9hcGkuc3BsYXkudXovcnUvYXBpL3YzL2Jyb2FkY2FzdC9wbGF5L3MvJXMvcC8lcy5tM3U4'), token, inAdr)
		local rc, answer = m_simpleTV.Http.Request(session, {url = adr})
		if rc ~= 200 and i == 1 then
			m_simpleTV.Config.Remove('splay_token')
			adr = GetUrl(inAdr)
		else
			return adr
		end
	end

	inAdr = encode64(inAdr)
	local retAdr = GetUrl(inAdr)
		if not retAdr then return end
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
