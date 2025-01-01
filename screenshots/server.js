const express = require("express");
const puppeteer = require("puppeteer");
const fs = require("fs");
const path = require("path");
const axios = require("axios");
const FormData = require("form-data");

const app = express();

app.get("/screenshot", async (req, res) => {
  const url = req.query.url;
  const chatbotCreationId = req.query.chatbot_creation_id; // ID of the Rails model to update
  const filename = `${Date.now()}.png`;
  const savePath = path.join(__dirname, "screenshots", filename);

  if (!url || !chatbotCreationId) {
    return res.status(400).send("Please provide a URL and model ID");
  }

  try {
    // Launch Puppeteer and capture screenshot
    const browser = await puppeteer.launch();
    const page = await browser.newPage();

    await page.goto(url, { waitUntil: "networkidle0", timeout: 0 });
    await page.setViewport({ width: 1920, height: 3160 });
    await page.screenshot({ path: savePath, fullPage: true });

    await browser.close();

    // Prepare FormData with the screenshot file
    const form = new FormData();
    form.append("chatbot_creation[screenshot]", fs.createReadStream(savePath));

    // Rails endpoint URL to update the model's photo
    const railsEndpoint = `http://localhost:3000/chatbot_creations/${chatbotCreationId}`;

    // Send POST request with screenshot to Rails
    await axios.patch(railsEndpoint, form, {
      headers: {
        ...form.getHeaders(),
      },
    });

    // Delete the screenshot file after sending
    fs.unlinkSync(savePath);

    res.send("Screenshot uploaded successfully to Rails model.");
  } catch (error) {
    console.error("Failed to take screenshot or upload to Rails:", error);
    res.status(500).send("Failed to take screenshot or upload to Rails");
  }
});

const port = 3030;
app.listen(port, () =>
  console.log(`Screenshot service running on http://localhost:${port}`)
);
