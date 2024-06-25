from fastapi import APIRouter, HTTPException
import requests
from app.utils.translation import translate_text


router = APIRouter()
API_KEY = "AIzaSyDzBpNPGfU1k3uIs4fWGzx9qN0wLhh9Sno"

@router.get("/parking-locations/")
async def get_parking_locations(lat: float, lon: float):
    url = f"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location={lat},{lon}&radius=2000&type=parking&key={API_KEY}"
    response = requests.get(url)
    if response.status_code == 200:
        data = response.json()
        results = []
        for place in data.get("results", []):
            place_id = place["place_id"]
            details_url = f"https://maps.googleapis.com/maps/api/place/details/json?place_id={place_id}&key={API_KEY}"
            details_response = requests.get(details_url)
            if details_response.status_code == 200:
                details_data = details_response.json()
                place["address"] = details_data.get("result", {}).get("formatted_address", "")
            results.append(place)
        return {"results": results}
    else:
        raise HTTPException(status_code=response.status_code, detail="Failed to fetch parking locations")




@router.get("/service-locations/")
async def get_service_locations(lat: float, lon: float, type: str):
    service_type_map = {
        "Car Garages": "car_repair",
        "Gas Stations": "gas_station",
        "Car Washes": "car_wash"
    }
    place_type = service_type_map.get(type, "car_repair")
    url = f"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location={lat},{lon}&radius=2000&type={place_type}&key={API_KEY}"
    response = requests.get(url)
    if (response.status_code == 200):
        data = response.json()
        results = []
        for place in data.get("results", []):
            place_id = place["place_id"]
            details_url = f"https://maps.googleapis.com/maps/api/place/details/json?place_id={place_id}&key={API_KEY}"
            details_response = requests.get(details_url)
            if details_response.status_code == 200:
                details_data = details_response.json()
                place["address"] = details_data.get("result", {}).get("formatted_address", "")
                place["rating"] = details_data.get("result", {}).get("rating", "No rating")
            results.append(place)
        return {"results": results}
    else:
        raise HTTPException(status_code=response.status_code, detail="Failed to fetch service locations")