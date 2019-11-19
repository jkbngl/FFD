from datetime import datetime
import psycopg2


def get_timestamp():
    return datetime.now().strftime(("%Y-%m-%d %H:%M:%S"))

# Data to serve with our API
PEOPLE = {
    "Farrell": {
        "fname": "Doug",
        "lname": "Farrell",
        "timestamp": get_timestamp()
    },
    "Brockman": {
        "fname": "Kent",
        "lname": "Brockman",
        "timestamp": get_timestamp()
    },
    "Easter": {
        "fname": "Bunny",
        "lname": "Easter",
        "timestamp": get_timestamp()
    }
}

def connect():
    try:
        connection = psycopg2.connect(user = <user>,
                                      password = <password>,
                                      host = "192.168.0.20",
                                      port = "5432",
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
    #finally:
    #    #closing database connection.
    #        if(connection):
    #            cursor.close()
    #            connection.close()
    #            print("PostgreSQL connection is closed")

# Create a handler for our read (GET) people
def read():
    """
    This function responds to a request for /api/people
    with the complete lists of people

    :return:        sorted list of people
    """
    connection = connect()
    cursor = connection.cursor()

    postgreSQL_select_Query = "select * from tp_plan"
    cursor.execute(postgreSQL_select_Query)
    mobile_records = cursor.fetchall() 

    return mobile_records

    # Create the list of people from our data
    #return [PEOPLE[key] for key in sorted(PEOPLE.keys())]
