from datetime import datetime
import psycopg2
import psycopg2.extras
from flask import request
import json
from configparser import *
import logging

"""
from google.oauth2 import id_token
from google.auth.transport import requests
import google.auth 
"""
import firebase_admin
from firebase_admin import credentials
from firebase_admin import auth

_AUTH_ATTRIBUTE = '_auth'

config = ConfigParser()
config.read('config.ini')

logging.basicConfig(level=logging.DEBUG, format='%(asctime)s:%(levelname)s:%(message)s')

# Firebase app instance, needs to be declared globally as it may only be initialized once and if handled in def state is lost on next run
app = None

def get_timestamp():
    return datetime.now().strftime(("%Y-%m-%d %H:%M:%S"))

def validateDummyToken(token):

    try:
        global app

        logging.info(f"validating {token}")

        #cred = credentials.Certificate("../signindemoffdv2-firebase-adminsdk-gtlce-04508e9efc.json")
        
        
        # ONLY NEEDS TO BE DONE ONCE
        
        if(app is not None):
            logging.info(f"APP {app} already initialized")
        else:
            logging.info(f"initializing APP as it does not already exist")
            app = firebase_admin.initialize_app()
            logging.info(f"using {app}")


        decoded_token = auth.verify_id_token(token)
        uid = decoded_token['uid']


        logging.info(f"validated {uid}")

        return "validated"

    except ValueError as e:
        # Invalid token
        logging.critical(f"error {e}")

        return f"not validated {e}"
    except Exception as e:
        logging.critical(f"error {e}")
        return f"not validated v2 {e}"

def connect():
    try:

        connection = psycopg2.connect(user = config.get('db', 'user'),
                                      password = config.get('db', 'password'),
                                      host = config.get('db', 'host'),
                                      port = config.get('db', 'port'),
                                      database = config.get('db', 'database')
        )
        
        # Print PostgreSQL Connection properties
        cursor = connection.cursor()
        print(connection.get_dsn_parameters(),"\n")

        # Print PostgreSQL version
        cursor.execute("SELECT version();")
        record = cursor.fetchone()
        print("You are connected to - ", record,"\n")

        return connection

    except (Exception, psycopg2.Error) as error :
        print ("Error while connecting to PostgreSQL", error)

def readAccounts(level_type):
    """
    This function responds to a request for /api/ffd/level_type
    with the complete lists of accounts for the user

    :return:        list of accounts
    """

    # Declare an empty data object which will be filled with key value pairs, as psycogp2 only returns the values without keys
    data = []

    connection = connect()
    cursor = connection.cursor(cursor_factory = psycopg2.extras.DictCursor)

    query = f"select * from ffd.account_dim where level_type = {level_type} and active = 1 order by id asc"

    cursor.execute(query)
    record = cursor.fetchall()
    # fetch the column names from the cursror
    columnnames = [desc[0] for desc in cursor.description]

    # Create from the value array a key value object
    for row in record:
        cache = {}

        for columnname in columnnames:
            cache[columnname] = row[columnname]

        data.append(cache)
        
    cursor.close()
    connection.close()

    return data

def readPreferences(user):
    """
    This function responds to a request for /api/ffd/Preferences
    with the complete lists of Preferences for the user

    :return:        list of preferences
    """

    # Declare an empty data object which will be filled with key value pairs, as psycogp2 only returns the values without keys
    data = []

    connection = connect()
    cursor = connection.cursor(cursor_factory = psycopg2.extras.DictCursor)

    query = f"select user_fk, group_fk, company_fk \
                   , costtypes_active, accounts_active \
                   , accountsLevel1_active, accountsLevel2_active, accountsLevel3_active \
                    from ffd.preference_dim"

    cursor.execute(query)
    record = cursor.fetchall()
    # fetch the column names from the cursror
    columnnames = [desc[0] for desc in cursor.description]

    # Create from the value array a key value object
    for row in record:
        cache = {}

        for columnname in columnnames:
            cache[columnname] = row[columnname]

        data.append(cache)
        
    cursor.close()
    connection.close()

    return data

