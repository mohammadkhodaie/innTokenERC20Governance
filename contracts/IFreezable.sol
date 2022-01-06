// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IFreezable {
    /**
     * @dev return the freezed amount of an account .    
     */
    function freezedOf(address account) external view returns(uint256);

    /**
     * @dev freeze amounts of token from sender address .    
     */  
    function freeze(address freezed, uint256 amount) external returns(bool);
    /**
     * @dev unfreeze amounts of token from sender address .    
     */  
    function unFreeze(address freezed, uint256 amount) external returns(bool);

    /**
     *@dev Emmitted the `value` and `oldValue` of tokens freezed by the owner of token . 
     */
    event Freezed(address indexed owner , uint256 oldValue ,uint256 value );

}