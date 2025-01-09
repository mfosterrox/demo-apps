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
      <h1>Request an appointment</h1>

      <form id="appointment-request-form">
        <input id="patient" type="hidden" name="patient"/>

        <div class="form-field">
          <div>Date</div>
          <div><input type="date" id="date" name="date" required="required"/></div>
          <div>Your preferred date for the appointment</div>
        </div>

        <div class="form-field">
          <div>Time</div>
          <div><input type="time" id="time" name="time" required="required"/></div>
          <div>Your preferred time for the appointment</div>
        </div>

        <div class="form-field">
          <div>Description</div>
          <div><input id="description" name="description" pattern=".*\\S+.*" required="required"/></div>
          <div>The reason for your visit</div>
        </div>

        <div class="form-buttons">
          <button type="submit">Submit request</button>
        </div>
      </form>
    </div>
  </section>
</body>
`;

export class CreatePage extends gesso.Page {
    constructor(router) {
        super(router, "/appointment-request/create", html);

        this.body.$("#appointment-request-form").addEventListener("submit", event => {
            event.preventDefault();

            const patient = parseInt($p("patient"));
            const datetime = new Date(`${event.target.date.value}T${event.target.time.value}`);

            gesso.postJSON("/api/appointment-request/create", {
                patient: patient,
                datetime: datetime.toISOString(),
                description: event.target.description.value,
            });

            this.router.navigate(new URL(`/patient?id=${patient}`, window.location));
        });
    }

    update() {
        $("#appointment-request-form").reset();

        const now = new Date();

        $("#date").setAttribute("value", gesso.formatISODate(now));
        $("#time").setAttribute("value", gesso.formatISOTime(now).slice(0, 5));
    }
}
