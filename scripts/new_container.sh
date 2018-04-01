#!/bin/bash

curl -v -u"mmartin:Nond0Quolth7;realm=default_domain,another=option" -H "x-cdmi-specification-version: 1.1" -H "content-type: application/cdmi-container" -H "Accept: application/cdmi-container" -X PUT "http://localhost:4000/cdmi/v1/new_container3/" -d '{"metadata": {"cdmi_domain_enabled": "true"}}' | python -mjson.tool
sleep 1
curl -v -u"mmartin:Nond0Quolth7;realm=default_domain,another=option" -H "x-cdmi-specification-version: 1.1" -H "content-type: application/cdmi-container" -H "Accept: application/cdmi-container" -X PUT "http://localhost:4000/cdmi/v1/new_container3/childz/" -d '{"metadata": {"cdmi_domain_enabled": "true"}}' | python -mjson.tool
#curl -v -u"administrator:test;realm=system_domain,another=option" -H "x-cdmi-specification-version: 1.1" -H "content-type: application/cdmi-container" -H "Accept: application/cdmi-container" -X PUT "http://localhost:4000/api/v1/new_container8/" -d '{"metadata": {"cdmi_domain_enabled": "true"}}' | python -mjson.tool
#curl -v -u"administrator:test;realm=system_domain,another=option" -H "x-cdmi-specification-version: 1.1" -H "content-type: application/cdmi-container" -H "Accept: application/cdmi-container" -X PUT "http://localhost:4000/cdmi/new_containeru/zzz2/" -d '{}' | python -mjson.tool
#curl -v -uadministrator:test -H "x-cdmi-specification-version: 1.1" -H "content-type: application/cdmi-container" -H "Accept: application/cdmi-container" -X PUT "http://localhost:4000/cdmi/new_container1/child1/" -d '{"metadata": {"cdmi_domain_enabled": "true"}}'
#curl -v -uadministrator:test -H "x-cdmi-specification-version: 1.1" -H "content-type: application/cdmi-container" -H "Accept: application/cdmi-container" -X PUT "http://localhost:4000/cdmi/new_container1/child2/" -d '{"metadata": {"cdmi_domain_enabled": "true"}}'
#curl -v -uadministrator:test -H "x-cdmi-specification-version: 1.1" -H "content-type: application/cdmi-container" -H "Accept: application/cdmi-container" -X PUT "http://localhost:4000/cdmi/new_container1/child3/" -d '{"metadata": {"cdmi_domain_enabled": "true"}}'
#curl -v -uadministrator:test -H "x-cdmi-specification-version: 1.1" -H "content-type: application/cdmi-container" -H "Accept: application/cdmi-container" -X PUT "http://localhost:4000/cdmi/new_container1/child2/grandchild1/" -d '{"metadata": {"cdmi_domain_enabled": "true"}}'
