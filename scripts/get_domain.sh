#!/bin/bash

curl -uadministrator:test -H "x-cdmi-specification-version: 1.1"  -H "Accept: application/cdmi-domain" -X GET "http://localhost:4000/cdmi/v1/cdmi_domains/Fuzzcat5/" -v |python -m json.tool
