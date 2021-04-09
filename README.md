## ICP Canisters Automatic Top-up Service

Implementation of a canister called periodically by a Node.js service; that top-up automatically user-defined canisters with cycles.


### High level Diagram


![diagram](./docs/ICP%20Canisters%20Automatic%20Top-up.png)



### Directory structure

```
.
├── README.md
├── backend_service # contains the back-end service that would be running and call periodically the canister
├── canisters # contains the canisters codes with some examples canisters
└── docs
```