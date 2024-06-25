from typing import List
from fastapi import APIRouter, Depends, HTTPException, status, Request
from app.models.user import UserRegistration, EmailResponse, CarIdRequest, EmailRequest, EmailsRequest
from app.core.security import pwd_context
from app.db.db import users_collection
from app.utils.translation import translate_text, is_hebrew
from app.utils.dmv import is_car_id_valid, is_motorcycle_id_valid
from fastapi.security import OAuth2PasswordBearer
from app.api.auth import verify_token
import logging

logger = logging.getLogger(__name__)

router = APIRouter()

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")


@router.post("/register", status_code=status.HTTP_200_OK)
def register_user(user_data: UserRegistration):
    logger.info(user_data)
    if users_collection.find_one({"email": user_data.email}):
        raise HTTPException(status_code=400, detail="Email already exists")
    if users_collection.find_one({"vehicle.carId": user_data.vehicle.carId}):
        raise HTTPException(status_code=400, detail="Car already registered")

    api_record = is_car_id_valid(user_data.vehicle.carId)
    if not api_record:
        api_record_motor = is_motorcycle_id_valid(user_data.vehicle.carId)
        if api_record_motor:
            user_data.vehicle.color = "Motorcycle Not Detailed"
            user_data.vehicle.year = api_record_motor.get('shnat_yitzur')
            user_data.vehicle.brend = translate_text(api_record_motor.get('tozeret_nm'))
            user_data.vehicle.model = translate_text(api_record_motor.get('degem_nm'))
        else:
            raise HTTPException(status_code=400, detail="Invalid car ID")

    else:
        # Translate and update vehicle details from API
        print(api_record.get('tzeva_rechev'))

        print(is_hebrew(api_record.get('tzeva_rechev')))

        user_data.vehicle.color = translate_text(api_record.get('tzeva_rechev'))
        user_data.vehicle.year = api_record.get('shnat_yitzur')
        user_data.vehicle.brend = translate_text(api_record.get('tozeret_nm'))
        user_data.vehicle.model = translate_text(api_record.get('kinuy_mishari'))

    hashed_password = pwd_context.hash(user_data.password)

    user_doc = {
        "email": user_data.email,
        "first_name": user_data.first_name.capitalize(),
        "last_name": user_data.last_name.capitalize(),
        "password": hashed_password,
        "vehicle": user_data.vehicle.dict(),
        "gender": user_data.gender,
        "last_seen": user_data.last_seen,
        "is_active": user_data.is_active,
        "phone": user_data.phone,
    }

    try:
        users_collection.insert_one(user_doc)
        return {"message": "User registered successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/emails_by_car", response_model=EmailResponse)
async def fetch_user_emails(request: CarIdRequest):
    try:
        carIds = request.carIds

        if not carIds:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="carIds list cannot be empty")

        cursor = users_collection.find({"vehicle.carId": {"$in": carIds}}, {"email": 1})
        users = list(cursor)

        if not users:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="No users found for the provided car IDs")

        emails = [user['email'] for user in users if 'email' in user]

        return EmailResponse(emails=emails)
    except HTTPException as http_exc:
        raise http_exc
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))


@router.get("/user/profile", response_model=UserRegistration)
def read_user_profile(current_user: str = Depends(verify_token)):
    user_data = users_collection.find_one({"email": current_user})
    if user_data is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    return UserRegistration(**user_data)


# Get user by email

def get_current_user(email: str = Depends(verify_token)):
    user = get_user_by_email(email)
    if user is None:
        logging.error(f"User not found: {email}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return UserRegistration(**user)


@router.post("/users_by_car", response_model=List[UserRegistration])
async def fetch_users_by_car(request: CarIdRequest):
    try:
        carIds = request.carIds

        if not carIds:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="carIds list cannot be empty")

        cursor = users_collection.find({"vehicle.carId": {"$in": carIds}})
        users = list(cursor)

        if not users:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Users not found")

        return [UserRegistration(**user) for user in users]
    except HTTPException as http_exc:
        raise http_exc
    except Exception as e:
        logging.error(f"Error in fetch_users_by_car: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))


@router.post("/users_by_emails", response_model=List[UserRegistration])
async def fetch_users_by_emails(request: EmailsRequest, current_user: str = Depends(verify_token)):
    try:
        emails = request.emails

        if not emails:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Emails list cannot be empty")

        users = get_users_by_emails(emails)

        if not users:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="No users found")

        return [UserRegistration(**user) for user in users]
    except HTTPException as http_exc:
        raise http_exc
    except Exception as e:
        logging.error(f"Error in fetch_users_by_emails: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))


def get_user_by_email(email: str) -> dict:
    try:
        user = users_collection.find_one({"email": email})
        return user
    except Exception as e:
        logging.error(f"Error fetching user by email: {e}")
        return None


def get_users_by_emails(emails: List[str]) -> List[dict]:
    try:
        cursor = users_collection.find({"email": {"$in": emails}})
        users = list(cursor)
        return users
    except Exception as e:
        logging.error(f"Error fetching users by emails: {e}")
        return []


@router.post("/fetch_login_emails", response_model=UserRegistration)
async def fetch_login_emails(current_user: str = Depends(verify_token)):
    try:
        user = get_login_email(current_user)

        if not user:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

        return UserRegistration(**user)
    except HTTPException as http_exc:
        raise http_exc
    except Exception as e:
        logging.error(f"Error in fetch_login_emails: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))

def get_login_email(email: str) -> dict:
    try:
        user = users_collection.find_one({"email": email})
        return user
    except Exception as e:
        logging.error(f"Error fetching user by email: {e}")
        return None