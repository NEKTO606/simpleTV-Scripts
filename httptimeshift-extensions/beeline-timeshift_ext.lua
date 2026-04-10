-- расширение дополнения httptimeshift - beeline (9/4/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/NEKTO606/simpleTV-Scripts/
	function httpTimeshift_beeline(eventType, eventParams)
		if eventType == 'StartProcessing' then
			if not eventParams.params
				or not eventParams.params.address
			then
			 return
			end
			if not eventParams.params.address:match('video%.beeline%.tv')
			then
			 return
			end
			if eventParams.queryType == 'Start' then
				if eventParams.params.offset > 0 then
					local starttime = os.time() - (eventParams.params.offset / 1000)
					if eventParams.params.offset > 14100000 then
						stoptime = starttime + 14100
					else 
						stoptime = os.time()
					end
					local ts = '?starttime=' .. math.floor(starttime) .. '&stoptime=' .. math.floor(stoptime)
					eventParams.params.address = eventParams.params.address:gsub('%.mpd', '.mpd' .. ts)
				end
			 return true
			end
		 return true
		end
	end
	httpTimeshift.addEventExecutor('httpTimeshift_beeline')