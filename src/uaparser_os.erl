-module(uaparser_os).
-compile({parse_transform, ct_expand}).
-include("../include/uaparser.hrl").
-export([parse/1, get_operating_systems/0]).

-spec parse(UserAgent :: binary()) -> [{atom(), ua_value()}].
parse(UserAgent) ->
    make_proplist(find(UserAgent, get_operating_systems()), UserAgent).

-spec make_proplist(OS :: #os{}, UserAgent :: binary()) -> [{atom(), ua_value()}].
make_proplist(undefined, UserAgent) ->
    make_proplist(#os{}, UserAgent);
make_proplist(OS = #os{name = Name, family = Family, manufacturer = Manufacturer, device_type = DeviceType}, UserAgent) ->
    {Version, Details} = get_version(OS, UserAgent),
    [
        {name,                  Name},
        {family,                Family},
        {manufacturer,          Manufacturer},
        {type,                  DeviceType},
        {version,               Version},
        {version_details,       Details}
    ].

-spec get_version(OS :: #os{}, UserAgent :: binary()) -> {binary(), version_details()}.
get_version(_ = #os{version_regex = undefined}, _UserAgent) ->
    {<<"0">>, []};
get_version(_ = #os{version_regex = RX}, UserAgent) ->
    case re:run(UserAgent, RX, [{capture, all_but_first, binary}]) of
        {match, [FullVersion|Rest]} ->
            {FullVersion, get_version_details(Rest)};
        nomatch ->
            {<<"0">>, []}
    end.

-spec get_version_details(Details :: [binary()]) -> version_details().
get_version_details(Details) ->
    [ {K, uaparser_utils:bin_to_num(Detail)} || {K, Detail} <- do_get_version_details(Details) ].

-spec do_get_version_details([binary()]) -> [{atom(), binary()}].
do_get_version_details([Major, Minor, Build, Patch]) ->
    [{major, Major}, {minor, Minor}, {build, Build}, {patch, Patch}];
do_get_version_details([Major, Minor, Patch]) ->
    [{major, Major}, {minor, Minor}, {patch, Patch}];
do_get_version_details([Major, Minor]) ->
    [{major, Major}, {minor, Minor}];
do_get_version_details([Major]) ->
    [{major, Major}, {minor, <<"0">>}].

-spec get_operating_systems() -> [#os{}].
get_operating_systems() ->
    ct_expand:term(operating_systems()).

-spec find(UserAgent :: binary(), Options :: [#os{}] | []) -> 'undefined' | #os{}.
find(UserAgent, [OS|Rest]) ->
    case check_useragent(OS, UserAgent) of
        undefined -> find(UserAgent, Rest);
        Result -> Result
    end;
find(_UserAgent, []) ->
    undefined.

-spec check_useragent(OS :: #os{}, UserAgent :: binary()) -> 'undefined' | #os{}.
check_useragent(OS = #os{aliases = Aliases, exclusions = Exclusions, children = Children}, UserAgent) ->
    case contains(Aliases, UserAgent) of
        true ->
            case find(UserAgent, Children) of
                undefined ->
                    case contains(Exclusions, UserAgent) of
                        true -> undefined;
                        false -> OS
                    end;
                Result ->
                    inherit(Result, OS)
            end;
        false ->
            undefined
    end.

-spec contains(Tokens :: [binary()] | [], Binary :: binary()) -> boolean().
contains([Token|Tokens], Binary) ->
    binary:match(Binary, Token, []) =/= nomatch orelse contains(Tokens, Binary);
contains([], _Binary) ->
    false.

-spec inherit(Child :: #os{}, Parent :: #os{}) -> #os{}.
inherit(Child = #os{version_regex = undefined}, _Parent = #os{version_regex = RX}) ->
    Child#os{version_regex = RX};
inherit(Child, _Parent) ->
    Child.

operating_systems() ->
    [{[{<<"family">>,<<"windows">>},
        {<<"name">>,<<"windows">>},
        {<<"manufacturer">>,<<"microsoft">>},
        {<<"device_type">>,<<"computer">>},
        {<<"version_regex">>,
            <<"windows (?:nt|(?:phone(?: os)?))? (([0-9]+)(?:\\.([0-9]+)))">>},
        {<<"aliases">>,[<<"windows">>]},
        {<<"exclusions">>,[<<"palm">>,<<"ggpht.com">>]},
        {<<"children">>,
            [{[{<<"family">>,<<"windows">>},
                {<<"name">>,<<"windows 8.1">>},
                {<<"manufacturer">>,<<"microsoft">>},
                {<<"device_type">>,<<"computer">>},
                {<<"aliases">>,[<<"windows nt 6.3">>]},
                {<<"children">>,[]}]},
                {[{<<"family">>,<<"windows">>},
                    {<<"name">>,<<"windows 8">>},
                    {<<"manufacturer">>,<<"microsoft">>},
                    {<<"device_type">>,<<"computer">>},
                    {<<"aliases">>,[<<"windows nt 6.2">>]},
                    {<<"children">>,[]}]},
                {[{<<"family">>,<<"windows">>},
                    {<<"name">>,<<"windows 7">>},
                    {<<"manufacturer">>,<<"microsoft">>},
                    {<<"device_type">>,<<"computer">>},
                    {<<"aliases">>,[<<"windows nt 6.1">>]},
                    {<<"children">>,[]}]},
                {[{<<"family">>,<<"windows">>},
                    {<<"name">>,<<"windows vista">>},
                    {<<"manufacturer">>,<<"microsoft">>},
                    {<<"device_type">>,<<"computer">>},
                    {<<"aliases">>,[<<"windows nt 6">>]},
                    {<<"children">>,[]}]},
                {[{<<"family">>,<<"windows">>},
                    {<<"name">>,<<"windows 2000">>},
                    {<<"manufacturer">>,<<"microsoft">>},
                    {<<"device_type">>,<<"computer">>},
                    {<<"aliases">>,[<<"windows nt 5.0">>]},
                    {<<"children">>,[]}]},
                {[{<<"family">>,<<"windows">>},
                    {<<"name">>,<<"windows xp">>},
                    {<<"manufacturer">>,<<"microsoft">>},
                    {<<"device_type">>,<<"computer">>},
                    {<<"aliases">>,[<<"windows nt 5">>]},
                    {<<"exclusions">>,[<<"ggpht.com">>]},
                    {<<"children">>,[]}]},
                {[{<<"family">>,<<"windows">>},
                    {<<"name">>,<<"windows phone 8.1">>},
                    {<<"manufacturer">>,<<"microsoft">>},
                    {<<"device_type">>,<<"mobile">>},
                    {<<"aliases">>,[<<"windows phone 8.1">>]},
                    {<<"children">>,[]}]},
                {[{<<"family">>,<<"windows">>},
                    {<<"name">>,<<"windows phone 8">>},
                    {<<"manufacturer">>,<<"microsoft">>},
                    {<<"device_type">>,<<"mobile">>},
                    {<<"aliases">>,[<<"windows phone 8">>]},
                    {<<"children">>,[]}]},
                {[{<<"family">>,<<"windows">>},
                    {<<"name">>,<<"windows phone 7">>},
                    {<<"manufacturer">>,<<"microsoft">>},
                    {<<"device_type">>,<<"mobile">>},
                    {<<"aliases">>,[<<"windows phone os 7">>]},
                    {<<"children">>,[]}]},
                {[{<<"family">>,<<"windows">>},
                    {<<"name">>,<<"windows mobile">>},
                    {<<"manufacturer">>,<<"microsoft">>},
                    {<<"device_type">>,<<"mobile">>},
                    {<<"aliases">>,[<<"windows ce">>]},
                    {<<"children">>,[]}]},
                {[{<<"family">>,<<"windows">>},
                    {<<"name">>,<<"windows 98">>},
                    {<<"manufacturer">>,<<"microsoft">>},
                    {<<"device_type">>,<<"computer">>},
                    {<<"aliases">>,[<<"windows 98">>,<<"win98">>]},
                    {<<"exclusions">>,[<<"palm">>]},
                    {<<"children">>,[]}]}]}]},
        {[{<<"family">>,<<"android">>},
            {<<"name">>,<<"android">>},
            {<<"manufacturer">>,<<"google">>},
            {<<"device_type">>,<<"mobile">>},
            {<<"version_regex">>,<<"android (([0-9]+)\\.([0-9]+)(?:\\.([0-9]+))?)">>},
            {<<"aliases">>,[<<"android">>]},
            {<<"children">>,
                [{[{<<"family">>,<<"android">>},
                    {<<"name">>,<<"android 4.x">>},
                    {<<"manufacturer">>,<<"google">>},
                    {<<"device_type">>,<<"mobile">>},
                    {<<"aliases">>,[<<"android 4">>,<<"android-4">>]},
                    {<<"children">>,
                        [{[{<<"family">>,<<"android">>},
                            {<<"name">>,<<"android 4.x tablet">>},
                            {<<"manufacturer">>,<<"google">>},
                            {<<"device_type">>,<<"tablet">>},
                            {<<"aliases">>,[<<"android 4">>,<<"android-4">>]},
                            {<<"exclusions">>,[<<"mobile">>]},
                            {<<"children">>,[]}]}]}]},
                    {[{<<"family">>,<<"android">>},
                        {<<"name">>,<<"android 3.x tablet">>},
                        {<<"manufacturer">>,<<"google">>},
                        {<<"device_type">>,<<"tablet">>},
                        {<<"aliases">>,[<<"android 3">>]},
                        {<<"children">>,[]}]},
                    {[{<<"family">>,<<"android">>},
                        {<<"name">>,<<"android 2.x">>},
                        {<<"manufacturer">>,<<"google">>},
                        {<<"device_type">>,<<"mobile">>},
                        {<<"aliases">>,[<<"android 2">>]},
                        {<<"children">>,
                            [{[{<<"family">>,<<"android">>},
                                {<<"name">>,<<"android 2.x tablet">>},
                                {<<"manufacturer">>,<<"google">>},
                                {<<"device_type">>,<<"tablet">>},
                                {<<"aliases">>,[<<"kindle fire">>,<<"gt-p1000">>,<<"sch-i800">>]},
                                {<<"children">>,[]}]}]}]},
                    {[{<<"family">>,<<"android">>},
                        {<<"name">>,<<"android 1.x">>},
                        {<<"manufacturer">>,<<"google">>},
                        {<<"device_type">>,<<"mobile">>},
                        {<<"aliases">>,[<<"android 1">>]},
                        {<<"children">>,[]}]},
                    {[{<<"family">>,<<"android">>},
                        {<<"name">>,<<"android mobile">>},
                        {<<"manufacturer">>,<<"google">>},
                        {<<"device_type">>,<<"mobile">>},
                        {<<"aliases">>,[<<"mobile">>]},
                        {<<"children">>,[]}]},
                    {[{<<"family">>,<<"android">>},
                        {<<"name">>,<<"android tablet">>},
                        {<<"manufacturer">>,<<"google">>},
                        {<<"device_type">>,<<"tablet">>},
                        {<<"aliases">>,[<<"tablet">>]},
                        {<<"children">>,[]}]}]}]},
        {[{<<"family">>,<<"webos">>},
            {<<"name">>,<<"webos">>},
            {<<"manufacturer">>,<<"hp">>},
            {<<"device_type">>,<<"mobile">>},
            {<<"version_regex">>,
                <<"webos\\/(([0-9]+)(?:\\.([0-9]+))?(?:\\.([0-9]+))?(?:\\.([0-9]+))?)">>},
            {<<"aliases">>,[<<"webos">>]},
            {<<"children">>,[]}]},
        {[{<<"family">>,<<"palm">>},
            {<<"name">>,<<"palmos">>},
            {<<"manufacturer">>,<<"hp">>},
            {<<"device_type">>,<<"mobile">>},
            {<<"aliases">>,[<<"palm">>]},
            {<<"children">>,[]}]},
        {[{<<"family">>,<<"meego">>},
            {<<"name">>,<<"meego">>},
            {<<"manufacturer">>,<<"nokia">>},
            {<<"device_type">>,<<"mobile">>},
            {<<"aliases">>,[<<"meego">>]},
            {<<"children">>,[]}]},
        {[{<<"family">>,<<"ios">>},
            {<<"name">>,<<"ios">>},
            {<<"manufacturer">>,<<"apple">>},
            {<<"device_type">>,<<"mobile">>},
            {<<"version_regex">>,
                <<"cpu(?: iphone)? os (([0-9]+)(?:_([0-9]+))?(?:_([0-9]+))?)">>},
            {<<"aliases">>,[<<"iphone os">>,<<"like mac os x">>]},
            {<<"children">>,
                [{[{<<"family">>,<<"ios">>},
                    {<<"name">>,<<"ios 7 (iphone)">>},
                    {<<"manufacturer">>,<<"apple">>},
                    {<<"device_type">>,<<"mobile">>},
                    {<<"aliases">>,[<<"iphone os 7">>]},
                    {<<"children">>,[]}]},
                    {[{<<"family">>,<<"ios">>},
                        {<<"name">>,<<"ios 6 (iphone)">>},
                        {<<"manufacturer">>,<<"apple">>},
                        {<<"device_type">>,<<"mobile">>},
                        {<<"aliases">>,[<<"iphone os 6">>]},
                        {<<"children">>,[]}]},
                    {[{<<"family">>,<<"ios">>},
                        {<<"name">>,<<"ios 5 (iphone)">>},
                        {<<"manufacturer">>,<<"apple">>},
                        {<<"device_type">>,<<"mobile">>},
                        {<<"aliases">>,[<<"iphone os 5">>]},
                        {<<"children">>,[]}]},
                    {[{<<"family">>,<<"ios">>},
                        {<<"name">>,<<"ios 4 (iphone)">>},
                        {<<"manufacturer">>,<<"apple">>},
                        {<<"device_type">>,<<"mobile">>},
                        {<<"aliases">>,[<<"iphone os 4">>]},
                        {<<"children">>,[]}]},
                    {[{<<"family">>,<<"ios">>},
                        {<<"name">>,<<"mac os x (ipad)">>},
                        {<<"manufacturer">>,<<"apple">>},
                        {<<"device_type">>,<<"tablet">>},
                        {<<"aliases">>,[<<"ipad">>]},
                        {<<"children">>,
                            [{[{<<"family">>,<<"ios">>},
                                {<<"name">>,<<"ios 7 (ipad)">>},
                                {<<"manufacturer">>,<<"apple">>},
                                {<<"device_type">>,<<"tablet">>},
                                {<<"aliases">>,[<<"os 7">>]},
                                {<<"children">>,[]}]},
                                {[{<<"family">>,<<"ios">>},
                                    {<<"name">>,<<"ios 6 (ipad)">>},
                                    {<<"manufacturer">>,<<"apple">>},
                                    {<<"device_type">>,<<"tablet">>},
                                    {<<"aliases">>,[<<"os 6">>]},
                                    {<<"children">>,[]}]}]}]},
                    {[{<<"family">>,<<"ios">>},
                        {<<"name">>,<<"mac os x (iphone)">>},
                        {<<"manufacturer">>,<<"apple">>},
                        {<<"device_type">>,<<"mobile">>},
                        {<<"aliases">>,[<<"iphone">>]},
                        {<<"children">>,[]}]},
                    {[{<<"family">>,<<"ios">>},
                        {<<"name">>,<<"mac os x (ipod)">>},
                        {<<"manufacturer">>,<<"apple">>},
                        {<<"device_type">>,<<"mobile">>},
                        {<<"aliases">>,[<<"ipod">>]},
                        {<<"children">>,[]}]}]}]},
        {[{<<"family">>,<<"mac_os_x">>},
            {<<"name">>,<<"mac os x">>},
            {<<"manufacturer">>,<<"apple">>},
            {<<"device_type">>,<<"computer">>},
            {<<"version_regex">>,
                <<"mac os ?x (([0-9]+)(?:[_\\.]([0-9]+))?(?:[_\\.]([0-9]+))?)">>},
            {<<"aliases">>,[<<"mac os x">>,<<"cfnetwork">>]},
            {<<"children">>,[]}]},
        {[{<<"family">>,<<"mac_os">>},
            {<<"name">>,<<"mac os">>},
            {<<"manufacturer">>,<<"apple">>},
            {<<"device_type">>,<<"computer">>},
            {<<"aliases">>,[<<"mac">>]},
            {<<"children">>,[]}]},
        {[{<<"family">>,<<"maemo">>},
            {<<"name">>,<<"maemo">>},
            {<<"manufacturer">>,<<"nokia">>},
            {<<"device_type">>,<<"mobile">>},
            {<<"aliases">>,[<<"maemo">>]},
            {<<"children">>,[]}]},
        {[{<<"family">>,<<"bada">>},
            {<<"name">>,<<"bada">>},
            {<<"manufacturer">>,<<"samsung">>},
            {<<"device_type">>,<<"mobile">>},
            {<<"aliases">>,[<<"bada">>]},
            {<<"children">>,[]}]},
        {[{<<"family">>,<<"google_tv">>},
            {<<"name">>,<<"android (google tv)">>},
            {<<"manufacturer">>,<<"google">>},
            {<<"device_type">>,<<"dmr">>},
            {<<"aliases">>,[<<"googletv">>]},
            {<<"children">>,[]}]},
        {[{<<"family">>,<<"kindle">>},
            {<<"name">>,<<"linux (kindle)">>},
            {<<"manufacturer">>,<<"amazon">>},
            {<<"device_type">>,<<"tablet">>},
            {<<"aliases">>,[<<"kindle">>]},
            {<<"children">>,
                [{[{<<"family">>,<<"kindle">>},
                    {<<"name">>,<<"linux (kindle 3)">>},
                    {<<"manufacturer">>,<<"amazon">>},
                    {<<"device_type">>,<<"tablet">>},
                    {<<"aliases">>,[<<"kindle/3">>]},
                    {<<"children">>,[]}]},
                    {[{<<"family">>,<<"kindle">>},
                        {<<"name">>,<<"linux (kindle 2)">>},
                        {<<"manufacturer">>,<<"amazon">>},
                        {<<"device_type">>,<<"tablet">>},
                        {<<"aliases">>,[<<"kindle/2">>]},
                        {<<"children">>,[]}]}]}]},
        {[{<<"family">>,<<"linux">>},
            {<<"name">>,<<"linux">>},
            {<<"manufacturer">>,<<"other">>},
            {<<"device_type">>,<<"computer">>},
            {<<"aliases">>,[<<"linux">>,<<"camelhttpstream">>]},
            {<<"children">>,[]}]},
        {[{<<"family">>,<<"symbian">>},
            {<<"name">>,<<"symbian os">>},
            {<<"manufacturer">>,<<"symbian">>},
            {<<"device_type">>,<<"mobile">>},
            {<<"aliases">>,[<<"symbian">>,<<"series60">>]},
            {<<"children">>,
                [{[{<<"family">>,<<"symbian">>},
                    {<<"name">>,<<"symbian os 9.x">>},
                    {<<"manufacturer">>,<<"symbian">>},
                    {<<"device_type">>,<<"mobile">>},
                    {<<"aliases">>,[<<"symbianos/9">>,<<"series60/3">>]},
                    {<<"children">>,[]}]},
                    {[{<<"family">>,<<"symbian">>},
                        {<<"name">>,<<"symbian os 8.x">>},
                        {<<"manufacturer">>,<<"symbian">>},
                        {<<"device_type">>,<<"mobile">>},
                        {<<"aliases">>,
                            [<<"symbianos/8">>,<<"series60/2.6">>,<<"series60/2.8">>]},
                        {<<"children">>,[]}]},
                    {[{<<"family">>,<<"symbian">>},
                        {<<"name">>,<<"symbian os 7.x">>},
                        {<<"manufacturer">>,<<"symbian">>},
                        {<<"device_type">>,<<"mobile">>},
                        {<<"aliases">>,[<<"symbianos/7">>]},
                        {<<"children">>,[]}]},
                    {[{<<"family">>,<<"symbian">>},
                        {<<"name">>,<<"symbian os 6.x">>},
                        {<<"manufacturer">>,<<"symbian">>},
                        {<<"device_type">>,<<"mobile">>},
                        {<<"aliases">>,[<<"symbianos/6">>]},
                        {<<"children">>,[]}]}]}]},
        {[{<<"family">>,<<"series40">>},
            {<<"name">>,<<"series 40">>},
            {<<"manufacturer">>,<<"nokia">>},
            {<<"device_type">>,<<"mobile">>},
            {<<"aliases">>,[<<"nokia6300">>]},
            {<<"children">>,[]}]},
        {[{<<"family">>,<<"sony_ericsson">>},
            {<<"name">>,<<"sony ericsson">>},
            {<<"manufacturer">>,<<"sony_ericsson">>},
            {<<"device_type">>,<<"mobile">>},
            {<<"aliases">>,[<<"sonyericsson">>]},
            {<<"children">>,[]}]},
        {[{<<"family">>,<<"sun_os">>},
            {<<"name">>,<<"sunos">>},
            {<<"manufacturer">>,<<"sun">>},
            {<<"device_type">>,<<"computer">>},
            {<<"aliases">>,[<<"sunos">>]},
            {<<"children">>,[]}]},
        {[{<<"family">>,<<"psp">>},
            {<<"name">>,<<"sony playstation">>},
            {<<"manufacturer">>,<<"sony">>},
            {<<"device_type">>,<<"game_console">>},
            {<<"aliases">>,[<<"playstation">>]},
            {<<"children">>,[]}]},
        {[{<<"family">>,<<"wii">>},
            {<<"name">>,<<"nintendo wii">>},
            {<<"manufacturer">>,<<"nintendo">>},
            {<<"device_type">>,<<"game_console">>},
            {<<"aliases">>,[<<"wii">>]},
            {<<"children">>,[]}]},
        {[{<<"family">>,<<"blackberry">>},
            {<<"name">>,<<"blackberryos">>},
            {<<"manufacturer">>,<<"blackberry">>},
            {<<"device_type">>,<<"mobile">>},
            {<<"aliases">>,[<<"blackberry">>]},
            {<<"children">>,
                [{[{<<"family">>,<<"blackberry">>},
                    {<<"name">>,<<"blackberry 7">>},
                    {<<"manufacturer">>,<<"blackberry">>},
                    {<<"device_type">>,<<"mobile">>},
                    {<<"aliases">>,[<<"version/7">>]},
                    {<<"children">>,[]}]},
                    {[{<<"family">>,<<"blackberry">>},
                        {<<"name">>,<<"blackberry 6">>},
                        {<<"manufacturer">>,<<"blackberry">>},
                        {<<"device_type">>,<<"mobile">>},
                        {<<"aliases">>,[<<"version/6">>]},
                        {<<"children">>,[]}]}]}]},
        {[{<<"family">>,<<"blackberry_tablet">>},
            {<<"name">>,<<"blackberry tablet os">>},
            {<<"manufacturer">>,<<"blackberry">>},
            {<<"device_type">>,<<"tablet">>},
            {<<"aliases">>,[<<"rim tablet os">>]},
            {<<"children">>,[]}]},
        {[{<<"family">>,<<"roku">>},
            {<<"name">>,<<"roku os">>},
            {<<"manufacturer">>,<<"roku">>},
            {<<"device_type">>,<<"dmr">>},
            {<<"aliases">>,[<<"roku">>]},
            {<<"children">>,[]}]},
        {[{<<"family">>,<<"proxy">>},
            {<<"name">>,<<"proxy">>},
            {<<"manufacturer">>,<<"other">>},
            {<<"device_type">>,<<"unknown">>},
            {<<"aliases">>,[<<"ggpht.com">>]},
            {<<"children">>,[]}]},
        {[{<<"family">>,<<"unknown_mobile">>},
            {<<"name">>,<<"unknown mobile">>},
            {<<"manufacturer">>,<<"other">>},
            {<<"device_type">>,<<"mobile">>},
            {<<"aliases">>,[<<"mobile">>]},
            {<<"children">>,[]}]},
        {[{<<"family">>,<<"unknown_tablet">>},
            {<<"name">>,<<"unknown tablet">>},
            {<<"manufacturer">>,<<"other">>},
            {<<"device_type">>,<<"tablet">>},
            {<<"aliases">>,[<<"tablet">>]},
            {<<"children">>,[]}]},
        {[{<<"family">>,<<"unknown">>},
            {<<"name">>,<<"unknown">>},
            {<<"manufacturer">>,<<"other">>},
            {<<"device_type">>,<<"unknown">>},
            {<<"aliases">>,[]},
            {<<"children">>,[]}]}].