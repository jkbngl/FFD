from datetime import datetime
from datetime import timedelta
import psycopg2
import psycopg2.extras
from flask import request
import json
from configparser import *
import logging
import pytz
import firebase_admin
from firebase_admin import credentials
from firebase_admin import auth
from dateutil.relativedelta import relativedelta

config = ConfigParser()
config.read('config.ini')

logging.basicConfig(level=logging.INFO, format='%(asctime)s:%(levelname)s:%(message)s')

# Firebase app instance, needs to be declared globally as it may only be initialized once and if handled in def state is lost on next run
app = None


# 69
def to_utc(timestamp, timezone):
    local = pytz.timezone (timezone)
    naive = datetime.datetime.strptime (timestamp, "%Y-%m-%d %H:%M:%S")
    local_dt = local.localize(naive, is_dst=None)
    
    return local_dt.astimezone(pytz.utc)


def get_timestamp():
    return datetime.now().strftime(("%Y-%m-%d %H:%M:%S"))

def validate(header):
    
    headerMail, code = validateToken(header)

    if(code == 403):
        logging.error("ACCESS FORBIDDEN")
        return "ACCESS FORBIDDEN", 403, "ERROR: ACCESS FORBIDDEN"

    return getIdByMail(headerMail), headerMail, None


def validateToken(token):

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

        logging.info(f"{decoded_token}")

        return decoded_token, 200

    except ValueError as e:
        # Invalid token
        logging.critical(f"error {e}")

        return f"not validated {e}", 403
    except Exception as e:
        logging.critical(f"error {e}")
        return f"not validated v2 {e}", 403

def getIdByMail(mail):
    data = []

    connection = connect()
    cursor = connection.cursor(cursor_factory = psycopg2.extras.DictCursor)

    cursor.execute('select id from ffd.user_dim where mail =  %s', (mail['email'],))

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

    return data[0]['id'] if len(data) > 0 else -1


def getAccessRights(data):
    pass

def connect():
    try:
        connection = psycopg2.connect(user = config.get('db', 'user'),
                                      password = config.get('db', 'password'),
                                      host = config.get('db', 'host'),
                                      port = config.get('db', 'port'),
                                      database = config.get('db', 'database')
        )
        
        cursor = connection.cursor()
        
        # Log PostgreSQL Connection properties
        logging.debug(connection.get_dsn_parameters())

        # Get PostgreSQL version
        cursor.execute("SELECT version();")
        record = cursor.fetchone()
        logging.debug(f"You are connected to - {record}\n")

        return connection

    except (Exception, psycopg2.Error) as error :
        logging.critical(f"Error while connecting to PostgreSQL {error}")

def userExists():
    
    headerAccesstoken = request.headers.get('accesstoken')
    userId, mail, errorMessage = validate(headerAccesstoken)

    if(userId < 0):
        connection = connect()
        cursor = connection.cursor()

        cursor.execute("INSERT INTO ffd.user_dim (name, mail) VALUES (%s, %s)", (mail['name'].upper(), mail['email'],))
        connection.commit()

        cursor.close()
        connection.close()

        chartOfAccountCreated = createDefaultChartOfAccount(getIdByMail(mail))
        chartOfCostTypesCreated = createDefaultChartOfCostTypes(getIdByMail(mail))

        return {'created': True, 'mail': mail['email'], 'id': getIdByMail(mail), 'name': mail['name'], 'chartOfAccountCreated': chartOfAccountCreated, 'chartOfCostTypesCreated': chartOfCostTypesCreated}
    else:
        return {'created': False, 'mail': mail['email'], 'id': getIdByMail(mail), 'name': mail['name']}


def createDefaultChartOfAccount(userId):
    connection = connect()
    cursor = connection.cursor()

    cursor.execute("INSERT INTO ffd.costtype_dim (name, comment, user_fk) VALUES ('VARIABLE', 'variable costs like eating out once a week', %s);", (userId,))
    cursor.execute("INSERT INTO ffd.costtype_dim (name, comment, user_fk) VALUES ('FIX', 'fix costs like rent', %s);", (userId,))

    connection.commit()
    cursor.close()
    connection.close()
    return False

