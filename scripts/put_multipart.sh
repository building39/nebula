clear;curl -v -include --form "file=@multipart_body;type=application/cdmi-object" --form "file=@Janice-SchoolPhoto.jpg.base64" -X PUT "http://cloud.fuzzcat.net:8080/cdmi/new_container7/Janice-SchoolPhoto.jpg" -H "Content-Type: multipart/mixed" -H "x-cdmi-specification-version: 1.1" -u"administrator:test;realm=system_domain" # | python -mjson.tool
#clear;curl -v -include --form "file=@multipart_body;type=application/cdmi-object" --form "file=@new_domain.sh" -X PUT "http://localhost:8080/cdmi/new_container7/multipart6.txt" -H "Content-Type: multipart/mixed" -H "x-cdmi-specification-version: 1.1" -uadministrator:test | python -mjson.tool