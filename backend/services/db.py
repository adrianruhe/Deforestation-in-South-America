import psycopg2
from werkzeug.exceptions import HTTPException


class DBManager():
    __database = None
    __user = None
    __password = None
    __host = None
    __port = None

    __connection = None

    def __init__(self, database, user, password, host="127.0.0.1", port=5432) -> None:
        self.__database = database
        self.__user = user
        self.__password = password
        self.__host = host
        self.__port = port

        self.__connect()

    def __connect(self) -> None:
        try:
            self.__connection = psycopg2.connect(
                host=self.__host,
                port=self.__port,
                dbname=self.__database,
                user=self.__user,
                password=self.__password)
            self.__connection.set_session(autocommit=True)
            print("connected to database")
        except psycopg2.OperationalError as e:
            print(e)


    def __disconnect(self) -> None:
 
        if self.__connection is None or self.__connection.closed != 0:
            return

        self.__connection.close()
        print("connection to database closed")


    def execute_query(self, query):
        if self.__connection is None or self.__connection.closed != 0:
            self.__connect()

        if self.__connection is None:
            raise HTTPException(status_code=503, detail="No connection to database")

        cur = self.__connection.cursor()
        cur.execute(query)

        result = cur.fetchall()
        cur.close()

        return result

