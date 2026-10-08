-- видеоскрипт для плейлиста "КСК KZ" https://uplink.kz (8/10/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/NEKTO606/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: uplinkkz_pls.lua
-- ## открывает подобные ссылки ##
-- https://uplink.kz/perviy_kanal_evrasia
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://uplink%.kz')
		then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local id = inAdr:match('([^/]+)$')
	local retAdr = string.format(decode64('aHR0cHM6Ly9mcy51cGxpbmsua3ovJXMvaW5kZXgubTN1OD90b2tlbj1vbmxpbmV0dg'), id)
		if not retAdr then return end
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
