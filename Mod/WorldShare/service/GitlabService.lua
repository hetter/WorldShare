--[[
Title: GitlabService
Author(s):  big
Date:  2017.4.15
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/WorldShare/service/GitlabService.lua");
local GitlabService = commonlib.gettable("Mod.WorldShare.service.GitlabService");
------------------------------------------------------------
]]

NPL.load("(gl)Mod/WorldShare/service/HttpRequest.lua");
NPL.load("(gl)Mod/WorldShare/login.lua");
NPL.load("(gl)Mod/WorldShare/main.lua");
NPL.load("(gl)script/ide/Encoding.lua");
NPL.load("(gl)Mod/WorldShare/SyncMain.lua");

local HttpRequest   = commonlib.gettable("Mod.WorldShare.service.HttpRequest");
local login		    = commonlib.gettable("Mod.WorldShare.login");
local GitEncoding   = commonlib.gettable("Mod.WorldShare.helper.GitEncoding");
local WorldShare    = commonlib.gettable("Mod.WorldShare");
local Encoding      = commonlib.gettable("commonlib.Encoding");
local SyncMain      = commonlib.gettable("Mod.WorldShare.sync.SyncMain");

local GitlabService = commonlib.gettable("Mod.WorldShare.service.GitlabService");

GitlabService.inited = false;

function GitlabService:apiGet(_url, _callback)
	HttpRequest:GetUrl({
		url     = login.apiBaseUrl .. "/" .._url,
		json    = true,
		headers = {
			["PRIVATE-TOKEN"] = login.dataSourceToken,
			["User-Agent"]    = "npl",
		},
	},_callback);
end

function GitlabService:apiPost(_url, _params, _callback)
	HttpRequest:GetUrl({
		url       = login.apiBaseUrl .. _url,
		json      = true,
		headers   = {
			["PRIVATE-TOKEN"] = login.dataSourceToken,
			["User-Agent"]    = "npl",
			["content-type"]  = "application/json"
		},
		form = _params,
	},_callback);
end

function GitlabService:apiPut(_url, _params, _callback)
	HttpRequest:GetUrl({
		method     = "PUT",
		url        = login.apiBaseUrl .. _url,
		json       = true,
	  	headers    = {
		  	["PRIVATE-TOKEN"] = login.dataSourceToken,
			["User-Agent"]    = "npl",
			["content-type"]  = "application/json"
		},
		form = _params
	},_callback);
end

function GitlabService:apiDelete(_url, _params, _callback)
	local github_token = login.dataSourceToken;
	
	LOG.std(nil,"debug","GithubService:githubApiDelete",github_token);

	HttpRequest:GetUrl({
		method     = "DELETE",
		url        = login.apiBaseUrl .. _url,
		json       = true,
	  	headers    = {
	  		["PRIVATE-TOKEN"] = login.dataSourceToken,
			["User-Agent"]    = "npl",
			["content-type"]  = "application/json"
		},
		form = _params,
	},_callback);
end

function GitlabService:getFileUrlPrefix()
    return '/projects/' .. GitlabService.projectId .. '/repository/files/';
end

function GitlabService:getCommitMessagePrefix()
    return "keepwork commit: ";
end

-- ����ļ��б�
function GitlabService:getTree(_foldername,_callback)
    local url = '/projects/' .. GitlabService.projectId .. '/repository/tree?recursive=true';
	GitlabService:apiGet(url,function(data,err)
		for key,value in ipairs(data) do
			value.sha = value.id;
		end

		_callback(data,err);
	end);
end

-- commit
function GitlabService:listCommits(data, cb, errcb)
    --data.ref_name = data.ref_name || 'master';
    local url = '/projects/' .. GitlabService.projectId .. '/repository/commits';
    GitlabService:httpRequest('GET', url, data, cb, errcb);
end

