import ExperimentalCycles "mo:base/ExperimentalCycles";
import Principal "mo:base/Principal";
import D "mo:base/Debug";

/**
    This is an example of canister that does not implement the interface.
**/
actor {
    public func greet(name : Text) : async Text {
        return "Hello, " # name # "!";
    };

};