def readListActualBudget(_type, user):
    data = []
    query = f"select * from ffd.{'act' if _type == 'actual' else 'bdg'}_data where user_fk = {user} and data_date > date_trunc('month', CURRENT_DATE) - INTERVAL '1 year' order by data_date desc"

    connection = connect()
    cursor = connection.cursor(cursor_factory = psycopg2.extras.DictCursor)

    cursor.execute(query)
    record = cursor.fetchall()
    # fetch the column names from the cursror
    columnnames = [desc[0] for desc in cursor.description]

    # Create from the value array a key value object
    for row in record:
        cache = {}

        for columnname in columnnames:
            cache[columnname] = row[columnname]

        data.append(cache)
        
    cursor.close()
    connection.close()

    
    return data

def readAmounts(level_type, cost_type, parent_account, year, month, _type):
    
    """
    This function responds to a request for /api/ffd/amounts
    with the complete lists of amounts for the specified params

    :return:        list of accounts
    """

    # Used to concat the query depending on the parameters passed
    select_params = ''
    where_params = 'where active = 1'
    group_params = ''
    order_params = ''

    if(level_type == 1):
        select_params += ' select sum(amount), level1, level1_fk ' if len(select_params) <= 0 else ' , level1, level1_fk'
        group_params += ' group by level1, level1_fk ' if len(group_params) <= 0 else ' , level1, level1_fk'
        order_params += ' order by level1 ' if len(order_params) <= 0 else ' , level1'
    if(level_type == 2): 
        select_params += ' select sum(amount), level2, level2_fk ' if len(select_params) <= 0 else ' , level2, level2_fk'
        group_params += ' group by level2, level2_fk ' if len(group_params) <= 0 else ' , level2, level2_fk'
        order_params += ' order by level2 ' if len(order_params) <= 0 else ' , level2'
    if(level_type == 3):
        select_params += ' select sum(amount), level3, level3_fk ' if len(select_params) <= 0 else ' , level3, level3_fk '
        group_params += ' group by level3, level3_fk ' if len(group_params) <= 0 else ' , level3, level3_fk '
        order_params += ' order by level3 ' if len(order_params) <= 0 else ' , level3'

    if(cost_type > 0):
        select_params += ' select sum(amount), costtype, costtype_fk ' if len(select_params) <= 0 else ' , costtype, costtype_fk'
        where_params += f' where costtype_fk = {cost_type}' if len(where_params) <= 0 else f' and costtype_fk = {cost_type}'
        group_params += ' group by costtype, costtype_fk ' if len(group_params) <= 0 else ' , costtype, costtype_fk'
        order_params += ' order by costtype ' if len(order_params) <= 0 else ' , costtype'
    
    if(parent_account > 0):
        select_params += f' select sum(amount), level{level_type - 1}_fk  ' if len(select_params) <= 0 else f' , level{level_type - 1}_fk '
        where_params += f' where level{level_type - 1}_fk = {parent_account}' if len(where_params) <= 0 else f' and level{level_type - 1}_fk = {parent_account}'
        group_params += f' group by level{level_type - 1}_fk  ' if len(group_params) <= 0 else f' , level{level_type - 1}_fk '
        order_params += f' order by level{level_type - 1}_fk  ' if len(order_params) <= 0 else f' , level{level_type - 1}_fk '
    
    if(year > 0):
        select_params += ' select sum(amount), year ' if len(select_params) <= 0 else ' , year'
        where_params += f' where year = {year}' if len(where_params) <= 0 else f' and year = {year}'
        group_params += ' group by year ' if len(group_params) <= 0 else ' , year'
        order_params += ' order by year ' if len(order_params) <= 0 else ' , year'

    if(month > 0):
        select_params += ' select sum(amount), month ' if len(select_params) <= 0 else ' , month'
        where_params += f' where month = {month}' if len(where_params) <= 0 else f' and month = {month}'
        group_params += ' group by month ' if len(group_params) <= 0 else ' , month'
        order_params += ' order by month ' if len(order_params) <= 0 else ' , month'

    print(f"{select_params}{where_params}{group_params}{order_params}")

    # Declare an empty data object which will be filled with key value pairs, as psycogp2 only returns the values without keys
    data = []
    query = f"{select_params} from ffd.{'act' if _type == 'actual' else 'bdg'}_data {where_params}{group_params} order by sum desc"

    connection = connect()
    cursor = connection.cursor(cursor_factory = psycopg2.extras.DictCursor)

    cursor.execute(query)
    record = cursor.fetchall()
    # fetch the column names from the cursror
    columnnames = [desc[0] for desc in cursor.description]

    # Create from the value array a key value object
    for row in record:
        cache = {}

        for columnname in columnnames:
            cache[columnname] = row[columnname]

        data.append(cache)
        
    cursor.close()
    connection.close()

    
    return data

