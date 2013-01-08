-module(eservices_queue_controller, [Req]).
-compile(export_all).

% list returns all messages stored in queue
list('GET', [])->
    case boss_db:find(squeue, [queue_name, 'equals', 'all']) of
	[] ->
	    {output, "//No messages"};
	Messages ->
	    {jsonp, "Defaceit.Queue.response", [{queue_name, 'all'},{type, messages}, {result, ok}, {data, Messages}]}
end;
list('GET', [QueueName,CallId]) ->
    case boss_db:find(squeue, [queue_name, 'equals', QueueName]) of
	[] ->
	    
	    {jsonp, "Defaceit.Queue.response", [{queue_name, QueueName}, {call_id, CallId}, {type, status}, {result, empty}]};
	Messages ->
	    {jsonp, "Defaceit.Queue.response", [{queue_name, QueueName}, {call_id, CallId}, {type, messages}, {result, ok}, {data, Messages}]}
	    
end.

% share function used for get data for queue
top('GET', []) ->
	Ip = string:join(io_lib:format("~p~p~p~p", tuple_to_list(Req:peer_ip())),"."),
	case boss_db:find(squeue, [queue_name, 'equals', 'all'], 1, 0, creation_time, num_descending) of
		[] ->
			{output, "//No messages"};
		[Message|_] ->
			Key = Message:id(),
			case boss_db:find(stoplist, [{ip, 'equals', Ip}, {key, 'equals', Key}]) of
				[] ->
					NewStop = stoplist:new(id, Ip, Key),
					{ok, Saved} = NewStop:save(),
					{jsonp, "Defaceit.Queue.response", [{queue_name, 'all'}, {type, message}, {result, ok}, {data, Message}]};
				[Stop|_] ->
					{output, "//No messages"}
				end
	end;
top('GET', [QueueName,CallId]) ->
        Ip = string:join(io_lib:format("~p~p~p~p", tuple_to_list(Req:peer_ip())),"."),
        case boss_db:find(squeue, [queue_name, 'equals', QueueName], 1, 0, creation_time, num_descending) of
                [] ->
                        {output, "//No messages"};
                [Message|_] ->
                        Key = Message:id(),
                        case boss_db:find(stoplist, [{ip, 'equals', Ip}, {key, 'equals', Key}]) of
                                [] ->
                                        NewStop = stoplist:new(id, Ip, Key),
                                        {ok, Saved} = NewStop:save(),
					{jsonp, "Defaceit.Queue.response", [{queue_name, QueueName}, {call_id, CallId}, {type, message}, {result, ok}, {data, Message}]};
                                        
                                [Stop|_] ->
                                        {output, "//No messages"}
                        end

	end.

last('GET', [QueueName,CallId]) ->
        case boss_db:find(squeue, [queue_name, 'equals', QueueName], 1, 0, creation_time, num_descending) of
                [] ->
		        {jsonp, "Defaceit.Queue.response", [{queue_name, QueueName}, {call_id, CallId}, {type, status}, {result, empty}]};
                [Message|_] ->
			{jsonp, "Defaceit.Queue.response", [{queue_name, QueueName}, {call_id, CallId}, {type, message}, {result, ok}, {data, Message}]}
	end.

last_a('GET', []) ->
	D = run(["content.article.test.babywonder.ru", "content.article.test.babywonder.ru", "title.article.test.babywonder.ru"]),
	{jsonp, "Defaceit.Queue.response", [{'pack',D}]};
last_a('POST', []) ->
	D = run(r(Req:post_param("a[0]"), 1)),
	{jsonp, "Defaceit.Queue.response", [{'pack',D}]}.

last_n('GET', [QueueNamespace]) ->
	case boss_db:find('squeue', [queue_name, 'matches', "*"++QueueNamespace]) of
		[] ->
			{jsonp, "Defaceit.Queue.response", [{'pack', []}]};
		Messages ->
			D = run(wrap(Messages)),
			{jsonp, "Defaceit.Queue.response", [{'pack',D}]}
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
	{_,_,B} = last('GET', [A, 1]),
	run(Tail) ++ [B].




r(undefined, _) ->
	[];
r(Element, Index) ->
	[Element] ++ r(Req:post_param("a["++integer_to_list(Index)++"]"), Index+1).



% pop function uses do popup data from queue
pop('GET', [QueueName, CallId]) ->
	case boss_db:find(squeue, [queue_name, 'equals', QueueName], 1, 0, creation_time, num_descending) of
		[] ->
			{output, "//No messages"};
		[Message|_] ->
			boss_db:delete(Message:id()),
			{jsonp, "Defaceit.Queue.response", [ {queue_name, QueueName},{call_id, CallId}, {type, message}, {result, ok}, {data, Message}]}
	end.

push('GET', [Message]) ->
	NewMessage = squeue:new(id, Message, erlang:now(), 'all'),
	{ok, Saved} = NewMessage:save(),
	{jsonp, "Defaceit.Queue.response", [{queue_name, 'all'}, {type, status},{result, "ok"}]};
push('GET', [QueueName, CallId, Message]) ->
	NewMessage = squeue:new(id, Message, erlang:now(), QueueName),
	{ok, Saved} = NewMessage:save(),
	{jsonp, "Defaceit.Queue.response", [{queue_name, QueueName}, {call_id, CallId}, {type, status},{result, "ok"}]};
push('POST', []) ->
	NewMessage = squeue:new(id, Req:post_param("message_text"), erlang:now(), 'all'),
	{ok, Saved} = NewMessage:save(),
	{jsonp, "Defaceit.Queue.response", [{queue_name, 'all'}, {type, status},{result, "ok"}]};
push('POST', [QueueName, CallId]) ->
	NewMessage = squeue:new(id, Req:post_param("message_text"), erlang:now(), QueueName),
	{ok, Saved} = NewMessage:save(),
	{jsonp, "Defaceit.Queue.response", [{queue_name, QueueName}, {call_id, CallId}, {type, status},{result, "ok"}]}.

