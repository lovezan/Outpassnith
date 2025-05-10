const { createServer } = require("http")
const { parse } = require("url")
const next = require("next")
const { setupCronJobs } = require("./lib/utils/cron-jobs")

const dev = process.env.NODE_ENV !== "production"
const hostname = process.env.HOSTNAME || "localhost"
const port = Number.parseInt(process.env.PORT || "3000", 10)

const app = next({ dev, hostname, port })
const handle = app.getRequestHandler()

// Track connections for graceful shutdown
const connections = {}
let connectionCounter = 0

app.prepare().then(() => {
  console.log(`> Environment: ${process.env.NODE_ENV}`)

  // Set up cron jobs if enabled
  let cronJobs = { jobs: [], intervals: [] }
  if (process.env.ENABLE_CRON_JOBS !== "false") {
    cronJobs = setupCronJobs()
    console.log(`> Started ${cronJobs.jobs.length} cron jobs successfully`)
  } else {
    console.log("> Cron jobs are disabled")
  }

  const server = createServer((req, res) => {
    // Track the connection
    const connectionId = connectionCounter++
    connections[connectionId] = res

    // Remove the connection when it closes
    res.on("close", () => {
      delete connections[connectionId]
    })

    // Handle the request
    const parsedUrl = parse(req.url, true)
    handle(req, res, parsedUrl)
  })

  server.listen(port, (err) => {
    if (err) throw err
    console.log(`> Ready on http://${hostname}:${port}`)
  })

  // Graceful shutdown function
  const gracefulShutdown = (signal) => {
    console.log(`\n${signal} received. Starting graceful shutdown...`)

    // Create a shutdown timeout
    const shutdownTimeout = setTimeout(() => {
      console.log("Forcing shutdown after timeout")
      process.exit(1)
    }, 30000)

    // Stop accepting new connections
    server.close(() => {
      console.log("HTTP server closed")

      // Clean up cron jobs
      if (cronJobs.intervals) {
        cronJobs.intervals.forEach((interval) => clearInterval(interval))
        console.log("Cron jobs stopped")
      }

      // Close any database connections here if needed

      // Clear the shutdown timeout
      clearTimeout(shutdownTimeout)
      console.log("Graceful shutdown completed")
      process.exit(0)
    })

    // Close existing connections
    Object.keys(connections).forEach((key) => {
      connections[key].end("Server is shutting down")
    })
  }

  // Handle termination signals
  process.on("SIGTERM", () => gracefulShutdown("SIGTERM"))
  process.on("SIGINT", () => gracefulShutdown("SIGINT"))

  // Handle uncaught exceptions and unhandled rejections
  process.on("uncaughtException", (err) => {
    console.error("Uncaught exception:", err)
    gracefulShutdown("UNCAUGHT_EXCEPTION")
  })

  process.on("unhandledRejection", (reason, promise) => {
    console.error("Unhandled rejection at:", promise, "reason:", reason)
  })
})
