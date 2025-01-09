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
<body>
  <header>
    <div>
      <div>
        <span class="material-icons-outlined">medical_services</span>
        Patient Portal
      </div>
      <nav id="global-nav">
        <a>Doctor <span id="doctor-name">-</span></a>
        <a id="log-out-link" href="/">Log out</a>
      </nav>
    </div>
  </header>

  <section>
    <div>

<div class="tabs" id="tab">
  <nav>
    <a data-tab="overview">Overview</a>
    <a data-tab="appointment-requests">Appointment requests</a>
    <a data-tab="appointments">Appointments</a>
    <a data-tab="bills">Bills</a>
    <a data-tab="patients">Patients</a>
  </nav>

  <div data-tab="overview">
    <h1>Hello, Doctor <span id="greeting-name">-</span></h1>

    <p id="appointment-request-summary"></p>

    <p id="appointment-summary"></p>
  </div>

  <div data-tab="appointment-requests">
    <h1>Appointment requests</h1>

    <div id="appointment-request-table"></div>
  </div>

  <div data-tab="appointments">
    <h1>Appointments</h1>

    <div id="appointment-table"></div>
  </div>

  <div data-tab="bills">
    <h1>Bills</h1>

    <div id="bill-table"></div>
  </div>

  <div data-tab="patients">
    <h1>Patients</h1>

    <div id="patient-table"></div>
  </div>
</div>

    </div>
  </section>

  <footer>
  </footer>
</body>
`;

const tabs = new gesso.Tabs("tab");

function createAppointmentLink(id) {
    const doctor = $p("id");
    return gesso.createLink(null, `/appointment/create?doctor=${doctor}&appointment-request=${id}`,
                            {class: "button", text: "Create appointment"});
}

const appointmentRequestTable = new gesso.Table("appointment-request-table", [
    ["ID", "id"],
    ["Patient", "patient_id", (id, record, data) => data.patients[id].name],
    ["Date and time", "datetime", datetime => new Date(datetime).toLocaleString()],
    ["Description", "description"],
    ["", "id", createAppointmentLink],
]);

const appointmentTable = new gesso.Table("appointment-table", [
    ["ID", "id"],
    ["Patient", "appointment_request_id", (id, record, data) => data.patients[data.appointment_requests[id].patient_id].name],
    ["Date and time", "datetime", datetime => new Date(datetime).toLocaleString()],
    ["Description", "appointment_request_id", (id, record, data) => data.appointment_requests[id].description],
    ["", "id", id => gesso.createLink(null, `/bill/create?appointment=${id}`, {class: "button", text: "Bill patient"})],
]);

const billTable = new gesso.Table("bill-table", [
    ["ID", "id"],
    ["Patient", "appointment_id", (id, record, data) => {
        return data.patients[data.appointment_requests[data.appointments[id].appointment_request_id].patient_id].name;
    }],
    ["Appointment", "appointment_id", (id, record, data) => new Date(data.appointments[id].datetime).toLocaleString()],
    ["Amount due", "amount_due", amount_due => `$${amount_due}`],
    ["Date paid", "payment_datetime", datetime => nvl(datetime, "-", new Date(datetime).toLocaleString())],
]);

const patientTable = new gesso.Table("patient-table", [
    ["ID", "id"],
    ["Name", "name"],
    ["ZIP", "zip"],
    ["Phone", "phone"],
    ["Email", "email"],
]);

export class MainPage extends gesso.Page {
    constructor(router) {
        super(router, "/doctor", html);
    }

    getContentKey() {
        return [this.path, $p("id")].join();
    }

    updateView() {
        tabs.update();
    }

    updateContent() {
        gesso.fetchJSON("/api/data", data => {
            const id = parseInt($p("id"));
            const name = data.doctors[id].name;
            const appointmentCreateLink = `/appointment/create?doctor=${id}`;

            const appointmentRequests = Object.values(data.appointment_requests).filter(record => {
                return !Object.values(data.appointments).some(x => x.appointment_request_id === record.id);
            });

            const appointments = Object.values(data.appointments).filter(record => record.doctor_id === id);
            const bills = Object.values(data.bills).filter(record => data.appointments[record.appointment_id].doctor_id === id);
            const patients = Object.values(data.patients);

            $("#doctor-name").textContent = name;
            $("#greeting-name").textContent = name.split(/ /)[1];

            $("#appointment-request-summary").innerHTML =
                `You have <b>${appointmentRequests.length}</b> ${gesso.plural("appointment request", appointmentRequests.length)}.`;
            $("#appointment-summary").innerHTML =
                `You have <b>${appointments.length}</b> ${gesso.plural("confirmed appointment", appointments.length)}.`;

            appointmentRequestTable.update(appointmentRequests, data);
            appointmentTable.update(appointments, data);
            billTable.update(bills, data);
            patientTable.update(patients, data);
        });
    }
}
