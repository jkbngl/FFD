from datetime import datetime
import psycopg2
import psycopg2.extras
from flask import request
import json


def get_timestamp():
    return datetime.now().strftime(("%Y-%m-%d %H:%M:%S"))

def connect():
    try:
        connection = psycopg2.connect(user = "postgres",
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

# Create a handler for our read (GET) people
def read(level_type):
    """
    This function responds to a request for /api/ffd/level_type
    with the complete lists of accounts for the user

    :return:        list of accounts
    """
    data = []

    connection = connect()
    cursor = connection.cursor(cursor_factory = psycopg2.extras.DictCursor)


    query = f"select  * from    ffd.account_dim where   level_type = {level_type}"

    cursor.execute(query)
    record = cursor.fetchall()
    columnnames = [desc[0] for desc in cursor.description]


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
        send_actual(data)
        

    #data = request.values
    #print(f'RECEIVED DATA: {dir(request)}')
    data['status'] = 'success'
    return data

def send_actual(data):
    connection = connect()
    cursor = connection.cursor()
    command = f"INSERT INTO ffd.act_data (amount) VALUES (1, {data['actual']})"
    print(command)
    cursor.execute(command)
    connection.commit()


