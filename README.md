# Rails AI Chatbots

Create a **RAG** AI Chatbot from scraped data of any website levering the simplicity of **OpenAI**, **Low-Code** tools, and **Ruby on Rails**.

![Rails AI Chatbots](preview.gif)

## Technologies

- **App**: `Ruby on Rails`, `Hotwire`, `ActiveJob`, `TailwindCSS`
- **Chatbots**: `FlowiseAI`, `OpenAI`
- **Databases**: `ChromaDB`, `PostgreSQL`
- **Scraper**: `FastAPI`, `Python`
- **Screenshoter**: `Puppeteer`, `Node.js`

## Project Overview

## Installation and Setup

Clone the whole monorepository before starting the setup and navigate to the root directory of the project.

### FlowiseAI, ChromaDB, PostgreSQL

1. Go to `llm` directory.
2. Run `docker compose up -d --remove-orphans` to start the Flowise AI, Chroma DB and Postgres.
3. Enter the Flowise AI by opening the URL `http://localhost:3020/`
4. Login with `admin:admin` credentials.
5. Go to `Credentials` and create a new credential with the following details:
   - Name: `OpenAI`
     - API Key: `<your-openai-api-key>`
   - Name: `Postgres`
     - user: `postgres`
     - password: `postgres`

### Scraper

1. Go to the `scraper` directory.
2. Create a new virtual environment with `python -m venv env`.
3. Activate the virtual environment with `source env/bin/activate`.
4. Install dependencies with `pip install -r requirements.txt`.
5. Run the scraper with `fastapi dev main.py --port 3002`.

### Screenshoter

1. Go to the `screenshots` directory.
2. Install dependencies with `pnpm install`.
3. Run the screenshoter with `pnpm start`.

### Rails App

1. Go to the `app` directory.
2. Install gems with `bundle install`.
3. Setup the database with `./bin/setup`.
4. Run the Rails app with `./bin/dev` and open the URL `http://localhost:3000/`.