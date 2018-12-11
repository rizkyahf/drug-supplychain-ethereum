pragma solidity ^0.4.23 ;

import "./SupplyChainStorageOwnable.sol";

contract SupplyChainStorage is SupplyChainStorageOwnable {
    
    address public lastAccess;
    constructor() public {
        authorizedCaller[msg.sender] = 1;
        emit AuthorizedCaller(msg.sender);
    }
    
    /* Events */
    event AuthorizedCaller(address caller);
    event DeAuthorizedCaller(address caller);
    
    /* Modifiers */
    
    modifier onlyAuthCaller(){
        lastAccess = msg.sender;
        // require(authorizedCaller[msg.sender] == 1);
        _;
    }
    
    /* User Related */
    struct user {
        string  name;
        string  contactNo;
        bool    isActive;
        string  profileHash;
    } 
    
    mapping(address => user)    userDetails;
    mapping(address => string)  userRole;
    
    /* Caller Mapping */
    mapping(address => uint8) authorizedCaller;
    
    /* authorize caller */
    function authorizeCaller(address _caller) public onlyOwner returns(bool) 
    {
        authorizedCaller[_caller] = 1;
        emit AuthorizedCaller(_caller);
        return true;
    }
    
    /* deauthorize caller */
    function deAuthorizeCaller(address _caller) public onlyOwner returns(bool) 
    {
        authorizedCaller[_caller] = 0;
        emit DeAuthorizedCaller(_caller);
        return true;
    }
    
    /*User Roles
        ADMIN,
        SUPPLIER,
        FACTORY,
        DISTRIBUTOR,
        DRUGSTORE
    */
    
    /* Process Related */
    // basicDetails yg pertama diisi admin
    struct basicDetails {
        string registrationNo;
        string drugName;
    }

    struct supplier{
        string sendDate;
        string factoryName;
        string itemName;
        uint32 quantity;
    }

    struct factoryIn{
        string receiveDate;
        string itemName;
        uint32 quantity;
    }   

    struct factorySend{
        string sendDate;
        string drugName;
        string productionNumber;
        string productionDate;
        string expiredDate;
        uint32 quantity;
    }

    struct distributorIn{
        string receiveDate;
        string drugName;
        uint32 quantity;
    }

    struct distributorSend{
        string sendDate;
        string drugStoreName;
        uint32 quantity;
    }

    struct drugStore{
        string receiveDate;
        uint32 quantity;
        string additionalInfo;
    }

    mapping (address => basicDetails)   	batchBasicDetails;
    mapping (address => supplier)       	batchSupplier;
    mapping (address => factoryIn)       	batchFactoryIn;
    mapping (address => factorySend)     	batchFactorySend;
    mapping (address => distributorIn)		batchDistributorIn;
	mapping (address => distributorSend)	batchDistributorSend;
	mapping (address => drugStore)			batchDrugStore;
    mapping (address => string)         	nextAction;
  
    /*Initialize struct pointer*/
	user			userDetail;
	basicDetails	basicDetailsData;
	supplier		supplierData;
	factoryIn		factoryInData;
	factorySend		factorySendData;
	distributorIn	distributorInData;
	distributorSend	distributorSendData;
	drugStore		drugStoreData;

    /* Get User Role */
    function getUserRole(address _userAddress) public onlyAuthCaller view returns(string){
        return userRole[_userAddress];
    }
    
    /* Get Next Action  */    
    function getNextAction(address _batchNo) public onlyAuthCaller view returns(string){
        return nextAction[_batchNo];
    }
        
    /*set user details*/
    function setUser(address _userAddress,
                     string _name, 
                     string _contactNo, 
                     string _role, 
                     bool _isActive,
                     string _profileHash) public onlyAuthCaller returns(bool){
        
        /*store data into struct*/
        userDetail.name 		= _name;
        userDetail.contactNo 	= _contactNo;
        userDetail.isActive 	= _isActive;
        userDetail.profileHash 	= _profileHash;
        
        /*store data into mapping*/
        userDetails[_userAddress] 	= userDetail;
        userRole[_userAddress] 		= _role;
        
        return true;
    }  
    
    /*get user details*/
    function getUser(address _userAddress) public onlyAuthCaller view returns(string name, 
                                                                    string contactNo, 
                                                                    string role,
                                                                    bool isActive, 
                                                                    string profileHash
                                                                ){
        /*Getting value from struct*/
        user memory tmpData = userDetails[_userAddress];
        
        return (tmpData.name, tmpData.contactNo, userRole[_userAddress], tmpData.isActive, tmpData.profileHash);
    }
    
    /*set batch basicDetails*/
    function setBasicDetails(string _registrationNo, string _drugName) public onlyAuthCaller returns(address) {
        uint tmpData = uint(keccak256(msg.sender, now));
        address batchNo = address(tmpData);
        
        basicDetailsData.registrationNo = _registrationNo;
        basicDetailsData.drugName = _drugName;

        batchBasicDetails[batchNo] = basicDetailsData;
        nextAction[batchNo] = 'SUPPLIER';   
        
        return batchNo;
    }
    
    /*get batch basicDetails*/
    function getBasicDetails(address _batchNo) public onlyAuthCaller view returns(string registrationNo, string drugName) {
        basicDetails memory tmpData = batchBasicDetails[_batchNo];
        return (tmpData.registrationNo,tmpData.drugName);
    }

	/*set batch supplierData*/
	function setSupplierData(address batchNo, 
							 string _sendDate,
							 string _factoryName, 
							 string _itemName, 
							 uint32 _quantity) public onlyAuthCaller returns(bool){
		supplierData.sendDate		= _sendDate;
		supplierData.factoryName	= _factoryName;
		supplierData.itemName		= _itemName;
		supplierData.quantity		= _quantity;

		batchSupplier[batchNo] 	= supplierData;
		nextAction[batchNo]		= 'FACTORY_IN';

		return true;
	}

	/*get batch supplierData */
	function getSupplierData(address batchNo) public onlyAuthCaller view returns(string sendDate, 
																				 string factoryName,
																				 string itemName,
																				 uint32 quantity){
		supplier memory tmpData = batchSupplier[batchNo];
		return(tmpData.sendDate, tmpData.factoryName, tmpData.itemName, tmpData.quantity);
	}

	/*set batch factoryInData*/
	function setFactoryInData(address batchNo,
							  string _receiveDate,
							  string _itemName,
							  uint32 _quantity) public onlyAuthCaller returns(bool){
		factoryInData.receiveDate	= _receiveDate;
		factoryInData.itemName		= _itemName;
		factoryInData.quantity		= _quantity;

		batchFactoryIn[batchNo]	= factoryInData;
		nextAction[batchNo]		= 'FACTORY_SEND';

		return true;
	}

	/*get batch factoryInData*/
	function getFactoryInData(address batchNo) public onlyAuthCaller view returns(string receiveDate,
																				  string itemName,
																				  uint32 quantity){
		factoryIn memory tmpData = batchFactoryIn[batchNo];
		return(tmpData.receiveDate, tmpData.itemName, tmpData.quantity);
	}

	/*set batch factorySendData*/
	function setFactorySendData(address batchNo,
								string _sendDate,
								string _drugName,
								string _productionNumber,
								string _productionDate,
								string _expiredDate,
								uint32 _quantity) public onlyAuthCaller returns(bool){
		factorySendData.sendDate			= _sendDate;
		factorySendData.drugName			= _drugName;
		factorySendData.productionNumber	= _productionNumber;
		factorySendData.productionDate		= _productionDate;
		factorySendData.expiredDate			= _expiredDate;
		factorySendData.quantity			= _quantity;

		batchFactorySend[batchNo]	= factorySendData;
		nextAction[batchNo]			= 'DISTRIBUTOR_IN';

		return true;
	}
    
	/*get batch factorySendData*/
	function getFactorySendData(address batchNo) public onlyAuthCaller view returns(string sendDate,
																					string drugName,
																					string productionNumber,
																					string productionDate,
																					string expiredDate,
																					uint32 quantity){
		factorySend memory tmpData = batchFactorySend[batchNo];
		return(tmpData.sendDate, tmpData.drugName, tmpData.productionNumber, tmpData.productionDate, tmpData.expiredDate, tmpData.quantity);
	}

	/*set batch distributorInData*/
	function setDistributorInData(address batchNo,
								  string _receiveDate,
								  string _drugName,
								  uint32 _quantity) public onlyAuthCaller returns(bool){
		distributorInData.receiveDate	= _receiveDate;
		distributorInData.drugName		= _drugName;
		distributorInData.quantity		= _quantity;

		batchDistributorIn[batchNo]	= distributorInData;
		nextAction[batchNo]			= 'DISTRIBUTOR_SEND';

		return true;
	}

	/*get batch distributorInData*/
	function getDistributorInData(address batchNo) public onlyAuthCaller view returns(string receiveDate,
																					  string drugName,
																					  uint32 quantity){
		distributorIn memory tmpData = batchDistributorIn[batchNo];
		return(tmpData.receiveDate, tmpData.drugName, tmpData.quantity);
	}

	/*set batch distributorSendData*/
	function setDistributorSendData(address batchNo,
									string _sendDate,
									string _drugStoreName,
									uint32 _quantity) public onlyAuthCaller returns(bool){
		distributorSendData.sendDate		= _sendDate;
		distributorSendData.drugStoreName	= _drugStoreName;
		distributorSendData.quantity		= _quantity;

		batchDistributorSend[batchNo]	= distributorSendData;
		nextAction[batchNo]				= 'DRUGSTORE';	

		return true;
	}

	/*get batch distributorSendData*/
	function getDistributorSendData(address batchNo) public onlyAuthCaller view returns(string sendDate,
																						string drugStoreName,
																						uint32 quantity){
		distributorSend memory tmpData = batchDistributorSend[batchNo];
		return(tmpData.sendDate, tmpData.drugStoreName, tmpData.quantity);
	}

	/*set batch drugStoreData*/
	function setDrugStoreData(address batchNo,
							  string _receiveDate,
							  uint32 _quantity,
							  string _additionalInfo) public onlyAuthCaller returns(bool){
		drugStoreData.receiveDate		= _receiveDate;
		drugStoreData.quantity			= _quantity;
		drugStoreData.additionalInfo	= _additionalInfo;

		batchDrugStore[batchNo]	= drugStoreData;
		nextAction[batchNo]		= 'DONE';

		return true;
	}

	/*get batch drugStoreData*/
	function getDrugStoreData(address batchNo) public onlyAuthCaller view returns(string receiveDate,
																				  uint32 quantity,
																				  string additionalInfo) {
	 	drugStore memory tmpData = batchDrugStore[batchNo];
		return(tmpData.receiveDate, tmpData.quantity, tmpData.additionalInfo);
	}

}    
