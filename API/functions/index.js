
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
// [START trigger]
exports.date = functions.https.onRequest((req, res) => {
  // [END trigger]
  // [START sendError]
  // Forbidding PUT requests.
  if (req.method === 'PUT') {
    res.status(403).send('Forbidden!');
    return;
  }
  // [END sendError]

  // [START usingMiddleware]
  // Enable CORS using the `cors` express middleware.
  cors(req, res, () => {
    // [END usingMiddleware]
    // Reading date format from URL query parameter.
    // [START readQueryParam]
    let format = req.query.format;
    // [END readQueryParam]
    // Reading date format from request body query parameter
    if (!format) {
      // [START readBodyParam]
      format = req.body.format;
      // [END readBodyParam]
    }
    // [START sendResponse]
    const formattedDate = moment().format(`${format}`);
    functions.logger.log('Sending Formatted date:', formattedDate);
    res.status(200).send(formattedDate);
    // [END sendResponse]
  });
});
// [END all]

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
    /* .where("ts", "===", ts) */
    .doc(ts)
    .get()
    //console.log(snapShot)
    if (snapShot != null || snapShot.exists) {
      //console.log("h")
      res.status(409).send('There is already information for that time period');
    }
    
    let date = ts.split(" ")[0].split("-")[2];
    console.log(date + " - day")
    await db.collection("/sleepInfo").doc(ts).create({
      ts: ts,
      press: press,
      light: light,
      gyro: gyro,
      day: date,
    });

    res.status(200).send('done, time:' + ts.toString());
  } catch (error) {
    //console.log("Wrong token");
    return res.status(500).send(error);
  }
  
})

//let previousBeginning=0;

/* exports.getSleep = functions.firestore.document('/sleepInfo/{timestamp}').onCreate((snap, context)=> { 
    const sleepInfo = snap.data().sleepInfo
    //functions.logger.log('data ', data);
    
    if(sleepInfo.light>10 && sleepInfo.gyro>0 && sleepInfo.press>10){
      //if(previousBeginning==0){ previousBeginnig=timestamp}
      previousBeginning?
        await db.collection("/sleepSchedule").doc(ts).create({
          beginning: previousBeginning,
          
        })
        :
        await db.collection("/sleepSchedule").doc(ts).update({
          beginning: ,
          
        })
    }
  }
) */

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
    var sleepInterval = [];
    let prevSleep=false;
    let auxInterval=[];
    var today = new Date().getDate();
    console.log(today)
    db.collection("/sleepInfo").where("day", "==", today.toString()).get().then( (querySnapshot) => {
      querySnapshot.forEach((doc)=>{
        /* querySnapshot.forEach((doc) => { */
        let date=doc.data().ts.split(" ")[0].split("-");
        let time=doc.data().ts.split(" ")[1];
        //let hour=time.split(":")[0];
        console.log(time +" is time")
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
            /* let obj = {
              start: auxInterval[0],
              end: auxInterval[auxInterval.length-1]
            } */
            const obj=[auxInterval[0], auxInterval[auxInterval.length-1]];
            /* obj[0]=auxInterval[0];
            obj[1]=auxInterval[auxInterval.length-1]; */
            sleepInterval.push(obj);
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
        /* }); */
      })
      //console.log("hey")
      return res.status(200).send(sleepInterval);
    });
      /* sleepInterval.forEach(i=> console.log("-> "+i)) */
    //const querySnapshot = await getDocs(q);
    
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


