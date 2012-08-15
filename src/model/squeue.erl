-module(squeue, [Id, MessageText, CreationTime, QueueName]).
-compile(export_all).


% only url decoded messages should save to queue
validation_tests() -> [
    {fun()-> case re:run(MessageText, "[<>']", [{capture, [0], list}]) of
	nomatch -> true;
	{match,_} -> false
    end end, "Validation error"}
].
