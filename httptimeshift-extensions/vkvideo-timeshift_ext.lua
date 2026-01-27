-- расширение дополнения httptimeshift: "VK Видео TV" (7/1/26)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Addons
	function httpTimeshift_vkvideo(eventType, eventParams)
		if eventType == 'StartProcessing' then
			if not eventParams.params
				or not eventParams.params.address
			then
			 return
			end
			if not (eventParams.params.address:match('live%.vkvideo%.ru')
				or eventParams.params.address:match('vkvideo%.ru/live')
				or eventParams.params.address:match('%.okcdn%.ru/cmaf')
				and m_simpleTV.User
				and m_simpleTV.User.vklive
				and m_simpleTV.User.vklive.duration
				)
			then
			 return
			end
			if eventParams.queryType == 'Start' 
				or eventParams.queryType == 'TestAddress'
				or eventParams.queryType == 'GetLengthByAddress'
			then
				local m = math.floor((m_simpleTV.User.vklive.duration / 60) / 1000)
				eventParams.params.rawM3UString = string.format('catchup="append" catchup-minutes="%s" catchup-source="?offset_p=${offset}000"', m)
			 return true
			end
		 return true
		end
	end
	httpTimeshift.addEventExecutor('httpTimeshift_vkvideo')