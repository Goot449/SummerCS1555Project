DROP TABLE users CASCADE CONSTRAINTS;
DROP TABLE friends CASCADE CONSTRAINTS;
DROP TABLE pendingFriends CASCADE CONSTRAINTS;
DROP TABLE groupInfo CASCADE CONSTRAINTS;
DROP TABLE groupMembership CASCADE CONSTRAINTS;
DROP TABLE messages CASCADE CONSTRAINTS;
DROP TABLE groupMessageRecipients CASCADE CONSTRAINTS;

DROP SEQUENCE seq_usersID;
DROP SEQUENCE seq_groupID;
DROP SEQUENCE seq_msgID;

purge recyclebin;


--Assuming that all users data is necessary (name, email, etc.)
CREATE TABLE users
(
    usersID NUMBER(10) NOT NULL,
    name VARCHAR2(50) NOT NULL,
    email VARCHAR2(50) NOT NULL,
    dob DATE NOT NULL,
    lastLogin DATE,--time needed?
    CONSTRAINT users_pk PRIMARY KEY (usersID)
);
--Allows new users to be added without needing to know the next available usersID
--to use: call seq_userID.nextval
CREATE SEQUENCE seq_usersID START WITH 1 INCREMENT BY 1;

CREATE TABLE friends
(
    usersID1 NUMBER(10) NOT NULL,
    usersID2 NUMBER(10) NOT NULL,
    dateEstablished DATE NOT NULL,
    CONSTRAINT friends_pk PRIMARY KEY (usersID1, usersID2),
    CONSTRAINT friends_fk1 FOREIGN KEY (usersID1) REFERENCES users(usersID),
    CONSTRAINT friends_fk2 FOREIGN KEY (usersID2) REFERENCES users(usersID)
);

CREATE TABLE pendingFriends
(
    fromID NUMBER(10) NOT NULL,
    toID NUMBER(10) NOT NULL,
    CONSTRAINT pendingFriends_pk PRIMARY KEY (fromID, toID),
    CONSTRAINT pendingFriends_fk1 FOREIGN KEY (fromID) REFERENCES users(usersID),
    CONSTRAINT pendingFriends_fk2 FOREIGN KEY (toID) REFERENCES users(usersID)
);

--assuming group description is not longer than 255 characters

CREATE TABLE groupInfo
(
    groupID NUMBER(10) NOT NULL,
    name VARCHAR2(50) NOT NULL,
    description VARCHAR2(255),
    memberLimit VARCHAR2(5) NOT NULL,
    CONSTRAINT group_pk PRIMARY KEY (groupID)
);

CREATE SEQUENCE seq_groupID START WITH 1 INCREMENT BY 1;
CREATE TABLE groupMembership
(
    membershipID NUMBER(10) NOT NULL,
    groupID NUMBER(10) NOT NULL,
    usersID NUMBER(10) NOT NULL,
    CONSTRAINT groupMembership_pk PRIMARY KEY (membershipID),
    CONSTRAINT groupMembership_fk1 FOREIGN KEY (groupID) REFERENCES groupInfo(groupID),
    CONSTRAINT groupMembership_fk2 FOREIGN KEY (usersID) REFERENCES users(usersID)
);
--trigger needed to ensure groupInfo.memberLimit is enforeced

--if tousersID is not null, message will be sent there. Otherwise, check toGroupID and send to all group members
--add respective rows to groupMessageRecipients
CREATE TABLE messages
(
    msgID NUMBER(10) NOT NULL,
    fromID NUMBER(10) NOT NULL,
    tousersID NUMBER(10) DEFAULT NULL,
    toGroupID NUMBER(10) DEFAULT NULL, 
    subject VARCHAR2(50) NOT NULL,
    message VARCHAR2(100) NOT NULL,
    dateSent DATE NOT NULL,
    CONSTRAINT msg_pk PRIMARY KEY (msgID),
    CONSTRAINT msg_fk1 FOREIGN KEY (fromID) REFERENCES users(usersID)
);
CREATE SEQUENCE seq_msgID START WITH 1 INCREMENT BY 1;

CREATE TABLE groupMessageRecipients
(
    msgID NUMBER(10) NOT NULL,
    tousersID NUMBER(10) NOT NULL,
    CONSTRAINT groupMessageRecipients_pk PRIMARY KEY (msgID, tousersID),
    CONSTRAINT groupMessageRecipients_fk1 FOREIGN KEY (msgID) REFERENCES messages(msgID),
    CONSTRAINT groupMessageRecipients_fk2 FOREIGN KEY (tousersID) REFERENCES users(usersID)
);