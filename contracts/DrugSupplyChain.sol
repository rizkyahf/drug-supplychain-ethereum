pragma solidity ^0.4.23;
import "./SupplyChainStorage.sol";
import "./Ownable.sol";

contract DrugSupplyChain is Ownable{
	event InitialBatch(address indexed user, address indexed batchNo);
	event DoneSupplier(address indexed user, address indexed batchNo);
	event DoneFactoryIn(address indexed user, address indexed batchNo);
	event DoneFactorySend(address indexed user, address indexed batchNo);
	event DoneDistributorIn(address indexed user, address indexed batchNo);
	event DoneDistributorSend(address indexed user, address indexed batchNo);
	event DoneDrugStore(address indexed user, address indexed batchNo);

	/* Modifier */
    modifier isValidPerformer(address batchNo, string role, string nextAction) {
    
        require(keccak256(supplyChainStorage.getUserRole(msg.sender)) == keccak256(role));
        require(keccak256(supplyChainStorage.getNextAction(batchNo)) == keccak256(nextAction));
        _;
    }
	
    /* Storage Variables */    
    SupplyChainStorage supplyChainStorage;
	
    constructor(address _supplyChainAddress) public {
        supplyChainStorage = SupplyChainStorage(_supplyChainAddress);
    }
    
	/* Get Next Action */
	function getNextAction(address _batchNo) public view returns(string action){
       (action) = supplyChainStorage.getNextAction(_batchNo);
       return (action);
    }

	/* Perform Basic Batch */
	function addBasicDetails(string _registrationNo, string _drugName) public onlyOwner returns(address){
		address batchNo = supplyChainStorage.setBasicDetails(_registrationNo, _drugName);

		emit InitialBatch(msg.sender, batchNo);
		return(batchNo);
	}

	/* Get Basic Details */
	function getBasicDetails(address _batchNo) public view returns(string registrationNo, string drugName){
		/* Call Storage Contract */
		(registrationNo, drugName) = supplyChainStorage.getBasicDetails(_batchNo);
		return(registrationNo, drugName);
	}

	/* Perform Supplier */
	function updateSupplierData(address _batchNo, 
								string _sendDate,
								string _factoryName,
								string _itemName,
								uint32 _quantity) public isValidPerformer(_batchNo, 'SUPPLIER', 'SUPPLIER') returns(bool){
		/* Call Storage Contract */
		bool status = supplyChainStorage.setSupplierData(_batchNo, _sendDate, _factoryName, _itemName, _quantity);

		emit DoneSupplier(msg.sender, _batchNo);
		return(status);
	}

	/* Get Supplier */
	function getSupplierData(address _batchNo) public view returns(string sendDate,
																   string factoryName,
																   string itemName,
																   uint32 quantity){
		/* Call Storage Contract */
		(sendDate, factoryName, itemName, quantity) = supplyChainStorage.getSupplierData(_batchNo);
		return(sendDate, factoryName, itemName, quantity);
	}
	
	/* Perform Factory In */
	function updateFactoryInData(address _batchNo,
							  string _receiveDate,
							  string _itemName,
							  uint32 _quantity) public isValidPerformer(_batchNo, 'FACTORY', 'FACTORY_IN') returns(bool){
		/* Call Storage Contract */
		bool status = supplyChainStorage.setFactoryInData(_batchNo, _receiveDate, _itemName, _quantity);

		emit DoneFactoryIn(msg.sender, _batchNo);
		return(status);
	}

	/* Get Factory In */
	function getFactoryInData(address _batchNo) public view returns(string receiveDate,
																string itemName,
																uint32 quantity){
		(receiveDate, itemName, quantity) = supplyChainStorage.getFactoryInData(_batchNo);
		return(receiveDate, itemName, quantity);
	}

	/* Perform Factory Send */
	function updateFactorySendData(address _batchNo,
								   string _sendDate,
								   string _drugName,
								   string _productionNumber,
								   string _productionDate,
								   string _expiredDate,
								   uint32 _quantity) public isValidPerformer(_batchNo, 'FACTORY', 'FACTORY_SEND') returns(bool){
		/* Call Storage Contract */
		bool status = supplyChainStorage.setFactorySendData(_batchNo, _sendDate, _drugName, _productionNumber, _productionDate, _expiredDate, _quantity);

		emit DoneFactorySend(msg.sender, _batchNo);
		return(status);
	}

	/* Get Factory Send */
	function getFactorySendData(address _batchNo) public view returns(string sendDate,
																	  string drugName,
																	  string productionNumber,
																	  string productionDate,
																	  string expiredDate,
																	  uint32 quantity){
		(sendDate, drugName, productionNumber, productionDate, expiredDate, quantity) = supplyChainStorage.getFactorySendData(_batchNo);
		return(sendDate, drugName, productionNumber, productionDate, expiredDate, quantity);
	}

	/* Perform Distributor In */
	function updateDistributorInData(address _batchNo,
									 string _receiveDate,
									 string _drugName,
									 uint32 _quantity) public isValidPerformer(_batchNo, 'DISTRIBUTOR', 'DISTRIBUTOR_IN') returns(bool){
		/* Call Storage Contract */
		bool status = supplyChainStorage.setDistributorInData(_batchNo, _receiveDate, _drugName, _quantity);

		emit DoneDistributorIn(msg.sender, _batchNo);
		return(status);
	}

	/* Get Distributor In */
	function getDistributorInData(address _batchNo) public view returns(string receiveDate,
																		string drugName,
																		uint32 quantity){
		(receiveDate, drugName, quantity) = supplyChainStorage.getDistributorInData(_batchNo);
		return(receiveDate, drugName, quantity);
	}

	/* Perform Distributor Send */
	function updateDistributorSendData(address _batchNo,
									   string _sendDate,
									   string _drugStoreName,
									   uint32 _quantity) public isValidPerformer(_batchNo, 'DISTRIBUTOR', 'DISTRIBUTOR_SEND') returns(bool){
		/* Call Storage Contract */
		bool status = supplyChainStorage.setDistributorSendData(_batchNo, _sendDate, _drugStoreName, _quantity);

		emit DoneDistributorSend(msg.sender, _batchNo);
		return(status);
	}

	/* Get Distributor Send */
	function getDistributorSendData(address _batchNo) public view returns(string sendDate,
																		string drugStoreName,
																		uint32 quantity){
		(sendDate, drugStoreName, quantity) = supplyChainStorage.getDistributorSendData(_batchNo);
		return(sendDate, drugStoreName, quantity);
	}

	/* Perform Drugstore */
	function updateDrugStoreData(address _batchNo,
								 string _receiveDate,
								 uint32 _quantity,
							 	 string _additionalInfo) public isValidPerformer(_batchNo, 'DRUGSTORE', 'DRUGSTORE') returns(bool){
		/* Call Storage Contract */
		bool status = supplyChainStorage.setDrugStoreData(_batchNo, _receiveDate, _quantity, _additionalInfo);

		emit DoneDrugStore(msg.sender, _batchNo);
		return(status);
	}

	/* Get Drugstore */
	function getDrugStoreData(address _batchNo) public view returns(string receiveDate,
																	uint32 quantity,
																	string additionalInfo){
		(receiveDate, quantity, additionalInfo) = supplyChainStorage.getDrugStoreData(_batchNo);
		return(receiveDate, quantity, additionalInfo);
	}
}
