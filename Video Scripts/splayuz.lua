-- скрапер TVS для загрузки плейлиста "Splay UZ" https://splay.uz (5/2/26)
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
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	inAdr  = encode64(inAdr)
	local retAdr = string.format(decode64('aHR0cHM6Ly9hcGkuc3BsYXkudXovcnUvYXBpL3YzL2Jyb2FkY2FzdC9wbGF5L3MvWjlNbEgyQXdTNWpCVDd2b0NqYmpIS0Z6TEc5RU5sc0RaNWVwVVJiVmg3Yy9wLyVzLm0zdTg'), inAdr)
		if not retAdr then return end
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
