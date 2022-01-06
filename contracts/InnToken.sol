// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
import 'openzeppelin-solidity/contracts/token/ERC20/extensions/ERC20Burnable.sol';
import 'openzeppelin-solidity/contracts/access/Ownable.sol';
import './IFreezable.sol';
import 'openzeppelin-solidity/contracts/utils/introspection/ERC165.sol';



contract innToken is
 ERC20Burnable , Ownable , IFreezable , ERC165  {
   //now we need to override the functions that we need to change 
   mapping(address => uint256) _freezingBalance ; 
  constructor(uint256 initialSupply) ERC20("InnoToken" , "INT"){
   _mint(address(this), initialSupply);
   _approve(address(this), msg.sender,balanceOf(address(this)));

  }

  //TODO :  need to check the flow of this function 
  function transferOwnership(address newOwner) public override(Ownable) onlyOwner {
    _approve(address(this),msg.sender , 0);//TODO : here i need to know that msg.sender cost more gas or super._owner 
    super.transferOwnership(newOwner);
    _approve(address(this), newOwner,balanceOf(address(this)));
  }

  function renounceOwnership() public override(Ownable) onlyOwner {
    revert("renounceOwnership: cannot remove the owner of contract");
  }
  /**
    * @dev in this method owner of contract burn some value of contract address .       
    */  
  function burn(uint256 amount) public override(ERC20Burnable) onlyOwner {
    super.burnFrom(address(this) , amount);
  }
  function burnFrom(address account, uint256 amount) public override(ERC20Burnable) {
    revert("only Owner can burn");
  }
  /**
    * @dev in this method mint `amount` of token for the contract address 
    * and set the allowance of that to the contract owner     
    */  
  function mint(uint256 amount) onlyOwner external {
    super._mint(address(this), amount);
    super._approve(address(this) , msg.sender, balanceOf(address(this)));
  }
  /**
  * @dev return the freezed amount of an account .    
  */
  function freezedOf(address account) external view returns(uint256){
    return _freezingBalance[account];
  }

  /**
    * @dev freeze amounts of token from sender address .    
    */  
  function freeze(address freezed, uint256 amount) external onlyOwner returns(bool){
    require(freezed != owner(), "Not Owner: callee is not the owner");
    super._burn(freezed , amount);
    _freezingBalance[freezed] += amount ; 
    return true;
  }
  /**
  * @dev unfreeze amounts of token from sender address .    
  */  
  function unFreeze(address freezed, uint256 amount) external returns(bool){
    require(freezed != owner(), "Not Owner: callee is not the owner");
    uint256 freezedBalance = _freezingBalance[freezed];
    require(freezedBalance >= amount , "ERC20: unfreeze amount exceed freezedBalance");
    super._mint(freezed , amount);
    _freezingBalance[freezed] -= amount ; 
    return true ; 
  }



  /**
    * @dev See {IERC165-supportsInterface}.
    */
  function supportsInterface(bytes4 interfaceId)
      public
      view
      virtual
      override(ERC165)
      returns (bool)
  {
      return
          interfaceId == type(IFreezable).interfaceId ||
          interfaceId == type(IERC20).interfaceId || 
          super.supportsInterface(interfaceId);
  }

    // /**
    //  * @dev Throws if recive address and msg.sender the same 
    //  */
    // modifier notOwner(address input) {szsw-+

























    
    //     require(input != owner(), "Not Owner: caller is not the owner");
    //     _;
    // }

} 
