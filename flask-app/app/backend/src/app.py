from fastapi import FastAPI, WebSocket
from fastapi.middleware.cors import CORSMiddleware
import asyncio
import random
import json

app = FastAPI()

# Allow frontend to connect
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Simulated IoT data endpoint
@app.get("/sensor")
async def get_sensor_data():
    return {"temperature": random.uniform(20.0, 25.0), "humidity": random.uniform(40.0, 60.0)}

# WebSocket for real-time data
@app.websocket("/ws/sensor")
async def sensor_websocket(websocket: WebSocket):
    await websocket.accept()
    try:
        while True:
            # Send simulated data every second
            data = {
                "temperature": round(random.uniform(20.0, 25.0), 2),
                "humidity": round(random.uniform(40.0, 60.0), 2),
            }
            await websocket.send_text(json.dumps(data))
            await asyncio.sleep(1)
    except Exception as e:
        print(f"WebSocket connection closed: {e}")