/* router

  // Functions related to events

  // CREATE
  // Post Event

  
  .post(
    "/",
    body("name").isString(),
    body("description").isString(),
    body("startDate").isDate(),
    body("startTime").isString(),
    body("endDate").isDate(),
    body("badge").isString(),
    body("badgeContrast").isString(),
    body("cars").isArray(),
    body("url").optional({ nullable: true }).isString(),
    body("infoUrl").optional({ nullable: true }).isString(),
    body("infoImage").optional({ nullable: true }).isString(),
    body("liveUrl").optional({ nullable: true }).isString(),

    (req, res) => {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).send({ errors: errors.array() });
      }
      (async () => {
        try {

          await admin.auth().verifyIdToken(req.header('AuthToken'))

          try {

            const eventId = uuidv4();
            if (req.body.tags) {
              tags = req.body.tags;
            } else {
              tags = [];
            }
            await db.collection("events").doc(eventId).create({
              name: req.body.name,
              description: req.body.description,
              startDate: req.body.startDate,
              startTime: req.body.startTime,
              endDate: req.body.endDate,
              url: req.body.url,
              infoUrl: req.body.infoUrl,
              infoImage: req.body.infoImage,
              liveUrl: req.body.liveUrl,
              badge: req.body.badge,
              badgeContrast: req.body.badgeContrast,
              cars: req.body.cars,
              tags: tags,
              deleted: false,
            });

            return res.status(201).send(`New event created: ${eventId}`);
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

  // READ
  // Read a specific Event based on id
  // Get

  
  .get("/:eventId", param("eventId").isUUID(), (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).send({ errors: errors.array() });
    }
    (async () => {
      try {
        const document = db.collection("events").doc(req.params.eventId);
        let event = await document.get();

        if (!event.exists || event.data().deleted) {
          return res.status(404).send(`Event ${req.params.eventId} not found.`);
        }

        let response = event.data();

        return res.status(200).send(response);
      } catch (error) {
        console.log(error);
        return res.status(500).send(error);
      }
    })();
  })

  // READ ALL
  // Read all Events
  // Get

  
  .get("/", (req, res) => {
    (async () => {
      try {
        var today = new Date();
        let query = db
          .collection("events")
          .where("deleted", "==", false)
          .orderBy("startDate", "asc");
        let first = false;
        let nextEvents = [];
        let previousEvents = [];
        let allEvents = [];
        let response = {};
        //let nextEventDate = new Date("4000-01-01");
        let nextEvent;

        await query.get().then((querySnapshot) => {
          let docs = querySnapshot.docs; //the result of the query
          for (let doc of docs) {
            let eventEndDate = new Date(`${doc.data().endDate} 23:59:59`);
            //let eventStartDate = new Date(doc.data().startDate);

            const selectedEvent = {
              eventId: doc.id,
              name: doc.data().name,
              description: doc.data().description,
              startDate: doc.data().startDate,
              startTime: doc.data().startTime,
              endDate: doc.data().endDate,
              url: doc.data().url,
              infoUrl: doc.data().infoUrl,
              infoImage: doc.data().infoImage,
              liveUrl: doc.data().liveUrl,
              badge: doc.data().badge,
              badgeContrast: doc.data().badgeContrast,
              tags: doc.data().tags,
              cars: doc.data().cars
            };

            allEvents.push(selectedEvent);
            if (eventEndDate.getTime() < today.getTime()) { //preenchimento do vetor PREV
              previousEvents.push(selectedEvent);
            } else {
              if (eventEndDate.getTime() > today.getTime() && !first) {
                //procura pelo proximo evento (NEXT)
                first = true;
                nextEvent = selectedEvent;
                //nextEventDate = eventStartDate;
              } else {
                nextEvents.push(selectedEvent);
              }
            }
          }
        });
        //console.log(nextEvents);

        if (req.query.next && req.query.previous && req.query.nextEvents) {
          response = {
            nextEvents: nextEvents,
            next: nextEvent,
            prev: previousEvents,
          };
        } else if (req.query.next && req.query.previous) {
          response = {
            next: nextEvent,
            prev: previousEvents,
          };
        } else if (req.query.next) {
          response = { nextEvent };
        } else if (req.query.previous) {
          response = { previousEvents };
        } else {
          response = { allEvents };
        }

        return res.status(200).send(response);
      } catch (error) {
        console.log(error);
        return res.status(500).send(error);
      }
    })();
  })

  // UPDATE
  // Update Event
  // Put

  .put(
    "/:eventId",
    body("name").optional({ nullable: true }).isString(),
    body("description").optional({ nullable: true }).isString(),
    body("startDate").optional({ nullable: true }).isDate(),
    body("startTime").optional({ nullable: true }).isString(),
    body("endDate").optional({ nullable: true }).isDate(),
    body("url").optional({ nullable: true }).isString(),
    body("infoUrl").optional({ nullable: true }).isString(),
    body("cars").optional({ nullable: true }).isArray(),
    body("infoImage").optional({ nullable: true }).isString(),
    body("badge").optional({ nullable: true }).isString(),
    body("badgeContrast").optional({ nullable: true }).isString(),
    body("liveUrl").optional({ nullable: true }).isString(),
    param("eventId").isUUID(),
    (req, res) => {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).send({ errors: errors.array() });
      }
      (async () => {
        try {
          await admin.auth().verifyIdToken(req.header('AuthToken'))

          try {

            const document = db.collection("events").doc(req.params.eventId);
            if (req.body.tags) {
              tags = req.body.tags;
            } else {
              tags = [];
            }

            let event = await document.get();

            if (!event.exists || event.data().deleted) {
              return res
                .status(404)
                .send(`Event ${req.params.eventId} not found.`);
            }

            await document.update({
              name: req.body.name,
              description: req.body.description,
              startDate: req.body.startDate,
              startTime: req.body.startTime,
              endDate: req.body.endDate,
              url: req.body.url,
              infoUrl: req.body.infoUrl,
              cars: req.body.cars,
              infoImage: req.body.infoImage,
              liveUrl: req.body.liveUrl,
              badge: req.body.badge,
              badgeContrast: req.body.badgeContrast,
              tags: tags,
            });

            return res.status(200).send(`Event updated: ${req.params.eventId}`);
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

  // DELETE
  // Delete Event
  
  .delete("/:eventId", param("eventId").isUUID(), (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).send({ errors: errors.array() });
    }
    (async () => {
      try {

        await admin.auth().verifyIdToken(req.header('AuthToken'))

        try {

          const document = db.collection("events").doc(req.params.eventId);
          let event = await document.get();

          if (!event.exists || event.data().deleted) {
            return res
              .status(404)
              .send(`Campaign ${req.params.eventId} not found.`);
          }

          await document.update({
            deleted: true,
          });

          return res.status(200).send(`Event deleted: ${req.params.eventId}`);
        } catch (error) {
          console.log(error);
          return res.status(500).send(error);
        }

      } catch (error) {
        console.log("Wrong token");
        return res.status(400).send(error);
      }
    })();
  })

  // Read all event STAGES
  // Get

  
  .get("/:eventId/stages", param("eventId").isUUID(), (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).send({ errors: errors.array() });
    }
    (async () => {
      try {
        let query = db
          .collection("stages")
          .where("eventId", "==", req.params.eventId)
          .where("deleted", "==", false)
          .orderBy("startDate", "asc")
          .orderBy("startTime", "asc");
        let response = [];
        await query.get().then((querySnapshot) => {
          let docs = querySnapshot.docs; //the result of the query

          for (let doc of docs) {
            const selectedItem = {
              stageId: doc.id,
              eventId: doc.data().eventId,
              title: doc.data().title,
              description: doc.data().description,
              subTitle: doc.data().subTitle,
              startDate: doc.data().startDate,
              startTime: doc.data().startTime,
              location: doc.data().location,
              latitude: doc.data().latitude,
              longitude: doc.data().longitude,
              distanceKm: doc.data().distanceKm,
              images: doc.data().images,
              url: doc.data().url,
            };
            response.push(selectedItem);
          }
        });

        return res.status(200).send(response);
      } catch (error) {
        console.log(error);
        return res.status(500).send(error);
      }
    })();
  });

module.exports = router; */
