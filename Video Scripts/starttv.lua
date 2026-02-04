-- видеоскрипт для плейлиста "Start TV" https://start.ru (4/2/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: starttv_pls.lua
-- видеоскприпт: mediavitrina.lua
-- ## открывает подобные ссылки ##
-- https://start.ru/channel/baby-time
	local host = 'https://api.start.ru'
	if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
	if not m_simpleTV.Control.CurrentAddress:match('^https?://start%.ru')
		then return end	
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	
	local function showMsg(str, color)
		local t = {text = str, showTime = 1000 * 3, color = color, id = 'channelName'}
		 m_simpleTV.OSD.ShowMessageT(t)
	end
	
	local inAdr = m_simpleTV.Control.CurrentAddress
	inAdr = inAdr:gsub('$OPT:.+', '')
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local slug = inAdr:match('([^/]+)$')

	local url = string.format(decode64('aHR0cHM6Ly9hcGkuc3RhcnQucnUvbXVsdGlwbGV4L2NoYW5uZWxzLyVzP2FwaWtleT1hMjBiMTJiMjc5Zjc0NGYyYjNjN2I1YzU0MDBjNGViNSZ0ej0z'), slug)
	
	local rc, answer = m_simpleTV.Http.Request(session, {url = url})
		if rc ~= 200 or not answer then return end
	local stream = answer:match('"stream":"([^"]+)')
	
	if not stream and answer:match('"player"') then
	local player = answer:match('"player":"([^"]+)')
		if player and player:match('mediavitrina') then
			m_simpleTV.Control.ChangeAddress = 'No'
			m_simpleTV.Control.CurrentAddress = player .. '$OPT:INT-SCRIPT-PARAMS=start.ru'
			dofile(m_simpleTV.MainScriptDir .. 'user/video/video.lua')
		  return
		end
	end
	
	local url_2 = host .. stream .. '?apikey=a20b12b279f744f2b3c7b5c5400c4eb5&auth_token='
	
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.starttv then
		m_simpleTV.User.starttv = {}
	end
	
	local function GetToken()
		local headers = m_simpleTV.Common.CryptographicHash(m_simpleTV.Common.GetCModuleExtension(), Md5) .. ': ' .. m_simpleTV.Common.CryptographicHash(os.date("!%Y|%m|%d", os.time()), Md5)
		local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cDovL285Njg4OW5vLmJlZ2V0LnRlY2gvdGtuLnBocD90dj1zdGFydA'), headers = headers})
			if rc ~= 200 or not answer then return end
		return answer
	end
	
	local i = 0
	local function GetStream(url)
	i = i + 1
		local token = m_simpleTV.Config.GetValue('starttv_token')
			if not token then
				token = GetToken()
				m_simpleTV.Config.SetValue('starttv_token', token)
			end
		m_simpleTV.User.starttv.url_archive = url_2 .. token
		local rc, answer = m_simpleTV.Http.Request(session, {url = url .. token})
		local adr = answer:match('"hls":%s?"([^"]+)')
		if not adr and rc ~= 200 and i == 1 then
			m_simpleTV.Config.Remove('starttv_token')
			adr = GetStream(url)
		else
			if answer:match('"message"') then
				showMsg(answer:match('"message":%s?"([^"]+)'), ARGB(255,255, 0, 0))
			return
			end
		end
		if not adr then
			showMsg('Нет рабочего токена', ARGB(255,255, 0, 0))
		 return
		end
		return adr
	end
	
	local retAdr = GetStream(url_2)
		if not retAdr then return end
	m_simpleTV.Control.CurrentAddress = retAdr

 --debug_in_file(m_simpleTV.Control.CurrentAddress .. '\n'\)
