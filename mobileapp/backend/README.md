# Campus Management API

Backend server for the Campus Management Mobile Application built with Node.js, Express, and MongoDB.

## Features

- **User Authentication**: JWT-based authentication with refresh tokens
- **Role-Based Access Control**: Student, Faculty, Admin roles
- **Announcements Management**: Create, read, update, delete announcements
- **Event Management**: Create and manage campus events
- **Attendance Tracking**: Track student attendance
- **Job Postings**: Manage job opportunities
- **User Profiles**: User profile management
- **Secure API**: Request validation, rate limiting, CORS protection

## Technology Stack

- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: MongoDB with Mongoose ORM
- **Authentication**: JWT (JSON Web Tokens)
- **Validation**: Joi
- **Security**: Helmet, CORS, Rate limiting, bcryptjs

## Prerequisites

- Node.js >= 14.0.0
- MongoDB >= 4.0
- npm or yarn

## Installation

1. Clone the repository
```bash
cd backend
```

2. Install dependencies
```bash
npm install
```

3. Create `.env` file from `.env.example`
```bash
cp .env.example .env
```

4. Update environment variables in `.env`

5. Start MongoDB service

## Running the Server

### Development mode (with hot reload)
```bash
npm run dev
```

### Production mode
```bash
npm start
```

The API will be available at `http://localhost:5000/api/v1`

## API Documentation

### Authentication Endpoints

```
POST   /api/v1/auth/register       - Register new user
POST   /api/v1/auth/login          - Login user
POST   /api/v1/auth/logout         - Logout user
POST   /api/v1/auth/refresh        - Refresh JWT token
```

### User Endpoints

```
GET    /api/v1/users/:id           - Get user profile
PUT    /api/v1/users/:id           - Update user profile
GET    /api/v1/users               - Get all users (admin only)
```

### Announcements Endpoints

```
GET    /api/v1/announcements       - Get all announcements
GET    /api/v1/announcements/:id   - Get announcement by ID
POST   /api/v1/announcements       - Create announcement
PUT    /api/v1/announcements/:id   - Update announcement
DELETE /api/v1/announcements/:id   - Delete announcement
```

### Events Endpoints

```
GET    /api/v1/events              - Get all events
GET    /api/v1/events/:id          - Get event by ID
POST   /api/v1/events              - Create event
PUT    /api/v1/events/:id          - Update event
DELETE /api/v1/events/:id          - Delete event
```

### Attendance Endpoints

```
GET    /api/v1/attendance          - Get attendance records
POST   /api/v1/attendance          - Mark attendance
GET    /api/v1/attendance/:userId  - Get user attendance
```

### Job Postings Endpoints

```
GET    /api/v1/jobs                - Get all job postings
GET    /api/v1/jobs/:id            - Get job posting by ID
POST   /api/v1/jobs                - Create job posting
PUT    /api/v1/jobs/:id            - Update job posting
DELETE /api/v1/jobs/:id            - Delete job posting
```

## Project Structure

```
backend/
├── src/
│   ├── config/          - Configuration files (database, environment)
│   ├── controllers/      - Route controllers (business logic)
│   ├── middleware/       - Express middleware (auth, validation, error)
│   ├── models/           - Mongoose schemas and models
│   ├── routes/           - API route definitions
│   ├── utils/            - Utility functions and helpers
│   └── server.js         - Main server file
├── uploads/              - User uploaded files
├── .env.example          - Environment variables example
├── .gitignore            - Git ignore file
├── package.json          - Dependencies and scripts
└── README.md             - This file
```

## Environment Variables

See `.env.example` for all available configuration options.

## Testing

```bash
npm test
```

## Code Quality

### Linting
```bash
npm run lint
```

### Fix Linting Issues
```bash
npm run lint:fix
```

## Deployment

### Using Docker

```bash
docker build -t campus-api .
docker run -d -p 5000:5000 --env-file .env campus-api
```

### Using PM2

```bash
npm install -g pm2
pm2 start src/server.js --name "campus-api"
pm2 save
pm2 startup
```

## Contributing

1. Create a feature branch
2. Make your changes
3. Test your changes
4. Submit a pull request

## License

MIT License - see LICENSE file for details

## Support

For support, email support@campusmanagement.com or open an issue on GitHub.
