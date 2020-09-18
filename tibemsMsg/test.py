import time
from multiprocessing import Process
from emsSession import EmsSession


def test():
    p1 = Process(target=request)
    p2 = Process(target=response)
    p2.start()
    time.sleep(0.5)
    p1.start()


def request():
    data = '''<?xml version="1.0" encoding="utf-8"?><Message">{}</Message>'''.format('Test Request')
    sess = EmsSession('tcp://10.93.223.22:7222', 'admin', '', debug=1)
    sess.producer('test.request', data)
    res = sess.consumer('test.response')
    print(res)


def response():
    data = '''<?xml version="1.0" encoding="utf-8"?><Message">{}</Message>'''.format('Test Response')
    sess = EmsSession()
    sess.create('tcp://10.93.223.22:7222', 'admin', '')
    sess.consumer('test.request')
    sess.producer('test.response', data)


if __name__ == '__main__':
    test()
