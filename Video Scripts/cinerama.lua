-- видеоскрипт для плейлиста "cinerama" https://cinerama.uz (8/2/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: cinerama_pls.lua
-- ## открывает подобные ссылки ##
-- https://cinerama.uz/1228
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://cinerama%.uz/%d')
		then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	inAdr = inAdr:gsub('$OPT.+', '')
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local retAdr = string.format(decode64('aHR0cHM6Ly9zdHJlYW04LmNpbmVyYW1hLnV6LyVzL2luZGV4Lm0zdTg'), inAdr:match('([^/]%d*)$'))
		if not retAdr then return end
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
