%%  Copyright (C) SiftLogic LLC- All Rights Reserved
%%  Unauthorized copying of this file, via any medium is strictly prohibited
%%  Proprietary and confidential
%%  Written by Kyle Neal <kyle@verias.com>, June 2015

-module(uaparser_test).

%%%===================================================================
%%% Tests
%%%===================================================================
-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").

do_check_ua_strings_test() ->
    [{browser,B1},
     {os,O1}] = uaparser:parse("Mozilla/5.0 (Windows; U; Windows NT 6.1; rv:2.2) Gecko/20110201"),
    ?assertEqual(uaparser_utils:keyget(name, B1), <<"mozilla">>),
    ?assertEqual(uaparser_utils:keyget(name, O1), <<"windows 7">>),
    ?assertEqual(uaparser_utils:keyget(type, O1), <<"computer">>),

    [{browser,B2},
     {os,O2}] = uaparser:parse("Mozilla/5.0 (Windows; U; Windows NT 5.1; cs; rv:1.9) Gecko/2008052906"),
    ?assertEqual(uaparser_utils:keyget(name, B2), <<"mozilla">>),
    ?assertEqual(uaparser_utils:keyget(name, O2), <<"windows xp">>),
    ?assertEqual(uaparser_utils:keyget(type, O2), <<"computer">>),

    [{browser,B3},
     {os,O3}] = uaparser:parse("Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.7.9) Gecko/20050711"),
    ?assertEqual(uaparser_utils:keyget(name, B3), <<"mozilla">>),
    ?assertEqual(uaparser_utils:keyget(name, O3), <<"linux">>),
    ?assertEqual(uaparser_utils:keyget(type, O3), <<"computer">>),

    [{browser,B4},
     {os,O4}] = uaparser:parse("Mozilla/5.0 (Linux; U; Android 2.3.4; fr-fr; HTC Desire Build/GRJ22) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1"),
    ?assertEqual(uaparser_utils:keyget(name, B4), <<"mobile safari">>),
    ?assertEqual(uaparser_utils:keyget(name, O4), <<"android 2.x">>),
    ?assertEqual(uaparser_utils:keyget(type, O4), <<"mobile">>),

    [{browser,B5},
     {os,O5}] = uaparser:parse("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1664.3 Safari/537.36"),
    ?assertEqual(uaparser_utils:keyget(name, B5), <<"chrome 32">>),
    ?assertEqual(uaparser_utils:keyget(name, O5), <<"mac os x">>),
    ?assertEqual(uaparser_utils:keyget(type, O5), <<"computer">>),

    [{browser,B6},
     {os,O6}] = uaparser:parse("Mozilla/5.0 (Windows; U; Windows NT 6.1; rv:2.2) Gecko/20110201"),
    ?assertEqual(uaparser_utils:keyget(name, B6), <<"mozilla">>),
    ?assertEqual(uaparser_utils:keyget(name, O6), <<"windows 7">>),
    ?assertEqual(uaparser_utils:keyget(type, O6), <<"computer">>),

    [{browser,B7},
     {os,O7}] = uaparser:parse("Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.81 Safari/537.36"),
    ?assertEqual(uaparser_utils:keyget(name, B7), <<"chrome">>),
    ?assertEqual(uaparser_utils:keyget(name, O7), <<"windows 7">>),
    ?assertEqual(uaparser_utils:keyget(type, O7), <<"computer">>),

    [{browser,B8},
     {os,O8}] = uaparser:parse("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/600.6.3 (KHTML, like Gecko) Version/8.0.6 Safari/600.6.3"),
    ?assertEqual(uaparser_utils:keyget(name, B8), <<"safari">>),
    ?assertEqual(uaparser_utils:keyget(name, O8), <<"mac os x">>),
    ?assertEqual(uaparser_utils:keyget(type, O8), <<"computer">>),

    [{browser,B9},
     {os,O9}] = uaparser:parse("Mozilla/5.0 (Windows NT 6.1; WOW64; rv:38.0) Gecko/20100101 Firefox/38.0"),
    ?assertEqual(uaparser_utils:keyget(name, B9), <<"firefox 3">>),
    ?assertEqual(uaparser_utils:keyget(name, O9), <<"windows 7">>),
    ?assertEqual(uaparser_utils:keyget(type, O9), <<"computer">>),

    [{browser,B10},
     {os,O10}] = uaparser:parse("Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.152 Safari/537.36"),
    ?assertEqual(uaparser_utils:keyget(name, B10), <<"chrome">>),
    ?assertEqual(uaparser_utils:keyget(name, O10), <<"windows 7">>),
    ?assertEqual(uaparser_utils:keyget(type, O10), <<"computer">>),

    [{browser,B11},
     {os,O11}] = uaparser:parse("Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.81 Safari/537.36"),
    ?assertEqual(uaparser_utils:keyget(name, B11), <<"chrome">>),
    ?assertEqual(uaparser_utils:keyget(name, O11), <<"windows 8.1">>),
    ?assertEqual(uaparser_utils:keyget(type, O11), <<"computer">>),

    [{browser,B12},
     {os,O12}] = uaparser:parse("Mozilla/5.0 (iPhone; CPU iPhone OS 8_3 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/8.0 Mobile/12F70 Safari/600.1.4"),
    ?assertEqual(uaparser_utils:keyget(name, B12), <<"mobile safari">>),
    ?assertEqual(uaparser_utils:keyget(name, O12), <<"mac os x (iphone)">>),
    ?assertEqual(uaparser_utils:keyget(type, O12), <<"mobile">>).

-endif.