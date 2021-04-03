from fastapi import FastAPI, Request, Form
from fastapi.responses import StreamingResponse
from starlette.middleware.cors import CORSMiddleware
from pytube import YouTube
import os
import logging
import ffd
from typing import Optional
from pydantic import BaseModel

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


@app.get("/api/ffd/list/")
def readListActualBudget(request: Request, _type: Optional[str] = None, sort: Optional[str] = None, sortType: Optional[str] = None):

    headerAccesstoken = request.headers.get('accesstoken')

    return ffd.readListActualBudget(_type, sort, sortType, headerAccesstoken)


@app.get("/api/ffd/amounts/")
def readAmounts(request: Request, level_type: Optional[int] = None, cost_type: Optional[int] = None, parent_account: Optional[int] = None, year: Optional[int] = None, month: Optional[int] = None, day: Optional[int] = None, _type: Optional[str] = None, groupBy: Optional[str] = None):
    headerAccesstoken = request.headers.get('accesstoken')

    print(
        f"Requesting with params - level_type: {level_type}, cost_type: {cost_type}, parent_account: {parent_account}, year: {year}, month: {month}, day: {day},")

    return ffd.readAmounts(level_type, cost_type, parent_account, year, month, day, _type, groupBy, headerAccesstoken)


@app.get("/api/ffd/preferences")
def readPreferences(request: Request):
    headerAccesstoken = request.headers.get('accesstoken')

    return ffd.readPreferences(headerAccesstoken)


@app.get("/api/ffd/accounts/{level_type}")
def accounts(level_type: int, request: Request):
    headerAccesstoken = request.headers.get('accesstoken')

    return ffd.readAccounts(level_type, headerAccesstoken)


@app.get("/api/ffd/costtypes/")
def readCosttypes(request: Request):

    headerAccesstoken = request.headers.get('accesstoken')

    return ffd.readCosttypes(headerAccesstoken)


@app.post("/api/ffd/")
async def send(request: Request, type: str = Form(default=None), amount: str = Form(default=None), actualcomment: str = Form(default=None), budgetcomment: str = Form(default=None), level1: str = Form(default=None), level2: str = Form(default=None), level3: str = Form(default=None), level1id: str = Form(default=None), level2id: str = Form(default=None), level3id: str = Form(default=None), costtype: str = Form(default=None), costtypeid: str = Form(default=None), date: str = Form(default=None), year: str = Form(default=None), month: str = Form(default=None), day: str = Form(default=None), timezoneOffsetMin: str = Form(default=None), timeInUtc: str = Form(default=None), costtypetoadd: str = Form(default=None), costtypetoaddcomment: str = Form(default=None), costtypetodeleteid: str = Form(default=None), costtypetodelete: str = Form(default=None), adminaccountlevel1id: str = Form(default=None), adminaccountlevel2id: str = Form(default=None), adminaccountlevel3id: str = Form(default=None), adminaccountlevel1: str = Form(default=None), adminaccountlevel2: str = Form(default=None), adminaccountlevel3: str = Form(default=None), accounttoaddlevel1: str = Form(default=None), accounttoaddlevel2: str = Form(default=None), accounttoaddlevel3: str = Form(default=None), accounttoaddlevel1comment: str = Form(default=None), accounttoaddlevel2comment: str = Form(default=None), accounttoaddlevel3comment: str = Form(default=None), accountfornewlevel2parentaccount: str = Form(default=None), accountfornewlevel3parentaccount: str = Form(default=None), arecosttypesactive: str = Form(default=None), areaccountsactive: str = Form(default=None), arelevel1accountsactive: str = Form(default=None), arelevel2accountsactive: str = Form(default=None), arelevel3accountsactive: str = Form(default=None), actlistitemtodelete: str = Form(default=None), bdglistitemtodelete: str = Form(default=None), scheduleYear: str = Form(default=None), scheduleMonth: str = Form(default=None), scheduleWeek: str = Form(default=None), scheduleDay: str = Form(default=None), schedulestrerval: str = Form(default=None), status: str = Form(default=None), mailFrontend: str = Form(default=None), group: str = Form(default=None), company: str = Form(default=None)):

    data = {
        'type': type,
        'amount': amount,
        'actualcomment': actualcomment,
        'budgetcomment': budgetcomment,
        'level1': level1,
        'level2': level2,
        'level3': level3,
        'level1id': level1id,
        'level2id': level2id,
        'level3id': level3id,
        'costtype': costtype,
        'costtypeid': costtypeid,
        'date': date,
        'year': year,
        'month': month,
        'day': day,
        'timezoneOffsetMin': timezoneOffsetMin,
        'timeInUtc': timeInUtc,
        'costtypetoadd': costtypetoadd,
        'costtypetoaddcomment': costtypetoaddcomment,
        'costtypetodeleteid': costtypetodeleteid,
        'costtypetodelete': costtypetodelete,
        'adminaccountlevel1id': adminaccountlevel1id,
        'adminaccountlevel2id': adminaccountlevel2id,
        'adminaccountlevel3id': adminaccountlevel3id,
        'adminaccountlevel1': adminaccountlevel1,
        'adminaccountlevel2': adminaccountlevel2,
        'adminaccountlevel3': adminaccountlevel3,
        'accounttoaddlevel1': accounttoaddlevel1,
        'accounttoaddlevel2': accounttoaddlevel2,
        'accounttoaddlevel3': accounttoaddlevel3,
        'accounttoaddlevel1comment': accounttoaddlevel1comment,
        'accounttoaddlevel2comment': accounttoaddlevel2comment,
        'accounttoaddlevel3comment': accounttoaddlevel3comment,
        'accountfornewlevel2parentaccount': accountfornewlevel2parentaccount,
        'accountfornewlevel3parentaccount': accountfornewlevel3parentaccount,
        'arecosttypesactive': arecosttypesactive,
        'areaccountsactive': areaccountsactive,
        'arelevel1accountsactive': arelevel1accountsactive,
        'arelevel2accountsactive': arelevel2accountsactive,
        'arelevel3accountsactive': arelevel3accountsactive,
        'actlistitemtodelete': actlistitemtodelete,
        'bdglistitemtodelete': bdglistitemtodelete,
        'scheduleYear': scheduleYear,
        'scheduleMonth': scheduleMonth,
        'scheduleWeek': scheduleWeek,
        'scheduleDay': scheduleDay,
        'schedulestrerval': schedulestrerval,
        'status': status,
        'mailFrontend': mailFrontend,
        'group': group,
        'company': company,
    }

    print('++++++++++++++')
    print(data)
    print('++++++++++++++')

    headerAccesstoken = request.headers.get('accesstoken')

    return ffd.send(headerAccesstoken, data)
