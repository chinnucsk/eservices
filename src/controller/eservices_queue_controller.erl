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

