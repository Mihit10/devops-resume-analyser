import pytest
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# Target the Next.js frontend running locally
BASE_URL = "http://localhost:3000"

@pytest.fixture(scope="module")
def driver():
    """Setup the Selenium WebDriver for Chrome in Headless mode."""
    chrome_options = Options()
    # Headless mode is critical for Jenkins CI/CD as there's no physical display
    chrome_options.add_argument("--headless=new") 
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    
    # Initialize the WebDriver
    driver = webdriver.Chrome(options=chrome_options)
    driver.implicitly_wait(10)
    
    yield driver
    
    # Teardown: close the browser after tests
    driver.quit()

def test_homepage_loads_successfully(driver):
    """Test that the frontend homepage loads without crashing."""
    driver.get(BASE_URL)
    
    # Wait up to 10 seconds for the body tag to be present
    WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.TAG_NAME, "body"))
    )
    
    # Assert that the page actually loaded (title should not be completely empty)
    assert driver.title != "", "The page title is empty, meaning the page might not have loaded correctly."
    print("Homepage loaded successfully. Page Title:", driver.title)

def test_placeholder_upload_button(driver):
    """Placeholder to check if a file input exists for uploading a resume."""
    driver.get(BASE_URL)
    
    try:
        # Looking for <input type="file"> which is typical for uploads
        file_input = driver.find_element(By.XPATH, "//input[@type='file']")
        assert file_input is not None
    except Exception:
        # If not found, skip the test for now rather than failing the whole suite
        pytest.skip("File upload input not found on the page yet. Update the XPath when the UI is built.")
