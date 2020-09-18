from Cython.Build import cythonize

from setuptools import setup
from setuptools.extension import Extension

# python setup.py build_ext --inplace

with open('README.md', 'r') as fh:
    long_description = fh.read()

setup(
    name='tibemsMsg',
    version='0.0.1',
    author='qian_bi',
    author_email='2295823382@qq.com',
    description='Tibco EMS Toolkit for Python',
    long_description=long_description,
    long_description_content_type='text/markdown',
    url='https://pypi.org/project/tibemsMsg/',
    license='MIT',
    platforms='python 3.6',
    packages=['tibemsMsg'],
    package_data={
        '': ['*.dll', '*.so*'],
    },
    classifiers=[
        'Programming Language :: Python :: 3',
        'License :: OSI Approved :: MIT License',
        'Operating System :: Microsoft :: Windows',
    ],
    python_requires='>=3.6',
    ext_modules=cythonize([
        Extension('tibemsMsg.emsSession', ['tibemsMsg/emsSession.pyx'], libraries=['tibems'], library_dirs=['lib'], include_dirs=['include']),
    ], language_level=3, gdb_debug=False, compiler_directives={'infer_types': False, 'boundscheck': False, 'wraparound': False}),
    zip_safe=False,
)
