-- видеоскрипт для плейлиста "N3-entry TV" https://tv.n3.ru/ (24/2/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: tvn3_pls.lua
-- ## открывает подобные ссылки ##
-- https://tv.n3.ru/66ba1d2e9a7b3e72cc6625fa
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://tv%.n3%.ru')
		then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local function showMsg(str, color)
		local t = {text = str, showTime = 1000 * 3, color = color, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	local host = 'https://n3.server-api.lfstrm.tv/'
	local inAdr = m_simpleTV.Control.CurrentAddress
	inAdr = inAdr:gsub('$OPT:.+', '')
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local id = inAdr:match('([^/]*)$')
		if not id then return end
	
	local function CheckToken(token)
		local stat
		local rc, answer = m_simpleTV.Http.Request(session, {url = host .. 'playback-info-media/' .. id .. '?session=' .. token})
		if rc == 200 then
			stat = 200
		elseif rc ~= -1 and rc ~= 200 and answer:match('"msg":"([^"]+)') then
			stat = answer:match('"msg":"([^"]+)')
		end
	 return stat
	end	
	
	local function GetToken()
		local saveToken = m_simpleTV.Config.GetValue('tvn3_token')
		local tok
		if saveToken and CheckToken(saveToken) == 200 then
			tok = saveToken
		else
			local headers = m_simpleTV.Common.CryptographicHash(m_simpleTV.Common.GetCModuleExtension(), Md5) .. ': ' .. m_simpleTV.Common.CryptographicHash(os.date("!%Y|%m|%d", os.time()), Md5)
			local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cDovL285Njg4OW5vLmJlZ2V0LnRlY2gvdHZuMy5waHA'), headers = headers})
			if rc ~= 200 then return end
				if answer then
					answer = decode64(answer)
					
					if CheckToken(answer) == 200 then
						tok = answer
						m_simpleTV.Config.SetValue('tvn3_token', tok)
					else
						showMsg(CheckToken(answer), ARGB(255,255, 0, 0))
					end
				else
					showMsg('Нет рабочего токена', ARGB(255,255, 0, 0))
				end
		end
	 return tok
	end
	
	local token = GetToken()
		if not token then return end
	
	local url = host .. 'playback-info-media/' .. id .. '?session=' .. token
	local rc, answer = m_simpleTV.Http.Request(session, {url = url})
	local adr
	if rc ~= 200 then
		if answer and answer:match('msg":"([^"]+)') then
			showMsg(answer:match('msg":"([^"]+)'), ARGB(255,255, 0, 0))
		end
	elseif rc == 200 then
		answer = answer:gsub('\\', '\\\\')
		answer = answer:gsub('\\"', '\\\\"')
		answer = answer:gsub('\\/', '/')
		answer = answer:gsub('%[%]', '""')
		require 'json'
		local err, tab = pcall(json.decode, answer)
			if not tab or not tab.languages then return end
		for i = 1, #tab.languages[1].renditions do
			if tab.languages[1].renditions[i].id == 'Auto' then
				adr = tab.languages[1].renditions[i].url
			end
		end
	end
		if not adr then return end
	adr = adr:gsub('\\u0026', '&')
		if not adr then return end
	m_simpleTV.Control.CurrentAddress = adr

-- debug_in_file(m_simpleTV.Control.CurrentAddress .. '\n')