# WETHMock

A minimal implementation of WETH for testing purposes.

It has many flaws and doesn't work correctly. Don't even think of using it in production!

## Functions

### constructor

```solidity
  constructor(
    string name,
    string symbol,
    uint8 tokenDecimals,
    address supplyReceiver,
    uint256 initialSupply
  )
```

Sets metadata and mints an initial supply to `supplyReceiver`.

#### Parameters:

| Name             | Type    | Description                                     |
| :--------------- | :------ | :---------------------------------------------- |
| `name`           | string  | The name of the token.                          |
| `symbol`         | string  | The symbol of the token.                        |
| `tokenDecimals`  | uint8   | The number of decimals of the token.            |
| `supplyReceiver` | address | The address receiving the initial token supply. |
| `initialSupply`  | uint256 | The amount of pre-minted tokens.                |

### deposit

```solidity
  function deposit(
  ) external
```

Deposit ether to get wrapped ether.

### withdraw

```solidity
  function withdraw(
    uint256 wad
  ) external
```

Withdraw wrapped ether to get ether.

#### Parameters:

| Name  | Type    | Description                      |
| :---- | :------ | :------------------------------- |
| `wad` | uint256 | The amount of ether to withdraw. |

### balanceOf2

```solidity
  function balanceOf2(
    address account
  ) public returns (uint256 wad)
```

Returns the amount of tokens owned by `account`, that were transferred using the mocked transfer function.

This should be used instead of the original.

#### Parameters:

| Name      | Type    | Description                           |
| :-------- | :------ | :------------------------------------ |
| `account` | address | The address whose balance is queried. |

#### Return Values:

| Name  | Type    | Description                                |
| :---- | :------ | :----------------------------------------- |
| `wad` | address | The amount of tokens owned by the account. |

### \_transfer

```solidity
  function _transfer(
  ) internal
```

Updates the mapping declared here and does nothing else.

## State variables

```solidity
  mapping(address => uint256) _balances;
```
