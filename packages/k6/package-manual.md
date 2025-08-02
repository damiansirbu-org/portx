# k6 Package Manual

## Package Information
- **Package Name**: k6
- **Category**: Testing
- **Type**: Load Testing Tool
- **License**: AGPL v3

## Description
Modern load testing tool for developers and testers in DevOps/CI environments.

JavaScript-based load testing platform for testing APIs, microservices, and websites.
Designed for performance testing with developer-friendly scripting and comprehensive metrics.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| k6.exe | Load testing and performance monitoring tool | Execute performance tests with JavaScript |

## Common Usage Examples

### Basic Load Testing
```bash
# Run simple load test
k6 run script.js

# Run with specific virtual users and duration
k6 run --vus 10 --duration 30s script.js

# Run with stages (ramp up/down)
k6 run --stage 5s:10,10s:20,5s:0 script.js

# Run with iterations instead of duration
k6 run --iterations 100 script.js
```

### Test Configuration
```bash
# Override options from command line
k6 run --vus 50 --duration 5m script.js

# Set HTTP timeout
k6 run --http-timeout 10s script.js

# Disable SSL verification
k6 run --insecure-skip-tls-verify script.js

# Set user agent
k6 run --user-agent "k6-load-test" script.js
```

### Output and Reporting
```bash
# JSON output
k6 run --out json=results.json script.js

# CSV output
k6 run --out csv=results.csv script.js

# InfluxDB output
k6 run --out influxdb=http://localhost:8086/mydb script.js

# Cloud output
k6 run --out cloud script.js
```

## JavaScript Test Scripts

### Basic HTTP Test
```javascript
// basic-test.js
import http from 'k6/http';
import { sleep, check } from 'k6';

export let options = {
  vus: 10,        // 10 virtual users
  duration: '30s', // for 30 seconds
};

export default function() {
  let response = http.get('https://httpbin.org/get');
  
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
  
  sleep(1);
}
```

### API Testing
```javascript
// api-test.js
import http from 'k6/http';
import { check } from 'k6';

export let options = {
  stages: [
    { duration: '2m', target: 100 }, // Ramp up
    { duration: '5m', target: 100 }, // Stay at 100 users
    { duration: '2m', target: 0 },   // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% of requests under 500ms
    http_req_failed: ['rate<0.02'],   // Error rate under 2%
  },
};

export default function() {
  // POST request
  let payload = JSON.stringify({
    name: 'John Doe',
    email: 'john@example.com'
  });
  
  let params = {
    headers: {
      'Content-Type': 'application/json',
    },
  };
  
  let response = http.post('https://httpbin.org/post', payload, params);
  
  check(response, {
    'POST status is 200': (r) => r.status === 200,
    'POST response has data': (r) => r.json().json.name === 'John Doe',
  });
  
  // GET request
  response = http.get('https://httpbin.org/get');
  check(response, {
    'GET status is 200': (r) => r.status === 200,
  });
}
```

### Authentication Testing
```javascript
// auth-test.js
import http from 'k6/http';
import { check } from 'k6';

export default function() {
  // Login
  let loginResponse = http.post('https://api.example.com/login', {
    username: 'testuser',
    password: 'testpass'
  });
  
  check(loginResponse, {
    'login successful': (r) => r.status === 200,
  });
  
  // Extract token
  let token = loginResponse.json('token');
  
  // Authenticated request
  let params = {
    headers: {
      'Authorization': `Bearer ${token}`,
    },
  };
  
  let response = http.get('https://api.example.com/protected', params);
  
  check(response, {
    'authenticated request successful': (r) => r.status === 200,
  });
}
```

### WebSocket Testing
```javascript
// websocket-test.js
import ws from 'k6/ws';
import { check } from 'k6';

export default function() {
  let url = 'ws://echo.websocket.org';
  let params = { tags: { my_tag: 'websocket' } };
  
  let response = ws.connect(url, params, function(socket) {
    socket.on('open', function open() {
      console.log('connected');
      socket.send(Date.now().toString());
    });
    
    socket.on('message', function(message) {
      console.log(`Received message: ${message}`);
    });
    
    socket.on('close', function close() {
      console.log('disconnected');
    });
    
    socket.setTimeout(function() {
      console.log('Timeout reached, closing socket');
      socket.close();
    }, 10000);
  });
  
  check(response, { 'status is 101': (r) => r && r.status === 101 });
}
```

