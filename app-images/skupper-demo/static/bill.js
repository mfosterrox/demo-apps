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

const createHtml = `
<body class="excursion">
  <section>
    <div>
      <h1>Bill a patient for an appointment</h1>

      <form id="bill-create-form">
        <input type="hidden" id="appointment" name="appointment"/>
        <input type="hidden" id="patient" name="patient"/>
        <input type="hidden" id="doctor" name="doctor"/>

        <div class="form-field">
          <div>Patient</div>
          <div><input id="patient-name" name="patient-name" readonly="readonly"/></div>
          <div>The patient for this appointment</div>
        </div>

        <div class="form-field">
          <div>Appointment</div>
          <div><input id="appointment-datetime" name="appointment-datetime" readonly="readonly"/></div>
          <div>The date and time of the patient's visit</div>
        </div>

        <div class="form-field">
          <div>Amount due</div>
          <div>
            <input type="number" id="amount-due" name="amount-due" placeholder="0" required="required"/>
          </div>
          <div>The amount to bill the patient</div>
        </div>

        <div class="form-buttons">
          <button type="submit">Bill patient</button>
        </div>
      </form>
    </div>
  </section>
</body>
`;

export class CreatePage extends gesso.Page {
    constructor(router) {
        super(router, "/bill/create", createHtml);

        this.body.$("#bill-create-form").addEventListener("submit", event => {
            event.preventDefault();

            const doctor = parseInt(event.target.doctor.value);

            gesso.postJSON("/api/bill/create", {
                appointment: parseInt(event.target.appointment.value),
                amount_due: parseInt(event.target["amount-due"].value),
            });

            this.router.navigate(new URL(`/doctor?id=${doctor}&tab=bills`, window.location));
        });
    }

    update() {
        gesso.fetchJSON("/api/data", data => {
            $("#bill-create-form").reset();

            const appointment = data.appointments[$p("appointment")];
            const appointmentRequest = data.appointment_requests[appointment.appointment_request_id];
            const patient = data.patients[appointmentRequest.patient_id];

            $("#appointment").setAttribute("value", appointment.id);
            $("#patient").setAttribute("value", patient.id);
            $("#doctor").setAttribute("value", appointment.doctor_id);
            $("#patient-name").setAttribute("value", patient.name);
            $("#appointment-datetime").setAttribute("value", new Date(appointment.datetime).toLocaleString());
        });
    }
}

const payHtml = `
<body class="excursion">
  <section>
    <div>
      <h1>Pay a bill</h1>
      <form id="bill-pay-form">
        <input type="hidden" id="bill" name="bill"/>
        <input type="hidden" id="patient" name="patient"/>

        <div class="form-field">
          <div>Doctor</div>
          <div><input id="doctor" name="doctor" readonly="readonly"/></div>
          <div>Your doctor for this appointment</div>
        </div>

        <div class="form-field">
          <div>Appointment</div>
          <div><input id="appointment-datetime" name="appointment-datetime" readonly="readonly"/></div>
          <div>The date and time of your visit</div>
        </div>

        <div class="form-field">
          <div>Amount due</div>
          <div>
            <input id="amount-due" readonly="readonly" name="amount-due"/>
          </div>
          <div>The amount to pay</div>
        </div>

        <div class="form-field">
          <div>Credit card number</div>
          <div>
            <input name="credit-card-number" required="required" value="4005 5192 0000 0004"/>
          </div>
          <div>The credit card to pay with</div>
        </div>

        <div class="form-buttons">
          <button type="submit">Submit payment</button>
        </div>
      </form>
    </div>
  </section>
</body>
`;

export class PayPage extends gesso.Page {
    constructor(router) {
        super(router, "/bill/pay", payHtml);

        this.body.$("#bill-pay-form").addEventListener("submit", event => {
            event.preventDefault();

            const bill = parseInt(event.target.bill.value);
            const patient = parseInt(event.target.patient.value);

            gesso.postJSON("/api/bill/pay", {bill: bill});

            main.router.navigate(new URL(`/patient?id=${patient}&tab=bills`, window.location));
        });
    }

    update() {
        gesso.fetchJSON("/api/data", data => {
            $("#bill-pay-form").reset();

            const bill = data.bills[parseInt($p("id"))];
            const appointment = data.appointments[bill.appointment_id];
            const appointmentRequest = data.appointment_requests[appointment.appointment_request_id];
            const doctor = data.doctors[appointment.doctor_id];

            $("#bill").setAttribute("value", bill.id);
            $("#patient").setAttribute("value", appointmentRequest.patient_id);
            $("#appointment-datetime").setAttribute("value", new Date(appointment.datetime).toLocaleString());
            $("#doctor").setAttribute("value", doctor.name);
            $("#amount-due").setAttribute("value", bill.amount_due);
        });
    }
}
