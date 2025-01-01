# Rails AI Chatbots

Create a **RAG AI chatbot** from scraped data of any website, leveraging the simplicity of **OpenAI**, **low-code** tools, background processing and **Ruby on Rails**.

<img src="preview.gif" alt="Rails AI Chatbots" style="width: 100%;" />

<p>
  <img src="https://img.shields.io/badge/rails_7-%23CC0000.svg?style=for-the-badge&logo=ruby-on-rails&logoColor=white" alt="Rails">
  <img src="https://img.shields.io/badge/ruby-3.3.5-%23CC342D.svg?style=for-the-badge&logo=ruby&logoColor=white" alt="Ruby">
  <img src="https://img.shields.io/badge/hotwire-%234c4c4c.svg?style=for-the-badge&logo=hotwire&logoColor=white" alt="Hotwire">
  <img src="https://img.shields.io/badge/postgresql-%23316192.svg?style=for-the-badge&logo=postgresql&logoColor=white" alt="Postgres">
  <img src="https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white" alt="Docker">
  <img src="https://img.shields.io/badge/tailwindcss-%2306B6D4.svg?style=for-the-badge&logo=tailwindcss&logoColor=white" alt="TailwindCSS">
</p>

<p>
  <img src="https://img.shields.io/badge/openai-%23000000.svg?style=for-the-badge&logo=openai&logoColor=white" alt="OpenAI">
  <img src="https://img.shields.io/badge/flowise_ai-%2300844f.svg?style=for-the-badge&logo=flowise&logoColor=white" alt="FlowiseAI">
  <img src="https://img.shields.io/badge/chroma_db-%23FF9900.svg?style=for-the-badge&logo=data&logoColor=white" alt="ChromaDB">
  <img src="https://img.shields.io/badge/langchain-%230075A4.svg?style=for-the-badge&logo=langchain&logoColor=white" alt="LangChain">
  <img src="https://img.shields.io/badge/python-3.x-%233776AB.svg?style=for-the-badge&logo=python&logoColor=white" alt="Python">
  <img src="https://img.shields.io/badge/node.js-20.x-%23339933.svg?style=for-the-badge&logo=node.js&logoColor=white" alt="Node.js">
</p>

## Technologies Used
- **App**: `Ruby 3.3.5`, `Ruby on Rails 7.2`, `Hotwire`, `ActiveJob`, `ActiveAdmin 4`, `Docker`, `Faraday`.
- **Low-Code LLM**: `FlowiseAI`, `OpenAI`.
- **Vector Database**: `ChromaDB`.
- **Relational Database**: `PostgreSQL`.
- **Scraper**: `FastAPI`, `Python`.
- **Screenshoter**: `Puppeteer`, `Node.js`.

## System Diagram

![System Diagram](system_diagram.png)

## Project Overview

This project enables you to create a **RAG (Retrieval-Augmented Generation)** AI chatbot from any website's data in just seconds!

### 🎯 Key Features:

- **Instant Website Integration:**  
  Simply provide the website's URL via a parameter or through the admin panel.

- **Automated Pipeline:**  
  Once the URL is provided, the app triggers the following processes:
  - **Scrape Website Data**: Extracts relevant content from the provided website.
  - **Create Document Store**: Stores the data in FlowiseAI for seamless retrieval.
  - **Generate Embeddings**: Converts the scraped content into embeddings and uploads them to ChromaDB.
  - **Set Up Chatflow**: Automatically creates a chatflow in FlowiseAI for conversational interactions.
  - **Website Screenshot**: Captures a high-quality screenshot of the website.

- **Embedded Chatbot Interface:**
  The chatbot is displayed beautifully with the scraped website as the background. Users can ask questions about the website's content and get accurate AI-powered answers in real-time.

### 💡 How It Works:
1. Input a URL.
2. Watch the magic happen as the app processes the website in the background (builds the chatbot, and integrates it seamlessly).
3. Start asking questions and receiving contextually accurate answers based on the website's data.

### 🤖 Why Use This?
- Simplifies chatbot creation with minimal effort.
- Provides a visually appealing and user-friendly experience.
- Leverages the power of AI to answer questions directly from website data.

## Screenshots:

**Home Page:**

The home page of the app where you can input the URL of the website you want to create a chatbot for or login to the admin panel.

![Home Page](app_home.png)

**Admin Panel:**

Manage the companies added to the system, from which the chatbots are created.

![Admin Panel](app_companies.png)

You can also view the chatbot creation history and manage the chatbot creation process, with the ability to view the chatbot's details (like the chatflow ID, document store ID, errors, scraped data, screenshots, etc.).

![Admin Panel](app_chatbot_creation.png)

**FlowiseAI Integration:**

The app leverages the power of FlowiseAI to create a seamless chatbot experience. The chatbot is trained on the scraped website data and can answer questions accurately using upserted vector store with embeddings.

![FlowiseAI](flowise_store.png)

The chatflow is very simple and only connects the chatbot to the document store.

![FlowiseAI](flowise_flow.png)

## Installation and Setup

Clone the whole monorepository before starting the setup and navigate to the root directory of the project.

### 1️⃣ FlowiseAI, ChromaDB, PostgreSQL

1. Go to `llm` directory.
2. Run `docker compose up -d --remove-orphans` to start the **FlowiseAI**, **ChromaDB** and **PostgreSQL**.
3. Enter the **FlowiseAI** by opening the URL `http://localhost:3020/`
4. Login with `admin:admin` credentials.
5. Go to `Credentials` and create a new credential with the following details:
   - Name: `OpenAI`
     - API Key: `<your-openai-api-key>`
   - Name: `Postgres`
     - user: `postgres`
     - password: `postgres`

### 2️⃣ Scraper

1. Go to the `scraper` directory.
2. Create a new virtual environment with `python -m venv env`.
3. Activate the virtual environment with `source env/bin/activate`.
4. Install dependencies with `pip install -r requirements.txt`.
5. Run the scraper with `fastapi dev main.py --port 3002`.

### 3️⃣ Screenshoter

1. Go to the `screenshoter` directory.
2. Install dependencies with `pnpm install`.
3. Run the screenshoter with `pnpm start`.

### 4️⃣ Rails App

1. Go to the `app` directory.
2. Install gems with `bundle install`.
3. Setup the database with `./bin/setup`.
4. Run the Rails app with `./bin/dev` and open the URL `http://localhost:3000/`.