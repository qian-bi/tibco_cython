
from tibemsMsg cimport ctibco


cdef extern from "Python.h":
    ctypedef enum PyGILState_STATE:
        pass
    PyGILState_STATE PyGILState_Ensure()
    void PyGILState_Release(PyGILState_STATE)


cdef void callback(ctibco.tibemsMsgConsumer msgConsumer, ctibco.tibemsMsg msg, void* closure):
    cdef:
        const char* txt
        PyGILState_STATE state
    ctibco.tibemsTextMsg_GetText(msg, &txt)
    state = PyGILState_Ensure()
    func = <object>closure
    try:
        func(txt.decode())
    except Exception as e:
        print('Listener callback error:', e, 'receive:', txt.encode())
    PyGILState_Release(state)


cdef class EmsSession:

    cdef:
        ctibco.tibemsErrorContext errorContext
        ctibco.tibemsConnectionFactory factory
        ctibco.tibemsConnection connection
        ctibco.tibemsSession session
        ctibco.tibems_status status
        const char* txt
        char* msgTypeName
        int debug
        dict msgTypeMap
        str msg

        public:
            int connected

    def __cinit__(self, str serverUrl='', str userName='', str password='', int debug=0):
        self.debug = debug
        self.errorContext = NULL
        self.factory = NULL
        self.connection = NULL
        self.session = NULL
        self.status = ctibco.TIBEMS_OK
        self.msgTypeMap = {
            'BYTES': ctibco.TIBEMS_BYTES_MESSAGE,
            'MAP': ctibco.TIBEMS_MAP_MESSAGE,
            'OBJECT': ctibco.TIBEMS_OBJECT_MESSAGE,
            'STREAM': ctibco.TIBEMS_STREAM_MESSAGE,
            'TEXT': ctibco.TIBEMS_TEXT_MESSAGE,
        }
        if serverUrl != '':
            self._create(serverUrl.encode(), userName.encode(), password.encode())

    def __dealloc__(self):
        self._close()

    def create(self, str serverUrl, str userName, str password):
        self._create(serverUrl.encode(), userName.encode(), password.encode())

    def close(self):
        self._close()

    def producer(self, str dest, str data, int useTopic=1, str msgType='TEXT', str name=''):
        self._check_conn()
        self._producer(dest.encode(), useTopic, data.encode(), self.msgTypeMap[msgType.upper()], name.encode())

    def consumer(self, str dest, int useTopic=1, int timeout=120):
        self._check_conn()
        self._consumer(dest.encode(), useTopic, timeout * 1000)
        return self.msg

    def requester(self, str dest, str data, int useTopic=1):
        self._check_conn()
        self._requester(dest.encode(), useTopic, data.encode())
        return self.msg

    def listener(self, str dest, object func, int useTopic=1):
        self._check_conn()
        self._listener(dest.encode(), useTopic, <ctibco.tibemsMsgCallback>callback, <void *>func)

    def subscriber(self, str topic, str name, str selector='', int timeout=120):
        self._check_conn()
        self._subscriber(topic.encode(), name.encode(), selector.encode(), timeout * 1000)
        return self.msg

    def shared_consumer(self, str topic, str name, str selector='', int timeout=120):
        self._check_conn()
        self._shared_consumer(topic.encode(), name.encode(), selector.encode(), timeout * 1000)
        return self.msg

    def shared_subscriber(self, str topic, str name, str selector='', int timeout=120):
        self._check_conn()
        self._shared_subscriber(topic.encode(), name.encode(), selector.encode(), timeout * 1000)
        return self.msg

    def unsubscribe(self, str name):
        self._check_conn()
        self._unsubscribe(name.encode())

    cdef int _check_status(self, int error=0, char* msg=NULL) except ? -1:
        cdef:
            const char* errMsg
            const char* errTraceback
            const char* status_text
        if error or self.status != ctibco.TIBEMS_OK:
            status_text = ctibco.tibemsStatus_GetText(self.status)
            self.status = ctibco.tibemsErrorContext_GetLastErrorString(self.errorContext, &errMsg)
            self.status = ctibco.tibemsErrorContext_GetLastErrorStackTrace(self.errorContext, &errTraceback)
            raise TibcoError(status_text.decode(), msg.decode() if msg != NULL else errMsg.decode(), errTraceback.decode())
        return 0

    cdef int _check_conn(self) except ? -1:
        if self.connected != 1:
            raise TibcoError('Not Connected.')

    cdef void _getMsgTypeName(self, ctibco.tibemsMsgType msgType):
        if msgType == ctibco.TIBEMS_MESSAGE:
            self.msgTypeName = 'MESSAGE'
        elif msgType == ctibco.TIBEMS_BYTES_MESSAGE:
            self.msgTypeName = 'BYTES'
        elif msgType == ctibco.TIBEMS_OBJECT_MESSAGE:
            self.msgTypeName = 'OBJECT'
        elif msgType == ctibco.TIBEMS_STREAM_MESSAGE:
            self.msgTypeName = 'STREAM'
        elif msgType == ctibco.TIBEMS_MAP_MESSAGE:
            self.msgTypeName = 'MAP'
        elif msgType == ctibco.TIBEMS_TEXT_MESSAGE:
            self.msgTypeName = 'TEXT'
        else:
            self.msgTypeName = 'UNKNOWN'

    cdef int _create(self, char* serverUrl, char* userName, char* password) except ? -1:
        self.status = ctibco.tibemsErrorContext_Create(&self.errorContext)
        self._check_status()
        self.factory = ctibco.tibemsConnectionFactory_Create()
        if self.factory == NULL:
            self._check_status(1)
        self.status = ctibco.tibemsConnectionFactory_SetServerURL(self.factory, serverUrl)
        self._check_status()
        self.status = ctibco.tibemsConnectionFactory_CreateConnection(self.factory, &self.connection, userName, password)
        self._check_status()
        self.status = ctibco.tibemsConnection_CreateSession(self.connection, &self.session, ctibco.TIBEMS_FALSE, ctibco.TIBEMS_AUTO_ACKNOWLEDGE)
        self._check_status()
        self.connected = 1
        return 0

    cdef int _close(self) except ? -1:
        if self.session != NULL:
            self.status = ctibco.tibemsSession_Close(self.session)
            self._check_status()
            self.session = NULL
        if self.connection != NULL:
            self.status = ctibco.tibemsConnection_Close(self.connection)
            self._check_status()
            self.connection = NULL
        if self.factory != NULL:
            self.status = ctibco.tibemsConnectionFactory_Destroy(self.factory)
            self._check_status()
            self.factory = NULL
        if self.errorContext != NULL:
            self.status = ctibco.tibemsErrorContext_Close(self.errorContext)
            self.errorContext = NULL
        self.connected = 0
        return 0

    cdef int _create_dest(self, ctibco.tibemsDestination* destination, char* dest, int useTopic) except ? -1:
        if useTopic != 0:
            self.status = ctibco.tibemsDestination_Create(destination, ctibco.TIBEMS_TOPIC, dest)
        else:
            self.status = ctibco.tibemsDestination_Create(destination, ctibco.TIBEMS_QUEUE, dest)
        self._check_status()
        return 0

    cdef int _destroy_dest(self, ctibco.tibemsDestination destination) except ? -1:
        self.status = ctibco.tibemsDestination_Destroy(destination)
        self._check_status()
        return 0

    cdef int _get_msg(self, ctibco.tibemsMsg msg) except ? -1:
        cdef:
            ctibco.tibemsMsgType msgType
            ctibco.tibemsMsgEnum enumeration
            const char* name
        if self.debug != 0:
            ctibco.tibemsMsg_Print(msg)
        self.status = ctibco.tibemsMsg_GetBodyType(msg, &msgType)
        self._check_status()
        if msgType == ctibco.TIBEMS_TEXT_MESSAGE:
            self.status = ctibco.tibemsTextMsg_GetText(msg, &self.txt)
            self._check_status()
        elif msgType == ctibco.TIBEMS_MAP_MESSAGE:
            self.status = ctibco.tibemsMapMsg_GetMapNames(msg, &enumeration)
            self._check_status()
            self.status = ctibco.tibemsMsgEnum_GetNextName(enumeration, &name)
            self._check_status()
            self.status = ctibco.tibemsMapMsg_GetString(msg, name, &self.txt)
            self._check_status()
            self.status = ctibco.tibemsMsgEnum_Destroy(enumeration)
            self._check_status()
        else:
            self._getMsgTypeName(msgType)
            self._check_status(1, self.msgTypeName)
        self.msg = self.txt.decode()
        return 0

    cdef int _producer(self, char* dest, int useTopic, char* data, ctibco.tibemsMsgType msgType, char* name) except ? -1:
        cdef:
            ctibco.tibemsDestination destination
            ctibco.tibemsMsgProducer msgProducer
            ctibco.tibemsMsg msg
        self._create_dest(&destination, dest, useTopic)
        self.status = ctibco.tibemsSession_CreateProducer(self.session, &msgProducer, destination)
        self._check_status()
        if msgType == ctibco.TIBEMS_TEXT_MESSAGE:
            self.status = ctibco.tibemsTextMsg_Create(&msg)
            self._check_status()
            self.status = ctibco.tibemsTextMsg_SetText(msg, data)
            self._check_status()
        elif msgType == ctibco.TIBEMS_MAP_MESSAGE:
            self.status = ctibco.tibemsMapMsg_Create(&msg)
            self._check_status()
            self.status = ctibco.tibemsMapMsg_SetString(msg, name, data)
            self._check_status()
        if self.debug != 0:
            ctibco.tibemsMsg_Print(msg)
        self.status = ctibco.tibemsMsgProducer_Send(msgProducer, msg)
        self._check_status()
        self.status = ctibco.tibemsMsg_Destroy(msg)
        self._check_status()
        self.status = ctibco.tibemsMsgProducer_Close(msgProducer)
        self._check_status()
        self._destroy_dest(destination)
        return 0

    cdef int _consumer(self, char* dest, int useTopic, int timeout) except ? -1:
        cdef:
            ctibco.tibemsDestination destination
            ctibco.tibemsMsgConsumer msgConsumer
            ctibco.tibemsMsg msg
        self._create_dest(&destination, dest, useTopic)
        self.status = ctibco.tibemsSession_CreateConsumer(self.session, &msgConsumer, destination, NULL, ctibco.TIBEMS_FALSE)
        self._check_status()
        self.status = ctibco.tibemsConnection_Start(self.connection)
        self._check_status()
        self.status = ctibco.tibemsMsgConsumer_ReceiveTimeout(msgConsumer, &msg, timeout)
        self._check_status()
        self._get_msg(msg)
        self.status = ctibco.tibemsMsg_Destroy(msg)
        self._check_status()
        self.status = ctibco.tibemsMsgConsumer_Close(msgConsumer)
        self._check_status()
        self._destroy_dest(destination)
        return 0

    cdef int _requester(self, char* dest, int useTopic, char* data) except ? -1:
        cdef:
            ctibco.tibemsDestination destination
            ctibco.tibemsMsgRequestor msgRequestor
            ctibco.tibemsMsg msg
            ctibco.tibemsMsg reply
        self._create_dest(&destination, dest, useTopic)
        self.status = ctibco.tibemsMsgRequestor_Create(self.session, &msgRequestor, destination)
        self._check_status()
        self.status = ctibco.tibemsTextMsg_Create(&msg)
        self._check_status()
        self.status = ctibco.tibemsTextMsg_SetText(msg, data)
        self._check_status()
        if self.debug != 0:
            ctibco.tibemsMsg_Print(msg)
        self.status = ctibco.tibemsMsgRequestor_Request(msgRequestor, msg, &reply)
        self._check_status()
        self.status = ctibco.tibemsConnection_Start(self.connection)
        self._check_status()
        self._get_msg(reply)
        self.status = ctibco.tibemsMsg_Destroy(msg)
        self._check_status()
        self.status = ctibco.tibemsMsg_Destroy(reply)
        self._check_status()
        self.status = ctibco.tibemsMsgRequestor_Close(msgRequestor)
        self._check_status()
        self._destroy_dest(destination)
        return 0

    cdef int _listener(self, char* dest, int useTopic, ctibco.tibemsMsgCallback callback, void* closure) except ? -1:
        cdef:
            ctibco.tibemsDestination destination
            ctibco.tibemsMsgConsumer msgConsumer
            ctibco.tibemsMsg msg
        self._create_dest(&destination, dest, useTopic)
        self.status = ctibco.tibemsSession_CreateConsumer(self.session, &msgConsumer, destination, NULL, ctibco.TIBEMS_FALSE)
        self._check_status()
        self.status = ctibco.tibemsMsgConsumer_SetMsgListener(msgConsumer, callback, closure)
        self._check_status()
        self.status = ctibco.tibemsConnection_Start(self.connection)
        self._check_status()
        return 0

    cdef int _unsubscribe(self, char* name) except ? -1:
        self.status = ctibco.tibemsSession_Unsubscribe(self.session, name)
        self._check_status()
        return 0

    cdef int _subscriber(self, char* topic, char* name, char* selector, int timeout) except ? -1:
        cdef:
            ctibco.tibemsDestination destination
            ctibco.tibemsMsgConsumer msgConsumer
            ctibco.tibemsMsg msg
        self._create_dest(&destination, topic, 1)
        self.status = ctibco.tibemsSession_CreateDurableSubscriber(self.session, &msgConsumer, destination, name, selector, ctibco.TIBEMS_FALSE)
        self._check_status()
        self.status = ctibco.tibemsConnection_Start(self.connection)
        self._check_status()
        self.status = ctibco.tibemsMsgConsumer_ReceiveTimeout(msgConsumer, &msg, timeout)
        self._check_status()
        self._get_msg(msg)
        self.status = ctibco.tibemsMsg_Destroy(msg)
        self._check_status()
        self.status = ctibco.tibemsMsgConsumer_Close(msgConsumer)
        self._check_status()
        self._destroy_dest(destination)
        return 0

    cdef int _shared_consumer(self, char* topic, char* name, char* selector, int timeout) except ? -1:
        cdef:
            ctibco.tibemsDestination destination
            ctibco.tibemsMsgConsumer msgConsumer
            ctibco.tibemsMsg msg
        self._create_dest(&destination, topic, 1)
        self.status = ctibco.tibemsSession_CreateSharedConsumer(self.session, &msgConsumer, destination, name, selector)
        self._check_status()
        self.status = ctibco.tibemsConnection_Start(self.connection)
        self._check_status()
        self.status = ctibco.tibemsMsgConsumer_ReceiveTimeout(msgConsumer, &msg, timeout)
        self._check_status()
        self._get_msg(msg)
        self.status = ctibco.tibemsMsg_Destroy(msg)
        self._check_status()
        self.status = ctibco.tibemsMsgConsumer_Close(msgConsumer)
        self._check_status()
        self._destroy_dest(destination)
        return 0

    cdef int _shared_subscriber(self, char* topic, char* name, char* selector, int timeout) except ? -1:
        cdef:
            ctibco.tibemsDestination destination
            ctibco.tibemsMsgConsumer msgConsumer
            ctibco.tibemsMsg msg
        self._create_dest(&destination, topic, 1)
        self.status = ctibco.tibemsSession_CreateSharedDurableConsumer(self.session, &msgConsumer, destination, name, selector)
        self._check_status()
        self.status = ctibco.tibemsConnection_Start(self.connection)
        self._check_status()
        self.status = ctibco.tibemsMsgConsumer_ReceiveTimeout(msgConsumer, &msg, timeout)
        self._check_status()
        self._get_msg(msg)
        self.status = ctibco.tibemsMsg_Destroy(msg)
        self._check_status()
        self.status = ctibco.tibemsMsgConsumer_Close(msgConsumer)
        self._check_status()
        self._destroy_dest(destination)
        return 0


class TibcoError(Exception):

    def __init__(self, status, msg='', tb=''):
        self.status = status
        self.msg = msg
        self.tb = tb

    def __str__(self):
        return '{}\n{}\n{}'.format(self.status, self.msg, self.tb)
