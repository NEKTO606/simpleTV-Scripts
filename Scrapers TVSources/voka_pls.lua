-- скрапер TVS для загрузки плейлиста "Voka" https://voka.tv (1/2/25)
-- Copyright © 2017-2026 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видеоскрипт: voka.lua
-- ## Переименовать каналы ##
local filter = {
	--{'Мир-ТВ', 'МИР'},
	}
	local host = 'https://voka.tv/'
	local my_src_name = 'Voka'
	module('voka_pls', package.seeall)
	local function ProcessFilterTableLocal(t)
		if not type(t) == 'table' then return end
		for i = 1, #t do
			t[i].name = tvs_core.tvs_clear_double_space(t[i].name)
			for _, ff in ipairs(filter) do
				if (type(ff) == 'table' and t[i].name == ff[1]) then
					t[i].name = ff[2]
				end
			end
		end
	 return t
	end
	function GetSettings()
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\voka.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 0}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function LoadFromSite()
		local cnannels = {
						{5, 'РТР Беларусь HD', 2},
						{6, 'НТВ Беларусь HD', 2},
						{8, 'Беларусь 3 HD', 2},
						{9, 'Беларусь 5 HD', 7},
						{10, 'Первый информационный HD', 7},
						{59, 'Киноман', 2},
						{84, 'Сарафан', 7},
						{109, 'Психология', 2},
						{110, 'Bridge TV Deluxe HD', 5},
						{131, 'RTG TV', 1},
						{157, 'Киномульт', 2},
						{167, 'Наука 2.0 HD', 7},
						{168, 'Оружие', 2},
						{171, 'Epic HD', 7},
						{175, 'НТВ Стиль', 7},
						{207, '.sci-fi', 7},
						{211, 'Нано ТВ HD', 2},
						{212, 'Luxury HD', 7},
						{214, 'Россия К', 2},
						{218, 'Наше ТВ HD', 2},
						{235, 'Шансон ТВ', 0},
						--{240, 'Mezzo', 7},
						{244, 'Рыбалка и охота', 2},
						{285, 'Наш кинопоказ HD', 7},
						{332, 'Феникс+Кино', 2},
						{335, 'Ретро', 2},
						{336, 'Драйв', 2},
						{341, 'Усадьба', 2},
						{342, 'Здоровое ТВ', 2},
						{540, 'VIJU Explore', 7},
						{541, 'VIJU History', 7},
						{542, 'VIJU Nature', 7},
						{545, 'VIJU TV1000 Новелла HD', 7},
						{583, 'Союз', 2},
						{588, 'Авто 24', 2},
						{602, 'Точка отрыва HD', 2},
						{603, 'Иллюзион+', 2},
						{693, 'Беларусь 2 HD', 2},
						{753, 'СТВ HD', 2},
						{754, 'МИР HD', 2},
						{849, 'ОНТ HD', 2},
						{869, 'Русский иллюзион HD', 1},
						--{871, 'Mezzo Live HD', 7},
						{903, 'Еврокино', 2},
						{907, 'Red Lips HD', 0},
						{961, 'Домашний', 2},
						{962, '8 канал HD Беларусь', 2},
						{963, 'Europa Plus TV', 1},
						{964, 'Travel+Adventure HD', 3},
						{966, 'БелМузТВ', 2},
						{971, 'Перец', 2},
						{972, 'RU.TV Беларусь', 0},
						{973, 'Светлое ТВ HD', 0},
						{977, 'ТВЦ+TV', 1},
						{992, 'НТВ Право', 7},
						{994, 'Curiosity Stream HD', 7},
						{996, 'Зоопарк', 2},
						{1013, '2-й городской канал', 0},
						{1042, 'ULTRA 4KEXTREME HD', 0},
						--{1092, 'Лапки LIVE', 7},
						{1123, 'VHS-ка', 2},
						{1124, 'Золотая коллекция', 2},
						{1205, 'NovellaTV HD', 7},
						{1247, 'Звезда Плюс HD', 2},
						{1303, 'Cartoon Classics', 7},
						{1400, '.red HD', 7},
						{1405, 'Время', 7},
						{1406, 'RTG HD', 7},
						{1448, 'СТС Kids HD', 7},
						{1492, 'DuckTV', 2},
						{1500, 'Terra HD', 3},
						{1515, 'Вопросы и ответы', 2},
						{1804, 'Start Air HD', 7},
						{1812, 'Кинеко HD', 7},
						{1908, 'Мир24 HD', 2},
						{2011, 'Беларусь 4 HD Гомель', 1},
						{2012, 'Беларусь 4 HD Витебск', 1},
						{2013, 'Беларусь 4 HD Брест', 1},
						{2018, 'ТВ XXI', 7},
						{2023, 'Витебск', 0},
						{2065, 'НТВ Сериал', 7},
						{2092, 'Cinema', 7},
						{2097, 'Беларусь 4 HD Могилёв', 1},
						{2100, 'MMA-TV.COM HD', 6},
						{2112, 'Домашние животные', 2},
						{2324, 'Дикая рыбалка HD', 2},
						{2325, 'Дикая охота HD', 2},
						{2424, 'Лёва HD', 3},
						{2812, 'Телекафе', 7},
						{3001, '.black', 7},
						{3005, 'Неизвестная Планета', 2},
						{3006, 'Movie Classic', 2},
						{3007, 'Советские Мультфильмы', 2},
						{3009, 'Extreme Sports', 7},
						{3012, 'Бобёр', 7},
						{3013, 'О!', 7},
						{3017, 'Терра Инкогнита HD', 2},
						{3018, 'Советское кино', 2},
						{3101, 'СКИФ HD', 2},
						--{3106, 'БелРос', 2},
						{3111, 'VIJU TV1000 romantica', 7},
						--{3434, 'Мир Баскетбола', 2},
						{3437, 'FunBox UHD', 0},
						{3870, 'Cinema Космос ТВ HD', 2},
						{3978, 'Сапфир HD', 7},
						{5007, 'Муви ТВ', 7},
						{5026, 'Candyman HD', 0},
						{5028, 'Поехали!', 7},
						{5105, 'Дом кино', 7},
						{5106, 'VIJU TV1000 action', 7},
						{5107, 'VIJU TV1000', 7},
						{5108, 'Мультиландия', 7},
						{5109, 'VIJU TV1000 Русское', 7},
						{5111, 'Дом кино Премиум', 7},
						{5120, 'ТНТ International HD', 2},
						{5121, 'Пятый канал', 3},
						{5123, 'Карусель', 2},
						{5127, 'ТВ3', 2},
						{5512, 'Уникум', 7},
						{6001, 'VIJU+ Premiere HD', 7},
						{6002, 'VIJU+ Megahit HD', 7},
						{6003, 'VIJU+ Comedy HD', 7},
						{6004, 'VIJU+ Serial HD', 7},
						{6005, 'VIJU+ Sport HD', 7},
						{6006, 'VIJU+ Planet HD', 7},
						{6007, 'Мульт HD', 7},
						{6008, 'НСТ', 7},
						{6028, 'Live music channel HD', 1},
						{6036, 'Первый городской телеканал HD', 2},
						{6238, 'Звязда HD', 3},
						{6239, 'Бобруйск 360', 2},
						{7001, 'БУГ-ТВ', 1},
						{7002, 'Лагуна ТВ HD', 1},
						{8000, 'Беларусь 1 HD', 2},
						{8001, 'ОНТ HD', 2},
						{8002, 'СТВ HD', 2},
						{8004, 'МИР HD', 2},
						{8112, 'Спорт ТВ HD', 2},
						{9011, 'Start World HD', 7},
						{9488, 'Umka HD', 7},
						{9489, 'Тех Лет ТВ', 2},
						--{11251, 'Classic Music HD', 1},
						{15082, 'Зал суда HD', 0},
						{21211, 'Da Vinci', 7},

		}
		local t = {}
			for _, v in pairs(cnannels) do
				if v[1] and v[2] and v[3] then
					t[#t + 1] = {}
					t[#t].name = unescape3(v[2])
					t[#t].address = host .. v[1]
					if v[3] > 0 then
						t[#t].RawM3UString = string.format('catchup="append" catchup-days="%s" catchup-source="?stream_start_offset=${offset}000000"', v[3])
					end
				end
			end
	 return t
	end
	function GetList(UpdateID, m3u_file)
			if not UpdateID then return end
			if not m3u_file then return end
			if not TVSources_var.tmp.source[UpdateID] then return end
		local Source = TVSources_var.tmp.source[UpdateID]
		local t_pls = LoadFromSite()
			if not t_pls or #t_pls == 0 then return end
		t_pls = ProcessFilterTableLocal(t_pls)
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(token .. '\n', "D:\xxx.txt")
