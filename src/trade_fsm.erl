-module(trade_fsm).
-behavior(gen_fsm).

%% public API
-export([start/1, start_link/1,
         trade/2, accept_trade/1,
         make_offer/2, retract_offer/2,
         ready/1, cancel/1]).

%% gen_fsm callbacks
-export([init/1,
         handle_event/3, handle_sync_event/4, handle_info/3,
         terminate/3, code_change/4,
         %% custom states
         idle/2, idle/3,
         idle_wait/2, idle_wait/3,
         negotiate/2, negotiate/3,
         wait/2,
         ready/2, ready/3]).

%%
%% PUBLIC API
%%

start(Name) ->
  gen_fsm:start(?MODULE, [Name], []).

start_link(Name) ->
  gen_fsm:start_link(?MODULE, [Name], []).

%% Starts a trade request
%% timeouts after 30 seconds
trade(OwnPid, OtherPid) ->
  gen_fsm:sync_send_event(OwnPid, {negotiate, OtherPid}, 30000).

%% Accepts a trade request
accept_trade(OwnPid) ->
  gen_fsm:sync_send_event(OwnPid, accept_negotiate).

%% Puts item on the negotiation table
make_offer(OwnPid, Item) ->
  gen_fsm:send_event(OwnPid, {make_offer, Item}).

%% Takes an item off the negotiation table
retract_offer(OwnPid, Item) ->
  gen_fsm:send_event(OwnPid, {retract_offer, Item}).

%% Let's the other party know that you're ready to finish the deal
%% and waits until the other party is ready.
ready(OwnPid) ->
  gen_fsm:sync_send_event(OwnPid, ready, infinity).

%% Cancels a transaction
cancel(OwnPid) ->
  gen_fsm:sync_send_all_state_event(OwnPid, cancel).

