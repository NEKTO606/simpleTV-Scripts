-- расширение дополнения httptimeshift "voka" https://voka.ru (4/5/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/NEKTO606/simpleTV-Scripts
	function httpTimeshift_voka(eventType, eventParams)
		if eventType == 'StartProcessing' then
			if not eventParams.params
				or not eventParams.params.address
			then
			 return
			end
			if not eventParams.params.address:match('%.voka%.tv') then return end
			if eventParams.queryType == 'Start' or eventParams.queryType == 'GetRecordAddress' then
				if eventParams.params.offset > 0 then
					local offset_add = eventParams.params.address:match('req_window_([^-]%d*)')
					local offset = (eventParams.params.offset * 1000) + offset_add
					local adr = eventParams.params.address:gsub('req_offset_%d*-', 'req_offset_' .. offset .. '-')
					eventParams.params.address = adr
				end
			 return true
			end
		 return true
		end
	end
	httpTimeshift.addEventExecutor('httpTimeshift_voka')