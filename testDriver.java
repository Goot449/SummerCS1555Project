//driver
//used to run and show all methods in FaceSpaceApp working properly

public class testDriver {
    //this is used as a faster testing method
    public testDriver(){
        FaceSpaceApp testApp = new FaceSpaceApp("driver");

        //test createUser()
        System.out.println("***create user Billy Joe***");
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

        System.out.println();
        System.out.println("***Create DriverGroup again to make sure we get an error***");
        testApp.createGroup("DriverGroup","this group should fail to create",6);

        //displayMessages
        System.out.println();
        System.out.println("***Display Messages for Nate***");
        testApp.displayMessages("spangy@gmail.com");

        //sendMessage to user
        System.out.println();
        System.out.println("***Send Message directly to Billy***");
        testApp.sendMessageToUser("Test User Subject","test user bod","testuser@gmail.com","jimjohn@gmail.com");

        //sendMessage to group
        System.out.println();
        System.out.println("***Send Message to DriverGroup (that Billy is part of)***");
        testApp.sendMessageToGroup("Test Group Subject","test group bod","DriverGroup","spangy@gmail.com");

        //displayMessages
        System.out.println();
        System.out.println("***Display Messages for Billy***");
        testApp.displayMessages("testuser@gmail.com");

        //test displayNewMessages()
        System.out.println();
        System.out.println("***Display New Messages for Timmy***");
        testApp.displayNewMessages("timjohn@gmail.com");
        
        System.out.println();
        System.out.println("***Display New Messages for Timmy again (notice no messages now that his last login is now)***");
        testApp.displayNewMessages("timjohn@gmail.com");

        //test searchForUser()


        //test threeDegrees()


        //test topMessagers()


        //test dropUser()



    }
}
