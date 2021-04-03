from fastapi import FastAPI
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
def user():
    return ffd.userExists()


@app.get("/api/ffd/list")
def readListActualBudget(_type: Optional[str] = None, sort: Optional[str] = None, sortType: Optional[str] = None):
    return ffd.readListActualBudget(_type, sort, sortType)


@app.get("/api/ffd/amounts")
def readAmounts(level_type: Optional[str] = None, cost_type: Optional[str] = None, parent_account: Optional[str] = None, year: Optional[str] = None, month: Optional[str] = None, day: Optional[str] = None, _type: Optional[str] = None, groupBy: Optional[str] = None)():
    return ffd.readAmounts(level_type, cost_type, parent_account, year, month, day, _type, groupBy)


@app.get("/api/ffd/preferences")
def readPreferences():
    return ffd.readPreferences()


@app.get("/api/ffd/accounts/{level_type}")
def accounts(leve_typel: int):
    return ffd.readAccounts(level_type)


@app.get("/api/ffd/costtypes")
def readCosttypes():
    return ffd.readCosttypes()


@app.post("/api/ffd")
def send():
    return ffd.send()
