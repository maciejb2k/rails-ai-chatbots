import requests
from bs4 import BeautifulSoup
from usp.tree import sitemap_tree_for_homepage
from fastapi import FastAPI, HTTPException, Query
from urllib.parse import urlparse, urlunparse
from concurrent.futures import ThreadPoolExecutor, as_completed
import re
import json
import os

app = FastAPI()


def validate_and_normalize_url(url: str) -> str:
    """
    Validates and normalizes the given URL.
    """
    parsed = urlparse(url)
    if not parsed.scheme:
        url = f"http://{url}"  # Default to HTTP if no scheme is provided.
        parsed = urlparse(url)
    if not parsed.netloc:
        raise ValueError("Invalid URL: Missing domain.")
    return urlunparse(parsed)


def get_sitemap(url: str):
    """
    Fetches the sitemap for the homepage and returns a list of page URLs.
    """
    try:
        tree = sitemap_tree_for_homepage(url)
        sitemap = [page.url for page in tree.all_pages()][:25]
        return sitemap
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch sitemap: {e}")


def fetch_page_content(url: str) -> str:
    """
    Fetches the content of a page and extracts plain text.
    """
    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        soup = BeautifulSoup(response.text, 'html.parser')
        text = soup.get_text(separator=' ', strip=True)
        return text
    except Exception as e:
        return f"Failed to fetch content for {url}: {e}"


@app.get("/")
def read_root():
    return {
        "name": "Simple Web Scraper",
        "description": "Fetches and combines plain text content from all pages in a website's sitemap.",
        "version": "0.1.0",
    }


@app.get("/scrape-mocked")
def scrape_website(url: str = Query(..., description="URL of the website to scrape")):
    """
    Fetches plain text from each page in the sitemap of the given URL and combines the text into a single response.
    """
    try:
        json_file_path = os.path.join(os.path.dirname(__file__), "example.json")
        with open(json_file_path, "r") as file:
            data = json.load(file)
        return {"url": url, "data": data["content"]}
    except FileNotFoundError:
        raise HTTPException(status_code=404, detail="JSON file not found")
    except json.JSONDecodeError:
        raise HTTPException(status_code=500, detail="Error decoding JSON file")


@app.get("/scrape")
def scrape_website(url: str = Query(..., description="URL of the website to scrape")):
    """
    Fetches plain text from each page in the sitemap of the given URL and combines the text into a single response.
    """
    try:
        # Step 1: Validate and normalize URL
        normalized_url = validate_and_normalize_url(url)

        # Step 2: Fetch sitemap
        page_urls = get_sitemap(normalized_url)

        # Step 3: Fetch content concurrently
        combined_text = []
        with ThreadPoolExecutor(max_workers=25) as executor:
            futures = {executor.submit(fetch_page_content, page_url): page_url for page_url in page_urls}

            for future in as_completed(futures):
                page_url = futures[future]
                try:
                    content = future.result()
                    combined_text.append(content)
                except Exception as e:
                    combined_text.append(f"Error with {page_url}: {e}")

        # Step 4: Return combined content with clean formatting
        return {"url": url, "data": " ".join(combined_text)}

    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An unexpected error occurred: {e}")
