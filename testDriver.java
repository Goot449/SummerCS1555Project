//driver for FaceSpaceApp
//used to run and show all methods in FaceSpaceApp working properly

public class testDriver {
    //this is used as a faster testing method
    public testDriver(){
        FaceSpaceApp testApp = new FaceSpaceApp("driver");

        //test createUser()
        System.out.println("***create user Billy Joe***");
        testApp.createUser("billy","joe","testuser@gmail.com","04/05/1995");
        System.out.println();

        System.out.println("***try to create user using Billy's email***");
        testApp.createUser("billy","joe","testuser@gmail.com","04/05/1995");
        System.out.println();

        //test initiateFriendship()
        System.out.println("***Nate Spangler friend Requests Billy Joe***");
        testApp.initiateFriendship("spangy@gmail.com","testuser@gmail.com");
        System.out.println();
        System.out.println("***Show Nate's Friends***");
        testApp.displayFriends("spangy@gmail.com");
        //test establishFriendship()
        System.out.println();
        System.out.println("***Billy Joe accepts friendship***");
        testApp.establishFriendship("spangy@gmail.com","testuser@gmail.com");

        //test displayFriends()
        System.out.println();
        System.out.println("***Show Billy's friends***");
        testApp.displayFriends("testuser@gmail.com");
        System.out.println();
        System.out.println("***Show Nate's friends (notice pending friends is now empty***");
        testApp.displayFriends("spangy@gmail.com");

        //test createGroup()
        System.out.println();
        System.out.println("***Create DriverGroup with member limit 2***");
        testApp.createGroup("DriverGroup","Group for testing",2);

        //test addToGroup()
        System.out.println();
        System.out.println("***Add Nate and Billy to DriverGroup***");
        testApp.addToGroup("spangy@gmail.com","DriverGroup");
        System.out.println("***Try to add Nate to DriverGroup even though he's already in***");
        testApp.addToGroup("spangy@gmail.com","DriverGroup");
        System.out.println("*Now Adding Billy to DriverGroup*");
        testApp.addToGroup("testuser@gmail.com","DriverGroup");

        System.out.println();
        System.out.println("***Try to 3rd member to DriverGroup with Limit of 2***");
        testApp.addToGroup("timjohn@gmail.com","DriverGroup");

        //test createGroup() error message
        System.out.println();
        System.out.println("***Create DriverGroup again to make sure we get an error***");
        testApp.createGroup("DriverGroup","this group should fail to create",6);

        //sendMessage to user
        System.out.println();
        System.out.println("***Send Message directly to Billy from Jimmy***");
        testApp.sendMessageToUser("Test User Subject","test user bod","testuser@gmail.com","jimjohn@gmail.com");

        //sendMessage to group
        System.out.println();
        System.out.println("***Send Message to DriverGroup (that Billy is part of) from Nate***");
        testApp.sendMessageToGroup("Test Group Subject","test group bod","DriverGroup","spangy@gmail.com");

        //displayMessages
        System.out.println();
        System.out.println("***Display All Messages for Billy***");
        testApp.displayMessages("testuser@gmail.com");

        //test displayNewMessages()
        System.out.println();
        System.out.println("***Display New Messages for Timmy***");
        testApp.displayNewMessages("timjohn@gmail.com");

        System.out.println();
        System.out.println("***Display New Messages for Timmy again (notice no messages now that his last login is now)***");
        testApp.displayNewMessages("timjohn@gmail.com");


        //test searchForUser()
        System.out.println();
        System.out.println("***Search for <empty String> in users list***");
        testApp.searchForUser("");

        System.out.println();
        System.out.println("***Search for <1 character> in users list***");
        testApp.searchForUser("a");

        System.out.println();
        System.out.println("***Search for <al> in users list***");
        testApp.searchForUser("al");

        System.out.println();
        System.out.println("***Search for <ric> in users list***");
        testApp.searchForUser("ric");

        //test threeDegrees()
        System.out.println();
        System.out.println("***Run Three Degrees from JIM John to TIM John***");
        testApp.threeDegrees("jimjohn@gmail.com","timjohn@gmail.com");

        //test threeDegrees()
        System.out.println();
        System.out.println("***Run Three Degrees from TIM John to JIM John***");
        testApp.threeDegrees("timjohn@gmail.com","jimjohn@gmail.com");

        //test topMessagers()
        System.out.println();
        System.out.println("***Display Top 3 Messagers Over the past 24 months***");
        testApp.topMessagers(3,24);

        //test dropUser()
        System.out.println();
        System.out.println("***Drop Rick Kot (UserID-10) from Users List***");
        testApp.dropUser("kotrr8@gmail.com");

        //test topMessagers()
        System.out.println();
        System.out.println("***Display Top 5 Messagers Over the past 24 months***");
        System.out.println("*Note: Rick Kot has been dropped and no longer listed*");
        testApp.topMessagers(5,24);

        //test topMessagers()
        System.out.println();
        System.out.println("***Display Top 3 Messagers Over the past 5 months***");
        testApp.topMessagers(3,5);

        //test dropUser()
        System.out.println();
        System.out.println("***Drop Nate from Users List***");
        testApp.dropUser("spangy@gmail.com");

        System.out.println();
        System.out.println("***Show Billy's friends (notice Nate is gone)***");
        testApp.displayFriends("testuser@gmail.com");

        System.out.println();
        System.out.println("***Display Messages for Nate after he is removed***");
        testApp.displayMessages("spangy@gmail.com");

        System.out.println();
        System.out.println("***Display Messages for Billy the message from Nate is still there***");
        testApp.displayMessages("testuser@gmail.com");

    }
}