def createDefaultChartOfCostTypes(userId):
        connection = connect()
        cursor = connection.cursor()

        # CAR
        cursor.execute("INSERT INTO   ffd.account_dim (name, comment, level_type, parent_account, user_fk) VALUES   ('CAR', 'all car related costs', 1, null, %s) RETURNING id;", (userId,))
        parent_account_id = cursor.fetchone()[0]
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('GAS', 'all gas costs for the car', 2, %s, %s) RETURNING id;", (parent_account_id, userId,))
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('INSURANCE', 'all insurcance costs for the car', 2, %s, %s) RETURNING id;", (parent_account_id, userId,))
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('TAX', 'all tac costs for the car', 2, %s, %s) RETURNING id;", (parent_account_id, userId,))
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('TIRES', 'all costs for tires for the car', 2, %s, %s) RETURNING id;", (parent_account_id, userId,))
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('OTHER', 'other car related costs', 2, %s, %s) RETURNING id;", (parent_account_id, userId,))
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('REPAIRS', 'all car related repair costs', 2, %s, %s) RETURNING id;", (parent_account_id, userId,))
        parent_account_id = cursor.fetchone()[0]
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('MOTOR', 'all motor repairs costs for the car', 3, %s, %s) RETURNING id;", (parent_account_id, userId,))
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('BREAKS', 'all breaks repairs costs for the car', 3, %s, %s) RETURNING id;", (parent_account_id, userId,))
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('WINDOWS','all windows repairs costs for the car', 3, %s, %s) RETURNING id;", (parent_account_id, userId,))
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('OTHER','all other repairs costs for the car', 3, %s, %s) RETURNING id;", (parent_account_id, userId,))

        # CLOTHES
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('CLOTHES', 'all clothes related costs', 1, null, %s) RETURNING id;", (userId,))
        parent_account_id = cursor.fetchone()[0]
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('SHOES', 'all costs for shoes', 2, %s, %s) RETURNING id;", (parent_account_id, userId,))
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('SHIRTS', 'all costs for shoes', 2, %s, %s) RETURNING id;", (parent_account_id, userId,))
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('TROUSERS', 'all costs for trousers', 2, %s, %s) RETURNING id;", (parent_account_id, userId,))
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('HOODIES', 'all costs for hoodies', 2, %s, %s) RETURNING id;", (parent_account_id, userId,))
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('CAPS', 'all costs for caps', 2, %s, %s) RETURNING id;", (parent_account_id, userId,))
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('OTHER', 'all other clothes related costs', 2, %s, %s) RETURNING id;", (parent_account_id, userId,))

        # CLOTHES
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('EATING OUT', 'all costs related to eating out', 1, null, %s) RETURNING id;", (userId,))
        parent_account_id = cursor.fetchone()[0]
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('PIZZA', 'all costs for eating out when eating pizza', 2, %s, %s) RETURNING id;", (parent_account_id, userId,))
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('BURGER', 'all costs for eating out when eating burger', 2, %s, %s) RETURNING id;", (parent_account_id, userId,))
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('HEALTHY', 'all costs for eating out when eating healthy', 2, %s, %s) RETURNING id;", (parent_account_id, userId,))
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('OTHER', 'all costs for eating out when eating other stuff', 2, %s, %s) RETURNING id;", (parent_account_id, userId,))

        # GROCERIES
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('GROCERIES', 'all costs related to groceries', 1, null, %s) RETURNING id;", (userId,))
        parent_account_id = cursor.fetchone()[0]
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('FOR FAM', 'all costs for groceries for the family', 2, %s, %s) RETURNING id;", (parent_account_id, userId,))
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('FOR ME', 'all costs for groceries for myself', 2, %s, %s) RETURNING id;", (parent_account_id, userId,))
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('OTHER', 'all other groceries related costs', 2, %s, %s) RETURNING id;", (parent_account_id, userId,))

        # PHONE
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('PHONE', 'all phone related costs', 1, null, %s) RETURNING id;", (userId,))
        parent_account_id = cursor.fetchone()[0]
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('CONTRACT', 'all phone costs for contracts', 2, %s, %s) RETURNING id;", (parent_account_id, userId,))
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('NEW PHONE', 'all costs for new phones', 2, %s, %s) RETURNING id;", (parent_account_id, userId,))
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('ACCESSOIRES', 'all costs for accessoires of the phone, like covers', 2, %s, %s) RETURNING id;", (parent_account_id, userId,))
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('OTHER', 'all other phone related costs', 2, %s, %s) RETURNING id;", (parent_account_id, userId,))

        # PRESENTS
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('PRESENTS', 'all costs for presents', 1, null, %s) RETURNING id;", (userId,))
        parent_account_id = cursor.fetchone()[0]
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('FOR MAM', 'all costs for presents for mam', 2, %s, %s) RETURNING id;", (parent_account_id, userId,))
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('FOR DAD', 'all costs for presents for dad', 2, %s, %s) RETURNING id;", (parent_account_id, userId,))
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('FOR GF', 'all costs for presents for gf', 2, %s, %s) RETURNING id;", (parent_account_id, userId,))
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('FOR FRIENDS', 'all costs for presents for friends', 2, %s, %s) RETURNING id;", (parent_account_id, userId,))
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('OTHER', 'all presents for other people', 2, %s, %s) RETURNING id;", (parent_account_id, userId,))

        # TRAVEL
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('TRAVEL', 'all travel related costs', 1, null, %s) RETURNING id;", (userId,))
        parent_account_id = cursor.fetchone()[0]
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('HOTEL', 'all hotel related costs', 2, %s, %s) RETURNING id;", (parent_account_id, userId,))
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('FLIGHTS', 'all flight related costs', 2, %s, %s) RETURNING id;", (parent_account_id, userId,))
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('EXCURSIONS', 'all excursions related costs', 2, %s, %s) RETURNING id;", (parent_account_id, userId,))
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('OTHER', 'all other related costs for travels', 2, %s, %s) RETURNING id;", (parent_account_id, userId,))

        # PUBLIC TRANSPORTATION
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('PUBLIC TRANSPORTATION', 'all public transportations related costs', 1, null, %s) RETURNING id;", (userId,))
        parent_account_id = cursor.fetchone()[0]
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('TRAIN', 'all train related costs', 2, %s, %s) RETURNING id;", (parent_account_id, userId,))
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('BUS', 'all bus related costs', 2, %s, %s) RETURNING id;", (parent_account_id, userId,))
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('CABLE CAR', 'all cable car related costs', 2, %s, %s) RETURNING id;", (parent_account_id, userId,))
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('CAR', 'cost for e.g. carsharing', 2, %s, %s) RETURNING id;", (parent_account_id, userId,))
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('SUBURBAN', 'all suburban related costs', 2, %s, %s) RETURNING id;", (parent_account_id, userId,))
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('OTHER', 'all other public transportations related costs', 2, %s, %s) RETURNING id;", (parent_account_id, userId,))
        
        # OTHER
        cursor.execute("INSERT INTO ffd.account_dim (name,   comment, level_type, parent_account, user_fk) VALUES ('OTHER', 'all other   costs', 1, null, %s) RETURNING id;", (userId,))


        connection.commit()
        cursor.close()
        connection.close()

        return True
        
        
