//
// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import * as gesso from "./gesso/main.js";
import * as main from "./main.js";

const html = `
<body class="excursion">
  <section>
    <div>
      <h1>Create an appointment</h1>

      <form id="appointment-form">
        <div class="form-field">
          <div>Patient</div>
          <div><input id="patient" readonly="readonly"/></div>
          <div>The patient requesting the appointment</div>
        </div>

        <div class="form-field">
          <div>Description</div>
          <div><input id="description" name="description" readonly="readonly"></div>
          <div>The purpose of the patient's visit</div>
        </div>

        <div class="form-field">
          <div>Date</div>
          <div><input type="date" id="date" name="date" required="required"/></div>
          <div>Requested date: <span id="requested-date">-</span></div>
        </div>

        <div class="form-field">
          <div>Time</div>
          <div><input type="time" id="time" name="time" required="required" step="1800"/></div>
          <div>Requested time: <span id="requested-time">-</span></div>
        </div>

        <div class="form-buttons">
          <button type="submit">Create appointment</button>
        </div>
      </form>
    </div>
  </section>
</body>
`;

export class CreatePage extends gesso.Page {
    constructor(router) {
        super(router, "/appointment/create", html);

        this.body.$("#appointment-form").addEventListener("submit", event => {
            event.preventDefault();

            const doctor = parseInt($p("doctor"));
            const appointmentRequest = parseInt($p("appointment-request"));
            const datetime = new Date(`${event.target.date.value}T${event.target.time.value}`);

            gesso.postJSON("/api/appointment/create", {
                appointment_request: appointmentRequest,
                doctor: doctor,
                datetime: datetime.toISOString(),
            });

            this.router.navigate(new URL(`/doctor?id=${doctor}&tab=appointments`, window.location));
        });
    }

    update() {
        gesso.fetchJSON("/api/data", data => {
            $("#appointment-form").reset();

            const appointmentRequest = data.appointment_requests[$p("appointment-request")];
            const datetime = new Date(appointmentRequest.datetime);

            $("#patient").setAttribute("value", data.patients[appointmentRequest.patient_id].name);
            $("#description").setAttribute("value", appointmentRequest.description);
            $("#date").setAttribute("value", gesso.formatISODate(datetime));
            $("#time").setAttribute("value", gesso.formatISOTime(datetime).slice(0, 5));
            $("#requested-date").textContent = datetime.toLocaleDateString();
            $("#requested-time").textContent = datetime.toLocaleTimeString();
        });
    }
}
