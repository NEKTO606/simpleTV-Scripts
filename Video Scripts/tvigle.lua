-- видеоскрипт для плейлиста "Tvigle" https://www.tvigle.ru (30/8/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/NEKTO606/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: tvigle_pls.lua
-- видеоскприпт: mediavitrina.lua
-- ## открывает подобные ссылки ##
-- https://tvigle.ru/220
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('https?://tvigle%.ru') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	inAdr = inAdr:gsub('$OPT:.+', '')
	local id = inAdr:match('([^/]%d+)$')
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:154.0) Gecko/20100101 Firefox/154.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, token = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly93d3cudHZpZ2xlLnJ1L2FwaS9iZmYvdXBkYXRlQXBwVG9rZW4v')})
		if rc ~= 200 then return end
	token = token:match('"token":"([^"]+)')
		if not token then return end
	local url = string.format(decode64('aHR0cHM6Ly93d3cudHZpZ2xlLnJ1L2FwaS90dmlnbGUtdHYvY2hhbm5lbHMvJXMvP3RzPTIwMjYtMDgtMzBUMTE6MTY6MTYuMjg0Wg'), id)
	local headers = 'Accept: application/json, text/plain, */*\nAuthorization: Token ' .. token
	local rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = headers})
		if rc ~= 200 then return end
	local adr = answer:match('broadcast_link":"([^"]+)')
		if not adr then return end
	if adr:match('player.mediavitrina.ru') then
		m_simpleTV.Control.ChangeAddress = 'No'
		m_simpleTV.Control.CurrentAddress = adr .. '$OPT:INT-SCRIPT-PARAMS=tvigle.ru'
		dofile(m_simpleTV.MainScriptDir .. 'user/video/video.lua')
	 return
	end
	url = string.format(decode64('aHR0cHM6Ly93d3cudHZpZ2xlLnJ1L3R2aWdsZS10di9hcGkvcGxheS92aWRlby8lcy8/cGFydG5lcl9pZD0yNA'), id)
	local rc, answer = m_simpleTV.Http.Request(session, {url = url})
		if rc ~= 200 then return end
	m_simpleTV.Http.Close(session)
	local retAdr = answer:match('"hls":%s?"([^"]+)')
		if not retAdr then return end
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(m_simpleTV.Control.CurrentAddress .. '\n')