def readAccounts(level_type):
    """
    This function responds to a request for /api/ffd/level_type
    with the complete lists of accounts for the user

    :return:        list of accounts
    """

    headerAccesstoken = request.headers.get('accesstoken')
    userId, mail, errorMessage = validate(headerAccesstoken)

    # Mail is ACCESS FORBIDDEN in this case
    if(errorMessage is not None):
        return mail, 403

    # Declare an empty data object which will be filled with key value pairs, as psycogp2 only returns the values without keys
    data = []

    connection = connect()
    cursor = connection.cursor(cursor_factory = psycopg2.extras.DictCursor)

    cursor.execute('select * from ffd.account_dim acc where level_type = %s and active = 1 and user_fk =  %s order by name asc', (level_type, userId,))

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

def readPreferences():
    """
    This function responds to a request for /api/ffd/Preferences
    with the complete lists of Preferences for the user

    :return:        list of preferences

    http://192.168.0.21:5000/api/ffd/preferences?user=1
    """

    headerAccesstoken = request.headers.get('accesstoken')
    userId, mail, errorMessage = validate(headerAccesstoken)

    # Mail is ACCESS FORBIDDEN in this case
    if(errorMessage is not None):
        return mail, 403

    # Declare an empty data object which will be filled with key value pairs, as psycogp2 only returns the values without keys
    data = []

    connection = connect()
    cursor = connection.cursor(cursor_factory = psycopg2.extras.DictCursor)


    cursor.execute("select user_fk, group_fk, company_fk \
                          , costtypes_active, accounts_active \
                          , accountsLevel1_active, accountsLevel2_active, accountsLevel3_active \
                     from ffd.preference_dim \
                     where  user_fk = %s", (userId,))

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

