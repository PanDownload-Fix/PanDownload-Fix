local curl = require "lcurl.safe"
local json = require "cjson.safe"


script_info = {
	["title"] = "搜盘8",
	["version"] = "0.0.1",
	["description"] = "勉强可用的网盘搜索(智能排序)",
}

function request(args)

	local cookie = args.cookie or ""
	local referer = args.referer or ""
	local header = args.header or {"User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36","Cookie: "..cookie,"Referer: "..referer}
	local method = args.method or "GET"
	local para = args.para
	local url = args.url
	local data = ""

	local c = curl.easy{
		url = url,
		ssl_verifyhost = 0,
		ssl_verifypeer = 0,
		timeout = 15,
		proxy = pd.getProxy(),
	}

	if para ~= nil then
		c:setopt(curl.OPT_POST, 1)
		c:setopt(curl.OPT_POSTFIELDS, para)
	end

	if header ~= nil then
		c:setopt(curl.OPT_HTTPHEADER, header)
	end

	if method == "HEAD" then
		c:setopt(curl.OPT_NOBODY, 1)
		c:setopt(curl.OPT_HEADERFUNCTION, function(h)
			data = data .. h
		end)
	else
		c:setopt(curl.OPT_WRITEFUNCTION, function(buffer)
			data = data .. buffer
			return #buffer
		end)
	end

	local _, err = c:perform()
	if err == nil and method == "HEAD" then
	end
	c:close()

	if err then
		return nil, tostring(err)
	else
		return data, nil
	end
end

function onSearch(key,page)
	local url = "https://www.soupan8.com/search/kw"..pd.urlEncode(key).."pg"..page
	local result = {}
	local start = 1
	local p_start,p_end,title,href,fileType,time,sharer
	local data = request({url=url})
	while true do
		--p_start,p_end,href,title,time,sharer=string.find(data,'<div class="info clear">.-<div class="title"><a href="(.-)" title="(.-)" target="_blank" >.-<div class="feed_time"><span>(.-)</span>.-的百度网盘分享" >(.-)</a></span>',start)
		
		p_start,p_end,href,title,time,sharer=string.find(data,'<div class="info clear">.-<div class="title"><a href="(.-)" title=".-" target="_blank" >(.-)</a></div>.-<div class="feed_time"><span>(.-)</span>.-的百度网盘分享" >(.-)</a></span>',start)
		if not href then
			--pd.logInfo("no href:..")
			break
		end
		href = "https://www.soupan8.com"..href
		local tooltip = string.gsub(title, '<font color="red" >(.-)</font>', "%1")
		title = string.gsub(title,'<font color="red" >(.-)</font>', "{c #ff0000}%1{/c}")
		description = "分享者："..sharer
		table.insert(result,{["href"]=href, ["title"]=title, ["time"]=time, ["showhtml"] = "true", ["tooltip"] = tooltip, ["description"] = description})
		start = p_end + 1
	end
	return result
end

function onItemClick(item)
	local url = getUrl(item.href)
	if url then
		return ACT_SHARELINK,url
	else
		return ACT_ERROR,"获取链接失败"
	end

end

function getUrl(href)
	local baiduPan_url,url
	local p_start,p_end,fileID = string.find(href,"https://www.soupan8.com/file/(%d+)")
	if fileID then
		url = "https://www.soupan8.com/redirect/file?id="..fileID
		data = request({url=url,referer=href})
		pd.logInfo("data:"..data)
		p_start,p_end,baiduPan_url = string.find(data," rel=\"noreferrer\" >(.-)?fid")
		p_start,p_end,pwd = string.find(data,"文件提取码：<.->(.-)</span>")
		if baiduPan_url == nil then
			p_start,p_end,baiduPan_url = string.find(data,"var url = '(.+)'")
		end
		pd.logInfo("href:"..baiduPan_url)
		if pwd ~= nil then
			pd.logInfo("pwd:"..pwd)
			baiduPan_url = baiduPan_url .. " " .. pwd
		end
	end
	return baiduPan_url
end

