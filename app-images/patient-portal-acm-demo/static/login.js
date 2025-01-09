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
<body class="excursion login">
  <section>
    <div>
      <h1><span class="material-icons-outlined">medical_services</span> Patient Portal</h1>

      <p>Patient Portal is an example application.  It uses a web
      frontend, a relational database, and a payment-processing
      service.</p>

      <p>Patients can request appointments and pay bills.  Doctors can
      confirm appointments and bill patients.  Log in as a patient or
      doctor to try it out.</p>

      <div class="hflex">
        <div>
          <h2>Log in as a patient:</h2>

          <nav id="patient-login-links"></nav>
        </div>

        <div>
          <h2>Log in as a doctor:</h2>

          <nav id="doctor-login-links"></nav>
        </div>
      </div>
    </div>
  </section>
</body>
`;

function updatePatientLoginLinks(data) {
    const nav = gesso.createNav(null, "#patient-login-links");

    for (const item of Object.values(data.patients)) {
        gesso.createLink(nav, `/patient?id=${item.id}`, item.name);
    }

    $("#patient-login-links").replaceWith(nav);
}

function updateDoctorLoginLinks(data) {
    const nav = gesso.createNav(null, "#doctor-login-links");

    for (const item of Object.values(data.doctors)) {
        gesso.createLink(nav, `/doctor?id=${item.id}`, item.name);
    }

    $("#doctor-login-links").replaceWith(nav);
}

export class MainPage extends gesso.Page {
    constructor(router) {
        super(router, "/", html);
    }

    updateContent() {
        gesso.fetchJSON("/api/data", data => {
            updatePatientLoginLinks(data);
            updateDoctorLoginLinks(data);
        });
    }
}
