#!/usr/bin/python 
#coding=utf-8
#2017-06-08

"""
"""

import sys

class Grouper:
    def __init__(self, ifs=sys.stdin, num_of_key=1, delimiter='\t'):
        self.ifs = ifs
        self.num_of_key = num_of_key
        self.delimiter = delimiter
        self.has_next_group = True
        self.next_key, self.next_val = self.__readline__()
        self.is_same_key = True

    def has_next(self):
        '''has next group or not'''
        self.is_same_key = True
        return self.has_next_group

    def next_group(self):
        pass

    def key_same(self):
        '''next line has the same key or don't'''
        return self.has_next_group and self.is_same_key

    def get(self):
        '''get key and value
        never fail after checking has_next() or key_same()'''
        key = self.next_key
        value = self.next_val
        self.next_key, self.next_val = self.__readline__()
        if self.next_key == key:
            self.is_same_key = True
        else:
            self.is_same_key = False
        return key, value

    def get_key(self):
        return self.next_key

    def next_value(self):
        key, value = self.get()
        return value

    def __readline__(self):
        '''read one line, split it by self.delimiter,
        and return the first field as key and others as value'''
        line = self.ifs.readline()
        if not line:
            self.has_next_group = False
            return None, None
        while len(line) > 0 and (line[-1] == '\n' or line[-1] == '\r'):
            line = line[:-1]
        fields = line.split(self.delimiter)
        key = self.delimiter.join(fields[:self.num_of_key])
        value = fields[self.num_of_key:]
        return key, value


if __name__ == "__main__":
    group = Grouper(sys.stdin)

    while group.has_next():
        key = None
        lst = []
        while group.key_same():
            key, value = group.get()
            lst.append(','.join(value))
        print key, ' || ', ';'.join(lst)


