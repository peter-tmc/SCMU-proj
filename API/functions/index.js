
//import { collection, query, /* where, */ getDocs } from "firebase/firestore";

'use strict';

// [START functionsimport]
const functions = require('firebase-functions');
// [END functionsimport]
const admin = require("firebase-admin");
var express = require("express"),
  router = express.Router();
admin.initializeApp()

// Moments library to format dates.
const moment = require('moment');
// CORS Express middleware to enable CORS Requests.
const cors = require('cors')({
  origin: true,
});

const db = admin.firestore();
const { v4: uuidv4 } = require("uuid");
const { body, param, validationResult } = require("express-validator");

// [START all]
/**
 * Returns the server's date. You must provide a `format` URL query parameter or `format` value in
 * the request body with which we'll try to format the date.
 *
 * Format must follow the Node moment library. See: http://momentjs.com/
 *
 * Example format: "MMMM Do YYYY, h:mm:ss a".
 * Example request using URL query parameters:
 *   https://us-central1-<project-id>.cloudfunctions.net/date?format=MMMM%20Do%20YYYY%2C%20h%3Amm%3Ass%20a
 * Example request using request body with cURL:
 *   curl -H 'Content-Type: application/json' /
 *        -d '{"format": "MMMM Do YYYY, h:mm:ss a"}' /
 *        https://us-central1-<project-id>.cloudfunctions.net/date
 *
 * This endpoint supports CORS.
 */

exports.POSTInfo = functions.https.onRequest(async (req, res) => {
  if(req.method!=='POST'){
    res.status(403).send('Forbidden!');
    return;
  }
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).send({ errors: errors.array() });
  }
  try{
    const ts = req.body.timestamp;
    const press = req.body.pressure;
    const light = req.body.light;
    const gyro = req.body.gyroscope;
    if(ts==null || press==null || light==null || gyro==null){
      res.status(400).send('Bad Request! Parameter missing.');
    }
    let snapShot= await db
    .collection('/sleepInfo')
    .where("ts", "==", ts)
    .get()
    console.log(snapShot)
    if (snapShot != null || snapShot.exists) {
      //console.log("h")
      res.status(409).send('There is already information for that timestamp');
    }
    
    let date = ts.split(" ")[0].split("-")[2];
    console.log(date + " - day")
    await db.collection("/sleepInfo").doc(ts).create({
      ts: ts,
      press: press,
      light: light,
      gyro: gyro,
      day: Number(date),
    });

    res.status(200).send('done, time:' + ts.toString());
  } catch (error) {
    return res.status(500).send(error);
  }
  
})

exports.GETSleep = functions.https.onRequest(async (req, res) => {
  if(req.method!=='GET'){
    res.status(403).send('Forbidden!');
    return;
  }
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).send({ errors: errors.array() });
  }
  try{
    const mode = req.body.mode;
    if(mode==null){
      res.status(400).send('Bad Request! Parameter missing.');
    }
    var sleepInterval = [];
    let prevSleep=false;
    let auxInterval=[];
    var today = new Date().getDate();
    var priorDays = new Date();
    priorDays.setDate(today - mode);
    
    db.collection("/sleepInfo").where("day", ">=", priorDays.getDate()).get().then( (querySnapshot) => {
      querySnapshot.forEach((doc)=>{
        
        let isSleeping = doc.data().light<100 && doc.data().press>10 && doc.data().gyro<2;
        
        // doc.data() is never undefined for query doc snapshots
        //console.log(doc.id, " => ", doc.data());
        //console.log(doc.id + ' - isSleeping '+ isSleeping)
        if(prevSleep){
          //console.log("pass")
          if(isSleeping){
            //console.log("was sleeping, still sleeping")
            auxInterval.push(doc.data().ts);
          }
          else {
            const obj=[auxInterval[0], auxInterval[auxInterval.length-1]];
            sleepInterval.push(obj);
            auxInterval=[];
            prevSleep=false;
            //console.log("was sleeping, no longer sleeping -"+ sleepInterval)
          }
        }
        else {
          if(isSleeping){
            auxInterval.push(doc.data().ts);
            prevSleep=true;
            //console.log('wasnt sleeping, is sleeping - '+ doc.data().ts +' - '+ auxInterval);
          }
        }
      })
      return res.status(200).send(sleepInterval);
    });
    
  } catch (error) {
    console.log(error);
    return res.status(500).send(error);
  }
})

/* router
  .put(
    "/putInfo",
    body("timestamp").isString(),
    body("pressure").isString(),
    body("light").isString(),
    body("gyro").isString(),
    (req, res) => {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).send({ errors: errors.array() });
      }
      
      (async () => {
        try {

          await admin.auth().verifyIdToken(req.header('AuthToken'))

          try {

            //const id = uuidv4();
            if (req.body.tags) {
              tags = req.body.tags;
            } else {
              tags = [];
            }

            //const tsConst= req.body.timestamp
            await db.collection("sleepInfo").doc(req.body.timestamp).create({
              ts: req.body.timestamp,
              press: req.body.pressure,
              light: req.body.light,
              gyro: req.body.gyro,
            });

            return res.status(200).send(`Sleep info of: ${req.body.timestamp}`);
          } catch (error) {
            console.log(error);
            return res.status(500).send(error);
          }
        } catch (error) {
          console.log("Wrong token");
          return res.status(400).send(error);
        }
      })();
    }
  ) 

  module.exports= router; */

/////////
