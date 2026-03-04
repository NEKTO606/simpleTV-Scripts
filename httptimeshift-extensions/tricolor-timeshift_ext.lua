-- расширение дополнения httptimeshift - tricolor (4/3/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Addons
	function httpTimeshift_tricolor(eventType, eventParams)
		if eventParams.queryType == 'OnStop'
			and m_simpleTV.User
			and m_simpleTV.User.tricolor
			and m_simpleTV.User.tricolor.url_tmp
		then
			os.remove(m_simpleTV.User.tricolor.url_tmp)
		end
		if eventType == 'StartProcessing' then
			if not eventParams.params
				or not eventParams.params.address
			then
			 return
			end
			
			if not (eventParams.params.address:match('tricolor_out%.m3u8')
				and m_simpleTV.User
				and m_simpleTV.User.tricolor
				and m_simpleTV.User.tricolor.url_archive
				and m_simpleTV.User.tricolor.url_tmp)
			then
			 return
			end
			local function DateFormat(temp)
				local newdate = os.date("!%d/%m/%YT%H:%M:%S", temp)
				return newdate
			end
			local function GetTmp(url)
					local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0')
						if not session then return end
					m_simpleTV.Http.SetTimeout(session, 8000)
					local rc, answer = m_simpleTV.Http.Request(session, {url = url})
						if rc ~= 200 then return end
					local tmp = m_simpleTV.User.tricolor.url_tmp
					local fhandle = io.open(tmp, 'w+')
					if fhandle then
						fhandle:write(answer)
						fhandle:close()
					end
				return tmp
			end
			
			if eventParams.queryType == 'Start' then
				if eventParams.params.offset > 0 then
					local startTime = DateFormat(os.time() - (eventParams.params.offset / 1000))
					local endTime = DateFormat(currentTime)
					local url = m_simpleTV.User.tricolor.url_archive
					url = url .. '&startTime=' .. startTime .. '&endTime=' .. endTime .. '&curPos=' .. startTime
					local path = GetTmp(url)
						if not path then return end
					m_simpleTV.Common.Sleep(1000)
					eventParams.params.address = path
				end
			 return true
			end
			if eventParams.queryType == 'GetRecordAddress'
				or eventParams.queryType == 'IsRecordAble'
			then
				local addToStart = (httpTimeshift.startRecordMargin() * 60) or 0
				local addToEnd = (httpTimeshift.endRecordMargin() * 60) or 0
				local progid = eventParams.params.epgId
				local prog = m_simpleTV.EPG.GetProgrammeById(progid)
				local progS = prog.Start - addToStart
				local progE = prog.End + addToEnd
				local progstart = DateFormat(progS)
				local progend = DateFormat(progE)
				local url = m_simpleTV.User.tricolor.url_archive
				url = url .. '&startTime=' .. progstart .. '&endTime=' ..  progend
				local path = GetTmp(url)
					if not path then return end
				m_simpleTV.Common.Sleep(1000)
				eventParams.params.address = path
			 return true
			 end
		 return true
		end
	end
	httpTimeshift.addEventExecutor('httpTimeshift_tricolor')
