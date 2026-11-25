-- видеоскрипт для плейлиста "Винтера" https://vinteratv.com (25/11/26)
-- Copyright © 2017-2023 Nexterr, NEKTO666 | https://github.com/NEKTO606/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: vinteratv_pls.lua
-- видоскрипт: mediavitrina.lua
-- ## открывает подобные ссылки ##
-- https://vinteratv.com/tv/662

		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://vinteratv%.com') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	inAdr = inAdr:gsub('$OPT:.+', '')
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local id = inAdr:match('([^/]%d*)$')
		if not id then return end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:160.0) Gecko/20100101 Firefox/160.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly9jbXMudmludGVyYXR2LmNvbS9hcGkvY2hhbm5lbHMv') .. id})
		if rc ~= 200 or not answer then return end
	m_simpleTV.Http.Close(session)
	local retAdr = answer:match('"stream_url":"([^"]+)'):gsub('\\', '')
		if not retAdr then return end
	if retAdr:match('mediavitrina') then
		m_simpleTV.Control.ChangeAddress = 'No'
		m_simpleTV.Control.CurrentAddress = retAdr .. '$OPT:INT-SCRIPT-PARAMS=vinteratv.com'
		dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
	 return
	end
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
