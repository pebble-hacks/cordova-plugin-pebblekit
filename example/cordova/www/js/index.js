/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

var uuid = "ebc92429-483e-4b91-b5f2-ead22e7e002d";

var app = {
  // Application Constructor
  initialize: function() {
    this.bindEvents();
  },

  // Bind Event Listeners
  //
  // Bind any events that are required on startup. Common events are:
  // 'load', 'deviceready', 'offline', and 'online'.
  bindEvents: function() {
    document.addEventListener('deviceready', this.onDeviceReady, false);
  },

  // deviceready Event Handler
  //
  // The scope of 'this' is the event. In order to call the 'receivedEvent'
  // function, we must explicitly call 'app.receivedEvent(...);'
  onDeviceReady: function() {
    app.receivedEvent('deviceready');
    // app.pebbleKit();
  },

  test: function() {
    window.pebblekit.setupIos(uuid, function () {
      console.log('ios is setup');

      window.pebblekit.registerPebbleConnectedReceiver(function() {
        console.log('pebble connected');
      });

      window.pebblekit.registerPebbleDisconnectedReceiver(function () {
        console.log('pebble disconnected');
      });

      window.pebblekit.startAppOnPebble(uuid, function () {
        console.log('started app on pebble with uuid', uuid);
      });
    });
  },

  // Update DOM on a Received Event
  receivedEvent: function(id) {
    var parentElement = document.getElementById(id);
    var listeningElement = parentElement.querySelector('.listening');
    var receivedElement = parentElement.querySelector('.received');

    listeningElement.setAttribute('style', 'display:none;');
    receivedElement.setAttribute('style', 'display:block;');

    console.log('Received Event: ' + id);
  },

  pebbleKit: function() {
    window.pebblekit.registerReceivedDataHandler(uuid, function(message) {
      if (message['0'] !== 0) {
        console.log('unrecognized app message', message);
        return;
      }

      app.testCalendarPermission();

    }, function (errorMessage) {
      console.log('got error: ', errorMessage);
    }, true);
    console.log('receivedDataHandler registered');
  },

  testCalendarPermission: function() {
    window.plugins.calendar.hasReadWritePermission(function(result) {
      console.log('read write permission ' + result);

      if (!result) {
        window.plugins.calendar.requestReadWritePermission();

      } else {
        app.findNextCalendarEvent();
      }
    });
  },

  findNextCalendarEvent: function() {
    // Find a calendar event between now and the end of the day
    var startDate = new Date();
    var endDate = new Date();
    endDate.setHours(24, 0, 0, 0); // Nearest midnight in the future

    window.plugins.calendar.findEvent(
        undefined, // title
        undefined, // eventLocation
        undefined, // notes
        startDate,
        endDate,
        calendarFindSuccess,
        calendarFindError
    );

    function calendarFindSuccess(events) {
      console.log('got calendar events: ', events);
      if (events.length === 0) {
        // TODO: No calendar events for today
        return;
      }

      var nextEvent = events[0];

      for (var i = 1; i < events.length; i++) {
        var tempDate = events[i];

        var date1 = Date.parse(nextEvent.startDate);
        var date2 = Date.parse(tempDate.startDate);

        if (date2 < date1) {
          nextEvent = tempDate;
        }
      }

      var nextMoment = moment(nextEvent.startDate, "YYYY-MM-DD HH:mm:ss");
      var data = {
        '10': nextEvent.title,
        '11': nextMoment.hour(),
        '12': nextMoment.minute()
      };
      console.log('sending data', data);

      window.pebblekit.sendAppMessage(uuid, data, function () {
        console.log('ack');
      }, function() {
        console.log('nack');
      });
    }

    function calendarFindError(message) {
      console.log(message);
    }

  },
};

app.initialize();
