const express = require("express");
const fs = require("fs");
const path = require("path");
const app = express();

let modelStatus = "WAITING";
let fileNumber = 1;
let lastCommand = "NONE";

app.use(express.json());

// Ensure results and errors directories exist
const resultsDir = path.join(__dirname, "results");
const errorsDir = path.join(__dirname, "errors");

if (!fs.existsSync(resultsDir)) {
  fs.mkdirSync(resultsDir, { recursive: true });
}
if (!fs.existsSync(errorsDir)) {
  fs.mkdirSync(errorsDir, { recursive: true });
}

app.post("/RUN-MODEL", (req, res) => {
  console.log("RUN-MODEL called");
  modelStatus = "RUNNING";
  lastCommand = "RUN-MODEL";

  // Create a result file immediately
  const resultFileName = `result_${fileNumber}_${Date.now()}.txt`;
  const resultFilePath = path.join(resultsDir, resultFileName);
  const resultContent = `Satellite Analysis Result #${fileNumber}
Timestamp: ${new Date().toISOString()}
Status: Processing
Model: Satlyt ML Model v1.0
Data: Simulated satellite image processing
Output: Analysis completed successfully
File created at: ${new Date().toISOString()}`;

  fs.writeFileSync(resultFilePath, resultContent);
  console.log(` Created result file: ${resultFileName}`);

  setTimeout(() => {
    modelStatus = "SUCCESS";
    fileNumber++;

    // Create an additional result file after processing
    const finalResultFileName = `final_result_${
      fileNumber - 1
    }_${Date.now()}.txt`;
    const finalResultFilePath = path.join(resultsDir, finalResultFileName);
    const finalResultContent = `Final Analysis Result #${fileNumber - 1}
Timestamp: ${new Date().toISOString()}
Status: COMPLETED
Model: Satlyt ML Model v1.0
Processing Time: 3 seconds
Output: Analysis completed successfully
Confidence Score: 0.95
File created at: ${new Date().toISOString()}`;

    fs.writeFileSync(finalResultFilePath, finalResultContent);
    console.log(`Created final result file: ${finalResultFileName}`);
    console.log(" Model execution completed");
  }, 3000);

  res.json({
    status: "Model started",
    message: "Processing satellite images...",
    timestamp: new Date().toISOString(),
    result_file: resultFileName,
  });
});

app.get("/MODEL-EXECUTION-STATUS", (req, res) => {
  console.log(" STATUS check:", modelStatus);
  res.json({
    status: modelStatus,
    file_number: fileNumber,
    last_command: lastCommand,
  });
});

app.get("/GET-FILE-NUMBER", (req, res) => {
  console.log("FILE-NUMBER request");
  res.json({
    latest_result_file: fileNumber,
    latest_error_file: 0,
    total_files: fileNumber,
  });
});

app.post("/CREATE-ERROR", (req, res) => {
  console.log("CREATE-ERROR called");
  const errorFileName = `error_${Date.now()}.txt`;
  const errorFilePath = path.join(errorsDir, errorFileName);
  const errorContent = `Error Log Entry
Timestamp: ${new Date().toISOString()}
Error Type: Test Error
Message: This is a test error file created for volume mounting verification
Severity: LOW
File created at: ${new Date().toISOString()}`;

  fs.writeFileSync(errorFilePath, errorContent);
  console.log(`Created error file: ${errorFileName}`);

  res.json({
    status: "Error file created",
    error_file: errorFileName,
    timestamp: new Date().toISOString(),
  });
});

app.get("/LIST-FILES", (req, res) => {
  console.log(" LIST-FILES called");
  try {
    const resultFiles = fs.readdirSync(resultsDir);
    const errorFiles = fs.readdirSync(errorsDir);

    res.json({
      results_files: resultFiles,
      errors_files: errorFiles,
      total_results: resultFiles.length,
      total_errors: errorFiles.length,
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    res.status(500).json({
      error: "Failed to list files",
      message: error.message,
    });
  }
});

app.post("/SHUT-DOWN", (req, res) => {
  console.log(" SHUTDOWN command received");
  res.json({ status: "Shutdown acknowledged" });
});

const PORT = 3000;
app.listen(PORT, "0.0.0.0", () => {
  console.log(` Satellite API Server running on port ${PORT}`);
  console.log("Ready to receive commands from gateway...");
});