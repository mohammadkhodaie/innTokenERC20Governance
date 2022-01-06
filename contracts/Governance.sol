// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import 'openzeppelin-solidity/contracts/governance/extensions/GovernorCountingSimple.sol';

contract governance is GovernorCountingSimple {
    address internal executer ; 
    address internal contractAddress ; 
    //this feature implemented instead of standard nft minting 
    //and use nft as accessToken 
    //https://blog.openzeppelin.com/governor-smart-contract/
    mapping(address => bool ) hasAccessToVote ; 
    constructor(string memory name_) Governor(name_) {
        executer = msg.sender;
        contractAddress = address(this);
    }
    modifier onlyContractAddress(){
        require(msg.sender == contractAddress , "Governor:only contract address can add validator after vote ");
        _;
    }
    modifier onlyValidators(){
        require(hasAccessToVote[msg.sender] == true , "Governor: only validator can vote");
        _;
    }
    /**
     * @dev it is the internal function for the parent `GovernorCountingSimple` and show how the votes count .
     * remember this vote can not reverted . 
     */
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
    * @dev this function call in parent `Governor` and in `onlyGovernance` modifier . 
    */
    function _executor() internal view override(Governor) returns (address) {
        return executer;
    }

    /**
     * @notice module:reputation
     * @dev Voting power of an `account` at a specific `blockNumber`.
     *
     * Note: this can be implemented in a number of ways, for example by reading the delegated balance from one (or
     * multiple), {ERC20Votes} tokens.
     * @dev this function calls in require for propose a new thing , for our purposes it is enough . 
     */
    function getVotes(address account, uint256 blockNumber) public view override(IGovernor) returns (uint256){
        return hasAccessToVote[account] ? 1 : 0 ;  
    }

    /**
     *@dev this function executes after `proposeNewValidator` voting period done . 
     */
    function addNewValidator(address newValidator) public onlyContractAddress {
        hasAccessToVote[newValidator] = true ; 
    }

    /**
     *@dev in this function we propose a new validator and start the voting for  `newValidator` to add in the list of validators . 
     * this piece of code creates call data
     */

    function proposeNewValidator(address newValidator ) public onlyValidators return(uint256) {
        bytes memory data = abi.encodeWithSelector(
            bytes4(
                keccak256("addNewValidator(address)")
            ),
            newValidator
        );
        //returning proposalId

        return super.propose(contractAddress , 0 , data , "adding new validator to the list of validators");

    }

    /**
     *@dev this function executes after `proposeNewStartUp` voting period done . 
     */
    function sendGrantToStratUpAccount(address startUpAddress , uint256 grantAmount) public onlyContractAddress {
        // TODO : implement this . 
    }

    function proposeNewStartUp(address startUpAddress ,uint256 grant , string memory description) external onlyValidators return(uint256){
        bytes memory data = abi.encodeWithSelector(
            bytes4(
                keccak256("sendGrantToStratUpAccount(address,uint256)")
            ),
            startUpAddress , grant
        );
        //returning proposalId
        return super.propose(contractAddress , 0 , data , "adding new validator to the list of validators");

    }

}