-- д�ļ�
function GitlabService:writeFile(_filename,_file_content_t,_callback) --params, cb, errcb
    local url = GitlabService:getFileUrlPrefix() .. _filename;

	local params = {
		commit_message = GitlabService:getCommitMessagePrefix() .. _filename,
		branch		   = "master",
		content 	   = _file_content_t,
	}

	GitlabService:apiPost(url, params, function()
		_callback(true,_filename);
	end);
end

--�����ļ�
function GitlabService:update(_filename, _file_content_t, _sha, _callback)
	local url = GitlabService:getFileUrlPrefix() .. _filename;

	local params = {
		commit_message = GitlabService:getCommitMessagePrefix() .. _filename,
		branch		   = "master",
		content 	   = _file_content_t,
	}

	GitlabService:apiPut(url, params, function()
		_callback(true,_filename);
	end);
end

-- ��ȡ�ļ�
function GitlabService:getContent(_path, _callback)
    local url  = GitlabService:getFileUrlPrefix() .. _path .. '?ref=master';
	--LOG.std(nil,"debug","apiGet-url",url);
	GitlabService:apiGet(url, function(data, err)
		LOG.std(nil,"debug","apiGet-data",data);
		LOG.std(nil,"debug","apiGet-err",err);

		_callback(data.content, err);
	end);
end

-- ��ȡ�ļ�
function GitlabService:getContentWithRaw(_foldername, _path, _callback)
	_foldername = GitEncoding.base64(_foldername);

	local url  = login.rawBaseUrl .. "/" .. login.dataSourceUsername .. "/" .. _foldername .. "/raw/master/" .. _path;

	HttpRequest:GetUrl({
		url     = url,
		json    = true,
		headers = {
			["PRIVATE-TOKEN"] = login.dataSourceToken,
			["User-Agent"]    = "npl",
		},
	},function(data, err)
		if(err == 200) then
			_callback(data, err);
		end
	end);
end

-- ɾ���ļ�
function GitlabService:deleteFile(_path, _sha, _callback)
    local url = GitlabService:getFileUrlPrefix() .. _path;

	local params = {
		commit_message = GitlabService:getCommitMessagePrefix() .. _path,
		branch         = 'master',
	}

	GitlabService:apiDelete(url, params, _callback);
end

--ɾ����
function GitlabService:deleteResp(_foldername, _callback)
	local url = "/projects/" .. GitlabService.projectId;

	GitlabService:apiDelete(url, {}, _callback);
end

-- ��ʼ��
function GitlabService:init(_foldername, _callback)
	_foldername = GitEncoding.base64(_foldername);
	local url   = "/projects";

	GitlabService:apiGet(url .. "?owned=true",function(projectList,err)
        for i=1,#projectList do
            if (projectList[i].name == _foldername) then
				GitlabService.projectId = projectList[i].id;

				if(SyncMain.worldName) then
					WorldShare:SetWorldData("gitLabProjectId", GitlabService.projectId, SyncMain.worldName);
					WorldShare:SaveWorldData(SyncMain.worldName);
				else
					GitlabService.projectId = WorldShare:GetWorldData("gitLabProjectId");
					WorldShare:SaveWorldData();
				end

                _callback(nil,201);
				return;
            end

			local params = {
				name = _foldername,
				request_access_enabled = true,
				visibility = "public",
			};

			GitlabService:apiPost(url, params, function(data,err)
				if(data.id ~= nil) then
					GitlabService.projectId = data.id;

					if(SyncMain.worldName) then
						WorldShare:SetWorldData("gitLabProjectId", GitlabService.projectId, SyncMain.worldName);
						WorldShare:SaveWorldData(SyncMain.worldName);
					else
						GitlabService.projectId = WorldShare:GetWorldData("gitLabProjectId");
						WorldShare:SaveWorldData();
					end

					LOG.std(nil,"debug","GitlabService.projectId",GitlabService.projectId);
					LOG.std(nil,"debug","err",err);
					_callback(nil,201);
					return;
				end
			end);
        end
	end);
end