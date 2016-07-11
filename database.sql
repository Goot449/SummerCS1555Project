CREATE TABLE user
{
    userID NUMBER(10) NOT NULL,
    name VARCHAR2(50),
    email VARCHAR2(50),
    dob DATE,
    lastLogin DATE,--time needed?
    CONSTRAINT user_pk REFERENCES (userID),
}

CREATE TABLE friends
{
    userID1 NUMBER(10) NOT NULL,
    userID2 NUMBER(10) NOT NULL,
    status NUMBER(1),
    dateAccepted DATE,
    CONSTRAINT friends_pk REFERENCES (userID1, userID2),
    CONSTRAINT friends_fk1 FOREIGN KEY (userID1) REFERENCES profile(userID),
    CONSTRAINT friends_fk2 FOREIGN KEY (userID2) REFERENCES profile(userID)

}


CREATE TABLE groupInfo
{
    groupID NUMBER(10) NOT NULL,
    name VARCHAR2(50) NOT NULL,
    description VARCHAR2(255),
    memberLimit VARCHAR2(5) NOT NULL,
}

CREATE TABLE groupMembership
{
    membershipID NUMBER(10) NOT NULL,
    groupID NUMBER(10) NOT NULL,
    userID NUMBER(10) NOT NULL,
    CONSTRAINT groupMembership_pk REFERENCES membershipID,
    CONSTRAINT groupMembership_fk1 FOREIGN KEY (groupID) REFERENCES groupInfo(groupID),
    CONSTRAINT groupMembership_fk2 FOREIGN KEY (userID) REFERENCES user(userID)

}

CREATE TABLE messages
{
    msgID NUMBER(10) NOT NULL,
    sendToID NUMBER(10) NOT NULL,
    sendToGroup NUMBER(1) NOT NULL, -- flag for groups. False, send to user with msgID. True send to group with corresponding ID 
    senderID NUMBER(10) NOT NULL,
    subject VARCHAR2(50) NOT NULL,
    message VARCHAR2(100) NOT NULL,
    dateSent DATE NOT NULL,
    CONSTRAINT msg_pk REFERENCES (msgID),
    CONSTRAINT msg_fk1 FOREIGN KEY (senderID) REFERENCES user(userID),
}