def readCosttypes():
    """
    This function responds to a request for /api/ffd/level_type
    with the complete lists of accounts for the user

    :return:        list of accounts
    """

    # Declare an empty data object which will be filled with key value pairs, as psycogp2 only returns the values without keys
    data = []

    connection = connect()
    cursor = connection.cursor(cursor_factory = psycopg2.extras.DictCursor)

    query = f"select * from ffd.costtype_dim where active = 1"

    cursor.execute(query)
    record = cursor.fetchall()
    # fetch the column names from the cursror
    columnnames = [desc[0] for desc in cursor.description]

    # Create from the value array a key value object
    for row in record:
        cache = {}

        for columnname in columnnames:
            cache[columnname] = row[columnname]

        data.append(cache)
        
    cursor.close()
    connection.close()

    return data
    #return dir(cursor)
    #return cursor.description

    # Create the list of people from our data
    #return [PEOPLE[key] for key in sorted(PEOPLE.keys())]

def send():
    """
    This function responds to a request for /api/ffd
    it is the entry point for all functionality
    This function reads the type of the call and assigns the correct function

    :return:        the body send, with the changed status
    """

    data = request.form.to_dict()


    if data['type'].lower() == 'actual':
        sendActual(data)
    elif data['type'].lower() == 'budget':
        sendBudget(data)
    elif data['type'].lower() == 'newcosttypedelete':
        deleteCostType(data)
    elif data['type'].lower() == 'newcosttypeadd':
        addCostType(data)
    elif data['type'].lower() == 'newaccountadd':
        data = addAccount(data)
    elif data['type'].lower() == 'newaccountdelete':
        deleteAccount(data)
    elif data['type'].lower() == 'generaladmin':
        savePreferences(data)
    elif data['type'].lower() == 'actlistdelete':
        deleteEntry('actual', data)
    elif data['type'].lower() == 'bsglistdelete':
        deleteEntry('budget', data)
    

    #data = request.values
    #print(f'RECEIVED DATA: {dir(request)}')
    data['status'] = 'success'
    return data

def sendActual(data):
    connection = connect()
    cursor = connection.cursor()
    command = f"INSERT INTO ffd.act_data (amount, comment, data_date, year, month, level1, level1_fk, level2, level2_fk, level3, level3_fk, costtype, costtype_fk, user_fk) \
                                  VALUES ({data['amount']}, '{data['actualcomment']}', '{data['date']}', {data['year']}, {data['month']}, '{data['level1']}', {data['level1id']}, '{data['level2']}', {data['level2id']}, '{data['level3']}', {data['level3id']} \
                                  , '{data['costtype']}', {data['costtypeid']}, {data['user']})"
    print(command)
    cursor.execute(command)
    connection.commit()
    cursor.close()
    connection.close()

