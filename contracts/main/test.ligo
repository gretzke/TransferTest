type token_id is nat;

type storage is record
    owner: address;
    token_address: address;
    balance_response: nat;
end;

type transfer_action is Transfer of michelson_pair(address, "from", michelson_pair(address, "to", nat, "value"), "")

function test(const to_: address; const amount_: nat; var storage: storage): (list(operation) * storage) is
begin

    const token_contract: contract(transfer_action) = case (Tezos.get_entrypoint_opt("%transfer", storage.token_address): option(contract(transfer_action))) of
      | Some (c) -> c
      | None -> (failwith("incorrect contract") : contract(transfer_action))
    end;

    const argument: michelson_pair(address, "from", michelson_pair(address, "to", nat, "value"), "") = (storage.owner, (to_, amount_));
    const result: (list(operation) * storage) = ((list [Tezos.transaction(Transfer(argument), 0mutez, token_contract)]: list(operation)), storage);

end with result;

type get_balance_action is GetBalanceAction of michelson_pair(address, "owner", contract(nat), "");

function store_balance(const balance_response : nat; const storage: storage) : (list(operation) * storage) is
begin
    storage.balance_response := balance_response;
end with ((nil: list(operation)), storage)

function call_get_balance(const owner: address; const storage: storage) : (list(operation) * storage) is
begin
    const other_contract: contract(get_balance_action) =
    case (Tezos.get_entrypoint_opt("%getBalance", storage.token_address): option(contract(get_balance_action))) of
      | Some (c) -> c
      | None -> (failwith("incorrect contract") : contract(get_balance_action))
    end;

    // The endpoint get_balance takes a tuple of address * contract(nat)
    const self_contract : contract(nat) = Tezos.self("%store_balance");
    const argument: michelson_pair(address, "owner", contract(nat), "") = (owner, self_contract);
    const result: (list(operation) * storage) =
    ((list [Tezos.transaction(GetBalanceAction(argument), 0mutez, other_contract)]: list(operation)), storage);
end with result


(***** actions -- defines available endpoints *****)
type action is
| Test of (address * nat)
| Call_get_balance of address
| Store_balance of nat

(***** MAIN FUNCTION *****)
(* Default function that represents our contract, it's sole purpose here is the entrypoint routing *)
function main (const action : action; var storage : storage) : (list(operation) * storage) is
begin
    if amount =/= 0tz then failwith("This contract does not accept tezi deposits")
    else skip;
end with case action of
    | Test(n) -> test(n.0, n.1, storage)
    | Call_get_balance(n) -> call_get_balance(n, storage)
    | Store_balance(addr) -> store_balance(addr, storage)
end