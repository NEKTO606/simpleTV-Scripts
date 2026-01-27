-- видеоскрипт для сайта https://vkvideo.ru (11/1/26)
-- Copyright © 2017-2026 Nexterr,NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://vkvideo.ru/tvchannels/-18496184_456260645
-- https://vkvideo.ru/live-116061363_456244502
-- https://live.vkvideo.ru/jove
-- https://live.vkvideo.ru/app/embed/sky_line
-- https://vkplay.live/c1ymba
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://vkvideo%.ru/tvchannels/')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://live%.vkvideo%.ru')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://vkvideo%.ru/live')
			and not m_simpleTV.Control.CurrentAddress:match('^https://vkplay%.live')
		then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	local logo = 'https://static.live.vkplay.ru/static/favicon.png?v='
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = logo, TypeBackColor = 0, UseLogo = 1, Once = 1})
	end
	
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	
	local retAdr
	local extOpt = '$OPT:http-user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0'
	
	if inAdr:match('tvchannels') or inAdr:match('vkvideo%.ru/live') then
		local body = 'client_secret=o557NLIkAErNhakXrQ7A&client_id=52461373'
		local rc, answer = m_simpleTV.Http.Request(session, {method = 'post', url = 'https://login.vk.com/?act=get_anonym_token', body = body})
			if rc ~= 200 then return end
		local token = answer:match('"access_token":"([^"]+)')
			if not token then return end
		local id = inAdr:match('([^/]+)$')
		id = id:gsub('live', '')
		local body = 'videos=' .. id .. '&access_token=' .. token
		local rc, answer = m_simpleTV.Http.Request(session, {method = 'post', url = 'https://api.vkvideo.ru/method/video.get?v=5.269&client_id=52461373', body = body})
			if rc ~= 200 then return end
		retAdr = answer:match('cmaf":"([^"]+)')
		retAdr = retAdr:gsub('\\/', '/')
		
	elseif inAdr:match('live%.vkvideo%.ru') or inAdr:match('vkplay%.live')  then
		local user = inAdr:match('([^/]+)$')
		local rc, answer = m_simpleTV.Http.Request(session, {url = 'https://api.live.vkvideo.ru/v1/channel/' .. user .. '/stream/slot/default?'})
			if rc ~= 200 then return end
		answer = answer:gsub('%[%]', '{}')
		require 'json'
		local err, tab = pcall(json.decode, answer)
			if not tab 
			or not tab.data 
			or not tab.data.stream 
			or not tab.data.stream.data
			or not tab.data.stream.data[1]
			then return end
		local addTitle = 'vkvideo'
		local title = tab.data.stream.user.displayName .. ' / ' .. tab.data.stream.title
		if not title then
			title = addTitle
		else
			if m_simpleTV.Control.MainMode == 0 then
				m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
				if tab.data.stream.user.avatarUrl and tab.data.stream.user.avatarUrl ~= ''
				then
					logo = tab.data.stream.user.avatarUrl
				end
				m_simpleTV.Control.ChangeChannelLogo(logo, m_simpleTV.Control.ChannelID, 'CHANGE_IF_NOT_EQUAL')
			end
			title = addTitle .. ' - ' .. title
		end
		m_simpleTV.Control.CurrentTitle_UTF8 = title
		
		for i = 1, #tab.data.stream.data[1].playerUrls do
			local typeUrl = tab.data.stream.data[1].playerUrls[i].type
			local adr = tab.data.stream.data[1].playerUrls[i].url
			local typeUrl = tab.data.stream.data[1].playerUrls[i].type
			local adr = tab.data.stream.data[1].playerUrls[i].url
			if typeUrl == 'live_ondemand_hls' and adr ~= '' then
				retAdr = adr
			break
			end
		end	
	end
	
	if inAdr:match('vkvideo%.ru%/video') then
		m_simpleTV.Control.CurrentAddress = retAdr .. extOpt
	 return
	end
	
	local gm, rs, bn
	if retAdr:match('%.mpd$') then
		gm = '<Representation id="video(.-)>'
		rs = 'height="([^"]%d+)'
		bn = 'bandwidth="([^"]%d+)'
		dr = '<vk:XPlaybackDuration>([^<]%d+)'
	elseif retAdr:match('%.m3u8$') then
		gm = '#EXT%-X%-STREAM%-INF:([^\n]+)'
		rs = 'resolution=%d+x(%d+)'
		bn = 'bandwidth=(%d+)'
		dr = '#EXT%-X%-VK%-PLAYBACK%-DURATION:([^\n]%d+)'
	end
	
		local rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
			if rc ~= 200 then return end
		m_simpleTV.Http.Close(session)
		
		if inAdr:match('live%.vkvideo%.ru') or inAdr:match('vkvideo%.ru/live') or inAdr:match('vkplay%.live') then
			if not m_simpleTV.User then
				m_simpleTV.User = {}
			end
			if not m_simpleTV.User.vklive then
				m_simpleTV.User.vklive = {}
			end
			local duration = answer:match(dr)
			if duration then
				m_simpleTV.User.vklive.duration = duration
			end
		end
		
		local t = {}
		for w in answer:gmatch(gm) do
			w = w:lower()
			local bw = w:match(bn)
			local res = w:match(rs)
			if bw then
				bw = tonumber(bw)
				bw = math.ceil(bw / 100000) * 100
				t[#t + 1] = {}
				if res then
					t[#t].Name = res .. 'p (' .. bw .. ' кбит/с)'
					t[#t].Id = tonumber(res)
					t[#t].Address = string.format('%s$OPT:adaptive-logic=highest$OPT:adaptive-maxheight=%s%s', retAdr, res, extOpt)
				else
					t[#t].Name = bw .. ' кбит/с'
					t[#t].Id = bw
					t[#t].Address = string.format('%s$OPT:adaptive-logic=highest$OPT:adaptive-max-bw=%s%s', retAdr, bw, extOpt)
					
				end
			end
		end
		
		if #t == 0 then
			m_simpleTV.Control.CurrentAddress = retAdr
		 return
		end

		table.sort(t, function(a, b) return a.Id < b.Id end)
		local lastQuality = tonumber(m_simpleTV.Config.GetValue('vkvideo_qlty') or 20000)
		local index = #t
		if #t > 1 then
			t[#t + 1] = {}
			t[#t].Id = 20000
			t[#t].Name = '▫ всегда высокое'
			t[#t].Address = t[#t - 1].Address
			t[#t + 1] = {}
			t[#t].Id = 50000
			t[#t].Name = '▫ адаптивное'
			t[#t].Address = adr
			index = #t
			for i = 1, #t do
				if t[i].Id >= lastQuality then
					index = i
				 break
				end
			end
			if index > 1 then
				if t[index].Id > lastQuality then
					index = index - 1
				end
			end

			if m_simpleTV.Control.MainMode == 0 then
				t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
				t.ExtParams = {LuaOnOkFunName = 'vkvideoSaveQuality'}
				m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128 + 8)
			end
		end
			
			m_simpleTV.Control.CurrentAddress = t[index].Address

	function vkvideoSaveQuality(obj, id)
			m_simpleTV.Config.SetValue('vkvideo_qlty', id)
	end
-- debug_in_file(token .. '\n', "D:\xxx.txt")