﻿--[[
Title: keepworkGen
Author(s): big
Date: 2017.4.24
Desc: generate KeepWork documentation 
-------------------------------------------------------
NPL.load("(gl)Mod/WorldShare/helper/KeepworkGen.lua");
local KeepworkGen = commonlib.gettable("Mod.WorldShare.helper.KeepworkGen");
-------------------------------------------------------
]]

local KeepworkGen = commonlib.gettable("Mod.WorldShare.helper.KeepworkGen");

--@param output: array of strings
--@param content: default to ""
--@return autogen_code_index
function KeepworkGen:InjectContent(output, content)
    local autogen_code_index;
    output[#output+1]  = "<!-- BEGIN_AUTOGEN: do NOT edit in this block -->\r\n";
    output[#output+1]  = content or "";
    autogen_code_index = #output;
    output[#output+1]  = "<!-- END_AUTOGEN-->\r\n";

    return autogen_code_index;
end

function KeepworkGen:GetContent(content)
    local from_code, from_code_end = content:find("<!%-%-%s*BEGIN_AUTOGEN: do NOT edit in this block %-%->");

    if(from_code) then
        local to_code, to_code_end = content:find("<!%-%-%s*END_AUTOGEN[^\r\n]*[\r\n]+", from_code_end);
        if(to_code) then
            return content:sub(from_code_end+1, to_code-1);
        end
    end
end

-- return array of text blocks and the index at which to insert autogenerated code. 
-- @return output, autogen_code_index
function KeepworkGen:GetAutoGenContent(content)
    local output = {};
    local autogen_code_index;
    
    local from_code, from_code_end = content:find("<!%-%-%s*BEGIN_AUTOGEN: do NOT edit in this block %-%->");

    if(from_code) then
        local to_code, to_code_end = content:find("<!%-%-%s*END_AUTOGEN[^\r\n]*[\r\n]+", from_code_end);
        if(to_code) then
            if(from_code>1) then
                output[#output+1] = content:sub(1, from_code-1);
            end
            autogen_code_index = self:InjectContent(output);
            output[#output+1] = content:sub(to_code_end+1, -1);
        end
    end

    if(not autogen_code_index) then
        autogen_code_index = self:InjectContent(output);
        output[#output+1] = content;
    end

    return output, autogen_code_index;
end

function KeepworkGen:SetAutoGenContent(content, text)
    if(not text and type(text) ~= "string") then
        return;
    end

    local output, autogen_code_index = self:GetAutoGenContent(content);
    if(output) then
        output[autogen_code_index] = text;
        return table.concat(output, "");
    end
end

function KeepworkGen:setCommand(command, params)
    local content = [[
```@{{command}}
{{params}}
```
]];

    if(command) then
        content = content:gsub("{{command}}" , command);
    else
        content = content:gsub("{{command}}" , "");
    end
    
    if(params)then
        params = NPL.ToJson(params, true);
    else
        params = "";
    end
    
    content = content:gsub("{{params}}" , params);

    return content;
end

function KeepworkGen:getCommand(command, content)
    content = content:gsub("```@" .. command , "");
    content = content:gsub("```" , "");

    local params = {};
    NPL.FromJson(content, params);

    return params;
end

KeepworkGen.readmeDefault = [[
### 作品介绍

本3D世界由[Paracraft](http://www.paracraft.cn/?lang=zh)创建。
[Paracraft](http://www.paracraft.cn/?lang=zh)创意空间是一款免费的3D创作软件。
适合全年龄层的用户使用。
[Paracraft](http://www.paracraft.cn/?lang=zh)创意空间可以创建3D场景和人物，制作动画和电影，并支持使用NPL语言对世界内容进行代码控制。
在软件中，还可欣赏不断更新的优秀电影作品，并创造属于您的个人作品。

<br/>

### 主要功能
– 学习电影与动画制作的基本原理。
– 支持3D建模，骨骼绑定。
– 支持镜头剪辑，并完成一部3D虚拟现实个人作品。
– 支持建立个人作品wiki网站（可访问[Keepwork.com](http://keepwork.com)）
– 支持发布作品到主流视频网站。
– 支持NPL语言，可以用编程的方式制作交互式3D场景。

<br/>

**官网地址：**[www.paracraft.cn](http://www.paracraft.cn/?lang=zh)
**软件下载：**[>点我查看<](http://www.paracraft.cn/download?lang=zh)
**视频教程：**[>点我查看<](https://github.com/LiXizhi/HourOfCode/wiki)

<br/>
]];

KeepworkGen.readmeEnglish = [[

]]

KeepworkGen.paracraftContainer = [[
```@template/js/default
{"class":"paracraft"}
```
]];