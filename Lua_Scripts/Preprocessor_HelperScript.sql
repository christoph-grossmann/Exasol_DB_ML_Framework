CREATE OR REPLACE SCRIPT ML.Preprocessor_HelperScript() AS
function nextnonwhitespaceorcomment(tokens, curpos)
	while curpos <= #tokens and
			sqlparsing.iswhitespaceorcomment(tokens[curpos]) do
		curpos = curpos + 1
	end
	
	return curpos
end
function prevnonwhitespaceorcomment(tokens, curpos)
	while curpos > 0 and
			sqlparsing.iswhitespaceorcomment(tokens[curpos]) do
		curpos = curpos - 1
	end
	
	return curpos
end
function extractcolumns(tokens, curpos, clause)
	if curpos > #tokens or not (tokens[curpos] == "(") then
		error("Invalid object syntax for '" .. clause .. "' clause.")
	end
	
	curpos = nextnonwhitespaceorcomment(tokens, curpos + 1)
	local startpos = curpos
	local endpos = 0
	
	while curpos <= #tokens do
		if not (sqlparsing.isidentifier(tokens[curpos]) or
				sqlparsing.isstringliteral(tokens[curpos])) then
			error("Invalid object syntax for '" .. clause .. "' clause.")
		end
	
		endpos = curpos
		curpos = nextnonwhitespaceorcomment(tokens, curpos + 1)
		
		if curpos > #tokens then
			error("Invalid object syntax for '" .. clause .. "' clause.")
		elseif tokens[curpos] == ")" then
			break
		elseif not (tokens[curpos] == ",") then
			error("Invalid object syntax for '" .. clause .. "' clause.")
		end
	
		curpos = nextnonwhitespaceorcomment(tokens, curpos + 1)
	end
	
	curpos = nextnonwhitespaceorcomment(tokens, curpos + 1)
		
	if curpos > #tokens then
		error("Invalid object syntax for '" .. clause .. "' clause.")
	end
	
	return { curpos, jointokens(tokens, startpos, endpos) }
end
function jointokens(tokens, startpos, endpos)
	local str = ''
	
	for i = startpos, endpos do
		if not sqlparsing.iswhitespaceorcomment(tokens[i]) then
			str = str .. tokens[i]
		end
	end
	
	return str
end
