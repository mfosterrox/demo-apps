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

import * as appointment from "./appointment.js";
import * as appointmentRequest from "./appointment-request.js";
import * as bill from "./bill.js";
import * as doctor from "./doctor.js";
import * as login from "./login.js";
import * as patient from "./patient.js";

export const router = new gesso.Router();

new login.MainPage(router);
new patient.MainPage(router);
new doctor.MainPage(router);
new appointment.CreatePage(router);
new appointmentRequest.CreatePage(router);
new bill.CreatePage(router);
new bill.PayPage(router);

new EventSource("/api/notifications").onmessage = event => {
    router.page.updateContent();
};
