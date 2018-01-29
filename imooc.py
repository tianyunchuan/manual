import MySQLdb
import numpy as np
import numpy
import pandas as pd
import pandas
import re
import datetime
import time
import os
from pandas import Series,DataFrame
import matplotlib
from matplotlib import pyplot as plt
from pandas import read_csv
from sklearn.linear_model import LinearRegression
import matplotlib.pyplot as plt
from pandas.tools.plotting import scatter_matrix
from sklearn import datasets
from sklearn.model_selection import train_test_split
from sklearn import neighbors
from sklearn.model_selection import cross_val_score
from sklearn.naive_bayes import BernoulliNB
from sklearn.tree import DecisionTreeClassifier
from sklearn.model_selection import cross_val_score
import urllib.request
import urllib.parse
import urllib.error
from pprint import pprint
import http.cookiejar
import http.cookiejar as cookielib;
import requests
from urllib.request import urlretrieve
from bs4 import BeautifulSoup
import seaborn as sns
import hashlib
from selenium import webdriver
from sqlalchemy import create_engine
from importlib import reload
import math
import random
import tushare as ts
import functools
import operator
from lxml import etree
import codecs

os.getcwd()
os.chdir(r'C:\t_py\imooc')
####        7-3 for range
a=[0,1,2,3,4,5,6,7,8,9]
#for s in range(0,len(a),2):
#    print(a[s],end=' | ')
a[0:len(a):2]       #切片方式


####        7-7 import导入模块
import imooc.c4 as im     #as简写

####        7-8 from import 导入变量
os.getcwd()
os.chdir(r'C:\t_py\atom')

##      包名称=__init__.py

##      导入包
import one.tian
print(one.tian.act,one.tian.psw)

##      导入模块
from one import tian
from all_setting import c4
print(all_setting.c4.a)

##      导入具体变量
from one.tian import act,psw
from one.tian import *        #导入该模块中的所有变量
from all_setting.c4 import a,b,c

#       定义* __all__=['a','c']
print(a,c)

####        7-9 __init__.py 的用法
##  代码换行1.    \反斜杠
from one.tian import a,\
b,c
##  代码换行1.    \括号
from one.tian import (a,
b,c)
print(a,b,c)

## __init__.py
import all_setting

print(all_setting.sys.path)     # 需要加上路径
all_setting.account
all_setting.time.time()

####        7-10 包与模块的几个常见错误_
##  不能重复导入！！！！
##  避免循环导入

####        7-11 模块内置变量
infos=dir()
"""
Created on Sun Jan 14 17:43:51 2018
@author: tianyunchuan
"""
print('name:  '+__name__)
print('package:  '+__package__)
print('doc:  '+__doc__)
print('file:  '+__file__)


####        7-12 入口文件和普通模块内置变量的区别
print('name:  '+__name__)
print('package:  '+(__package__ or '当前模块不属于任何包'))
print('doc:  '+__doc__)
#print('file:  '+__file__)


####        7-13 __name__的经典应用
info=dir(all_setting.sys)

#if __name__=='__main__':
#    pass

import all_setting
all_setting.time.time()

import a
a.time.time()

####        8-1 认识函数
round(1.2345,2)

####        8-2 函数的定义及运行特点
#def func(par):
#    pass
## 1. 参数列表可以没有
## 2. return value 没有的话 None
#def add(x,y):
#    result=x+y
#    return result
#
#def prt(code):
#    print(code)
#
#a=add(400,566)
#b=prt(999)
#print(a,b)
#
#import sys
#sys.setrecursionlimit(2000)

####        8-3 如何让函数返回多个结果
#   return后面不会执行  
#def prt(code):
#    print(code)
#    return
#    print(code)
#
#prt('tian')

##  返回多个结果
#def damage(skill1,skill2):
#    damage1=skill1**2
#    damage2=skill2+100
#    return damage1,damage2

damage=damage(100,5)
type(damage(100,5))
print(damage[0],damage[1])

skill1_damage,skill2_damage=damage(1000,500)

####        8-4 序列解包与链式赋值
a=1
b=2
c=3
a,b,c=1,2,3
z=4,5,6
a,b,c=z
z=1,2,1
a,b,c=(5,6,7)

a=b=c=998

####        8-5 必须参数与关键字参数
#   1. 必须参数 必须传递的参数
def add(x,y):      #x,y是形式参数，又叫形参
    result=x+y
    return result
a=add(100,200)      #100,200是实际参数，又叫实参
#   2. 关键字参数
c=add(y=200,x=800)

####        8-6 默认参数
#   3.默认参数
def mysql_conn(account,password='72102'):
    print(account,password)
    return account,password

my=mysql_conn('root')
my[0]

def add(x,y=100):
    result=x+y
    #return result

add(200)

####        8-7 可变参数
def demo(*param):
    print(param)
    print(type(param))

demo(1,3,5,7,9,11)

a=(10,20,30,40,50)
demo(*a)

def demo(param1,*param,param2=200):
    print(param1,*param,param2)
    print(param1)
    print(param2)
    print(*a)

demo('a',*a)
demo('abc',*a,param2='p2p')
demo('abc',*a)

####        8-8 关键字可变参数
def squsum(*param):
    sum=0
    for i in param:
        sum+=i*i
    print(sum)

squsum(1,2,3,4,5,6)
a=(1,2,3)
squsum(*a)

def city_temp(**param):
#    print(param)
#    print(type(param))
    for key,value in param.items():
        print(key,">>>>>",value)
city_temp(sh=36,bj=23,gz=50)
a={'sz':100,'wx':200,'cz':300}
city_temp(**a)
city_temp()

####        8-9 变量作用域
c=50

def add(x,y):
    c=x+y
    print(c)

add(1,2)
print(c)

b=10    # 全局变量
def demo():
    c=50
    for i in range(0,100):
        a='aaa'
        c+=1
#    b=9     #局部变量
    print(c)
    print(a)
demo()

## 没有块级作用域    
c=1
def func1():
    c=2
    def func2():
        c=3
        print(c)
    func2()

func1()

####        8-10 作用域链

####        8-11 global关键字
def demo():
    global d
    d=2000

demo()
print(d)

import c13
print(c13.demo)
print(c13.__doc__)
print(c13.__file__)
print(c13.__name__)
print(c13.__package__)

####        8-12 划算还是不划算