from app.models.service import Service
from fastapi import APIRouter, Depends, HTTPException, status
import requests
from fastapi import FastAPI, Query
from typing import List, Dict
from app.utils.dmv import get_vehicle_details
import logging
import yfinance as yf
from app.core.config import symbol_to_name

router = APIRouter()

GOOGLE_PLACES_API_KEY = "YOUR_API_KEY"  # Replace with your actual API key


@router.get("/vehicle_info/{car_id}")
def vehicle_info(car_id: str):
    vehicle_details = get_vehicle_details(car_id)
    if vehicle_details:
        return vehicle_details
    else:
        raise HTTPException(status_code=404, detail="Car ID not found")


API_KEY = "I3DH5Z2BLX4Q9BOZ"


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


@router.get("/stock_info")
def get_stock_info():
    symbols = list(symbol_to_name.keys())
    stocks = []
    for symbol in symbols:
        try:
            ticker = yf.Ticker(symbol)
            hist = ticker.history(period="1d")
            if not hist.empty:
                latest_data = hist.iloc[-1]
                stocks.append({
                    "symbol": symbol,
                    "name": symbol_to_name[symbol],
                    "price": latest_data["Close"],
                    "change": latest_data["Close"] - latest_data["Open"],
                    "percent_change": ((latest_data["Close"] - latest_data["Open"]) / latest_data["Open"]) * 100
                })
            else:
                logger.error(f"No data found for {symbol}")
                raise HTTPException(status_code=500, detail=f"No data found for {symbol}")
        except Exception as e:
            logger.error(f"Error fetching data for {symbol}: {e}")
            raise HTTPException(status_code=500, detail=f"Error fetching data for {symbol}")
    return stocks

def fetch_services_from_osm(latitude: float, longitude: float, service_type: str):
    service_types = {
        "car_repair": "amenity=car_repair",
        "car_wash": "amenity=car_wash",
        "gas_station": "amenity=fuel",
    }
    overpass_url = "http://overpass-api.de/api/interpreter"
    overpass_query = f"""
    [out:json];
    (
      node[{service_types[service_type]}](around:5000,{latitude},{longitude});
      way[{service_types[service_type]}](around:5000,{latitude},{longitude});
      rel[{service_types[service_type]}](around:5000,{latitude},{longitude});
    );
    out center;
    """
    response = requests.get(overpass_url, params={'data': overpass_query})
    data = response.json()
    elements = data['elements']

    services = []
    for i, element in enumerate(elements):
        if 'tags' in element and 'name' in element['tags']:
            services.append(Service(
                id=i,
                name=element['tags']['name'],
                address=element['tags'].get('addr:full', 'No address available'),
                latitude=element.get('lat', element['center']['lat']),
                longitude=element.get('lon', element['center']['lon']),
            ))
    return services

@router.get("/services/", response_model=List[Service])
async def get_services(
    latitude: float,
    longitude: float,
    type: str = Query(..., enum=["car_repair", "car_wash", "gas_station"])
):
    services = fetch_services_from_osm(latitude, longitude, type)
    return services

