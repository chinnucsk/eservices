-module(eservices_variable_controller, [Req]).
-compile(export_all).


get('GET', [VarName]) ->
        case boss_db:find(squeue, [queue_name, 'equals', VarName], 1, 0, creation_time, num_descending) of
                [] ->
		        {jsonp, "Defaceit.Variable.response", [{variable_name, VarName}, {type, status}, {result, empty}]};
                [Variable|_] ->
			{jsonp, "Defaceit.Variable.response", [{variable_name, VarName},  {type, data}, {result, ok}, {data, Variable}]}
end.


get_pack('GET', [VariableNamespace]) ->
	case boss_db:find('squeue', [queue_name, 'matches', "*"++VariableNamespace]) of
		[] ->
			{jsonp, "Defaceit.Variable.response", [{'pack', []}]};
		Messages ->
			D = run(wrap(Messages)),
			{jsonp, "Defaceit.Variable.response", [{variable_name_space, VariableNamespace},{'pack',D}]}
	end.

wrap([]) ->
	[];
wrap([Message|Tail]) ->
	D = wrap(Tail),
	case lists:member(Message:queue_name(), D) of
		true ->
			D;
		_ ->
			[Message:queue_name()] ++ D
	end.


run([]) ->
	[];
run([A|Tail]) ->
	{_,_,B} = get('GET', [A]),
	run(Tail) ++ [B].



set('POST', [VarName]) ->
	NewMessage = squeue:new(id, Req:post_param("message_text"), erlang:now(), VarName),
	{ok, Saved} = NewMessage:save(),
	{jsonp, "Defaceit.Variable.response", [{variable_name, VarName}, {type, status},{result, "ok"}]}.


