-module(uaparser_parser).
-compile({parse_transform, ct_expand}).
-include("uaparser.hrl").
-export([parse/2, get_browsers/0, get_operating_systems/0]).

parse(UserAgent, os) ->
    make_proplist(find(UserAgent, get_operating_systems()), UserAgent, os);
parse(UserAgent, browser) ->
    make_proplist(find(UserAgent, get_browsers()), UserAgent, browser).

make_proplist(undefined, UserAgent, Type) ->
    make_proplist([], UserAgent, Type);
make_proplist(OperatingSystem, UserAgent, os) ->
    {Version, Details} = get_version(OperatingSystem, UserAgent),
    [
        {name,                  uaparser_utils:keyget(<<"name">>, OperatingSystem)},
        {family,                uaparser_utils:keyget(<<"family">>, OperatingSystem)},
        {manufacturer,          uaparser_utils:keyget(<<"manufacturer">>, OperatingSystem)},
        {type,                  uaparser_utils:keyget(<<"device_type">>, OperatingSystem)},
        {version,               Version},
        {version_details,       Details}
    ];
make_proplist(Browser, UserAgent, browser) ->
    {Version, Details} = get_version(Browser, UserAgent),
    [
        {name,                  uaparser_utils:keyget(<<"name">>, Browser)},
        {family,                uaparser_utils:keyget(<<"family">>, Browser)},
        {manufacturer,          uaparser_utils:keyget(<<"manufacturer">>, Browser)},
        {type,                  uaparser_utils:keyget(<<"browser_type">>, Browser)},
        {renderer,              uaparser_utils:keyget(<<"rendering_engine">>, Browser)},
        {version,               Version},
        {version_details,       Details}
    ].

get_version(Item, UserAgent) ->
    case uaparser_utils:keyget(<<"version_regex">>, Item) of
        undefined ->
            {<<"0">>, []};
        RX ->
            case re:run(UserAgent, RX, [{capture, all_but_first, binary}]) of
                {match, [FullVersion|Rest]} ->
                    {FullVersion, get_version_details(Rest)};
                nomatch ->
                    {<<"0">>, []}
            end
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

-spec get_browsers() -> list().
get_browsers() ->
    ct_expand:term(uaparser_browser:browsers()).

-spec get_operating_systems() -> list().
get_operating_systems() ->
    ct_expand:term(uaparser_os:operating_systems()).

-spec find(UserAgent :: binary(), Options :: list() | []) -> 'undefined' | list().
find(UserAgent, [Item | Rest]) ->
    case check_useragent(Item, UserAgent) of
        undefined -> find(UserAgent, Rest);
        Result -> Result
    end;
find(_UserAgent, []) ->
    undefined.

-spec check_useragent(Item :: tuple(), UserAgent :: binary()) -> 'undefined' | list().
check_useragent({Item}, UserAgent) ->
    case contains(uaparser_utils:keyget(<<"aliases">>, Item), UserAgent) of
        true ->
            case find(UserAgent, uaparser_utils:keyget(<<"children">>, Item)) of
                undefined ->
                    case contains(uaparser_utils:keyget(<<"exclusions">>, Item), UserAgent) of
                        true -> undefined;
                        false -> Item
                    end;
                Result ->
                    inherit(Result, Item)
            end;
        false ->
            undefined
    end.

-spec contains(Tokens :: [binary()] | [], Binary :: binary()) -> boolean().
contains([Token|Tokens], Binary) ->
    binary:match(Binary, Token, []) =/= nomatch orelse contains(Tokens, Binary);
contains([], _Binary) ->
    false;
contains(undefined, _Binary) ->
    false.


inherit(Child, Parent) ->
    case uaparser_utils:keyget(<<"version_regex">>, Child) of
        undefined ->
            [{<<"version_regex">>, uaparser_utils:keyget(<<"version_regex">>, Parent)} | Child];
        _ ->
            Child
    end.
