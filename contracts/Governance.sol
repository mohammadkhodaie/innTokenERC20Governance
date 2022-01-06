// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import 'openzeppelin-solidity/contracts/governance/extensions/GovernorCountingSimple.sol';

contract governance is GovernorCountingSimple {
    address internal executer ; 
    
    //this feature implemented instead of standard nft minting 
    //and use nft as accessToken 
    //https://blog.openzeppelin.com/governor-smart-contract/
    mapping(address => bool ) hasAccessToVote ; 
    constructor(string memory name_) Governor(name_) {
        executer = msg.sender;
    }
    modifier onlyValidators(){
        require(hasAccessToVote[msg.sender] == true , "Governor: only validator can vote");
        _;
    }

    function _countVote(
        uint256 proposalId,
        address account,
        uint8 support,
        uint256 weight
    ) internal override(GovernorCountingSimple) onlyValidators {
        //we don't have weight in this contract 
        super._countVote(proposalId , account , support , 1);
    }
    /**
    * @dev Address through which the governor executes action. Will be overloaded by module that execute actions
    * through another contract such as a timelock.
    */
    function _executor() internal view override(Governor) returns (address) {
        return executer;
    }


}