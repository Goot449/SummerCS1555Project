***CS1555 Summer Term 2016***
***Database TermProject README***

***Group: Nathan Spangler, Connor Kazmierczak, Jacob Guttenplan***

***Running Procedure***
1. source bash.env on unix

2. Navigate to folder with source files

3. Login to sqlplus

4. type "start database.sql"

5. Open a 2nd Unix Window

6. source bash.env a 2nd time

7. navigate to fold with source files

8. compile java files "javac *.java"

9. Execute FaceSpaceApp.java ("java FaceSpaceSpace.java")

    -FaceSpaceApp Accepts 1 of 2 arguments:

      1. 'user'  -in order to run all methods manually

      2. 'driver' - in order to have that testDriver class execute all methods


***Assumptions:***

1. person running this program has followed the Running Procedure listed above

2. A message can be sent to a group by a non Member. "hey I would like to join"

3. Group Names are case sensitive

4. Methods check for user input errors but just return an error message.
    This is to ensure the driver doesn't get stuck in the method if an input is wrong.

5. Names are case sensitive. To make things simple all names are lowercase.


***Note***
The database.sql file does not need to be ran everytime before running FaceSpaceApp.
However, if not reran before running in DRIVER MODE, you shoul expect different results.
