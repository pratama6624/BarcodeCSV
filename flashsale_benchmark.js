//
//  flashsale_benchmark.js
//  vapor-flashsale-service
//
//  Created by Pratama One on 04/12/25.
//

//import http from 'k6/http';
//import { check, sleep } from 'k6';
//
//export let options = {
//  scenarios: {
//    flashsale_test: {
//      executor: 'ramping-vus',
//      startVUs: 0,
//      stages: [
//        { duration: '5s', target: 100 },    // warm up to 100 VUs
//        { duration: '15s', target: 500 },   // push 500 VUs
//        { duration: '20s', target: 1000 },  // up to 1000 VUs
//        { duration: '10s', target: 0 },     // cool down
//      ],
//      gracefulRampDown: '5s',
//    },
//  },
//};
//
//const BASE_URL = __ENV.BASE_URL || 'http://localhost:8080';
//const MODE = __ENV.MODE || 'DB';  // "DB" or "REDIS"
//
//export default function () {
//  const path =
//    MODE === 'DB'
//      ? '/flashsale/buy-db'
//      : '/flashsale/buy-redis';
//
//  const url = `${BASE_URL}${path}`;
//
//  let res = http.post(url);
//
//  check(res, {
//    'status is 200 or 409': (r) => r.status === 200 || r.status === 409,
//  });
//
//  // small sleep to avoid 100% CPU tight loop
//  sleep(0.01);
//}


import http from 'k6/http';
import { check, sleep } from 'k6';
import { Counter } from 'k6/metrics';

export let options = {
  scenarios: {
    flashsale_test: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '5s', target: 100 },
        { duration: '15s', target: 500 },
        { duration: '20s', target: 1000 },
        { duration: '10s', target: 0 },
      ],
      gracefulRampDown: '5s',
    },
  },
};

export const statusCount = new Counter('status_count');
export const failedCount = new Counter('failed_count');

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8080';
const MODE = __ENV.MODE || 'DB'; // "DB" or "REDIS"

export default function () {
  const path = MODE === 'DB' ? '/flashsale/buy-db' : '/flashsale/buy-redis';
  const url = `${BASE_URL}${path}`;

  const res = http.post(url);

  const ok = check(res, {
    'status is 200 or 409': (r) => r.status === 200 || r.status === 409,
  });

  statusCount.add(1, { status: String(res.status) });

  if (!ok) {
    failedCount.add(1, { status: String(res.status) });
  }

  sleep(0.01);
}
