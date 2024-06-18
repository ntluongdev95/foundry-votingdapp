// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract SigUtils {
    
    bytes32 internal immutable DOMAIN_SEPARATOR;
   

    /// @dev keccak256("VotingMessage(uint256 poolId,uint256 contestantId,uint256 tickNumber,uint256 expriedTime)");
    bytes32 public constant VOTINGMESSAGE_TYPEHASH = 0xd6013972aa40111e0e3a0a78aa33a6d4d79f325f65be6e92e71e4b6c73d5f051;

    ///@dev keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 public constant EIP712DOMAIN_TYPEHASH = 0x8b73d7ec7fffa0e2ec7b6e6a6f9d89c7bb3b40aa60c4846ba8bb5a514e6b3d87;

    struct VotingMessage {
        uint256 poolId;
        uint256 contestantId;
        uint256 tickNumber;
        uint256 expriedTime;
    }

    struct EIP712Domain {
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
    }

     constructor( address ) {
        DOMAIN_SEPARATOR = keccak256(
        abi.encode(
            EIP712DOMAIN_TYPEHASH,
            keccak256(bytes(eip_712_domain_separator_struct.name)),
            keccak256(bytes(eip_712_domain_separator_struct.version)),
            eip_712_domain_separator_struct.chainId,
            eip_712_domain_separator_struct.verifyingContract
        )
    }

    /// @dev Computes the hash of a permit
    /// @param _permit The approval to execute on-chain
    /// @return The encoded permit
    function getStructHash(Permit memory _permit)
        internal
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encode(
                    PERMIT_TYPEHASH,
                    _permit.owner,
                    _permit.spender,
                    _permit.value,
                    _permit.nonce,
                    _permit.deadline
                )
            );
    }

    /// @notice Computes the hash of a fully encoded EIP-712 message for the domain
    /// @param _permit The approval to execute on-chain
    /// @return The digest to sign and use to recover the signer
    function getTypedDataHash(Permit memory _permit)
        public
        view
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR,
                    getStructHash(_permit)
                )
            );
    }
}