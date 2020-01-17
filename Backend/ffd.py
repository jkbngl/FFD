from datetime import datetime
import psycopg2
import psycopg2.extras
from flask import request
import json
from configparser import *

config = ConfigParser()
config.read('config.ini')

print(config.get('db', 'user'))

def get_timestamp():
    return datetime.now().strftime(("%Y-%m-%d %H:%M:%S"))

def connect():
    try:
        connection = psycopg2.connect(user = config.get('db', 'user'),
                                      password = "dhjihdfjdksfhdfhsdfj",
                                      host = "192.168.0.21",
                                      port = "5433",
                                      database = "postgres")
        
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

    query = f"select * from ffd.account_dim where level_type = {level_type} order by id asc"

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

    :return:        None
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
        

    #data = request.values
    #print(f'RECEIVED DATA: {dir(request)}')
    data['status'] = 'success'
    return data

def sendActual(data):
    connection = connect()
    cursor = connection.cursor()
    command = f"INSERT INTO ffd.act_data (amount, data_date, year, month, level1, level1_fk, level2, level2_fk, level3, level3_fk, costtype, costtype_fk, user_fk) \
                                  VALUES ({data['amount']}, '{data['date']}', {data['year']}, {data['month']}, '{data['level1']}', {data['level1id']}, '{data['level2']}', {data['level2id']}, '{data['level3']}', {data['level3id']} \
                                  , '{data['costtype']}', {data['costtypeid']}, {data['user']})"
    print(command)
    cursor.execute(command)
    connection.commit()
    cursor.close()
    connection.close()

def sendBudget(data):
    connection = connect()
    cursor = connection.cursor()
    command = f"INSERT INTO ffd.bdg_data (amount, data_date, year, month, level1, level1_fk, level2, level2_fk, level3, level3_fk, costtype, costtype_fk, user_fk) \
                                  VALUES ({data['amount']}, '{data['date']}', {data['year']}, {data['month']}, '{data['level1']}', {data['level1id']}, '{data['level2']}', {data['level2id']}, '{data['level3']}', {data['level3id']} \
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
    command = f"INSERT INTO ffd.costtype_dim (name, comment, user_fk) \
                                  VALUES ('{data['costtypetoadd'].upper()}', '{data['costtypetoaddcomment']}', {data['user']})"
    print(command)
    cursor.execute(command)
    connection.commit()
    cursor.close()
    connection.close()
