-module(opening_hours).
-export([is_open_on/1, is_open_on/2, next_opening_date/1, next_opening_date/2]).
-export([run_tests/0]).

is_open_on(Date) -> is_open_on(get_data_from_file(),Date).

is_open_on(Data, {Date, {Hour, Minute, _}}) ->
  D = calendar:day_of_the_week(Date),
  Time = Hour * 100 + Minute,
  lists:any(fun ({Dow,Start,End}) -> 
                    D == Dow andalso Start =< Time andalso Time =< End end, Data).

next_opening_date(Date) -> next_opening_date(get_data_from_file(),Date).

next_opening_date(Data, {Date, _}) -> 
  D = calendar:day_of_the_week(Date),
  Next = case lists:filter(fun ({Dow,_,_}) -> D < Dow end, Data) of
    [{D1,S,_} | _] -> {add_days(Date, D1 - D), military_to_time(S)} ;
    []             -> [{D1, S, _} | _] = Data,
                      {add_days(Date, D1 + 7 - D), military_to_time(S)}
  end,
  format_datetime(Next).

get_data_from_file() ->
  {ok, [Data]} = file:consult("openhours.txt"),
  Data.
military_to_time(M) -> {trunc(M/100), M rem 100, 0}.
format_datetime({{Y,M,D},{Hour,Minute,Second}}) ->
  iolist_to_binary(
    io_lib:format("~4..0b-~2..0b-~2..0bT~2..0b:~2..0b:~2..0bZ",[Y,M,D,Hour,Minute,Second])).
add_days(Date,Days) ->
  calendar:gregorian_days_to_date(calendar:date_to_gregorian_days(Date) + Days).
  
run_tests() -> 
  Data = [{1,800,1600},{3,800,1600},{5,800,1600}],
  Wed = {{2016,5,11},{12,22,22}},
  Thu = {{2016,5,12},{12,22,22}},
  Fri = {{2016,5,13},{9,0,0}},
  Fri_m = <<"2016-05-13T08:00:00Z">>,
  Mon_m = <<"2016-05-16T08:00:00Z">>,
  true = is_open_on(Data,Wed),
  false = is_open_on(Data,Thu),
  Fri_m = next_opening_date(Data,Wed),
  Mon_m = next_opening_date(Data,Fri),
  tests_ok.