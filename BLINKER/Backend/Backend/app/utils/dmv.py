import requests
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

api_endpoint = "https://data.gov.il/api/3/action/datastore_search"
resource_id = "053cea08-09bc-40ec-8f7a-156f0677aff3"  # Replace with the actual resource ID
resource_motorcycle_id = "bf9df4e2-d90d-4c0a-a400-19e15af8e95f"

def fetch_data_from_api(resource_id, car_id):
    params = {
        'resource_id': resource_id,
        'q': f"{{\"mispar_rechev\": \"{car_id}\"}}"
    }
    response = requests.get(api_endpoint, params=params)
    print(response.json())
    if response.status_code == 200:
        return response.json()['result']['records']
    else:
        print("Error fetching data from API:", response.status_code)
        return []

# Function to compare user car ID with API data
def is_car_id_valid(car_id):
    api_data = fetch_data_from_api(resource_id, car_id)
    print(api_data)
    for record in api_data:
        str_num = str(record.get('mispar_rechev'))
        if str_num == car_id:
            return record
    return None

def get_vehicle_details(car_id):
    api_data = fetch_data_from_api(resource_id, car_id)
    if not api_data:
        api_data_motor = fetch_data_from_api(resource_motorcycle_id,car_id)
        for record in api_data_motor:
            if str(record.get('mispar_rechev')) == car_id:
                return {
                    "last_test_date": str(record.get('mishkal_kolel')),
                    "test_expiration_date": str(record.get('nefach_manoa')),
                    "on_road_date": record.get('moed_aliya_lakvish')
                }

    for record in api_data:
        if str(record.get('mispar_rechev')) == car_id:
            return {
                "last_test_date": record.get('mivchan_acharon_dt'),
                "test_expiration_date": record.get('tokef_dt'),
                "on_road_date": record.get('moed_aliya_lakvish')
            }
    return None

def is_motorcycle_id_valid(car_id):
    api_data = fetch_data_from_api(resource_motorcycle_id, car_id)
    print(api_data)
    for record in api_data:
        str_num = str(record.get('mispar_rechev'))
        if str_num == car_id:
            return record
    return None

