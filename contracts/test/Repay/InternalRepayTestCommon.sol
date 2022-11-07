pragma solidity ^0.8.0;

import "../TestCommons.sol";
import "../../DataStructure/Objects.sol";
import "../Borrow/ComplexBorrow/PreExecFuncs.sol";

contract InternalRepayTestCommon is ComplexBorrowPreExecFuncs{

    function multipleBorrow() public returns(ComplexBorrowData memory d){


        ComplexBorrowData memory complexBorrowData;

        initMinting();
        prepareSigners();

        complexBorrowData = initOffers(complexBorrowData);
        complexBorrowData = initOfferArgs(complexBorrowData);


        OfferArgs[] memory offerArgs = new OfferArgs[](2);
        offerArgs[0] = complexBorrowData.oargs1;
        offerArgs[1]= complexBorrowData.oargs2;


        complexBorrowData.bargs1 = BorrowArgs(
        {
        nft: NFToken(
            {implem:nft,
            id:1
            }),
        args: offerArgs
        });

        BorrowArgs[] memory batchbargs = new BorrowArgs[](1);
        batchbargs[0]= complexBorrowData.bargs1;

        kairos.borrow(batchbargs);
        //Provision memory supp1pos1 = kairos.position(1);

        return complexBorrowData;


    }
}
