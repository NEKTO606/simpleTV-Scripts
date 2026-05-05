-- видеоскрипт для плейлиста "Voka" https://voka.tv (5/5/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/NEKTO606/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: voka_pls.lua
-- ## открывает подобные ссылки ##
-- https://voka.tv/5108
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
	local id = inAdr:match('([^/]%d*)$')
	local userag = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:150.0) Gecko/20100101 Firefox/150.0'
	local session = m_simpleTV.Http.New(userag)
		if not session then return end
		
	local function GetCdn(token)
		local cdn
		local url = decode64('aHR0cHM6Ly9hcGkudm9rYS50di92MS9jaGFubmVscy8wMTFiOGU3ZS0zNzU1LTRjODctYmFmOS01NWQ3NGI1MmUwOWQvc3RyZWFtLmpzb24/YWNjZXNzX3Rva2VuPQ') .. token .. decode64('JmNsaWVudF9pZD0zZTI4Njg1Yy1mY2UwLTQ5OTQtOWQzYS0xZGFkMjc3NmUxNmEmY2xpZW50X3ZlcnNpb249NS4zLjEuNzQ2JmxvY2FsZT1ydS1SVSZ0aW1lem9uZT0xMDgwMCZhdWRpb19jb2RlYz1tcDRhJmRldmljZV90b2tlbj05MWJmOTYxZS1kNWU2LTQ0YmQtOTllYy01OTllY2Y5MzFhYTgmcHJvdG9jb2w9ZGFzaCZzY3JlZW5faGVpZ2h0PTQzMSZzY3JlZW5fd2lkdGg9MTQ0MCZ2aWRlb19jb2RlYz1oMjY0JmRybT1zcGJ0dmNhcw')
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
		if rc ~= -1 then
			if rc == 401 or not answer:match('"url":"(https://cdn.voka.tv/.-)"') then 
				cdn = 'error' 
			else
				cdn = answer:match('"url":"(https://cdn.voka.tv/.-)"')
			end
		end
	 return cdn
	end
	
	local function GetToken()
		local token
		if m_simpleTV.Config.GetValue('voka_token') then
			token = m_simpleTV.Config.GetValue('voka_token')
		elseif not m_simpleTV.Config.GetValue('voka_token') then
			local code = decode64("bG9jYWwgaGVhZGVycyA9IG1fc2ltcGxlVFYuQ29tbW9uLkNyeXB0b2dyYXBoaWNIYXNoKG1fc2ltcGxlVFYuQ29tbW9uLkdldENNb2R1bGVFeHRlbnNpb24oKSwgTWQ1KSAuLiAnOiAnIC4uIG1fc2ltcGxlVFYuQ29tbW9uLkNyeXB0b2dyYXBoaWNIYXNoKG9zLmRhdGUoJyElWXwlbXwlZCcsIG9zLnRpbWUoKSksIE1kNSkgcmV0dXJuIGhlYWRlcnM")
			local headers = loadstring(code)()
			local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cDovL285Njg4OW5vLmJlZ2V0LnRlY2gvdm9rYV90b2sucGhw'), headers = headers})
				if rc ~= 200 or not answer then return end
			m_simpleTV.Config.SetValue('voka_token', answer)
			token = answer
		end
	 return token
	end
	
	local cdn_link = GetCdn(GetToken())
	if cdn_link == 'error' then
		m_simpleTV.Config.Remove('voka_token')
		cdn_link = GetCdn(GetToken())
	end
	m_simpleTV.Http.Close(session)
		if not cdn_link then return end
		
	local prx = ''
	local session = m_simpleTV.Http.New(userag, prx, true)
		if not session then return end
	
	m_simpleTV.Http.SetRedirectAllow(session, false)
	m_simpleTV.Http.SetTimeout(session, 12000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = cdn_link})
		if rc ~= 302 then return end
	local head = m_simpleTV.Http.GetRawHeader(session)
	m_simpleTV.Http.Close(session)
	local adr = head:match('Location:%s(.-.mpd)')
	retAdr = adr:gsub('proxy/%d*/dash/%d*.mpd', 'proxy/'..id..'/dash/'..id..'.mpd')
	
		if not retAdr then return end
	m_simpleTV.Control.CurrentAddress = retAdr

-- debug_in_file(retAdr .. '\n')
