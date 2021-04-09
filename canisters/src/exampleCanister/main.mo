import ExperimentalCycles "mo:base/ExperimentalCycles";
import Principal "mo:base/Principal";
import D "mo:base/Debug";

actor {
    public func greet(name : Text) : async Text {
        return "Hello, " # name # "!";
    };

    public shared (msg) func whoiam(): async Principal {
        return msg.caller
    };

    // SECURITY ADVISORY: check the caller is an allowed canisters else throw
    // Return the Cycles balance of the canister
    public shared (msg) func canisterBalance(): async Nat {
        return ExperimentalCycles.balance()
    };
    // costs ~30k cycles

    // SECURITY ADVISORY: check the caller is an allowed canisters else throw
    // Allow canisters to send cycles; the canister keeps them aall
    public shared (msg) func topUp(): async Nat {
        let available = ExperimentalCycles.available();
        D.print(debug_show("topUp::available()", available));
        let accepted = ExperimentalCycles.accept(available);
        D.print(debug_show("topUp::accepted()", accepted));
        return ExperimentalCycles.balance()
    };

    // Bind select methods from the
    // system ManagementCanister at the well-known address "aaaaa-aa"
    // (not documented publically yet)
    // used below to create, stop and delete canisters.
    let ic00 = actor "aaaaa-aa" : actor {
      create_canister : () -> async { canister_id : Principal };
      stop : Principal -> async ();
      delete : Principal -> async ();
    };


    // This is a mock method; do not use in prod :-)
    // Just creates and deletes an empty canister,
    // no actor class required
    public func burnBest(amount : Nat) : async (Nat,Nat) {
        let pre = ExperimentalCycles.balance();
        // create an empty canister (sans code)
        ExperimentalCycles.add(amount);
        let id = await ic00.create_canister();
        // delete it and its cycles
        ignore ic00.delete(id.canister_id);
        return (pre, ExperimentalCycles.balance());
    };


};
