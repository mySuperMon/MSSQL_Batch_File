@echo off
more config.json | jq-win64.exe ".serviceUrl" >> temp.txt
set /p serviceUrl=<temp.txt
del -f temp.txt
del -f response.json
more config.json | jq-win64.exe ".username" >> temp.txt
set /p username=<temp.txt
del -f temp.txt

more config.json | jq-win64.exe ".password" >> temp.txt
set /p password=<temp.txt
del -f temp.txt

more config.json | jq-win64.exe ".recordingStopperTime" >> temp.txt
set /p recordingStopperTime=<temp.txt
del -f temp.txt

more config.json | jq-win64.exe ".useCaseId" >> temp.txt
set /p useCaseId=<temp.txt
del -f temp.txt

more config.json | jq-win64.exe ".applicationIdentifier" >> temp.txt
set /p applicationIdentifier=<temp.txt
del -f temp.txt

:start

curl -X POST %serviceUrl%oauth/token -u "performanceDashboardClientId:ljknsqy9tp6123" -d "grant_type=password" -d "username=%username%" -d "password=%password%" >> temp.txt
more temp.txt | jq-win64.exe ".access_token" >> accessToken.txt
set /p accessToken=<accessToken.txt
del -f temp.txt
del -f accessToken.txt
if %accessToken%==null (goto :showMessage)

curl -v -H "Authorization: Bearer %accessToken%", -H "applicationIdentifier:%applicationIdentifier%" -X GET %serviceUrl%devaten/data/operation?usecaseIdentifier="customer&action=start"


for /l %%x in (1, 1, 2) do (
sqlcmd -S 3.124.172.28 -d mykkdb -U sa -P HF3KTnuLgJXgHMfJ -i Customers.txt -o GetCustomerUpdates.out
sqlcmd -S 3.124.172.28 -d mykkdb -U sa -P HF3KTnuLgJXgHMfJ -i product.txt -o product.out
echo %%x
for /l %%y in (1, 1, 3) do (
sqlcmd -S 3.124.172.28 -d mykkdb -U sa -P HF3KTnuLgJXgHMfJ -i product_description_history.txt -o product_description_history.out
echo %%y
for /l %%b in (1, 1, 5) do (
sqlcmd -S 3.124.172.28 -d mykkdb -U sa -P HF3KTnuLgJXgHMfJ -i product_descriptions.txt -o product_descriptions.out
echo %%b
)
)

)

curl -v -H "Authorization: Bearer %accessToken%", -H "applicationIdentifier:%applicationIdentifier%" -X GET %serviceUrl%devaten/data/operation?usecaseIdentifier="customer&action=stop"

curl -v -H "Authorization: Bearer %accessToken%" -H "applicationIdentifier:%applicationIdentifier%" -X GET %serviceUrl%devaten/data/generateReport >> response.json

move /Y response.json report/



