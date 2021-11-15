pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;
contract HealthSystem{
    uint public dummy;
    struct Address{
        string streetName;
        string cityName;
        uint pinCode;
        string stateName;
        string countryName;
    }
    
    struct Patient{
        uint patientId;
        string name;
        uint yearOfBirth;
        string gender;
        string city;
        // Address patientAddress;
        // uint[] hrIds ;
    }
    
    struct Doctor{
        uint doctorId;
        string name;
        uint licenseNo;
        string specialization;
    }
    
    struct HealthRecord{
        uint healthRecordId;
        uint patientId;
        uint doctorId;
        string prescription;
        string feedBack;
        string disease;
        // we further need to add test reports and etc etc
    }
    
    //start
    mapping(string => uint) public isCityPresent;
    mapping(string => mapping(string => uint) ) public cityDiseaseMp;
    mapping(string => string[]) public cityDiseases;
    
    mapping(string => uint) public isDiseasePresent;
    mapping(string => mapping(string => uint) ) public diseaseCityMp;
    mapping(string => string[]) public diseaseInCities;

    // function get(address _addr) public view returns (uint) {
    //     // Mapping always returns a value.
    //     // If the value was never set, it will return the default value.
    //     return myMap[_addr];
    // }

    // function set(address _addr, uint _i) public {
    //     // Update the value at this address
    //     myMap[_addr] = _i;
    // }

    // function remove(address _addr) public {
    //     // Reset the value to the default value.
    //     delete myMap[_addr];
    // }
    //end
    
    
    // patient functions
    Patient[] public Patients_list;
    uint public nextPatientId=1;

    function newPatientReg(string memory name, uint yearOfBirth, string memory gender, string memory city) public{
        uint _yearOfBirth = yearOfBirth;
        uint _id = nextPatientId;
        Patients_list.push(Patient(_id, name, _yearOfBirth, gender, city));
        nextPatientId++;
    }
    
    function searchPatient(uint patientId) view public returns(string memory,uint, string memory,string memory, string memory,uint, string memory,string memory){
        uint i=find_id(patientId);
        return("Id", Patients_list[i].patientId, "Patient name", Patients_list[i].name,"Date of Birth", Patients_list[i].yearOfBirth, "Gender", Patients_list[i].gender);
    }
    
    function find_id(uint patientId)view internal returns(uint){
        for(uint i=0;i<Patients_list.length;i++){
            if(keccak256(abi.encodePacked(Patients_list[i].patientId))== keccak256(abi.encodePacked(patientId)))
            {
                return i;
            }
        }
        revert('This state does not exist in blockchain!');
    }
    
    function find_city(uint patientId) view internal returns(string memory){
        for(uint i=0;i<Patients_list.length;i++){
            if(keccak256(abi.encodePacked(Patients_list[i].patientId))== keccak256(abi.encodePacked(patientId)))
            {
                return Patients_list[i].city;
            }
        }
        revert('This state does not exist in blockchain!');
    }
    
    function isPresent(string memory name)view internal returns(uint){
        uint k=0;
        for(uint i=0;i<Patients_list.length;i++){
            if(keccak256(abi.encodePacked(Patients_list[i].name))==keccak256(abi.encodePacked(name)))
            {
                 k=1;
            }
        }
        return k;
    }
    
    
    // doctor functions
    Doctor[] public Doctors_list;
    uint public nextDoctorId=1;
    
    function newDoctorReg(string memory name, uint licenseNo, string memory specialization) public{
        uint _id = nextDoctorId;
        nextDoctorId++;
        uint _licenseNo = licenseNo;
        Doctors_list.push(Doctor(_id, name, _licenseNo, specialization));
    }
    
    // Health Record functions
    HealthRecord[] public HealthRecords_list;
    uint public nextRecordId=1;
    
    
    function newRecordReg(uint patientId, uint doctorId, string memory prescription, string memory feedBack, string memory disease) public{
        uint _id = nextRecordId;
        nextRecordId++;
        // mapping(string => uint) storage tmp;
        uint _patientId = patientId;
        string memory city = find_city(patientId); // we need to write a function to query the city
        if(isCityPresent[city] == 0){
            // tmp[disease] = 1;
            cityDiseases[city].push(disease);
            cityDiseaseMp[city][disease] = 1;
            isCityPresent[city] = 1;
        }else{
            if(cityDiseaseMp[city][disease] == 0){
                cityDiseaseMp[city][disease] = 1;
                cityDiseases[city].push(disease);
            }else{
                cityDiseaseMp[city][disease]++;
            }
        }
        
        if(isDiseasePresent[disease] == 0){
            isDiseasePresent[disease] = 1;
            diseaseInCities[disease].push(city);
            diseaseCityMp[disease][city] = 1;
        }else{
            if(diseaseCityMp[disease][city] == 0){
                diseaseCityMp[disease][city] = 1;
                diseaseInCities[disease].push(city);
            }else{
                diseaseCityMp[disease][city]++;
            }
        }
        
        uint _doctorId = doctorId;
        HealthRecords_list.push(HealthRecord(_id, _patientId, _doctorId, prescription, feedBack, disease));
    }
    
    function getDiseaseInCity(string memory city) public returns(string memory){
        uint mxval = 0;
        string memory disease = "No_Disease";
        for(uint i=0; i<cityDiseases[city].length; i++){
            string memory curDisease = cityDiseases[city][i];
            uint curVal = cityDiseaseMp[city][curDisease];
            if(curVal > mxval){
                mxval = curVal;
                disease = curDisease;
            }
        }
        return disease;
    }
    
    function getCityByDisease(string memory disease) public returns(string memory){
        uint mxval = 0;
        string memory city = "No_City";
        for(uint i=0; i<diseaseInCities[disease].length; i++){
            string memory curCity = diseaseInCities[disease][i];
            uint curVal = diseaseCityMp[disease][curCity];
            if(curVal > mxval){
                mxval = curVal;
                city = curCity;
            }
        }
        return city;
    }
    
    
}