DROP TABLE user CASCADE CONSTRAINTS;
DROP TABLE friends CASCADE CONSTRAINTS;
DROP TABLE pendingFriends CASCADE CONSTRAINTS;
DROP TABLE groupInfo CASCADE CONSTRAINTS;
DROP TABLE groupMembership CASCADE CONSTRAINTS;
DROP TABLE messages CASCADE CONSTRAINTS;

DROP SEQUENCE seq_userID;

purge recyclebin;


--Assuming that all user data is necessary (name, email, etc.)
CREATE TABLE user
(
    userID NUMBER(10) NOT NULL,
    name VARCHAR2(50) NOT NULL,
    email VARCHAR2(50) NOT NULL,
    dob DATE NOT NULL,
    lastLogin DATE,--time needed?
    CONSTRAINT user_pk REFERENCES (userID),
);
--Allows new users to be added without needing to know the next available userID
CREATE SEQUENCE seq_userID START WITH 10 INCREMENT BY 1;

CREATE TABLE friends
(
    userID1 NUMBER(10) NOT NULL,
    userID2 NUMBER(10) NOT NULL,
    dateEstablished DATE NOT NULL,
    CONSTRAINT friends_pk REFERENCES (userID1, userID2),
    CONSTRAINT friends_fk1 FOREIGN KEY (userID1) REFERENCES profile(userID),
    CONSTRAINT friends_fk2 FOREIGN KEY (userID2) REFERENCES profile(userID)

);

CREATE TABLE pendingFriends
(
    fromID NUMBER(10) NOT NULL,
    toID NUMBER(10) NOT NULL,
    CONSTRAINT pendingFriends_pk PRIMARY KEY (fromID, toID),
    CONSTRAINT pendingFriends_fk1 FOREIGN KEY (fromID) REFERENCES user(userID),
    CONSTRAINT pendingFriends_fk2 FOREIGN KEY (toID) REFERENCES user(userID)
);

--assuming group description is not longer than 255 characters
CREATE TABLE groupInfo
(
    groupID NUMBER(10) NOT NULL,
    name VARCHAR2(50) NOT NULL,
    description VARCHAR2(255),
    memberLimit VARCHAR2(5) NOT NULL,
);


CREATE TABLE groupMembership
(
    membershipID NUMBER(10) NOT NULL,
    groupID NUMBER(10) NOT NULL,
    userID NUMBER(10) NOT NULL,
    CONSTRAINT groupMembership_pk REFERENCES membershipID,
    CONSTRAINT groupMembership_fk1 FOREIGN KEY (groupID) REFERENCES groupInfo(groupID),
    CONSTRAINT groupMembership_fk2 FOREIGN KEY (userID) REFERENCES user(userID)

);
--trigger needed to ensure groupInfo.memberLimit is enforeced

--if toUserID is not null, message will be sent there. Otherwise, check toGroupID and send to all group members
--add respective rows to groupMessageRecipients
CREATE TABLE messages
(
    msgID NUMBER(10) NOT NULL,
    fromID NUMBER(10) NOT NULL,
    toUserID NUMBER(10) DEFAULT NULL,
    toGroupID NUMBER(10) DEFAULT NULL, 
    subject VARCHAR2(50) NOT NULL,
    message VARCHAR2(100) NOT NULL,
    dateSent DATE NOT NULL,
    CONSTRAINT msg_pk REFERENCES (msgID),
    CONSTRAINT msg_fk1 FOREIGN KEY (fromID) REFERENCES user(userID),
);

CREATE TABLE groupMessageRecipients
(
    msgID NUMBER(10) NOT NULL,
    toUserID NUMBER(10) NOT NULL,
    CONSTRAINT groupMessageRecipients_pk REFERENCES (msgID, toUserID),
    CONSTRAINT groupMessageRecipients_fk1 FOREIGN KEY (msgID) REFERENCES messages(msgID),
    CONSTRAINT groupMessageRecipients_fk2 FOREIGN KEY (toUserID) REFERENCES user(userID),

);