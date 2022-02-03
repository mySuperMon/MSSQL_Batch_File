#  mySupermon MSSQL_Batch_File

Usage of batch file-
Batch file is created to execute the multiple usecases at the same time. 

Prerequisite for running  mySuperMon  MSSQL batch file
First add your  MSSQL agent, application and data source of your application.

Do the following changes in the  MSSQL batch files folder

Step 1: In config.json file configure ServiceURL,Username, Password, ApplicationIdentifier, recordingStopperTime and UsecaseID like this
```ruby
{"serviceUrl":"https://app.mysupermon.com",
 "username":"Enter Your Username", 
"password":"Enter Your Password", 
"applicationIdentifier":"Enter Your applicationidentifier", 
"recordingStopperTime":15,
"useCaseId":"Enter Your usecaseId"}
```

In above json configure your details. 
 
Step 2: Create customer.txt file add the queries of the configured database.

Step 3: GetCustomer_Result.txt file is created to store the customer execution result.

Step 4: The response.json file is created in report folder in order to store the report of the usecase after executed

Step 5: In startStopRecording.bat file the start/stop functinality using start/stop API of mySupermMon is implemented.

5.1 Configured all the details specified in config.json in start/stop batch file using this below code
```ruby
more config.json | jq-win64.exe ".serviceUrl" >> temp.txt
set /p serviceUrl=<temp.txt
del -f temp.txt
```
You just need to add your config.json file here

5.2 Generated the access token using configured application details using this code
```ruby
curl -X POST %serviceUrl%oauth/token -u "performanceDashboardClientId:ljknsqy9tp6123" -d "grant_type=password" -d "username=%username%" -d "password=%password%" >> temp.txt
more temp.txt | jq-win64.exe ".access_token" >> accessToken.txt
set /p accessToken=<accessToken.txt
del -f temp.txt
del -f accessToken.txt
if %accessToken%==null (goto :showMessage)
```
In above code the curl is is a free command line tool. It uses URL syntax to transfer data to and from servers.

5.3 Start recording of mySuperMon using API 
```ruby
curl -v -H "Authorization: Bearer %accessToken%", -H "applicationIdentifier:%applicationIdentifier%" -X GET %serviceUrl%devaten/data/operation?usecaseIdentifier="customer&action=start"
```
In above the usecaseIdentifier parameter is passed and acion is pass as start for start recording  in API. 


5.4 Now pass your customer.txt as input and GetCustomer_Result.txt as ouput file for storing the result, using this code
```ruby
sqlcmd -S localhost -d mykkdb -U sa -P root -i Customers.txt -o GetCustomer_Result.out
```
In above code -S is Host name, -P is Port of host, -U is username, -P is password, -i is input, -o is output and -d for giving database name.

5.5 Stop recording of mySuperMon using stop recording API 
```ruby
curl -v -H "Authorization: Bearer %accessToken%", -H "applicationIdentifier:%applicationIdentifier%" -X GET %serviceUrl%devaten/data/operation?usecaseIdentifier="customer&action=stop"
```

This API aceepts usecaseIdentifier and action as parameters.

5.6 Generate the report start/stop recording using mySuperMon generate report API 
```ruby
curl -v -H "Authorization: Bearer %accessToken%" -H "applicationIdentifier:%applicationIdentifier%" -X GET %serviceUrl%devaten/data/generateReport >> response.json

move /Y response.json report/
 ```
In this API at the end passed the response.json file to store the response.

Step 6: You can see all executed usecase and usecase details on mySuperMon dashboard.





 
 

 
