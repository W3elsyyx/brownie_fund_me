// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {
    using SafeMathChainlink for uint256;

    mapping( address => uint256 ) public addressToAmountFunded;
    address[] public funders;
    address public owner;
    AggregatorV3Interface public priceFeed;

    constructor( address _priceFeed ) public {
        priceFeed = AggregatorV3Interface( _priceFeed );
        owner = msg.sender;
    }

    // "PAYABLE" = hei, this function can be used to pay
    function fund() public payable {
        // 50$
        uint256 minimumUSD = 50 * 10 ** 18;
        
        // a require statement checks the thruthiness of what we are asking
        require( getConversionRate( msg.value ) >= minimumUSD, "You need to spend more eth" );

        addressToAmountFunded[ msg.sender ] += msg.value;
        funders.push( msg.sender );

    }

    // what the ETH -> USD conversion rate
    function getVersion() public view returns( uint256 ) {
        // we have a contract located at that address
        return priceFeed.version();
    }

    function getPrice() public view returns( uint256 ) {
        // latestRoundData() return a tuple of 5 elements.
        // to clean up some code, we may delete those variables and leave a blank space between commas
        ( , int256 answer, , , ) = priceFeed.latestRoundData();

        return uint256( answer * 10000000000 );
        // 2,647.84257046
    }

    // we want convert 1000000000
    function getConversionRate( uint256 ethAmount ) public view returns( uint256 ) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUSD = ( ethPrice * ethAmount ) / 1000000000000000000;

        return ethAmountInUSD;
    }

    function getEntranceFee() public view returns( uint256 ) {
        // minimum USD
        uint256 minimumUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        return( minimumUSD * precision )/ price;
    }

    // MODIFIER: a modifier is used to change the behavior of a
    // function in a declarative way
    modifier onlyOnwer {
        require( msg.sender == owner );
        _; // do all the code, in this case withdraw()
    }
    

    function withdraw() payable onlyOnwer public {
        // only the owner of the address may withdraw
        // require( msg.sender == owner );
        msg.sender.transfer( address( this ).balance );

        // reset balance for funder
        for( uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++ ) {
            address funder = funders[ funderIndex ];
            addressToAmountFunded[ funder ] = 0;
        }

        funders = new address[]( 0 );
    }
}