def savePreferences(data):
    connection = connect()
    cursor = connection.cursor()
    command = f"insert into ffd.preference_dim (select {data['user']} as user, {data['group']} as group_fk, {data['company']} as company_fk, \
                                                       {data['arecosttypesactive']} costtypes_active, {data['areaccountsactive']} accounts_active, \
                                                       {data['arelevel1accountsactive']} accountslevel1_active, \
                                                       {data['arelevel2accountsactive']} accountslevel2_active, \
                                                       {data['arelevel3accountsactive']} accountslevel3_active) \
                ON CONFLICT (user_fk)  \
                do update set costtypes_active = EXCLUDED.costtypes_active , \
                              accounts_active = EXCLUDED.accounts_active, \
                              accountslevel1_active = EXCLUDED.accountslevel1_active, \
                              accountslevel2_active = EXCLUDED.accountslevel2_active, \
                              accountslevel3_active = EXCLUDED.accountslevel3_active "
                
    
    print(command)
    cursor.execute(command)
    connection.commit()
    cursor.close()
    connection.close()

def sendBudget(data):
    connection = connect()
    cursor = connection.cursor()
    command = f"INSERT INTO ffd.bdg_data (amount, comment, data_date, year, month, level1, level1_fk, level2, level2_fk, level3, level3_fk, costtype, costtype_fk, user_fk) \
                                  VALUES ({data['amount']}, '{data['budgetcomment']}', '{data['date']}', {data['year']}, {data['month']}, '{data['level1']}', {data['level1id']}, '{data['level2']}', {data['level2id']}, '{data['level3']}', {data['level3id']} \
                                  , '{data['costtype']}', {data['costtypeid']}, {data['user']})"
    print(command)
    cursor.execute(command)
    connection.commit()
    cursor.close()
    connection.close()

def deleteCostType(data):
    connection = connect()
    cursor = connection.cursor()
    command = f"update ffd.costtype_dim set active = 0 where id = {data['costtypetodeleteid']}"
    print(command)
    cursor.execute(command)
    connection.commit()
    cursor.close()
    connection.close()

def addCostType(data):
    connection = connect()
    cursor = connection.cursor()
    command = f"INSERT INTO ffd.costtype_dim (name, comment, user_fk, group_fk, company_fk) \
                                  VALUES ('{data['costtypetoadd'].upper()}', '{data['costtypetoaddcomment']}' \
                                  , {data['user']},  {data['group']},  {data['company']})"
    print(command)
    cursor.execute(command)
    connection.commit()
    cursor.close()
    connection.close()

def deleteAccount(data):
    connection = connect()
    cursor = connection.cursor()
    
    # Only delete the max account send, not if 1, 2 and 3 is sent, all three but only the 3
    # Same if one and two is sent, then only 2
    # And if only 1 is sent then the account level1
    accounttodelete = None

    if(int(data['adminaccountlevel1id']) >= 0 and int(data['adminaccountlevel2id']) >= 0 and int(data['adminaccountlevel3id']) >= 0):
        accounttodelete = data['adminaccountlevel3id']
    elif(int(data['adminaccountlevel1id']) >= 0 and int(data['adminaccountlevel2id']) >= 0):
        accounttodelete = data['adminaccountlevel2id']
    elif(int(data['adminaccountlevel1id']) >= 0):
        accounttodelete = data['adminaccountlevel1id']

    
    command = f"update ffd.account_dim set active = 0 where id = {accounttodelete}"
    print(command)
    
    cursor.execute(command)
    connection.commit()
    cursor.close()
    connection.close()

