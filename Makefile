all:
	@./rebar get-deps
	@./rebar compile

.PHONY: compile
compile:
	@./rebar compile
	
clean:
	@./rebar clean

# Test
.PHONY: test
test:
	make eunit

eunit:
	./rebar eunit skip_deps=true
