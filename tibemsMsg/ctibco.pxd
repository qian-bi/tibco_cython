cdef extern from "../include/tibems/tibems.h":
    ctypedef int tibems_int;
    ctypedef long long tibems_long
    ctypedef unsigned int tibems_uint

    cdef struct __tibemsMsg:
        pass

    cdef struct __tibemsMsgEnum:
        pass

    ctypedef void* tibemsConnectionFactory
    ctypedef void* tibemsConnection
    ctypedef void* tibemsSession
    ctypedef void* tibemsDestination
    ctypedef void* tibemsTopic
    ctypedef void* tibemsQueue
    ctypedef void* tibemsMsgProducer
    ctypedef void* tibemsMsgConsumer
    ctypedef void* tibemsMsgRequestor
    ctypedef void* tibemsErrorContext

    ctypedef enum tibems_status:
        TIBEMS_OK = 0
        TIBEMS_ILLEGAL_STATE = 1
        TIBEMS_INVALID_CLIENT_ID = 2
        TIBEMS_INVALID_DESTINATION = 3
        TIBEMS_INVALID_SELECTOR = 4
        TIBEMS_EXCEPTION = 5
        TIBEMS_SECURITY_EXCEPTION = 6
        TIBEMS_MSG_EOF = 7
        TIBEMS_MSG_NOT_READABLE = 9
        TIBEMS_MSG_NOT_WRITEABLE = 10
        TIBEMS_SERVER_NOT_CONNECTED = 11
        TIBEMS_VERSION_MISMATCH = 12
        TIBEMS_SUBJECT_COLLISION = 13
        TIBEMS_INVALID_PROTOCOL = 15
        TIBEMS_INVALID_HOSTNAME = 17
        TIBEMS_INVALID_PORT = 18
        TIBEMS_NO_MEMORY = 19
        TIBEMS_INVALID_ARG = 20
        TIBEMS_SERVER_LIMIT = 21
        TIBEMS_MSG_DUPLICATE = 22
        TIBEMS_SERVER_DISCONNECTED = 23
        TIBEMS_SERVER_RECONNECTING = 24
        TIBEMS_NOT_PERMITTED = 27
        TIBEMS_SERVER_RECONNECTED = 28
        TIBEMS_INVALID_NAME = 30
        TIBEMS_INVALID_TYPE = 31
        TIBEMS_INVALID_SIZE = 32
        TIBEMS_INVALID_COUNT = 33
        TIBEMS_NOT_FOUND = 35
        TIBEMS_ID_IN_USE = 36
        TIBEMS_ID_CONFLICT = 37
        TIBEMS_CONVERSION_FAILED = 38
        TIBEMS_INVALID_MSG = 42
        TIBEMS_INVALID_FIELD = 43
        TIBEMS_INVALID_INSTANCE = 44
        TIBEMS_CORRUPT_MSG = 45
        TIBEMS_PRODUCER_FAILED = 47
        TIBEMS_TIMEOUT = 50
        TIBEMS_INTR = 51
        TIBEMS_DESTINATION_LIMIT_EXCEEDED = 52
        TIBEMS_MEM_LIMIT_EXCEEDED = 53
        TIBEMS_USER_INTR = 54
        TIBEMS_INVALID_QUEUE_GROUP = 63
        TIBEMS_INVALID_TIME_INTERVAL = 64
        TIBEMS_INVALID_IO_SOURCE = 65
        TIBEMS_INVALID_IO_CONDITION = 66
        TIBEMS_SOCKET_LIMIT = 67
        TIBEMS_OS_ERROR = 68
        TIBEMS_WOULD_BLOCK = 69
        TIBEMS_INSUFFICIENT_BUFFER = 70
        TIBEMS_EOF = 71
        TIBEMS_INVALID_FILE = 72
        TIBEMS_FILE_NOT_FOUND = 73
        TIBEMS_IO_FAILED = 74
        TIBEMS_NOT_FILE_OWNER = 80
        TIBEMS_ALREADY_EXISTS = 91
        TIBEMS_INVALID_CONNECTION = 100
        TIBEMS_INVALID_SESSION = 101
        TIBEMS_INVALID_CONSUMER = 102
        TIBEMS_INVALID_PRODUCER = 103
        TIBEMS_INVALID_USER = 104
        TIBEMS_INVALID_GROUP = 105
        TIBEMS_TRANSACTION_FAILED = 106
        TIBEMS_TRANSACTION_ROLLBACK = 107
        TIBEMS_TRANSACTION_RETRY = 108
        TIBEMS_INVALID_XARESOURCE = 109
        TIBEMS_FT_SERVER_LACKS_TRANSACTION = 110
        TIBEMS_LDAP_ERROR = 120
        TIBEMS_INVALID_PROXY_USER = 121
        TIBEMS_INVALID_CERT = 150
        TIBEMS_INVALID_CERT_NOT_YET = 151
        TIBEMS_INVALID_CERT_EXPIRED = 152
        TIBEMS_INVALID_CERT_DATA = 153
        TIBEMS_ALGORITHM_ERROR = 154
        TIBEMS_SSL_ERROR = 155
        TIBEMS_INVALID_PRIVATE_KEY = 156
        TIBEMS_INVALID_ENCODING = 157
        TIBEMS_NOT_ENOUGH_RANDOM = 158
        TIBEMS_INVALID_CRL_DATA = 159
        TIBEMS_CRL_OFF = 160
        TIBEMS_EMPTY_CRL = 161
        TIBEMS_NOT_INITIALIZED = 200
        TIBEMS_INIT_FAILURE = 201
        TIBEMS_ARG_CONFLICT = 202
        TIBEMS_SERVICE_NOT_FOUND = 210
        TIBEMS_INVALID_CALLBACK = 211
        TIBEMS_INVALID_QUEUE = 212
        TIBEMS_INVALID_EVENT = 213
        TIBEMS_INVALID_SUBJECT = 214
        TIBEMS_INVALID_DISPATCHER = 215
        TIBEMS_JNI_EXCEPTION = 230
        TIBEMS_JNI_ERR = 231
        TIBEMS_JNI_EDETACHED = 232
        TIBEMS_JNI_EVERSION = 233
        TIBEMS_JNI_EEXIST = 235
        TIBEMS_JNI_EINVAL = 236
        TIBEMS_NO_MEMORY_FOR_OBJECT = 237
        TIBEMS_UFO_CONNECTION_FAILURE = 240
        TIBEMS_NOT_IMPLEMENTED = 255
    ctypedef enum tibemsMsgType:
        TIBEMS_MESSAGE_UNKNOWN = 0
        TIBEMS_MESSAGE = 1
        TIBEMS_BYTES_MESSAGE = 2
        TIBEMS_MAP_MESSAGE = 3
        TIBEMS_OBJECT_MESSAGE = 4
        TIBEMS_STREAM_MESSAGE = 5
        TIBEMS_TEXT_MESSAGE = 6
        TIBEMS_MESSAGE_UNDEFINED = 256
    ctypedef enum tibems_bool:
        TIBEMS_FALSE = 0
        TIBEMS_TRUE = 1
    ctypedef enum tibemsAcknowledgeMode:
        TIBEMS_SESSION_TRANSACTED = 0
        TIBEMS_AUTO_ACKNOWLEDGE = 1
        TIBEMS_CLIENT_ACKNOWLEDGE = 2
        TIBEMS_DUPS_OK_ACKNOWLEDGE = 3
        TIBEMS_NO_ACKNOWLEDGE = 22
        TIBEMS_EXPLICIT_CLIENT_ACKNOWLEDGE = 23
        TIBEMS_EXPLICIT_CLIENT_DUPS_OK_ACKNOWLEDGE = 24
    ctypedef enum tibemsDestinationType:
        TIBEMS_UNKNOWN = 0
        TIBEMS_QUEUE = 1
        TIBEMS_TOPIC = 2
        TIBEMS_DEST_UNDEFINED = 256
    ctypedef __tibemsMsg tibemsMsg
    ctypedef __tibemsMsg tibemsTextMsg
    ctypedef __tibemsMsg tibemsMapMsg
    ctypedef __tibemsMsg tibemsBytesMsg
    ctypedef __tibemsMsgEnum tibemsMsgEnum
    ctypedef void (*tibemsMsgCompletionCallback) (tibemsMsg msg, tibems_status status, void* closure)
    ctypedef void (*tibemsMsgCallback) (tibemsMsgConsumer msgConsumer, tibemsMsg msg, void* closure)

    const char* tibemsStatus_GetText(tibems_status status)
    tibems_status tibemsErrorContext_Create(tibemsErrorContext* errorContext)
    tibems_status tibemsErrorContext_Close(tibemsErrorContext errorContext)
    tibems_status tibemsErrorContext_GetLastErrorString(tibemsErrorContext errorContext, const char** string)
    tibems_status tibemsErrorContext_GetLastErrorStackTrace(tibemsErrorContext errorContext, const char** string)

    tibemsConnectionFactory tibemsConnectionFactory_Create()
    tibems_status tibemsConnectionFactory_SetServerURL(tibemsConnectionFactory factory, const char* url)
    tibems_status tibemsConnectionFactory_CreateConnection(tibemsConnectionFactory factory, tibemsConnection* connection, const char* username, const char* password)
    tibems_status tibemsConnectionFactory_Destroy(tibemsConnectionFactory factory)

    tibems_status tibemsConnection_Start(tibemsConnection connection)
    tibems_status tibemsConnection_Close(tibemsConnection connection)

    tibems_status tibemsDestination_Create(tibemsDestination* destination, tibemsDestinationType type, const char* name)
    tibems_status tibemsDestination_Destroy(tibemsDestination destination)
    tibems_status tibemsDestination_GetName(tibemsDestination destination, char* name, tibems_int name_len)

    tibems_status tibemsTopic_Create(tibemsTopic* topic, const char* topicName)
    tibems_status tibemsTopic_Destroy(tibemsTopic topic)
    tibems_status tibemsTopic_GetTopicName(tibemsTopic topic, char* name, tibems_int name_len)

    tibems_status tibemsQueue_Create(tibemsQueue* queue, const char* queueName)
    tibems_status tibemsQueue_Destroy(tibemsQueue queue)
    tibems_status tibemsQueue_GetQueueName(tibemsQueue queue, char* name, tibems_int name_len)

    tibems_status tibemsConnection_CreateSession(tibemsConnection connection, tibemsSession* session, tibems_bool transacted, tibemsAcknowledgeMode acknowledgeMode)
    tibems_status tibemsSession_Close(tibemsSession session)

    tibems_status tibemsSession_CreateConsumer(tibemsSession session, tibemsMsgConsumer* consumer, tibemsDestination destination, const char* optionalSelector, tibems_bool noLocal)
    tibems_status tibemsSession_CreateSharedConsumer(tibemsSession session, tibemsMsgConsumer* consumer, tibemsTopic topic, const char* sharedSubscriptionName, const char* optionalSelector)
    tibems_status tibemsSession_CreateDurableSubscriber(tibemsSession session, tibemsMsgConsumer* msgConsumer, tibemsTopic topic, const char* name, const char* messageSelector, tibems_bool noLocal)
    tibems_status tibemsSession_CreateSharedDurableConsumer(tibemsSession session, tibemsMsgConsumer* consumer, tibemsTopic topic, const char* durableName, const char* optionalSelector)
    tibems_status tibemsSession_Unsubscribe(tibemsSession session, const char* subscriberName)
    tibems_status tibemsMsgConsumer_Receive(tibemsMsgConsumer msgConsumer, tibemsMsg* msg)
    tibems_status tibemsMsgConsumer_ReceiveTimeout(tibemsMsgConsumer msgConsumer, tibemsMsg* msg, tibems_long timeout)
    tibems_status tibemsMsgConsumer_Close(tibemsMsgConsumer msgConsumer)
    tibems_status tibemsMsgConsumer_SetMsgListener(tibemsMsgConsumer msgConsumer, tibemsMsgCallback callback, void* closure)
    tibems_status tibemsMsgConsumer_GetMsgListener(tibemsMsgConsumer msgConsumer, tibemsMsgCallback* callbackPtr, void** closure)

    tibems_status tibemsSession_CreateProducer(tibemsSession session, tibemsMsgProducer* producer, tibemsDestination destination)
    tibems_status tibemsMsgProducer_AsyncSend(tibemsMsgProducer msgProducer, tibemsMsg msg, tibemsMsgCompletionCallback asyncSendCallback, void* asyncSendClosure)
    tibems_status tibemsMsgProducer_Send(tibemsMsgProducer msgProducer, tibemsMsg msg)
    tibems_status tibemsMsgProducer_Close(tibemsMsgProducer msgProducer)

    tibems_status tibemsMsgRequestor_Create(tibemsSession session, tibemsMsgRequestor* msgRequestor, tibemsDestination destination)
    tibems_status tibemsMsgRequestor_Request(tibemsMsgRequestor msgRequestor, tibemsMsg msgSent, tibemsMsg* msgReply)
    tibems_status tibemsMsgRequestor_Close(tibemsMsgRequestor msgRequestor)

    tibems_status tibemsTextMsg_Create(tibemsTextMsg* message)
    tibems_status tibemsTextMsg_SetText(tibemsTextMsg message, const char* text)
    tibems_status tibemsTextMsg_GetText(tibemsTextMsg message, const char** text)
    tibems_status tibemsMapMsg_Create(tibemsMapMsg* message)
    tibems_status tibemsMapMsg_SetString(tibemsMapMsg message, const char* name, const char* value)
    tibems_status tibemsMapMsg_GetMapNames(tibemsMsg message, tibemsMsgEnum* enumeration)
    tibems_status tibemsMsgEnum_GetNextName(tibemsMsgEnum enumeration, const char** name)
    tibems_status tibemsMsgEnum_Destroy(tibemsMsgEnum enumeration)
    tibems_status tibemsMapMsg_GetString(tibemsMapMsg message, const char* name, const char** value)
    tibems_status tibemsBytesMsg_Create(tibemsBytesMsg* message)
    tibems_status tibemsBytesMsg_WriteBytes(tibemsBytesMsg message, const void* value, tibems_uint size)
    tibems_status tibemsMsg_SetDestination(tibemsMsg message, tibemsDestination value)
    tibems_status tibemsMsg_SetReplyTo(tibemsMsg message, tibemsDestination value)
    tibems_status tibemsMsg_SetTimestamp(tibemsMsg message, tibems_long value)
    tibems_status tibemsMsg_GetBodyType(tibemsMsg message, tibemsMsgType* type)
    tibems_status tibemsMsg_Create(tibemsMsg* message)
    tibems_status tibemsMsg_SetType(tibemsMsg message, const char* value)
    tibems_status tibemsMsg_Destroy(tibemsMsg message)
    tibems_status tibemsMsg_GetByteSize(tibemsMsg msg, tibems_int* size)
    tibems_status tibemsMsg_GetAsBytes(const tibemsMsg msg, const void** bytes, tibems_int* actual_size)
    void tibemsMsg_Print(tibemsMsg message)
