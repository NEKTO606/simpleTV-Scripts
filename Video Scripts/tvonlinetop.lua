-- видеоскрипт для сайта rutv.pw (28/11/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/NEKTO606/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- http://tv-online.top/russia-today
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^http://tv%-online%.top') 
		then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	local host = 'http://tv-online.top'
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:161.0) Gecko/20100101 Firefox/161.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 12000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then return end
	local adr = answer:match('"GET","([^"]+)')
		if not adr then return end
	local headers = 'Referer: ' .. inAdr .. '\nX-Requested-With: XMLHttpRequest'
	local rc, answer = m_simpleTV.Http.Request(session, {url = host .. adr, headers = headers})
		if rc ~= 200 then return end
	m_simpleTV.Http.Close(session)
	local retAdr = answer:match('"u":"([^"]+)'):gsub('\\', '')
		if not retAdr then return end
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
