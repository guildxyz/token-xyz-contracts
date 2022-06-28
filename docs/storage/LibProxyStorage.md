# LibProxyStorage

Storage helpers for the proxy contract.



## Functions
### getStorage
```solidity
  function getStorage(
  ) internal returns (struct LibProxyStorage.Storage stor)
```
Get the storage bucket for this contract.







## Structs
### Storage
```solidity
  struct Storage{
    mapping(bytes4 => address) impls;
    address owner;
  }
```

