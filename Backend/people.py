from datetime import datetime
import psycopg2
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
def read():
    """
    This function responds to a request for /api/people
    with the complete lists of people

    :return:        sorted list of people
    """
    connection = connect()
    cursor = connection.cursor()

    postgreSQL_select_Query = "select * from ffd.costtype_dim"
    cursor.execute(postgreSQL_select_Query)
    mobile_records = cursor.fetchall() 
    cursor.close()
    connection.close()

    return mobile_records

    # Create the list of people from our data
    #return [PEOPLE[key] for key in sorted(PEOPLE.keys())]

def send():
    data2 = request.form.to_dict()

    #data = request.values
    #data = json.loads(data)
    #print(type(data))
    #print(f'RECEIVED DATA: {dir(request)}')
    connection = connect()
    cursor = connection.cursor()
    command = f"INSERT INTO ffd.costtype_dim (id, name) VALUES (1, {data2['actual']})"
    print(command)
    cursor.execute(command)
    connection.commit()
    data2['color'] = 'green'
    return data2

