//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

contract Gravity{
    uint utcStartTime; // Deepak: do we need this???

    address owner;
    uint    numberOfAccounts;

    uint strategyCount;
    uint daiDailyPurchase;
    bool tradeExecuted;

    event Deposited(address, uint256);
    event Withdrawn(address, uint256);

    // data structure for each account policy
    struct Account {
        uint             accountStart;
        string           sourceAsset;
        string           targetAsset;
        uint             originalSourceBalance;
        uint             sourceBalance;
        uint             targetBalance;
        uint             intervalAmount;
        string           strategyFrequency;   // number of interval days, minimum will be 1 day and max yearly;         // timestamp offset
    }

    // purchase order details for a user & account policy at a specific interval
    struct PurchaseOrder {
        address user;
        uint    AccountId;
        uint    purchaseAmount;
    }

    // user address to user Account policy mapping
    mapping (address => mapping (uint => Account)) public accounts;

    // timestamp interval to PurchaseOrder mapping
    mapping (uint => PurchaseOrder[]) public liveStrategies;

    // ERC20 token address mapping
    mapping (string => address) public tokenAddresses;

    //Frequency mapping for validation
    mapping (string => bool) public IntervalFrquency;

    constructor() {
        utcStartTime = block.timestamp; // contract deployment timestamp
        owner = msg.sender;
        numberOfAccounts = 0;
            
            // load asset addresses into tokenAddress mapping
        tokenAddresses['USDC']  = address(0xe11A86849d99F524cAC3E7A0Ec1241828e332C62);
        tokenAddresses['WETH'] = address(0xd0A1E359811322d97991E03f863a0C30C2cF029C);
        tokenAddresses['LINK'] = address(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);
        tokenAddresses['DAI'] = address(0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa);

        //Load IntervalFrquency mapping table 
        IntervalFrquency['Daily'] = true;
        IntervalFrquency['Weekly'] = true;
        IntervalFrquency['Monthly'] = true;
        IntervalFrquency['Quaterly'] = true;
        IntervalFrquency['HalfYearly'] = true;
        IntervalFrquency['Yearly'] = true;
    }

    function addNewToken(string memory _sourceAsset,address _sourceAssetAddress) external{
        require(msg.sender == owner,"Only owner can add new Source Asset");
        require(_sourceAssetAddress !=address(0x0));
        tokenAddresses[_sourceAsset] = _sourceAssetAddress;
    }

    function initiateNewStrategy( string            calldata _sourceAsset,
                                  string            calldata _targetAsset,
                                  uint                       _sourceBalance,
                                  uint                       _intervalAmount,
                                  string            calldata _strategyFrequency) 
                                external{
        console.log(_sourceAsset,tokenAddresses[_sourceAsset],_targetAsset,tokenAddresses[_targetAsset]);
        require(tokenAddresses[_sourceAsset] != address(0x0) && tokenAddresses[_targetAsset] != address(0x0), "Unsupported source or target asset type");                                    
        require(_intervalAmount<=_sourceBalance,"Interval Amount cannot be more than Strategy Source Asset");
        require(IntervalFrquency[_strategyFrequency],"Invalid value for strategy frequency");
        require(tokenAddresses[_sourceAsset] != tokenAddresses[_targetAsset],"Source and Target asset cannot be same");

        //Validate inputs for accounts
        //Create new Account of type structure Account
        Account memory newAccount;
        
        //Initialize new account
        uint       accountId             = numberOfAccounts+1;

        newAccount.accountStart          = block.timestamp;
        newAccount.sourceAsset           = _sourceAsset;
        newAccount.sourceBalance         = _sourceBalance;
        newAccount.originalSourceBalance = _sourceBalance;
        newAccount.targetAsset           = _targetAsset;        
        newAccount.targetBalance         = 0;
        newAccount.intervalAmount        = _intervalAmount;
        newAccount.strategyFrequency     = _strategyFrequency;

        // Add the new account policy to current user's accounts mapping
        accounts[msg.sender][accountId] = newAccount;

        // Deposit orginal source balance to contract
        deposit(_sourceAsset,_sourceBalance);
     
     }

     // deposit first requires approving an allowance by the msg.sender
    
     function deposit(string memory _sourceAsset,uint _amount) internal {
        address _token = tokenAddresses[_sourceAsset];
        require(IERC20(_token).transferFrom(msg.sender, address(this), _amount),"Initial deposit transfer failed");
        emit Deposited(msg.sender, _amount);
    }

    function withdraw(uint accountId, uint256 _amount) external {
        string   memory _sourceAsset = accounts[msg.sender][accountId].sourceAsset;
        address _token = tokenAddresses[_sourceAsset];
        require(accounts[msg.sender][accountId].sourceBalance >= _amount);
        accounts[msg.sender][accountId].sourceBalance -= _amount;
        (bool success) = IERC20(_token).transfer(msg.sender, _amount);
        require(success, "Withdraw unsuccessful");
        emit Withdrawn(msg.sender, _amount);
    }

    receive() external payable {}

}