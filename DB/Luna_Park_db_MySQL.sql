create database Luna_Park_db;
use Luna_Park_db;

create table Users(
	userId int primary key auto_increment,
    userName varchar(25) not null,
    idNumber varchar(100) not null unique,
    parentId int null,
    phone varchar(10) null,
    age int not null,
    role enum('user', 'admin') not null
);

alter table Users
add foreign key (parentId) references Users(userId);

create table Rides(
	rideId int primary key auto_increment,
    rideName varchar(25) not null,
    duringUse int not null,
    image varchar(255) null,
    numberSeats int not null,
    ageUser int not null,
    targetAge enum('baby', 'child', 'teenager', 'adult') not null
);

create table Act_times(
	actTimeId int primary key auto_increment,
	rideId int not null,
    foreign key (rideId) references Rides(rideId),
    timeStart time not null
);

create table Queues(
	userId int,
    foreign key(userId) references Users(userId),
    actTimeId int,
    foreign key (actTimeId) references Act_times(actTimeId),
    primary key(userId , actTimeId)
);

create table Tokens(
	tokenId int primary key auto_increment,
    userId int not null,
    foreign key(userId) references Users(userId),
    token varchar(200) not null,
    deviceId varchar(50) not null unique,
    CONSTRAINT unique_device_user UNIQUE (deviceId, userId)
);

create table Feedback(
	feebackId int primary key auto_increment,
    userName varchar(50) not null,
    content varchar(1000) not null,
	countStars int not null default 0
);

ALTER TABLE Users
ADD COLUMN tokenId INT,
ADD FOREIGN KEY (tokenId) REFERENCES Tokens(tokenId);

-- /*index*/
-- use Luna_Park_db;
-- create index idx_queues_actTimeId on queues(actTimeId);

/*trigger*/
DELIMITER //

CREATE TRIGGER check_available_seats
BEFORE INSERT ON queues
FOR EACH ROW
BEGIN
    DECLARE num_records INT;
    DECLARE num_seats INT;
    
    -- Get the number of records in queues with the same actTimeId as the new record
    SELECT COUNT(*) INTO num_records 
    FROM queues 
    WHERE actTimeId = NEW.actTimeId;
    
    -- Get the number of seats from the ride table
    SELECT numberSeats INTO num_seats 
    FROM rides 
    WHERE rideId = (
        SELECT rideId 
        FROM act_times
        WHERE actTimeId = NEW.actTimeId
    );
    
    -- Check if the number of records exceeds the number of seats
    IF num_records >= num_seats THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No available seats';
    END IF;
END //

DELIMITER ;

