App = {
  web3Provider: null,
  contracts: {},
  account: '0x0',

  init: function() {
    return App.initWeb3();
  },

  initWeb3: function() {
    web3 = new Web3(Web3.givenProvider || 'http://localhost:7545');
    // TODO: refactor conditional
    // if (typeof web3 !== 'undefined') {
    //   // If a web3 instance is already provided by Meta Mask.
    //   App.web3Provider = web3.currentProvider;
    //   web3 = new Web3(web3.currentProvider);
    // } else {
    //   // Specify default instance if no web3 instance provided
    //   App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
    //   web3 = new Web3(App.web3Provider);
    // }
    return App.initContract();
  },

  initContract: function() {
    $.getJSON("HealthSystem.json", function(healthsystem) {
      // Instantiate a new truffle contract from the artifact
      App.contracts.HealthSystem = TruffleContract(healthsystem);
      // Connect provider to interact with contract
      App.contracts.HealthSystem.setProvider(App.web3Provider);

      return App.render();
    });
  },

  render: function() {
    var healthSystemInstance;
    // var loader = $("#loader");
    // var content = $("#content");

    
    // content.hide();

    // Load account data
    web3.eth.getCoinbase(function(err, account) {
      if (err === null) {
        App.account = account;
        $("#accountAddress").html("Your Account: " + account);
      }
    });

    // Load contract data
    App.contracts.HealthSystem.deployed().then(function(instance) {
      healthSystemInstance = instance;
      return healthSystemInstance.nextPatientId();
    }).then(function(nextPatientId) {
      var patientsResult = $("#getPatients");
      patientsResult.empty();
      for (var i = 1; i < nextPatientId; i++) {
        healthSystemInstance.Patients_list(i).then(function(pat) {
          var id = pat[0];
          var name = pat[1];
          var yob = pat[2];
          var gender = pat[3];
          var city = pat[4];
          // Render candidate Result
          var patTemplate = "<tr><th>" + id + "</th><td>" + name + "</td><td>" + yob +"</td><td>" + gender + "</td><td>" + city + "</td></tr>"
          patientsResult.append(patTemplate);

        });
      }

    }).catch(function(error) {
      console.warn(error);
    });
  },
  newPatient: function(){
    var patientName = $('#patientName').val();
    var yob = $('#dob').val();
    var gender = $('#gender').val();
    var city = $('#city').val();
    console.log(patientName, yob, gender, city);
    App.contracts.HealthSystem.deployed().then(function(instance) {
      return instance.newPatientReg(patientName, yob, gender, city);
    }).then(function(result) {
      $("#newPatientMsg").html("Successful");
    }).catch(function(err) {
      console.error(err);
    });
  }
};

$(function() {
  $(window).load(function() {
    App.init();
  });
});