// SPDX-License-Identifier: Apache-2.0

/*

  The file has been modified.
  2022 token.xyz

*/

/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity 0.8.14;

import { LibBytesV06 } from "./utils/LibBytesV06.sol";
import { BootstrapFeature } from "./features/BootstrapFeature.sol";
import { LibProxyStorage } from "./storage/LibProxyStorage.sol";

/// @title An extensible proxy contract that serves as a universal entry point for
///      interacting with the token.xyz contracts.
contract TokenXyz {
    using LibBytesV06 for bytes;

    /// @notice Error thrown when the requested function is not found in any features.
    /// @param selector The function's selector that was attempted to be called.
    error NotImplemented(bytes4 selector);

    /// @notice Construct this contract and register the `BootstrapFeature` feature.
    ///         After constructing this contract, `bootstrap()` should be called
    ///         by `bootstrap()` to seed the initial feature set.
    /// @param bootstrapper Who can call `bootstrap()`.
    constructor(address bootstrapper) {
        // Temporarily create and register the bootstrap feature.
        // It will deregister itself after `bootstrap()` has been called.
        BootstrapFeature bootstrap = new BootstrapFeature(bootstrapper);
        LibProxyStorage.getStorage().impls[bootstrap.bootstrap.selector] = address(bootstrap);
    }

    /// @notice Forwards calls to the appropriate implementation contract.
    // solhint-disable-next-line no-complex-fallback
    fallback() external payable {
        bytes4 selector = msg.data.readBytes4(0);
        address impl = getFunctionImplementation(selector);
        if (impl == address(0)) revert NotImplemented(selector);

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory resultData) = impl.delegatecall(msg.data);
        if (!success) {
            _revertWithData(resultData);
        }
        _returnWithData(resultData);
    }

    /// @notice Fallback for just receiving ether.
    // solhint-disable-next-line no-empty-blocks
    receive() external payable {}

    /// @notice Get the implementation contract of a registered function.
    /// @param selector The function selector.
    /// @return impl The implementation contract address.
    function getFunctionImplementation(bytes4 selector) public view returns (address impl) {
        return LibProxyStorage.getStorage().impls[selector];
    }

    /// @notice Revert with arbitrary bytes.
    /// @param data Revert data.
    function _revertWithData(bytes memory data) private pure {
        assembly {
            revert(add(data, 32), mload(data))
        }
    }

    /// @notice Return with arbitrary bytes.
    /// @param data Return data.
    function _returnWithData(bytes memory data) private pure {
        assembly {
            return(add(data, 32), mload(data))
        }
    }
}
