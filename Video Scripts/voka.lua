-- видеоскрипт для плейлиста "Voka" https://voka.tv (4/5/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/NEKTO606/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: voka_pls.lua
-- ## открывает подобные ссылки ##
-- https://voka.tv/c85c5b22-51fb-4b01-99b6-197b2e29e855
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
	local id = inAdr:match('([^/]*)$')
	if m_simpleTV.Config.GetValue('voka_token') then
		m_simpleTV.Config.Remove('voka_token')
	end
	local inAdr = string.format(decode64('aHR0cDovLzkyLjYzLjEwNi40MS9wdHYvdm9rYS9jaC5waHA/aWQ9JXM'), id)
	local prx = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:150.0) Gecko/20100101 Firefox/150.0', prx, true)
		if not session then return end
	m_simpleTV.Http.SetRedirectAllow(session, false)
	m_simpleTV.Http.SetTimeout(session, 12000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 302 then return end
	local head = m_simpleTV.Http.GetRawHeader(session)
	m_simpleTV.Http.Close(session)
	local adr = head:match('Location:%s(.-.m3u8)')
	
		if not adr then return end
	
	m_simpleTV.Control.CurrentAddress = adr

-- debug_in_file(retAdr .. '\n')
