pragma solidity ^0.8.0;

import "./SetUp.sol";

contract TestProtocol is SetUp {

   function testUpdateOffer() public{
       money.transfer(address (kairos), 1 ether);
       
   }
}
