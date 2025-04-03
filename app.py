import re
import time
from fastapi import FastAPI
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager

app = FastAPI()

def get_products():
    options = webdriver.ChromeOptions()
    options.add_argument("--headless")
    options.add_argument("--disable-blink-features=AutomationControlled")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36")

    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)
    
    search_url = "https://www.ozon.ru/search/?text=Metabo+sb+18&from_global=true"
    driver.get(search_url)
    time.sleep(5)

    products = driver.find_elements(By.CSS_SELECTOR, '[data-index] a')
    pattern = re.compile(r'/product/[^/]+-(\d+)/\?')

    results = []
    for product in products:
        href = product.get_attribute("href")
        title = product.text
        if href:
            match = pattern.search(href)
            article = match.group(1) if match else "Не найден"
            results.append({"title": title, "link": href, "article": article})

    driver.quit()
    return results

@app.get("/scrape")
def scrape():
    return get_products()