## Advanced Test Scenarios

### Load Profiles
```javascript
// load-profiles.js
export let options = {
  scenarios: {
    constant_request_rate: {
      executor: 'constant-arrival-rate',
      rate: 1000, // 1000 RPS
      timeUnit: '1s',
      duration: '60s',
      preAllocatedVUs: 50,
      maxVUs: 100,
    },
    ramping_vus: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '2m', target: 10 },
        { duration: '5m', target: 10 },
        { duration: '2m', target: 0 },
      ],
    },
  },
};
```

### Data Parameterization
```javascript
// data-driven-test.js
import { SharedArray } from 'k6/data';
import papaparse from 'https://jslib.k6.io/papaparse/5.1.1/index.js';

const csvData = new SharedArray('users', function() {
  return papaparse.parse(open('./users.csv'), { header: true }).data;
});

export default function() {
  let user = csvData[Math.floor(Math.random() * csvData.length)];
  
  let response = http.post('https://api.example.com/login', {
    username: user.username,
    password: user.password
  });
  
  check(response, {
    'login successful': (r) => r.status === 200,
  });
}
```

## Metrics and Thresholds

### Built-in Metrics
```javascript
export let options = {
  thresholds: {
    // Response time metrics
    'http_req_duration': ['p(95)<500', 'p(99)<1000'],
    'http_req_duration{name:login}': ['avg<200'],
    
    // Error rate metrics
    'http_req_failed': ['rate<0.02'], // 2% error rate
    'http_req_failed{name:critical}': ['rate<0.01'],
    
    // Custom metrics
    'iterations': ['count>1000'],
    'vus': ['value<=100'],
  },
};
```

### Custom Metrics
```javascript
import { Counter, Gauge, Rate, Trend } from 'k6/metrics';

let myCounter = new Counter('my_counter');
let myGauge = new Gauge('my_gauge');
let myRate = new Rate('my_rate');
let myTrend = new Trend('my_trend');

export default function() {
  myCounter.add(1);
  myGauge.add(Math.random() * 100);
  myRate.add(Math.random() > 0.9);
  myTrend.add(Math.random() * 1000);
}
```

## CI/CD Integration

### Jenkins Pipeline
```groovy
pipeline {
  stages {
    stage('Load Test') {
      steps {
        sh 'k6 run --out json=results.json test.js'
        publishHTML([
          allowMissing: false,
          alwaysLinkToLastBuild: true,
          keepAll: true,
          reportDir: 'reports',
          reportFiles: 'index.html',
          reportName: 'K6 Load Test Report'
        ])
      }
    }
  }
}
```

### GitHub Actions
```yaml
name: Load Test
on: [push]
jobs:
  load-test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Run k6 load test
      uses: grafana/k6-action@v0.2.0
      with:
        filename: test.js
        flags: --vus 50 --duration 10s
```

### Docker Integration
```bash
# Run k6 in Docker
docker run -i grafana/k6 run - < script.js

# With volume mounting
docker run -v $(pwd):/scripts grafana/k6 run /scripts/test.js

# With environment variables
docker run -e API_BASE_URL=https://api.example.com grafana/k6 run script.js
```

## Use Cases

### API Performance Testing
- REST API load testing
- GraphQL performance validation
- Microservices stress testing
- Authentication flow testing

### Website Load Testing
- Page load performance
- User journey simulation
- E-commerce checkout flows
- Content delivery testing

### Infrastructure Testing
- Database connection pooling
- CDN performance validation
- Load balancer behavior
- Auto-scaling trigger testing

### Continuous Performance Testing
- CI/CD pipeline integration
- Performance regression detection
- SLA validation
- Capacity planning

## Installation
Modern load testing tool for API and website performance testing.
JavaScript-based scripting with comprehensive metrics and CI/CD integration.

## Dependencies
None - standalone executable with built-in JavaScript runtime and HTTP client.

## Performance Features
- High-performance JavaScript runtime
- Efficient virtual user simulation
- Real-time metrics collection
- Minimal resource overhead
- Scalable test execution

---
*Part of PORTX Portable Development Environment*