def addAccount(data):
    connection = connect()
    cursor = connection.cursor()
    
    # If a name for a new level1 aacount was sent, enter a new level1 account
    if(data['accounttoaddlevel1']):
        command = f"INSERT INTO ffd.account_dim (name, comment, level_type, parent_account, user_fk, group_fk, company_fk) \
                                  VALUES ('{data['accounttoaddlevel1'].upper()}', '{data['accounttoaddlevel1comment']}', 1, null \
                                  , {data['user']},  {data['group']},  {data['company']})"
        print(command)
        cursor.execute(command)
        connection.commit()

    # Check if a parent account for a new level2 was sent and a level2 account name, if yes create a new level2 account
    if(int(data['accountfornewlevel2parentaccount']) > 0 and data['accounttoaddlevel2']):
        command = f"INSERT INTO ffd.account_dim (name, comment, level_type, parent_account, user_fk, group_fk, company_fk) \
                                  VALUES ('{data['accounttoaddlevel2'].upper()}', '{data['accounttoaddlevel2comment']}', 2, {data['accountfornewlevel2parentaccount']} \
                                  , {data['user']},  {data['group']},  {data['company']})"
        print(command)
        cursor.execute(command)
        connection.commit()

    # If no parent account for the new level2 was sent but a name for a new level 2 account and also a name for the level1 parent account
    elif(int(data['accountfornewlevel2parentaccount']) < 0 and data['accounttoaddlevel2'] and data['accounttoaddlevel1']):
        # Check if a name for a level1 was sent, get the id of that and set this account as the parent
        query = f"select id from ffd.account_dim where level_type = 1 and name = '{data['accounttoaddlevel1'].upper()}'"
        
        cursor.execute(query)
        record = cursor.fetchall()
        command = f"INSERT INTO ffd.account_dim (name, comment, level_type, parent_account, user_fk, group_fk, company_fk) \
                                  VALUES ('{data['accounttoaddlevel2'].upper()}', '{data['accounttoaddlevel2comment']}', 2, {record[0][0]} \
                                  , {data['user']},  {data['group']},  {data['company']})"
        print(command)
        cursor.execute(command)
        connection.commit()
        
    
    # Check if a parent account for a new level3 was sent and a level3 account name, if yes create a new level3 account with the matching parent account
    if(int(data['accountfornewlevel3parentaccount']) > 0 and data['accounttoaddlevel3']):
        command = f"INSERT INTO ffd.account_dim (name, comment, level_type, parent_account, user_fk, group_fk, company_fk) \
                                  VALUES ('{data['accounttoaddlevel3'].upper()}', '{data['accounttoaddlevel3comment']}', 3, {data['accountfornewlevel3parentaccount']} \
                                  , {data['user']},  {data['group']},  {data['company']})"
        print(command)
        cursor.execute(command)
        connection.commit()

    # If no parent account for the new level3 was sent but a name for a new level 3 account and also a name for the level2 parent account
    elif(int(data['accountfornewlevel3parentaccount']) < 0 and data['accounttoaddlevel3'] and data['accounttoaddlevel2']):
        # Check if a name for a level1 was sent, get the id of that and set this account as the parent
        query = f"select id from ffd.account_dim where level_type = 2 and name = '{data['accounttoaddlevel2'].upper()}'"
        
        cursor.execute(query)
        record = cursor.fetchall()
        command = f"INSERT INTO ffd.account_dim (name, comment, level_type, parent_account, user_fk, group_fk, company_fk) \
                                  VALUES ('{data['accounttoaddlevel3'].upper()}', '{data['accounttoaddlevel3comment']}', 3, {record[0][0]} \
                                  , {data['user']},  {data['group']},  {data['company']})"
        print(command)
        cursor.execute(command)
        connection.commit()
    cursor.close()
    connection.close()

    return data

def deleteEntry(type, data):
    connection = connect()
    cursor = connection.cursor()

    command = f"update ffd.{'act' if type == 'actual' else 'bdg'}_data set active = case when active = 1 then 0 else 1 end where id = {data['actlistitemtodelete'] if type == 'actual' else data['bdglistitemtodelete']}"
    
    print(command)
    cursor.execute(command)
    connection.commit()
    cursor.close()
    connection.close()
    
    return data