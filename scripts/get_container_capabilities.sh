#!/bin/bash

curl -v -uadministrator:test -H "X-CDMI-Specification-Version: 1.1" -H "Content-Type: application/cdmi-capability" -H "Accept: application/cdmi-capability" -X GET "http://localhost:4000/api/v1/cdmi_capabilities" |python -m json.tool