def readListActualBudget(_type, sort, sortType):
    """
    This function responds to a request for /api/ffd/Preferences
    with the complete lists of Preferences for the user

    :return:        list of preferences

    http://192.168.0.21:5000/api/ffd/list/?_type=budget

    """

    headerAccesstoken = request.headers.get('accesstoken')
    userId, mail, errorMessage = validate(headerAccesstoken)

    # Mail is ACCESS FORBIDDEN in this case
    if(errorMessage is not None):
        return mail, 403

    data = []

    connection = connect()
    cursor = connection.cursor(cursor_factory = psycopg2.extras.DictCursor)
    
    if _type == 'actual':
        
        cursor.execute("select  *\
                        from    ffd.act_data \
                        where   data_date > date_trunc('month', CURRENT_DATE) - INTERVAL '1 year' \
                        and     user_fk = %s order by %s %s" % (userId, sort, sortType,)) # % instead of komma because of the sort column
    elif _type == 'budget':
        cursor.execute("select  *\
                        from    ffd.bdg_data \
                        where   data_date > date_trunc('month', CURRENT_DATE) - INTERVAL '1 year' \
                        and     user_fk = %s order by %s %s" % (userId, sort, sortType,))

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
    This function responds to a request for /api/ffd/amounts/?level_type=2&cost_type=-99&parent_account=3&year=2020&month=2&_type=actual
    with the complete lists of amounts for the specified params

    :return:        list of accounts

    Examples:
    http://192.168.0.21:5000/api/ffd/amounts/?level_type=2&cost_type=-99&parent_account=3&year=2020&month=2&_type=actual
    http://192.168.0.21:5000/api/ffd/amounts/?level_type=3&cost_type=-99&parent_account=-100&year=2020&month=2&_type=actual
    http://192.168.0.21:5000/api/ffd/amounts/?level_type=1&cost_type=-99&parent_account=-69&year=2020&month=2&_type=actual
    http://192.168.0.21:5000/api/ffd/amounts/?level_type=1&cost_type=-99&parent_account=-69&year=2020&month=2&_type=actual
    
    """

    headerAccesstoken = request.headers.get('accesstoken')
    userId, mail, errorMessage = validate(headerAccesstoken)

    #85 check to prohibit SQL injections, as the query is dynamically build and can not be done in the normal way - not relly needed as its already declaere in the swagger, just to be sure
    if type(level_type) == int and type(cost_type) == int and type(parent_account) == int and type(year) == int and type(month) == int and (_type == 'actual' or _type == 'budget'):
        pass
    else:
        return mail, 404

    # Mail is ACCESS FORBIDDEN in this case
    if(errorMessage is not None):
        return mail, 403

    

    # Used to concat the query depending on the parameters passed
    select_params = ''
    where_params = f'where active = 1 and user_fk = {userId} '
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

    logging.info(f"{select_params}{where_params}{group_params}{order_params}")

    # Declare an empty data object which will be filled with key value pairs, as psycogp2 only returns the values without keys
    data = []

    connection = connect()
    cursor = connection.cursor(cursor_factory = psycopg2.extras.DictCursor)

    cursor.execute(f"{select_params} from ffd.{'act' if _type == 'actual' else 'bdg'}_data {where_params}{group_params} order by sum desc")

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

    headerAccesstoken = request.headers.get('accesstoken')
    userId, mail, errorMessage = validate(headerAccesstoken)

    # Mail is ACCESS FORBIDDEN in this case
    if(errorMessage is not None):
        return mail, 403

    # Declare an empty data object which will be filled with key value pairs, as psycogp2 only returns the values without keys
    data = []

    connection = connect()
    cursor = connection.cursor(cursor_factory = psycopg2.extras.DictCursor)

    cursor.execute('select * from ffd.costtype_dim where active = 1 and user_fk =  %s', (userId,))

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
    
    headerAccesstoken = request.headers.get('accesstoken')
    userId, mail, errorMessage = validate(headerAccesstoken)

    # Mail is ACCESS FORBIDDEN in this case
    if(errorMessage is not None):
        return mail, 403

    if data['type'].lower() == 'actual':
        sendActual(data, userId)
    elif data['type'].lower() == 'budget':
        sendBudget(data, userId)
    elif data['type'].lower() == 'newcosttypedelete':
        deleteCostType(data, userId)
    elif data['type'].lower() == 'newcosttypeadd':
        addCostType(data, userId)
    elif data['type'].lower() == 'newaccountadd':
        data = addAccount(data, userId)
    elif data['type'].lower() == 'newaccountdelete':
        deleteAccount(data, userId)
    elif data['type'].lower() == 'generaladmin':
        savePreferences(data, userId)
    elif data['type'].lower() == 'actlistdelete':
        deleteEntry('actual', data, userId)
    elif data['type'].lower() == 'actualschedule':
        sendSchedule(data, userId)
    elif data['type'].lower() == 'budgetschedule':
        sendSchedule(data, userId)
    

    data['status'] = 'success'
    return data

def getTimeZoneFromOffset(minutes):
    utc_offset = timedelta(hours=minutes/60, minutes=minutes%60)
    
    now = datetime.now(pytz.utc) # current time

    return {now.astimezone(tz).tzname() for tz in map(pytz.timezone, pytz.all_timezones_set) if now.astimezone(tz).utcoffset() == utc_offset}


def sendActual(data, userId):
    connection = connect()
    cursor = connection.cursor()

    utcTime = datetime.now() + timedelta(minutes=int(data['timezoneOffsetMin']))

    cursor.execute("INSERT INTO ffd.act_data (amount, comment, data_date, year, month, level1, level1_fk, level2, level2_fk, level3, level3_fk, costtype, costtype_fk, user_fk, created) \
                                  VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)", 
                                                                                        ( data['amount']
                                                                                        , data['actualcomment']
                                                                                        , data['date']
                                                                                        , data['year']
                                                                                        , data['month']
                                                                                        , data['level1']
                                                                                        , data['level1id']
                                                                                        , data['level2']
                                                                                        , data['level2id']
                                                                                        , data['level3']
                                                                                        , data['level3id']
                                                                                        , data['costtype']
                                                                                        , data['costtypeid']
                                                                                        , userId
                                                                                        , data['timeInUtc']
                                                                                        ,))

    connection.commit()
    cursor.close()
    connection.close()

def sendSchedule(data, userId):

    amountOfSchedules = int(data['scheduleInterval']) + 1

    # 2020-04-15 00:00:00.000

    

    # Cache the data as the baseData as we are changing the data, we wont change the baseDate and the other functions dont use the baseData attribute
    data['baseDate'] = data['date']

    
    for i in range(1, amountOfSchedules):

        datetimeObj = datetime.strptime(data['baseDate'], '%Y-%m-%d %H:%M:%S.%f')

        if(data['scheduleYear'] == 'true'):
            logging.critical('scheduleYear')
            deltaDate = datetimeObj + relativedelta(years=i)
        elif(data['scheduleMonth'] == 'true'):
            logging.critical('scheduleMonth')
            deltaDate = datetimeObj + relativedelta(months=i)
        elif(data['scheduleWeek'] == 'true'):
            logging.critical('scheduleWeek')
            deltaDate = datetimeObj + relativedelta(weeks=i)
        elif(data['scheduleDay'] == 'true'):
            logging.critical('scheduleDay')
            deltaDate = datetimeObj + relativedelta(days=i)

        data['date'] = str(deltaDate)
        data['year'] = str(deltaDate.year)
        data['month'] = str(deltaDate.month)
    
    
        logging.critical(data['date'])
        logging.critical(data['year'])
        logging.critical(data['month'])
        
        # Add a SCHEDULE to the end of the comment to make sure that people understand that it was auto scheduled, only the first time though
        if(data['type'] == 'actualschedule' and i == 1):
            data['actualcomment'] += ' - SCHEDULED'
            sendActual(data, userId)
        elif(data['type'] == 'budgetschedule' and i == 1):
            data['budgetcomment'] += ' - SCHEDULED'
            sendBudget(data, userId)

    for i in range(0, amountOfSchedules):
        pass
        #sendActual()



def savePreferences(data, userId):
    connection = connect()
    cursor = connection.cursor()
    
    cursor.execute("insert into ffd.preference_dim (select    %s as user \
                                                            , %s as group_fk \
                                                            , %s as company_fk \
                                                            , %s costtypes_active \
                                                            , %s accounts_active \
                                                            , %s accountslevel1_active \
                                                            , %s accountslevel2_active \
                                                            , %s accountslevel3_active) \
            ON CONFLICT (user_fk)  \
            do update set costtypes_active = EXCLUDED.costtypes_active , \
                          accounts_active = EXCLUDED.accounts_active, \
                          accountslevel1_active = EXCLUDED.accountslevel1_active, \
                          accountslevel2_active = EXCLUDED.accountslevel2_active, \
                          accountslevel3_active = EXCLUDED.accountslevel3_active, \
                          updated = case when   ffd.preference_dim.costtypes_active        != EXCLUDED.costtypes_active or \
                                                ffd.preference_dim.accounts_active         != EXCLUDED.accounts_active or \
                                                ffd.preference_dim.accountslevel1_active   != EXCLUDED.accountslevel1_active or \
                                                ffd.preference_dim.accountslevel2_active   != EXCLUDED.accountslevel2_active or \
                                                ffd.preference_dim.accountslevel3_active   != EXCLUDED.accountslevel3_active then now() else ffd.preference_dim.updated end ", # Only update when something changed
                                                                                        ( userId
                                                                                        , data['group']
                                                                                        , data['company']
                                                                                        , data['arecosttypesactive']
                                                                                        , data['areaccountsactive']
                                                                                        , data['arelevel1accountsactive']
                                                                                        , data['arelevel2accountsactive']
                                                                                        , data['arelevel3accountsactive']
                                                                                        ,))

    connection.commit()
    cursor.close()
    connection.close()

def sendBudget(data, userId):
    connection = connect()
    cursor = connection.cursor()
   
    cursor.execute("INSERT INTO ffd.bdg_data (amount, comment, data_date, year, month, level1, level1_fk, level2, level2_fk, level3, level3_fk, costtype, costtype_fk, user_fk, created) \
                                  VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)", 
                                                                                        ( data['amount']
                                                                                        , data['budgetcomment']
                                                                                        , data['date']
                                                                                        , data['year']
                                                                                        , data['month']
                                                                                        , data['level1']
                                                                                        , data['level1id']
                                                                                        , data['level2']
                                                                                        , data['level2id']
                                                                                        , data['level3']
                                                                                        , data['level3id']
                                                                                        , data['costtype']
                                                                                        , data['costtypeid']
                                                                                        , userId
                                                                                        , data['timeInUtc']
                                                                                        ,))
    connection.commit()
    cursor.close()
    connection.close()

def deleteCostType(data, userId):
    connection = connect()
    cursor = connection.cursor()

    cursor.execute("update ffd.costtype_dim set active = 0,  updated = now() where id = %s and user_fk = %s", 
                                                                                                              (   data['costtypetodeleteid']
                                                                                                                , userId
                                                                                                                ,))

    connection.commit()

    cursor.close()
    connection.close()

def addCostType(data, userId):
    connection = connect()
    cursor = connection.cursor()

    cursor.execute("INSERT INTO ffd.costtype_dim (name, comment, user_fk, group_fk, company_fk, created) \
                              VALUES (%s, %s , %s,  %s,  %s, %s)",( data['costtypetoadd'].upper()
                                                                  , data['costtypetoaddcomment']
                                                                  , userId
                                                                  , data['group']
                                                                  , data['company']
                                                                  , data['timeInUtc']
                                                                  ,))
    
    connection.commit()
    cursor.close()
    connection.close()

def deleteAccount(data, userId):
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

    
    cursor.execute("update ffd.account_dim set active = 0, updated = now() where id = %s and user_fk = %s",( accounttodelete, userId,))
    connection.commit()
    
    cursor.close()
    connection.close()

def addAccount(data, userId):
    connection = connect()
    cursor = connection.cursor()
    
    # If a name for a new level1 aacount was sent, enter a new level1 account
    if(data['accounttoaddlevel1']):

        cursor.execute("INSERT INTO ffd.account_dim (name, comment, level_type, parent_account, user_fk, group_fk, company_fk, created) \
                                  VALUES (%s, %s, 1, null , %s,  %s,  %s, %s)",(  data['accounttoaddlevel1'].upper()
                                                                            , data['accounttoaddlevel1comment']
                                                                            , userId
                                                                            , data['group']
                                                                            , data['company']
                                                                            , data['timeInUtc']
                                                                            ,))
        connection.commit()

    # Check if a parent account for a new level2 was sent and a level2 account name, if yes create a new level2 account
    if(int(data['accountfornewlevel2parentaccount']) > 0 and data['accounttoaddlevel2']):

        cursor.execute("INSERT INTO ffd.account_dim (name, comment, level_type, parent_account, user_fk, group_fk, company_fk, created) \
                                  VALUES (%s, %s, 2, %s, %s, %s, %s, %s)",(    data['accounttoaddlevel2'].upper()
                                                                        , data['accounttoaddlevel2comment']
                                                                        , data['accountfornewlevel2parentaccount']
                                                                        , userId
                                                                        , data['group']
                                                                        , data['company']
                                                                        , data['timeInUtc']

                                                                        ,))
        connection.commit()

    # If no parent account for the new level2 was sent but a name for a new level 2 account and also a name for the level1 parent account
    elif(int(data['accountfornewlevel2parentaccount']) < 0 and data['accounttoaddlevel2'] and data['accounttoaddlevel1']):
        
        # Check if a name for a level1 was sent, get the id of that and set this account as the parent       
        cursor.execute("select id from ffd.account_dim where level_type = 1 and name = %s", (data['accounttoaddlevel1'].upper(),))
        record = cursor.fetchall()

        cursor.execute("INSERT INTO ffd.account_dim (name, comment, level_type, parent_account, user_fk, group_fk, company_fk, created) \
                                  VALUES (%s, %s, 2, %s, %s, %s, %s, %s)",(   data['accounttoaddlevel2'].upper()
                                                                        , data['accounttoaddlevel2comment']
                                                                        , record[0][0]
                                                                        , userId
                                                                        , data['group']
                                                                        , data['company']
                                                                        , data['timeInUtc']
                                                                        ,))
        connection.commit()
        
    
    # Check if a parent account for a new level3 was sent and a level3 account name, if yes create a new level3 account with the matching parent account
    if(int(data['accountfornewlevel3parentaccount']) > 0 and data['accounttoaddlevel3']):
        
        cursor.execute("INSERT INTO ffd.account_dim (name, comment, level_type, parent_account, user_fk, group_fk, company_fk, created) \
                                  VALUES (%s, %s, 3, %s, %s, %s, %s, %s)",(   data['accounttoaddlevel3'].upper()
                                                                        , data['accounttoaddlevel3comment']
                                                                        , data['accountfornewlevel3parentaccount']
                                                                        , userId
                                                                        , data['group']
                                                                        , data['company']
                                                                        , data['timeInUtc']
                                                                        ,))
        connection.commit()

    # If no parent account for the new level3 was sent but a name for a new level 3 account and also a name for the level2 parent account
    elif(int(data['accountfornewlevel3parentaccount']) < 0 and data['accounttoaddlevel3'] and data['accounttoaddlevel2']):

        # Check if a name for a level1 was sent, get the id of that and set this account as the parent
        cursor.execute("select id from ffd.account_dim where level_type = 2 and name = %s", (data['accounttoaddlevel2'].upper(),))
        record = cursor.fetchall()

        cursor.execute("INSERT INTO ffd.account_dim (name, comment, level_type, parent_account, user_fk, group_fk, company_fk, created) \
                                  VALUES (%s, %s, 3, %s, %s, %s,  %s, %s)",(  data['accounttoaddlevel3'].upper()
                                                                        , data['accounttoaddlevel3comment']
                                                                        , record[0][0]
                                                                        , userId
                                                                        , data['group']
                                                                        , data['company']
                                                                        , data['timeInUtc']
                                                                        ,))
        connection.commit()

    cursor.close()
    connection.close()

    return data

def deleteEntry(type, data, userId):
    connection = connect()
    cursor = connection.cursor()

    if type == 'actual':
        cursor.execute("update ffd.act_data \
                        set active = case when active = 1 then 0 else 1 end, \
                        updated = now() \
                        where id = %s \
                        and user_fk = %s",(   data['actlistitemtodelete']
                                            , userId
                                            ,))
    elif type == 'budget':
        cursor.execute("update ffd.bdg_data \
                        set active = case when active = 1 then 0 else 1 end, \
                        updated = now() \
                        where id = %s \
                        and user_fk = %s",(   data['bdglistitemtodelete']
                                            , userId
                                            ,))
    connection.commit()

    cursor.close()
    connection.close()
    
    return data