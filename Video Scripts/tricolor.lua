-- видеоскрипт для плейлиста "Триколор ТВ" https://tricolor.ru (2/3/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: tricolor_pls.lua
-- расширение дополнения httptimeshift: tricolor-timesift_ext.lua
-- ## открывает подобные ссылки ##
-- http://sgw.ott.tricolor.tv/streamingGateway/GetLivePlayList?source=Arkhyz_24.m3u8&serviceArea=MSK_SA_1
-- http://nea-live-stream.ott.tricolor.tv/streamingGateway/GetLivePlayList?source=domashny.m3u8
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('tricolor%.tv/streamingGateway/GetLivePlayList') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	inAdr = inAdr:gsub('$OPT:.+', '')
		
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.tricolor then
		m_simpleTV.User.tricolor = {}
	end
	
	local function showMsg(str, color)
		local t = {text = str, showTime = 1000 * 2, color = color, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	
	local function DeObfuscate(token)
		local str = ''
		local l = token:sub(-1)
		token =  l .. token:sub(1, -2)
		token = string.reverse(token)
		local f = tonumber(token:sub(1, 1))
			if not f then return 'Error' end
		f = f + 1
		token = token:sub(2)
		for i = 1, #token do
			if i % f ~= 0 then
				str = str .. token:sub(i, i)
			end
		end
		return str
	end
	
	local function Obfuscate(token)
		local str = ''
		local numb = '234567'
		local cs = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
		local rand_num = math.ceil(math.random() * #numb)
		local num = tonumber(numb:sub(rand_num,rand_num))
		str = num
		for i = 1, #token do
			local rand_char = math.ceil(math.random() * #cs)
			local c = cs:sub(rand_char,rand_char)
			str = str .. token:sub(i, i)
			if i % num == 0 then
				str = str .. c
			end
		end
		str = string.reverse(str)
		local f = str:sub(1, 1)
		str = str:sub(2) .. f
		return str
	end
	
	-- str = Obfuscate(token)
	-- str = DeObfuscate(str)
	-- debug_in_file(str .. '\n', "D:\xxx.txt")
	-- do return end
	
	local function CheckToken(token)
		local stat
		local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr .. '&drmreq=' .. token})
			if rc ~= 200 then return end
		for line in answer:gmatch("[^%c]+%c?") do 
		  url = line:match('^http://.-\n')
		end
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
			if rc ~= 200 then return end
		crypt = answer:match('#EXT%-X%-KEY:METHOD=AES%-128,URI="([^"]+)')
		if not crypt then
			stat = 200
		else
			local rc, answer = m_simpleTV.Http.Request(session, {url = crypt})
			if rc == 200 then
				stat = 200
			else	
				stat = answer:match('"title":"([^"]+)')
			end
		end
	 return stat
	end
	
	local function GetToken()
		local saveToken = m_simpleTV.Config.GetValue('tricolor_token')
		local tok
		local status
		if saveToken then
			saveToken = DeObfuscate(saveToken)
			if saveToken ~= 'Error' then
				status = CheckToken(saveToken)
				if status == 200 then
					tok = saveToken
				end
			end
		end
		if not saveToken or status ~= 200 or saveToken == 'Error' then
			local code = decode64("bG9jYWwgaGVhZGVycyA9IG1fc2ltcGxlVFYuQ29tbW9uLkNyeXB0b2dyYXBoaWNIYXNoKGRlY29kZTY0KCdKUzFFY0RSRScpLCBNZDUpIC4uICc6ICcgLi4gbV9zaW1wbGVUVi5Db21tb24uQ3J5cHRvZ3JhcGhpY0hhc2gob3MuZGF0ZSgnJVk8QHwjPiVtPCN8QD4lZCcsIG9zLnRpbWUoKSksIE1kNSkgcmV0dXJuIGhlYWRlcnM")
			local headers = assert(loadstring(code))()
			local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cDovL285Njg4OW5vLmJlZ2V0LnRlY2gvdGtuLW5ldy5waHA/dHY9dHJrbHI'), headers = headers})
			if rc ~= 200 or not answer then return end
				if answer then
					tok = decode64(answer)
					status = CheckToken(tok)
					if status == 200 then
						m_simpleTV.Config.SetValue('tricolor_token', Obfuscate(tok))
					else
						showMsg(status, ARGB(255,255, 0, 0))
					end
				else
					showMsg('Нет рабочего токена', ARGB(255,255, 0, 0))
				end
		end
	 return tok
	end
	
	local token = GetToken()
		if not token then return end
	local amp
	if inAdr:match('%?') then
		amp = '&'
	else 
		amp = '?'
	end
	
	if not inAdr:match('drmreq=') then
		inAdr = inAdr .. amp .. 'drmreq=' .. token
	end
	
	inAdr = inAdr:gsub('^http://', 'https://')
	m_simpleTV.User.tricolor.url_archive = inAdr:gsub('GetLivePlayList', 'GetNPVRPlayList')
	
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then return end
		
	local tmpName = m_simpleTV.Common.GetTmpName()
	
	m_simpleTV.User.tricolor.url_tmp = tmpName
	
	local fhandle = io.open(tmpName, 'w+')
	if fhandle then
		fhandle:write(answer)
		fhandle:close()
	end
	
	local t = {}
	for w in answer:gmatch('EXT%-X%-STREAM%-INF.-\n') do
		local bw = w:match('BANDWIDTH=(%d+)')
		local res = w:match('RESOLUTION=%d+x(%d+)')
		if bw then
			bw = tonumber(bw)
			bw = math.ceil(bw / 100000) * 100
			t[#t + 1] = {}
			if res then
				t[#t].Name = res .. 'p (' .. bw .. ' кбит/с)'
				t[#t].Id = tonumber(res)
				t[#t].Address = string.format('%s$OPT:adaptive-logic=highest$OPT:adaptive-maxheight=%s', tmpName, res)
			else
				t[#t].Name = bw .. ' кбит/с'
				t[#t].Id = bw
				t[#t].Address = string.format('%s$OPT:adaptive-logic=highest$OPT:adaptive-max-bw=%s', tmpName, bw)
			end
		end
	end

	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('tricolor_qlty') or 20000)
	local index = #t
	if #t > 1 then
		t[#t + 1] = {}
		t[#t].Id = 20000
		t[#t].Name = '▫ всегда высокое'
		t[#t].Address = t[#t - 1].Address
		t[#t + 1] = {}
		t[#t].Id = 50000
		t[#t].Name = '▫ адаптивное'
		t[#t].Address = retAdr
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
			t.ExtParams = {LuaOnOkFunName = 'tricolorSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128 + 8)
		end
	end

	m_simpleTV.Control.CurrentAddress = t[index].Address

	function tricolorSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('tricolor_qlty', id)
	end
-- debug_in_file(m_simpleTV.Control.CurrentAddress .. '\n')
