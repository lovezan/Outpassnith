import knex from "knex"

// Database connection pool configuration
const db = knex({
  client: "mysql2",
  connection: process.env.DATABASE_URL || {
    host: process.env.MYSQL_HOST || "localhost",
    port: Number.parseInt(process.env.MYSQL_PORT || "3306"),
    user: process.env.MYSQL_USER || "user",
    password: process.env.MYSQL_PASSWORD || "password",
    database: process.env.MYSQL_DATABASE || "hostel_outpass",
  },
  pool: {
    min: 2,
    max: 10,
    acquireTimeoutMillis: 30000,
    createTimeoutMillis: 30000,
    idleTimeoutMillis: 30000,
    reapIntervalMillis: 1000,
    createRetryIntervalMillis: 100,
  },
  acquireConnectionTimeout: 60000,
})

// Redis client for caching
import { Redis } from "@upstash/redis"

const redis = new Redis({
  url: process.env.REDIS_URL || "redis://localhost:6379",
  token: process.env.REDIS_PASSWORD || "",
})

export { db, redis }
