-module(eservices_question_controller, [Req]).
-compile(export_all).

% list function
list('GET'	, []) ->
	Q = boss_db:find(question,[]),
	{ok, [{questions, Q}]}.

create('GET', []) ->
	{ok, []};

create('POST', []) ->
	Q = Req:post_param("question_text"),
	NewQ = question:new(id, Q, ""),
	{ok, Saved} = NewQ:save(),
	{redirect, [{action, "list"}]}.
