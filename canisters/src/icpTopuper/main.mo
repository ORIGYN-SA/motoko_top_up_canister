import ExperimentalCycles "mo:base/ExperimentalCycles";
import Principal "mo:base/Principal";
import D "mo:base/Debug";
import Error "mo:base/Error";
import Array "mo:base/Array";

shared (deployer) actor class IcpTopuper() {
    D.print(debug_show("deployer is", deployer.caller));
    var admin = deployer.caller;
    var callers: [Principal] = [deployer.caller];
    var principals: [Principal] = [];
    var __threshold: Nat = 999_000_000_000;
    var __topUpAmount: Nat = 1_000_000_000;

    /**
    *   set the administator of this canister
    *   @params _principal: new administrator Principal
    */
    public shared(msg) func setAdmin(_principal: Principal): async () {
        if (msg.caller != admin) {
            throw Error.reject("not authorized")
        };
        admin := _principal;
    };

    /**
    *   returns the threshold limit to trigger a canister cycles top-up
    *   
    */
    public query func threshold(): async Nat {
        __threshold
    };
    
    /**
    *   returns the topUpAmount in cycles
    *   
    */
    public query func topUpAmount(): async Nat {
        __topUpAmount
    };
    

    /**
    *   returns the caller Principal
    *   
    */
    public shared (msg) func whoiam(): async Principal {
        return msg.caller
    };

    /**
    *   returns the canister cycles balance
    *   
    */
    public shared (msg) func canisterBalance(): async Nat {
        return ExperimentalCycles.balance()
    };
    // costs ~30k cycles

    /**
    *   accept all canisters cycles top-up
    *   
    */
    public shared (msg) func topUp(): async Nat {
        let available = ExperimentalCycles.available();
        D.print(debug_show("topUp::available()", available));
        let accepted = ExperimentalCycles.accept(available);
        D.print(debug_show("topUp::accepted()", accepted));
        return ExperimentalCycles.balance();
    };

    /**
    *   set a new threshold limit
    *   @param _threshold: new limit
    */
    public shared(msg) func setThreshold(_threshold: Nat): async() {
        if (msg.caller != admin) {
            throw Error.reject("not authorized")
        };
        __threshold := _threshold;
    };

    /**
    *   set a new top-up amount
    *   @param _topUpAmount: new amount
    */
    public shared(msg) func setTopupAmount(_topUpAmount: Nat): async() {
        if (msg.caller != admin) {
            throw Error.reject("not authorized")
        };
        __topUpAmount := _topUpAmount;
    };

    /**
    *   set the canisters to check to be topped-up
    *   @param _principals: canisters' Principal
    */
    public shared(msg) func setCanisters(_principals: [Principal]): async () {
        D.print(debug_show("setCanisters caller", msg.caller));
        if (msg.caller != admin) {
            throw Error.reject("not authorized")
        };
        principals := _principals;
    };

    /**
    *   set the allowed callers of `cronTask`
    *   @param _principals: canisters' Principal
    */
    public shared(msg) func setCallers(_principals: [Principal]): async () {
        D.print(debug_show("setCallers caller", msg.caller));
        if (msg.caller != admin) {
            throw Error.reject("not authorized")
        };
        callers := _principals;
    };

    /**
    *   returns the Array of canisters Principal
    *   
    */
    public query func getCanisters(): async [Principal] {
        return principals;
    };

    /**
    *   returns the Array of callers Principal
    *   
    */
    public query func getCallers(): async [Principal] {
        return callers;
    };

    type Result = {
        canisterId: Principal;
        message: Text;
    };

    /**
    *   run the periodic task
    *   returns an array of Result
    *   
    */
    public shared(msg) func cronTask(): async [Result] {
        var authorized = false;
        label allowed for ((allowedCaller) in callers.vals()) {
            if(msg.caller == allowedCaller) {
                authorized := true;
                break allowed;
            };
        };
        if (authorized == false) {
            throw Error.reject("not authorized")
        };
        var results: [Result] = [];
        // contains logic to check for all principals their balances;
        // if lower than threshold; top-up
        for (canId in principals.vals()) {
            try {
                let canister2 = actor(Principal.toText(canId)): actor { topUp: () -> async Nat; canisterBalance: () -> async Nat };
                let canister2Balance = await canister2.canisterBalance();
                D.print(debug_show("canister2", canId, "balance", canister2Balance));
                if ( canister2Balance < __threshold ) {
                    let amountToSend = __threshold - canister2Balance + __topUpAmount;
                    D.print(debug_show("topping up", canId));
                    ExperimentalCycles.add(amountToSend);
                    
                    let result = await canister2.topUp(); // topup
                    D.print(debug_show("result", result));
                    results := Array.append<Result>(results, [{
                        canisterId = canId;
                        message = "OK";
                    }]);
                };
            }
            catch (e: Error) {
                results := Array.append<Result>(results, [{
                    canisterId = canId;
                    message = "Error " # Error.message(e);
                }]);
            };
        };
        return results; 
    };

};
