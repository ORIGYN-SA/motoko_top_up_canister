# Demo of the icp canister cycles top-up canisters
#
#
# Need `didc` installed ( https://github.com/dfinity/candid/tree/master/tools/didc )
#
#
#
# icpTopuper checks a list of canisters which implements the interface
# public shared (msg) func canisterBalance(): async Nat
# and
# public shared (msg) func topUp(): async Nat
#
#
# Demo will initialize 3 canisters (A, B, C) that implement this interface
# and 1 canister that does not (D)
# and icpTopuper (X)
# By default the threshold is `999_000_000_000` cycles
# and the top-up amount is `1_000_000_000`
#
#
# We will burn 10_000_000_000 cycles in canisters A; and C;
#
#
# The controller of icpTopuper will set canisters A;B;C;D to top-up
#
# The controller will call the `cronTask` function periodically
# which would try to top them up  (this part would be periodically called outside of the demo)



set -e

npm install || true


dfx start --background --clean



# dfx identity new id_alice || true

# dfx --identity id_alice canister create --all

dfx canister create --all

dfx build

# dfx --identity id_alice canister install --all
dfx canister install --all


echo 
echo == Check balances ==
echo


echo == Balance of icpTopuper ==
dfx canister call icpTopuper canisterBalance
echo

echo == Balance of exampleCanister1 ==
dfx canister call exampleCanister1 canisterBalance
echo

echo == Balance of exampleCanister2 ==
dfx canister call exampleCanister2 canisterBalance
echo

echo == Balance of exampleCanister3 ==
dfx canister call exampleCanister3 canisterBalance
echo


echo 
echo == Burning 10_000_000_000 on exampleCanister1 and exampleCanister3 ==
echo

dfx canister call exampleCanister1 burnBest 10000000000
dfx canister call exampleCanister2 burnBest 10000000000


echo == Set canisters to top-up ==

if [[ -z "${DIDC_PATH}" ]]; then
  DIDC_PATH=/Users/dp/work/candid/tools/didc/out/debug/didc
else
  DIDC_PATH="${DIDC_PATH}"
fi
export DIDC_PATH

export COMMAND="$DIDC_PATH encode \"(vec { principal \\\"$(dfx canister id exampleCanister1)\\\"; principal \\\"$(dfx canister id exampleCanister2)\\\"; principal \\\"$(dfx canister id exampleCanister3)\\\"; principal \\\"$(dfx canister id exampleCanisterBad)\\\";  })\" -f blob"
echo $COMMAND
eval "$COMMAND>.demo.output.txt"
BLOB_ARGS=$(<.demo.output.txt)
echo $BLOB_ARGS
# dfx --identity id_alice canister call icpTopuper setCanisters "(vec { principal \"$(dfx canister id exampleCanister1)\"; principal \"$(dfx canister id exampleCanister2)\"; principal \"$(dfx canister id exampleCanister3)\"; principal \"$(dfx canister id exampleCanisterBad)\";  })"
dfx canister call $(dfx identity get-wallet) wallet_call "(record { canister = \"$(dfx canister id icpTopuper)\"; method_name = \"setCanisters\"; args= blob \"$BLOB_ARGS\"; cycles = (0:nat64);})"

echo


echo 
echo == Check balances ==
echo


echo == Balance of icpTopuper ==
dfx canister call icpTopuper canisterBalance
echo

echo == Balance of exampleCanister1 ==
dfx canister call exampleCanister1 canisterBalance
echo

echo == Balance of exampleCanister2 ==
dfx canister call exampleCanister2 canisterBalance
echo

echo == Balance of exampleCanister3 ==
dfx canister call exampleCanister3 canisterBalance
echo


echo == run cronTask ==

# dfx --identity id_alice canister call icpTopuper cronTask
# dfx canister call icpTopuper cronTask
dfx canister call $(dfx identity get-wallet) wallet_call "(record { canister = \"$(dfx canister id icpTopuper)\"; method_name = \"cronTask\"; args= blob \"DIDL\00\01\7f\"; cycles = (0:nat64);})"



echo 


echo 
echo == Check balances ==
echo


echo == Balance of icpTopuper ==
dfx canister call icpTopuper canisterBalance
echo

echo == Balance of exampleCanister1 ==
dfx canister call exampleCanister1 canisterBalance
echo

echo == Balance of exampleCanister2 ==
dfx canister call exampleCanister2 canisterBalance
echo

echo == Balance of exampleCanister3 ==
dfx canister call exampleCanister3 canisterBalance
echo
