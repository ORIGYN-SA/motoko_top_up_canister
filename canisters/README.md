# icpTopuper

Welcome to your new icpTopuper project and to the internet computer development community. By default, creating a new project adds this README and some template files to your project directory. You can edit these template files to customize your project and to include your own code to speed up the development cycle.

To get started, you might want to explore the project directory structure and the default configuration file. Working with this project in your development environment will not affect any production deployment or identity tokens.

To learn more before you start working with icpTopuper, see the following documentation available online:

- [Quick Start](https://sdk.dfinity.org/docs/quickstart/quickstart-intro.html)
- [SDK Developer Tools](https://sdk.dfinity.org/docs/developers-guide/sdk-guide.html)
- [Motoko Programming Language Guide](https://sdk.dfinity.org/docs/language-guide/motoko.html)
- [Motoko Language Quick Reference](https://sdk.dfinity.org/docs/language-guide/language-manual.html)

If you want to start working on your project right away, you might want to try the following commands:

```bash
cd icpTopuper/
dfx help
dfx config --help
```


## Demo

Run the demo:

**Edit demo.sh and specify `didc` path**

- Deploy the `icpTopuper` canister, 3 canisters `exampleCanister` and 1 canister `exampleCanisterBad`
- Display the cycles balances
- setThreshold, setAmount to `icpTopuper`
- Burn some cycles from some `exampleCanister`, such as the cycles of some canisters is lower than the threshold
- Call `cronTask` of `icpTopuper`
- It should call `topUp` to canisters below the threshold with the correct cycles amount
- Display the cycles balances

```
DIDC_PATH=/path/to/didc sh demo.sh
```

### Make your canister `icpTopuper` compatible

Your canister needs to have two functions defined as `src/exampleCanister/main.mo`:

```
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
```