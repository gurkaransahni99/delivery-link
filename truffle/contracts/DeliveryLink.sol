pragma solidity ^0.6.0;

import "@chainlink/contracts/src/v0.6/ChainlinkClient.sol";
import "./Ownable.sol";

contract DeliveryLink is ChainlinkClient, Ownable {
  uint256 constant private ORACLE_PAYMENT = 1 * LINK;

  string private packageCarrier;
  string private packageCode;

  string private timestampJobId;
  uint256 public timestamp;

  event TimestampResponseReceived(
    bytes32 indexed requestId,
    uint256 indexed timestamp
  );

  string private deliveryStatusJobId;
  string public deliveryStatus;

  event DeliveryStatusResponseReceived(
    bytes32 indexed requestId,
    string indexed deliveryStatus
  );

  constructor(address _link, address _oracle) public Ownable() {
    setChainlinkToken(_link);
    setChainlinkOracle(_oracle);
  }

  function requestCurrentTimestamp()
    public
    onlyOwner
  {
    Chainlink.Request memory req = buildChainlinkRequest(stringToBytes32(timestampJobId), address(this), this.handleTimestampResponse.selector);
    req.add("get", "https://showcase.linx.twenty57.net:8080/UnixTime/tounixtimestamp?datetime=now");
    req.add("path", "UnixTimeStamp");
    sendChainlinkRequest(req, ORACLE_PAYMENT);
  }

  function handleTimestampResponse(bytes32 _requestId, uint256 _timestamp)
    public
    recordChainlinkFulfillment(_requestId)
  {
    emit TimestampResponseReceived(_requestId, _timestamp);
    timestamp = _timestamp;
  }

  function requestDeliveryStatus()
    public
    onlyOwner
  {
    Chainlink.Request memory req = buildChainlinkRequest(stringToBytes32(deliveryStatusJobId), address(this), this.handleDeliveryStatusResponse.selector);
    req.add("car", packageCarrier);
    req.add("code", packageCode);
    req.add("copyPath", "status");
    sendChainlinkRequest(req, ORACLE_PAYMENT);
  }

  function handleDeliveryStatusResponse(bytes32 _requestId, bytes32 _deliveryStatus)
    public
    recordChainlinkFulfillment(_requestId)
  {
    deliveryStatus = bytes32ToString(_deliveryStatus);
    emit DeliveryStatusResponseReceived(_requestId, deliveryStatus);
  }

  function setPackageCarrier(string memory _packageCarrier) public onlyOwner {
    packageCarrier = _packageCarrier;
  }

  function getPackageCarrier() public view returns (string memory) {
    return packageCarrier;
  }

  function setPackageCode(string memory _packageCode) public onlyOwner {
    packageCode = _packageCode;
  }

  function getPackageCode() public view returns (string memory) {
    return packageCode;
  }

  function setTimestampJobId(string memory _timestampJobId) public onlyOwner {
    timestampJobId = _timestampJobId;
  }

  function getTimestampJobId() public view returns (string memory) {
    return timestampJobId;
  }

  function setDeliveryStatusJobId(string memory _deliveryStatusJobId) public onlyOwner {
    deliveryStatusJobId = _deliveryStatusJobId;
  }

  function getDeliveryStatusJobId() public view returns (string memory) {
    return deliveryStatusJobId;
  }

  function getChainlinkOracle() public view returns (address) {
    return chainlinkOracleAddress();
  }

  function updateChainlinkOracle(address _oracle) public onlyOwner {
    setChainlinkOracle(_oracle);
  }

  function getChainlinkToken() public view returns (address) {
    return chainlinkTokenAddress();
  }

  function updateChainlinkToken(address _link) public onlyOwner {
    setChainlinkToken(_link);
  }

  function withdrawLink() public onlyOwner {
    LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
    require(link.transfer(msg.sender, link.balanceOf(address(this))), "Unable to transfer");
  }

  function cancelRequest(
    bytes32 _requestId,
    uint256 _payment,
    bytes4 _callbackFunctionId,
    uint256 _expiration
  )
    public
    onlyOwner
  {
    cancelChainlinkRequest(_requestId, _payment, _callbackFunctionId, _expiration);
  }

  function stringToBytes32(string memory source) private pure returns (bytes32 result) {
    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
      return 0x0;
    }

    assembly { // solhint-disable-line no-inline-assembly
      result := mload(add(source, 32))
    }
  }

  function bytes32ToString(bytes32 source) private pure returns (string memory result) {
    bytes memory tempBytes = new bytes(32);
    for (uint256 byteNdx; byteNdx < 32; ++byteNdx) {
      tempBytes[byteNdx] = source[byteNdx];
    }

    return string(tempBytes);
  }

}

// SPDX-License-Identifier: UNLICENSED

// pragma solidity ^0.6.0;

// import "@chainlink/contracts/src/v0.6/ChainlinkClient.sol";
// import "./Ownable.sol";

// /**
//  * THIS IS AN EXAMPLE CONTRACT WHICH USES HARDCODED VALUES FOR CLARITY.
//  * PLEASE DO NOT USE THIS CODE IN PRODUCTION.
//  */
// contract DeliveryLink is ChainlinkClient, Ownable {
  
//     bytes32 public score;
    
//     address private oracle;
//     bytes32 private jobId;
//     uint256 private fee;
    
//     /**
//      * Network: Kovan
//      * Oracle: 0x2f90A6D021db21e1B2A077c5a37B3C7E75D15b7e
//      * Job ID: 29fa9aa13bf1468788b7cc4a500a45b8
//      * Fee: 0.1 LINK
//      */

//     constructor(address _link, address _oracle) public Ownable() {
//       setChainlinkToken(_link);
//       setChainlinkOracle(_oracle);
//     }
    
//     // constructor() public {
//     //     setPublicChainlinkToken();
//     //     oracle = 0x2f90A6D021db21e1B2A077c5a37B3C7E75D15b7e;
//     //     jobId = "50fc4215f89443d185b061e5d7af9490";
//     //     fee = 0.1 * 10 ** 18; // (Varies by network and job)
//     // }
    
//     /**
//      * Create a Chainlink request to retrieve API response, find the target
//      * data, then multiply by 1000000000000000000 (to remove decimal places from data).
//      */
//      function requestMatchScore() public returns (bytes32 requestId) 
//      {
//          Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
         
//          // Set the URL to perform the GET request on
//          request.add("get", "https://cricapi.com/api/cricketScore?apikey=3gs0qQGGN9ai70MfHP914xwoN523&unique_id=1254086");
         
//          // Set the path to find the desired data in the API response, where the response format is:
//          // {"RAW":
//          //      {"ETH":
//          //          {"USD":
//          //              {
//          //                  ...,
//          //                  "VOLUME24HOUR": xxx.xxx,
//          //                  ...
//          //              }
//          //          }
//          //      }
//          //  }
//          request.add("path", "score");
         
//          // Multiply the result by 1000000000000000000 to remove decimals
//          // int timesAmount = 10**18;
//          // request.addInt("times", timesAmount);
         
//          // Sends the request
//          return sendChainlinkRequestTo(oracle, request, fee);
//      }
    
//     /**
//      * Receive the response in the form of uint256
//      */ 
//     function fulfill(bytes32 _requestId, bytes32 _score) public recordChainlinkFulfillment(_requestId)
//     {
//         score = _score;
//     }
 
//     // function withdrawLink() external {} - Implement a withdraw function to avoid locking your LINK in the contract
// }