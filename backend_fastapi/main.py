from fastapi import FastAPI, Request
from fastapi.responses import StreamingResponse
from starlette.middleware.cors import CORSMiddleware
from pytube import YouTube
import os
import logging
import ffd
from typing import Optional

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def read_root():
    return {"Hello": "World"}


@app.get("/api/ffd/user/")
def user(request: Request):
    headerAccesstoken = request.headers.get('accesstoken')

    return ffd.userExists(headerAccesstoken)


@app.get("/api/ffd/list")
def readListActualBudget(request: Request, _type: Optional[str] = None, sort: Optional[str] = None, sortType: Optional[str] = None):

    headerAccesstoken = request.headers.get('accesstoken')

    return ffd.readListActualBudget(_type, sort, sortType, headerAccesstoken)


@app.get("/api/ffd/amounts")
def readAmounts(request: Request, level_type: Optional[str] = None, cost_type: Optional[str] = None, parent_account: Optional[str] = None, year: Optional[str] = None, month: Optional[str] = None, day: Optional[str] = None, _type: Optional[str] = None, groupBy: Optional[str] = None):
    headerAccesstoken = request.headers.get('accesstoken')

    return ffd.readAmounts(level_type, cost_type, parent_account, year, month, day, _type, groupBy, headerAccesstoken)


@app.get("/api/ffd/preferences")
def readPreferences(request: Request):
    headerAccesstoken = request.headers.get('accesstoken')

    return ffd.readPreferences(headerAccesstoken)


@app.get("/api/ffd/accounts/{level_type}")
def accounts(level_type: int, request: Request):
    headerAccesstoken = request.headers.get('accesstoken')

    return ffd.readAccounts(level_type, headerAccesstoken)


@app.get("/api/ffd/costtypes")
def readCosttypes(request: Request):

    headerAccesstoken = request.headers.get('accesstoken')

    return ffd.readCosttypes(headerAccesstoken)


@app.post("/api/ffd")
def send(request: Request):
    data = request.form.to_dict()
    headerAccesstoken = request.headers.get('accesstoken')

    return ffd.send(headerAccesstoken, data)
