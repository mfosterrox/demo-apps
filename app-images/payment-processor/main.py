import argparse
import os
import uvicorn

from starlette.applications import Starlette
from starlette.responses import JSONResponse, Response

star = Starlette(debug=True)

@star.route("/api/pay", methods=["POST"])
async def pay(request):
    request_data = await request.json()

    return JSONResponse({"error": None})

@star.route("/api/health", methods=["GET"])
async def health(request):
    return Response("OK\n", 200)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--host", default="0.0.0.0")
    parser.add_argument("--port", type=int, default=8080)

    args = parser.parse_args()

    uvicorn.run(star, host=args.host, port=args.port)
