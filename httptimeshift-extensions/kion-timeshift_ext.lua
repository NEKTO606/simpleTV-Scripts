-- расширение дополнения httptimeshift "kion" https://kion.ru (21/4/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/NEKTO606/simpleTV-Scripts
	function httpTimeshift_kion(eventType, eventParams)
		if eventType == 'StartProcessing' then
			if not eventParams.params
				or not eventParams.params.address
			then
			 return
			end
			if not eventParams.params.address:match('%.mts%.ru') then return end
			local function DateFormat(temp)
				local temp = temp - 10800
				local newdate = os.date("%Y%m%d%H%M00", temp)
				return newdate
			end
			if eventParams.queryType == 'Start' then
				if eventParams.params.offset > 0 then
					local startTime = DateFormat((os.time() - (eventParams.params.offset / 1000)))
					local endTime = DateFormat(os.time())
					local playseek = '?servicetype=3&playseek=' .. startTime .. '-' .. endTime .. '&timezone=UTC'
					eventParams.params.address = eventParams.params.address:gsub('%.mpd', '.mpd' .. playseek)
				end
			 return true
			end
			if eventParams.queryType == 'GetRecordAddress'
				or eventParams.queryType == 'IsRecordAble'
			then
				local progid = eventParams.params.epgId
				local prog = m_simpleTV.EPG.GetProgrammeById(progid)
				local progstart = DateFormat(prog.Start)
				local progend = DateFormat(prog.End)
				local playseek = '?servicetype=3&playseek=' .. progstart .. '-' .. progend .. '&timezone=UTC'
				eventParams.params.address = eventParams.params.address:gsub('%.mpd', '.mpd' .. playseek)
			 return true
			 end
		 return true
		end
	end
	httpTimeshift.addEventExecutor('httpTimeshift_kion')