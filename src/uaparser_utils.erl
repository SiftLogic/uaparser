-module(uaparser_utils).
-compile({parse_transform, ct_expand}).
-include("../include/uaparser.hrl").
-export([
         bin_to_num/1,
         keyget/2,
         keyget/3
        ]).

-spec bin_to_num(Bin :: binary()) -> number().
bin_to_num(Binary) when is_binary(Binary) ->
    List = re:replace(Binary, "\\.", "", [{return, list}]),
    case string:to_float(List) of
        {error, no_float} -> list_to_integer(List);
        {F,_Rest} -> F
    end.

keyget(Key, Data) ->
    keyget(Key, Data, undefined).

keyget(Key, Data, Default) ->
    case lists:keyfind(Key, 1, Data) of
        false ->
            Default;
        {Key, Value} ->
            Value
    end.