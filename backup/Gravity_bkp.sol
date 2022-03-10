//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

contract Gravity{
    uint utcStartTime; // Deepak: do we need this???

    address owner;
    uint    numberOfAccounts;

    uint strategyCount;
    uint daiDailyPurchase;
    bool tradeExecuted;

    enum IntervalFrquency {Daily, Weekly, Monthly, Quaterly, HalfYearly, Yearly} // Deepak: More descriptive intervals
    enum AssetType {DAI, wETH, LINK}

    constructor() {
        utcStartTime = block.timestamp; // contract deployment timestamp
        owner = msg.sender;
        numberOfAccounts = 0;
    }

    // struct LiveStrategy {
    //     uint             initStrategy;       // timestamp
    //     IntervalFrquency purchaseInterval;   // number of interval days, minimum will be 1 day and max yearly
    //     uint             purchaseAmount;     // e.g., 10% of daiBalance
    //     uint             trigger;            // timestamp trigger
    //     uint             purchasesRemaining; // count of purchases, calc at strat init
    // } 

    // data structure for each account policy
    struct Account {
        uint             accountId;
        uint             accountStart;
        AssetType        sourceAsset;
        AssetType        targetAsset;
        uint             sourceBalance;
        uint             targetBalance;
        uint             intervalAmount;
        IntervalFrquency strategyFrequency;   // number of interval days, minimum will be 1 day and max yearly;         // timestamp offset
    }

    // purchase order details for a user & account policy at a specific interval
    struct PurchaseOrder {
        address user;
        uint    AccountId;
        uint    purchaseAmount;
    }

    // user address to user Account policy mapping
    mapping (address => Account[]) public accounts;

    // timestamp interval to PurchaseOrder mapping
    mapping (uint => PurchaseOrder[]) public liveStrategies;

    function initiateNewStrategy(AssetType          _sourceAsset,
                                  AssetType         _targetAsset,
                                  uint              _sourceBalance,
                                  uint              _intervalAmount,
                                  IntervalFrquency  _strategyFrequency) 
                                external{
        require(_intervalAmount  <= uint(IntervalFrquency.Yearly));
        require(_sourceAsset <= AssetType.wETH && _targetAsset <= AssetType.wETH);
        require(_sourceAsset != _targetAsset);

        //Validate inputs for accounts
        //Create new Account of type structure Account
        Account memory newAccount;
        
        //Initialize new account
        newAccount.accountId            = numberOfAccounts+1;
        newAccount.accountStart         = block.timestamp;
        newAccount.sourceAsset          = _sourceAsset;
        newAccount.sourceBalance        = _sourceBalance;
        newAccount.targetAsset          = _targetAsset;        
        newAccount.targetBalance        = 0;
        newAccount.intervalAmount       = _intervalAmount;
        newAccount.strategyFrequency    = _strategyFrequency;

        accounts[msg.sender].push(newAccount);
        numberOfAccounts++;

        // Source and intervalAmount > 0. Source amount >= Interval amount 
        // Populate account
        // Populate Strategy
        // source and target type cannot be same

     }

    // // function to remove prior days array value from liveStrategies
    // function deleteKV(uint timestamp) internal {
    //     delete liveStrategies[timestamp];
    // }

    // // constant time function to remove users with 0 daiBalance, decrement dailyPoolUserCount
    // function removeStrategy(uint index) internal {
    //     require(index < liveStrategies.length, "Index out of range");
    //     liveStrategies[index] = liveStrategies[liveStrategies.length - 1];
    //     liveStrategies.pop();
    //     strategyCount--;
    // }

     

    // // function withdrawSource() {

    // // }

    // // function withdrawTarget() {

    // // }


    // /*
    //     TO DO: inherit Chainlink Keepers contract functionality
    // */
    // function checkUpkeep(bytes calldata /* checkData */) external override returns (bool upkeepNeeded, bytes memory /* performData */) {
    //     require(tradeExecuted == false);
    //     upkeepNeeded = (block.timestamp % 24 * 60 * 60 == 0);
    //     // We don't use the checkData in this example. The checkData is defined when the Upkeep was registered.
    // }

    // // performs the work on the contract, if instructed by checkUpkeep().
    // function performUpkeep(bytes calldata /* performData */) external override {
    //     //We highly recommend revalidating the upkeep in the performUpkeep function
    //     // We don't use the performData in this example. The performData is generated by the Keeper's call to your checkUpkeep function
    // }

    // // keeper performUpkeep function executes batchTransaction once per day
    // function batchTransaction() external payable {

    //     // daily range to check whether user has purchase to be made today
    //     uint today = block.timestamp;
    //     uint todayStart = today - (12 * 60 * 60);
    //     uint todayEnd = today + (12 * 60 * 60); 

    //     // loop over liveStrategies
    //     for(uint i = 0; i < strategyCount; i++) {
    //         uint userNextPurchase = liveStrategies[i].initStrategy + (liveStrategies[i].purchaseFrequency * 24 * 60 * 60);

    //         // if user still has purchasesRemaining continue
    //         if(liveStrategies[i].purchasesRemaining > 0) {

    //             // if users next purchase falls within today
    //             if(userNextPurchase > todayStart && userNextPurchase < todayEnd) {

    //                 // check balance is above user's purchase amount
    //                 if(accounts[liveStrategies[i].user].daiBalance > liveStrategies[i].purchaseAmount) {

    //                     // decrement user's daiBalance
    //                     accounts[liveStrategies[i].user].daiBalance - liveStrategies[i].purchaseAmount;

    //                     // decrement user's purchasesRemaining;
    //                     liveStrategies[i].purchasesRemaining -= 1;

    //                     // increment daiDailyPurchase for today
    //                     daiDailyPurchase += liveStrategies[i].purchaseAmount;
    //                 }
    //             }
    //         }
    //         else { // purchasesRemaining == 0; remove from liveStrategies array 
    //             removeStrategy(i);
    //         }
    //     }
    //     require(daiDailyPurchase > 0, "DA daily purchase insufficient");
        
    //     /*
    //         TO DO: integrate executeTrade() function
    //     */

    //     /*
    //         TO DO: run allocate function to update user ETH balances
    //     */

    // }


    // /*
    //     TO DO: yield function/treasury allocation 
    // */

}