import time
from multiprocessing import Process, Pipe

from tibemsMsg.emsSession import EmsSession, TibcoError


def listen(server, replyTopic, user='admin', password='', sleep=0.2):
    def func(res):
        msg.append(res)

    msg = []
    sess = EmsSession(server, user, password)
    sess.listener(replyTopic, func)
    while True:
        if msg:
            yield msg.pop(0)
        else:
            time.sleep(sleep)


def _consumer(server, user, password, pipe):
    sess = EmsSession(server, user, password)
    try:
        while True:
            replyTopic = pipe.recv()
            msg = sess.consumer(replyTopic)
            pipe.send(msg)
    except EOFError:
        pass


def request(server, user='admin', password=''):
    p1, p2 = Pipe()
    consumer = Process(target=_consumer, args=(server, user, password, p1))
    consumer.start()
    sess = EmsSession(server, user, password)

    msg = ''
    while True:
        requestTopic, data, replyTopic = yield msg
        p2.send(replyTopic)
        sess.producer(requestTopic, **data)
        msg = p2.recv()
