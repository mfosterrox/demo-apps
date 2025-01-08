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
        <a>Patient <span id="patient-name">-</span></a>
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
    <a data-tab="doctors">Doctors</a>
  </nav>

  <div data-tab="overview">
    <h1>Welcome, <span id="greeting-name">-</span>!</h1>

    <p><a class="button" id="appointment-request-create-link">Request an appointment</a></p>

    <p id="appointment-request-summary"></p>

    <p id="appointment-summary"></p>

    <p id="bill-summary"></p>
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

  <div data-tab="doctors">
    <h1>Doctors</h1>

    <div id="doctor-table"></div>
  </div>
</div>

    </div>
  </section>
  <footer>
  </footer>
</body>
`;

const tabs = new gesso.Tabs("tab");

const appointmentRequestTable = new gesso.Table("appointment-request-table", [
    ["ID", "id"],
    ["Date and time", "datetime", datetime => new Date(datetime).toLocaleString()],
    ["Description", "description", description => nvl(description, "-")],
    ["", "id", id => gesso.createLink(null, null, {class: "button cancel-request", text: "Cancel request", data_id: id})],
]);

const appointmentTable = new gesso.Table("appointment-table", [
    ["ID", "id"],
    ["Doctor", "doctor_id", (id, record, data) => data.doctors[id].name],
    ["Date and time", "datetime", datetime => new Date(datetime).toLocaleString()],
    ["Description", "description", (id, record, data) => nvl(data.appointment_requests[record.appointment_request_id].description, "-")],
]);

const billTable = new gesso.Table("bill-table", [
    ["ID", "id"],
    ["Doctor", "appointment_id", (id, record, data) => data.doctors[data.appointments[id].doctor_id].name],
    ["Appointment", "appointment_id", (id, record, data) => new Date(data.appointments[id].datetime).toLocaleString()],
    ["Amount due", "amount_due", amount_due => `$${amount_due}`],
    ["Date paid", "payment_datetime", datetime => nvl(datetime, "-", new Date(datetime).toLocaleString())],
    ["", "id", id => gesso.createLink(null, `/bill/pay?id=${id}`, {class: "button", text: "Pay bill"})],
]);

const doctorTable = new gesso.Table("doctor-table", [
    ["ID", "id"],
    ["Name", "name"],
    ["Phone", "phone"],
    ["Email", "email"],
]);

export class MainPage extends gesso.Page {
    constructor(router) {
        super(router, "/patient", html);
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
            const name = data.patients[id].name;
            const appointmentRequestCreateLink = `/appointment-request/create?patient=${id}`;

            const appointmentRequests = Object.values(data.appointment_requests).filter(record => {
                return id === record.patient_id && !Object.values(data.appointments).some(x => x.appointment_request_id === record.id);
            });

            const appointments = Object.values(data.appointments).filter(record => {
                return data.appointment_requests[record.appointment_request_id].patient_id === id;
            });

            const bills = Object.values(data.bills).filter(record => {
                return data.appointment_requests[data.appointments[record.appointment_id].appointment_request_id].patient_id === id;
            });

            const unpaidBills = bills.filter(record => record.payment_datetime === null);
            const doctors = Object.values(data.doctors);

            $("#patient-name").textContent = name;
            $("#greeting-name").textContent = name.split(/ /)[0];

            $("#appointment-request-create-link").setAttribute("href", appointmentRequestCreateLink);
            $("#appointment-request-summary").innerHTML =
                `You have <b>${appointmentRequests.length}</b> ${gesso.plural("appointment request", appointmentRequests.length)}.`;
            $("#appointment-summary").innerHTML =
                `You have <b>${appointments.length}</b> ${gesso.plural("confirmed appointment", appointments.length)}.`;
            $("#bill-summary").innerHTML =
                `You have <b>${unpaidBills.length}</b> ${gesso.plural("unpaid bill", unpaidBills.length)}.`;

            appointmentRequestTable.update(appointmentRequests, data);
            appointmentTable.update(appointments, data);
            billTable.update(bills, data);
            doctorTable.update(doctors);

            for (const elem of $$("a.cancel-request")) {
                elem.addEventListener("click", event => {
                    event.preventDefault();
                    gesso.postJSON("/api/appointment-request/delete", {appointment_request: event.target.getAttribute("data-id")});
                });
            }
        });
    }
}
