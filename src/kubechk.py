#!/usr/bin/python3

import argparse

parser = argparse.ArgumentParser(description='Kubernetes Feature Enablement Checker.')
parser.add_argument('--feature', '-f', dest='feature', nargs='?', type=ascii, help='feature name like readinessProbe, livenessProbe etc.')
parser.add_argument('--directory', '-d', dest='directory', nargs='?',default='.', type=ascii, help='helm chart location')
parser.add_argument('--scm', '-s', dest='inscm', action='store_true', help='static checker in scm project group')
parser.add_argument('--lab', '-l', dest='inlab', action='store_true', help='dynamic checker for deployed pod in one namespace')
parser.add_argument('--namespace', nargs='?', default='all-namespaces', type=ascii, help='dynamic checker namespace name')
args = parser.parse_args()
print(args)