var express = require('express');
var router = express.Router();
var app = require('../app');
var exec = require('child_process').exec;
const CHECK_STATUS = 0;
const ENABLE = 1;
const DISABLE = 2;

router.get('/', function(req, res, next) {
  res.render('home', {
    translate: app.translate,
    title: app.translate("Home"),
  });
});

router.post('/checkStatus', function(req, res, next) {
  var service = req.body.service;
  console.log("Request Service: " + JSON.stringify(service));  
  exec(getCall(service, CHECK_STATUS), function(err, out, stderr) {
    if (service == "kolibri") {
      if (err != null) {
        console.log("Error: " + err);
        console.log("disabled");
        res.status(200).send("disabled");
      } else {
        console.log("enabled");
        res.status(200).send("enabled");
      }
    } else {
      if (out == "enabled") {
        res.status(200).send("enabled");
      } else {
        res.status(200).send("disabled");
      }
    }
  });
});

router.post('/updateStatus', function(req, res, next) {
  var service = req.body.service;
  var checked = req.body.checked;
  console.log("Request Service: " + JSON.stringify(service));
  console.log("Request Checked: " + JSON.stringify(checked));
  console.log("Toggling Service: " + getCall(service, (checked == "true")? ENABLE : DISABLE));
  exec(getCall(service, (checked == "true") ? ENABLE : DISABLE), function(err, out, stderr) {
    if (err) {
      console.log("Error on enable/disable call: " + err);
      res.status(500).send("Something went wrong checking the webservices!");
    } else {
      console.log("Response: " + out); 
      res.status(200).send();
    }
  });
});

module.exports = router;