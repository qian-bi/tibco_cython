
from tibemsMsg cimport ctibco


cdef class EmsSession:

    cdef:
        ctibco.tibemsErrorContext errorContext
        ctibco.tibemsConnectionFactory factory
        ctibco.tibemsConnection connection
        ctibco.tibemsSession session
        ctibco.tibemsDestination destination
        ctibco.tibems_status status
        const char* errMsg
        const char* errTraceback
        const char* txt
        int debug

    def __cinit__(self, str serverUrl='', str userName='', str password='', int debug=0):
        self.debug = debug
        self.errorContext = NULL
        self.factory = NULL
        self.connection = NULL
        self.session = NULL
        self.destination = NULL
        self.status = ctibco.TIBEMS_OK
        if serverUrl:
            self.create(serverUrl, userName, password)

    def __dealloc__(self):
        self._close()

    def create(self, str serverUrl, str userName, str password):
        self._create(serverUrl.encode(), userName.encode(), password.encode())

    def close(self):
        self._close()

    def producer(self, str name, str data, int useTopic=1):
        self._producer(name.encode(), useTopic, data.encode())

    def consumer(self, str name, int useTopic=1, int timeout=10):
        self._consumer(name.encode(), useTopic, timeout * 1000)
        return self.txt.decode()

    def requester(self, str name, str data, int useTopic=1):
        self._requester(name.encode(), useTopic, data.encode())
        return self.txt.decode()

    cdef int _check_status(self, int error=0) except ? -1:
        cdef const char* status_text
        if self.status != ctibco.TIBEMS_OK or error:
            status_text = ctibco.tibemsStatus_GetText(self.status)
            self.status = ctibco.tibemsErrorContext_GetLastErrorString(self.errorContext, &self.errMsg)
            self.status = ctibco.tibemsErrorContext_GetLastErrorStackTrace(self.errorContext, &self.errTraceback)
            raise TibcoError(status_text.decode(), self.errMsg.decode(), self.errTraceback.decode())
        return 0

    cdef int _create(self, char* serverUrl, char* userName, char* password) except ? -1:
        self.status = ctibco.tibemsErrorContext_Create(&self.errorContext)
        if self.status != ctibco.TIBEMS_OK:
            raise TibcoError(ctibco.tibemsStatus_GetText(self.status))
        self.factory = ctibco.tibemsConnectionFactory_Create()
        if self.factory == NULL:
            self._check_status(1)
        self.status = ctibco.tibemsConnectionFactory_SetServerURL(self.factory, serverUrl)
        self._check_status()
        self.status = ctibco.tibemsConnectionFactory_CreateConnection(self.factory, &self.connection, userName, password)
        self._check_status()
        self.status = ctibco.tibemsConnection_CreateSession(self.connection, &self.session, ctibco.TIBEMS_FALSE, ctibco.TIBEMS_AUTO_ACKNOWLEDGE)
        self._check_status()
        return 0

    cdef int _close(self) except ? -1:
        if self.destination != NULL:
            self.status = ctibco.tibemsDestination_Destroy(self.destination)
            self._check_status()
            self.destination = NULL
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
        return 0

    cdef int _create_dest(self, char* name, int useTopic) except ? -1:
        if useTopic:
            self.status = ctibco.tibemsTopic_Create(&self.destination, name)
        else:
            self.status = ctibco.tibemsQueue_Create(&self.destination, name)
        self._check_status()
        return 0

    cdef int _destroy_dest(self) except ? -1:
        if self.destination != NULL:
            self.status = ctibco.tibemsDestination_Destroy(self.destination)
            self._check_status()
            self.destination = NULL
        return 0

    cdef int _producer(self, char* name, int useTopic, char* data) except ? -1:
        cdef:
            ctibco.tibemsMsgProducer msgProducer
            ctibco.tibemsMsg msg
        self._create_dest(name, useTopic)
        self.status = ctibco.tibemsSession_CreateProducer(self.session, &msgProducer, self.destination)
        self._check_status()
        self.status = ctibco.tibemsTextMsg_Create(&msg)
        self._check_status()
        self.status = ctibco.tibemsTextMsg_SetText(msg, data)
        self._check_status()
        if self.debug:
            ctibco.tibemsMsg_Print(msg)
        self.status = ctibco.tibemsMsgProducer_Send(msgProducer, msg)
        self._check_status()
        self.status = ctibco.tibemsMsg_Destroy(msg)
        self._check_status()
        self.status = ctibco.tibemsMsgProducer_Close(msgProducer)
        self._check_status()
        self._destroy_dest()
        return 0

    cdef int _consumer(self, char* name, int useTopic, int timeout) except ? -1:
        cdef:
            ctibco.tibemsMsgConsumer msgConsumer
            ctibco.tibemsMsg msg
            ctibco.tibemsMsgType msgType
        self._create_dest(name, useTopic)
        self.status = ctibco.tibemsSession_CreateConsumer(self.session, &msgConsumer, self.destination, NULL, ctibco.TIBEMS_FALSE)
        self._check_status()
        self.status = ctibco.tibemsConnection_Start(self.connection)
        self._check_status()
        self.status = ctibco.tibemsMsgConsumer_ReceiveTimeout(msgConsumer, &msg, timeout)
        self._check_status()
        if self.debug:
            ctibco.tibemsMsg_Print(msg)
        self.status = ctibco.tibemsMsg_GetBodyType(msg, &msgType)
        self._check_status()
        if msgType == ctibco.TIBEMS_TEXT_MESSAGE:
            self.status = ctibco.tibemsTextMsg_GetText(msg, &self.txt)
            self._check_status()
        else:
            raise TibcoError('Message Type: %s' % msgType)
        self.status = ctibco.tibemsMsg_Destroy(msg)
        self._check_status()
        self.status = ctibco.tibemsMsgConsumer_Close(msgConsumer)
        self._check_status()
        self._destroy_dest()
        return 0

    cdef int _requester(self, char* name, int useTopic, char* data) except ? -1:
        cdef:
            ctibco.tibemsMsgRequestor msgRequestor
            ctibco.tibemsMsg msg
            ctibco.tibemsMsg reply
            ctibco.tibemsMsgType replyType
        self._create_dest(name, useTopic)
        self.status = ctibco.tibemsMsgRequestor_Create(self.session, &msgRequestor, self.destination)
        self._check_status()
        self.status = ctibco.tibemsTextMsg_Create(&msg)
        self._check_status()
        self.status = ctibco.tibemsTextMsg_SetText(msg, data)
        self._check_status()
        if self.debug:
            ctibco.tibemsMsg_Print(msg)
        self.status = ctibco.tibemsMsgRequestor_Request(msgRequestor, msg, &reply)
        self._check_status()
        if self.debug:
            ctibco.tibemsMsg_Print(reply)
        self.status = ctibco.tibemsMsg_GetBodyType(reply, &replyType)
        self._check_status()
        if replyType == ctibco.TIBEMS_TEXT_MESSAGE:
            self.status = ctibco.tibemsTextMsg_GetText(reply, &self.txt)
            self._check_status()
        else:
            raise TibcoError('Message Type: %s' % replyType)
        self.status = ctibco.tibemsMsg_Destroy(msg)
        self._check_status()
        self.status = ctibco.tibemsMsg_Destroy(reply)
        self._check_status()
        self.status = ctibco.tibemsMsgRequestor_Close(msgRequestor)
        self._check_status()
        self._destroy_dest()
        return 0


class TibcoError(Exception):

    def __init__(self, status, msg=None, tb=None):
        self.status = status
        self.msg = msg
        self.tb = tb

    def __str__(self):
        return '%s\n%s\n%s' % (self.status, self.msg or '', self.tb or '')
