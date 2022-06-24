USE emerchant_project;


# Stores list of four security login questions and their corresponding number.
CREATE TABLE Security_T
	(Securitynum TINYINT PRIMARY KEY,
    Securityq VARCHAR (50) NOT NULL);

# Stores data on registered users of online store, including email, name, password, and an answer to their chosen security question.
CREATE TABLE User_T 
	(Uemail VARCHAR (50),
	ULname  VARCHAR(25) NOT NULL,
	UFname  VARCHAR(25) NOT NULL,
	Upassword VARCHAR(50) NOT NULL,
	Securitynum TINYINT NOT NULL,
    Usecuritya VARCHAR(50) NOT NULL,
    CONSTRAINT User_PK PRIMARY KEY (Uemail),
	CONSTRAINT User_FK FOREIGN KEY (Securitynum) REFERENCES Security_T(Securitynum));

CREATE TABLE Publisher_T
	(PubID INT PRIMARY KEY,
    Pubname VARCHAR(50) NOT NULL);
    
CREATE TABLE Author_T 
	(AuthID INT PRIMARY KEY,
	AuthLname VARCHAR(50) NOT NULL,
	AuthFname VARCHAR (50) NOT NULL);

# Stores data for every product; products are defined by their ID number and type (print, digital, or audiobook)
CREATE TABLE Product_T 
	(Pnumber VARCHAR(16),
	Ptype VARCHAR(25)
		CHECK (Ptype IN ("Print","Digital","Audiobook")),
	Ptitle VARCHAR(25) NOT NULL,
	Pgenre VARCHAR(25),
	Pprice FLOAT NOT NULL,
	Ppages INT,
    AuthID INT,
    PubID INT NOT NULL,
	CONSTRAINT Product_PK PRIMARY KEY (Pnumber, Ptype),
    CONSTRAINT Product_FK1 FOREIGN KEY (AuthID) REFERENCES Author_T(AuthID),
    CONSTRAINT Product_FK2 FOREIGN KEY (PubID) REFERENCES Publisher_T(PubID));

# Extend maximum character length for titles
ALTER TABLE Product_T
MODIFY COLUMN Ptitle VARCHAR(50) NOT NULL;

CREATE TABLE Order_T 
	(OID INT,
    Odate DATE,
	Uemail VARCHAR(50),
    CONSTRAINT Order_PK PRIMARY KEY (OID),
	CONSTRAINT Order_FK1 FOREIGN KEY (Uemail) REFERENCES User_T(Uemail));

CREATE TABLE OrderLine_T
	(OLID INT,
	OrderID INT NOT NULL,
    Pnumber VARCHAR(16) NOT NULL,
	Ptype VARCHAR (25) NOT NULL,
	OLquantity INT NOT NULL,
	CONSTRAINT OrderLine_PK PRIMARY KEY (OLID),
	CONSTRAINT OrderLine_FK1 FOREIGN KEY (OrderID) REFERENCES Order_T(OID),
	CONSTRAINT OrderLine_FK2 FOREIGN KEY (Pnumber, Ptype) REFERENCES Product_T(Pnumber, Ptype));

# Displays order info, including customer name, product ID number, total prices, and more for employees' reference.
# Results are grouped by orderline ID and can be limited to a single order using HAVING statement.
CREATE VIEW Invoice AS
	SELECT OrderLine_T.OLID, Order_T.OID, User_T.ULname, User_T.UFname, OrderLine_T.Pnumber, 
    Product_T.Pprice, OrderLine_T.OLquantity, (Product_T.Pprice * OrderLine_T.OLquantity) AS SubTotal
		FROM OrderLine_T LEFT OUTER JOIN Order_T
        ON OrderLine_T.OrderID = Order_T.OID
        INNER JOIN User_T
        ON User_T.Uemail = Order_T.Uemail
        INNER JOIN Product_T
        ON Product_T.Pnumber = OrderLine_T.Pnumber
            GROUP BY OrderLine_T.OLID;

# Users are able to rate products they have purchased. Each rating must correlate to one user, one product,
# and one order ID. Users have the option of adding tags to their reviews.
CREATE TABLE Rating_T 
	(Rscore TINYINT
		CHECK (Rscore IN (1,2,3,4,5)),
	Rtags VARCHAR(25)
		CHECK (Rtags IN ("Challenging Read","Made Me Smarter","Action Packed",
        "Couldn't Put It Down","Tear Jerker","Spooky","Strong Female Protagonist")),
	Uemail VARCHAR (50) NOT NULL,
	OID INT NOT NULL,
	Pnumber VARCHAR(16) NOT NULL,
	Ptype VARCHAR(25) NOT NULL,
	CONSTRAINT Rating_FK1 FOREIGN KEY (OID) REFERENCES Order_T(OID),
	CONSTRAINT Rating_FK2 FOREIGN KEY (Pnumber, Ptype) REFERENCES Product_T(Pnumber, Ptype),
    CONSTRAINT Rating_FK3 FOREIGN KEY (Uemail) REFERENCES User_T (Uemail));

# Joins Product table and Rating table to show average rating for each product. This is what a customer
# can view when deciding whether or not to purchase a product. Can search by product by adding "WHERE Product_T.Pnumber
# =" to the end of query.
CREATE VIEW Product_Profile AS
	SELECT Product_T.*, AVG(Rating_T.Rscore) AS Prating
		FROM Product_T LEFT OUTER JOIN Rating_T
        ON Product_T.Pnumber = Rating_T.Pnumber
			GROUP BY Product_T.Pnumber;

# Populates Security table with number and corresponding Qs
INSERT INTO Security_T
VALUES(1, "In what city were you born?");
INSERT INTO Security_T
VALUES(2, "What is your mother's maiden name?");
INSERT INTO Security_T
VALUES(3, "What is your dream job?");
INSERT INTO Security_T
VALUES(4, "What is your favorite film?");

SELECT * FROM Security_T;

# Populates Publisher and Author tables with real names and randomly generated ID numbers
INSERT INTO Publisher_T
VALUES(126317,'Crown Publishing Group');
INSERT INTO Publisher_T
VALUES(878429,'Little, Brown and Company');
INSERT INTO Publisher_T
VALUES(914961,'Knopf Doubleday Publishing Group');
INSERT INTO Publisher_T
VALUES(281519,'Scholastic, Inc.');
INSERT INTO Publisher_T
VALUES(223728,'ABRAMS');
INSERT INTO Publisher_T
VALUES(288947,'Grand Central Publishing');
INSERT INTO Publisher_T
VALUES(906372,'Random House Publishing Group');

INSERT INTO Author_T
VALUES(1301588,'Obama','Barack');
INSERT INTO Author_T
VALUES(2585648,'Patterson','James');
INSERT INTO Author_T
VALUES(1802283,'Grisham','John');
INSERT INTO Author_T
VALUES(3146938,'Rowling','J. K.');
INSERT INTO Author_T
VALUES(2244816,'Kinney','Jeff');
INSERT INTO Author_T
VALUES(2874640,'Baldacci','David');
INSERT INTO Author_T
VALUES(9705577,'Sparks','Nicholas');
INSERT INTO Author_T
VALUES(9661396,'Cline','Ernest');

# Populates Product table with information on each product (AFTER updating Publisher and Author tables)
# Products with null value in genre, pages, and author must specify columns in VALUES statement
INSERT INTO Product_T
VALUES('prd9781524763169','Print','A Promised Land','Biography',45.00,768,1301588,126317);
INSERT INTO Product_T
VALUES('prd9781524763169','Digital','A Promised Land','Biography',17.99,768,1301588,126317);
INSERT INTO Product_T (Pnumber, Ptype, Ptitle, Pgenre, Pprice, AuthID, PubID)
VALUES('prd9781524763169','Audiobook','A Promised Land','Biography',34.99,1301588,126317);
INSERT INTO Product_T
VALUES('prd9780316420259','Print','Deadly Cross (Alex Cross Series #26)','Mystery & Thriller',29.00,416,2585648,878429);
INSERT INTO Product_T
VALUES('prd9780385545969','Print','A Time for Mercy','General Fiction',29.95,480,1802283,914961);
INSERT INTO Product_T
VALUES('prd9781338732870','Print','The Ickabog','Sci-Fi & Fantasy',26.99,304,3146938,281519);
INSERT INTO Product_T
VALUES('prd9781338732870','Digital','The Ickabog','Sci-Fi & Fantasy',17.99,304,3146938,281519);
INSERT INTO Product_T (Pnumber, Ptype, Ptitle, Pgenre, Pprice, AuthID, PubID)
VALUES('prd9781338732870','Audiobook','The Ickabog','Sci-Fi & Fantasy',26.99,3146938,281519);
INSERT INTO Product_T
VALUES('prd9781419748684','Print','The Deep End (Diary of a Wimpy Kid Series #15)',"Kids' Books",14.99,224,2244816,281519);
INSERT INTO Product_T
VALUES('prd9781538761694','Print','Daylight (Atlee Pine Series #3)','Thriller',29.00,416,2874640,288947);
INSERT INTO Product_T
VALUES('prd9781538728574','Print','The Return','Romance',28.00,368,9705577,288947);
INSERT INTO Product_T (Pnumber, Ptype, Ptitle, Pgenre, Pprice, AuthID, PubID)
VALUES('prd9781538728574','Digital','The Return','Romance',13.99,9705577,288947);
INSERT INTO Product_T
VALUES('prd9781524761332','Print','Ready Player Two','Sci-Fi & Fantasy',28.99,384,9661396,906372);
INSERT INTO Product_T
VALUES('prd9781524761332','Digital','Ready Player Two','Sci-Fi & Fantasy',14.99,384,9661396,906372);

SELECT Product_T.*, CONCAT(Author_T.AuthFname, " ", Author_T.AuthLname) AS AuthorName, Publisher_T.Pubname
	FROM Product_T, Author_T, Publisher_T
    WHERE Product_T.AuthID = Author_T.AuthID
    AND Product_T.PubID = Publisher_T.PubID;

# Generates data for 50 customers’ email, last name, first name, password, security number, and security answer.
INSERT INTO User_T
VALUES("jwheeler@yahoo.com","Wheeler","Joshua","#*traPye6r",2,"Arellano");
INSERT INTO User_T
VALUES("jmendoza@yahoo.com","Mendoza","Jeffrey","C+nsD4EhwW",2,"Dixon");
INSERT INTO User_T
VALUES("phamilton@yahoo.com","Hamilton","Phillip","*s1OG_wqlN",1,"Hendrixmouth");
INSERT INTO User_T
VALUES("lhenderson@gmail.com","Henderson","Lori","&GEkp2aB6c",3,"Nature conservation officer");
INSERT INTO User_T
VALUES("jluna@aol.com","Luna","James","QFP#Mhpj+2",2,"Flores");
INSERT INTO User_T
VALUES("arobbins@yahoo.com","Robbins","Adam",")4FVD4Os94",2,"Clark");
INSERT INTO User_T
VALUES("ncarpenter@hotmail.com","Carpenter","Nancy","!3VsV$RB)o",3,"Automotive engineer");
INSERT INTO User_T
VALUES("ejones@gmail.com","Jones","Emily","dj5LX_cCw@",4,"Shrek");
INSERT INTO User_T
VALUES("asolomon@hotmail.com","Solomon","Alexander","s3GKZWvp+5",1,"North Alexistown");
INSERT INTO User_T
VALUES("gbishop@gmail.com","Bishop","Gregory","+K0PHAh@j_",1,"Andrealand");
INSERT INTO User_T
VALUES("asandoval@aol.com","Sandoval","Angela","2!+PoUaB%m",3,"Psychologist, clinical");
INSERT INTO User_T
VALUES("cwu@yahoo.com","Wu","Christopher","e_11Cq+c3s",2,"Jacobs");
INSERT INTO User_T
VALUES("emcknight@yahoo.com","Mcknight","Erika","V*7yXYRhbE",2,"Tran");
INSERT INTO User_T
VALUES("edavis@gmail.com","Davis","Eduardo","c(P0LzRk@^",3,"Investment banker, operational");
INSERT INTO User_T
VALUES("kcaldwell@hotmail.com","Caldwell","Kenneth","%3zJ8nxzj6",4,"Bee Movie");
INSERT INTO User_T
VALUES("hali@yahoo.com","Ali","Heather","iX#ts3Wxdo",4,"Shrek");
INSERT INTO User_T
VALUES("epotts@hotmail.com","Potts","Eugene","%3dXBCD!y8",3,"Teacher, music");
INSERT INTO User_T
VALUES("rlynch@gmail.com","Lynch","Richard","_mDt@Ov&d4",3,"Personnel officer");
INSERT INTO User_T
VALUES("jcarroll@aol.com","Carroll","Jose","cCFiv0Km+7",3,"Geochemist");
INSERT INTO User_T
VALUES("kmitchell@gmail.com","Mitchell","Kimberly","2#RdFyvf&I",4,"Bee Movie");
INSERT INTO User_T
VALUES("jcastillo@hotmail.com","Castillo","John","jH@UW#gt)7",4,"Bee Movie");
INSERT INTO User_T
VALUES("rmeza@hotmail.com","Meza","Riley","J*8tVEt@A3",1,"Manuelmouth");
INSERT INTO User_T
VALUES("jjones@gmail.com","Jones","Justin","dP48O1SeS(",2,"Guzman");
INSERT INTO User_T
VALUES("srodriguez@yahoo.com","Rodriguez","Shelley","(7Es*&Nlw9",4,"Shrek 2");
INSERT INTO User_T
VALUES("hhubbard@hotmail.com","Hubbard","Hannah",")lxYCWyr18",4,"Shrek 2");
INSERT INTO User_T
VALUES("awagner@aol.com","Wagner","Antonio","3P%wtEVg*F",4,"Bee Movie");
INSERT INTO User_T
VALUES("kwilcox@gmail.com","Wilcox","Kristin","&+@4g8YmqZ",1,"South Charlesburgh");
INSERT INTO User_T
VALUES("bgrant@gmail.com","Grant","Brenda","_dUmMIw#_6",1,"Shannonberg");
INSERT INTO User_T
VALUES("vburgess@hotmail.com","Burgess","Victoria","E!x9%VEdtR",1,"Conleychester");
INSERT INTO User_T
VALUES("bhoover@hotmail.com","Hoover","Blake","a6L*stAy+L",3,"Research scientist (medical)");
INSERT INTO User_T
VALUES("dbeck@hotmail.com","Beck","Derrick","ti7%BiK@o!",1,"Lake Laurashire");
INSERT INTO User_T
VALUES("danderson@aol.com","Anderson","Donna","Fw+7YrTE@!",1,"Estradafort");
INSERT INTO User_T
VALUES("ifernandez@yahoo.com","Fernandez","Isaac","%XW7OMLjFu",3,"Artist");
INSERT INTO User_T
VALUES("vcarroll@yahoo.com","Carroll","Vanessa","xu7P@XkI&w",1,"South Corey");
INSERT INTO User_T
VALUES("cparker@gmail.com","Parker","Courtney","avTk1Y9dg%",2,"Rich");
INSERT INTO User_T
VALUES("jdunlap@gmail.com","Dunlap","Jacob","2@(2ZpvT2I",3,"Insurance claims handler");
INSERT INTO User_T
VALUES("gwilson@yahoo.com","Wilson","George","*9DAN8j(Lb",1,"Sweeneystad");
INSERT INTO User_T
VALUES("criley@aol.com","Riley","Christine",")0i*dAtoOd",2,"Rios");
INSERT INTO User_T
VALUES("jgarcia@aol.com","Garcia","Jonathan","+evAaDW4)9",1,"Angelamouth");
INSERT INTO User_T
VALUES("preynolds@yahoo.com","Reynolds","Patricia","f(2L0Ldc5_",4,"Shrek 2");
INSERT INTO User_T
VALUES("aquinn@aol.com","Quinn","Anna","&^286XiqFa",2,"Rogers");
INSERT INTO User_T
VALUES("jhoffman@hotmail.com","Hoffman","Jeanette","6Q*+7_Qoid",4,"Shrek 2");
INSERT INTO User_T
VALUES("mmonroe@hotmail.com","Monroe","Michael","!RYVTK^iN8",1,"Erinfort");
INSERT INTO User_T
VALUES("shill@gmail.com","Hill","Sarah","2ExRk2wn)4",3,"Biochemist, clinical");
INSERT INTO User_T
VALUES("lmedina@gmail.com","Medina","Lawrence","T#1VGWbCb@",2,"Davis");
INSERT INTO User_T
VALUES("tmartin@aol.com","Martin","Trevor","!4TgAyaSU$",4,"Shrek 2");
INSERT INTO User_T
VALUES("bcole@yahoo.com","Cole","Brandon","(t3wBZ8di@",2,"Weaver");
INSERT INTO User_T
VALUES("eclark@aol.com","Clark","Elizabeth","O!m7VOp^81",1,"Brownstad");
INSERT INTO User_T
VALUES("jgarcia@gmail.com","Garcia","Jennifer","+7EP4MvC2W",3,"Prison officer");
INSERT INTO User_T
VALUES("rsnow@gmail.com","Snow","Robert","*jz#5NwD7d",1,"New Lindsay");

# Returns data on all customers; notice there are 50 rows as of now
SELECT * FROM User_T;

# User deletes account
DELETE FROM User_T WHERE Uemail = "rsnow@gmail.com";

# Now notice there are only 49 rows after executing above DELETE statement
SELECT * FROM User_T;

# Orders placed by the registered users.
INSERT INTO Order_T
VALUES(153513821,'2020-11-22','lmedina@gmail.com');
INSERT INTO Order_T
VALUES(153513822,'2020-11-24','bcole@yahoo.com');
INSERT INTO Order_T
VALUES(153513823,'2020-11-25','jgarcia@gmail.com');
INSERT INTO Order_T
VALUES(153513824,'2020-11-27','lmedina@gmail.com');
INSERT INTO Order_T
VALUES(153513825,'2020-11-27','kmitchell@gmail.com');

# Lines of each order placed above.
INSERT INTO OrderLine_T
VALUES(1382123457,153513821,'prd9781524763169','Print',2);
INSERT INTO OrderLine_T
VALUES(1382123458,153513821,'prd9780385545969','Print',1);
INSERT INTO OrderLine_T
VALUES(1382256789,153513822,'prd9780316420259','Print',1);
INSERT INTO OrderLine_T
VALUES(1382346890,153513823,'prd9780316420259','Print',1);
INSERT INTO OrderLine_T
VALUES(1382423456,153513824,'prd9781524763169','Audiobook',1);
INSERT INTO OrderLine_T
VALUES(1382423457,153513824,'prd9781338732870','Audiobook',1);
INSERT INTO OrderLine_T
VALUES(1382423458,153513824,'prd9781524761332','Print',1);
INSERT INTO OrderLine_T
VALUES(1382423459,153513824,'prd9781538761694','Print',1);
INSERT INTO OrderLine_T
VALUES(1382512346,153513825,'prd9781538728574','Digital',1);
INSERT INTO OrderLine_T
VALUES(1382512347,153513825,'prd9781524761332','Digital',1);
INSERT INTO OrderLine_T
VALUES(1382512348,153513825,'prd9781338732870','Digital',1);
INSERT INTO OrderLine_T
VALUES(1382512349,153513825,'prd9781524763169','Digital',1);
INSERT INTO OrderLine_T
VALUES(1382512350,153513825,'prd9781524763169','Print',1);

SELECT * FROM Invoice;
SELECT OID, ULname, UFname, SUM(SubTotal)
FROM Invoice
	WHERE OID = 153513821;

# Creates ratings for products that users have purchased
INSERT INTO Rating_T
VALUES(5,"Couldn't Put It Down",'lmedina@gmail.com',153513821,'prd9781524763169','Print');
INSERT INTO Rating_T (Rscore,Uemail,OID,Pnumber,Ptype)
VALUES(3,'kmitchell@gmail.com',153513825,'prd9781524763169','Digital');
INSERT INTO Rating_T
VALUES(4,"Challenging Read",'lmedina@gmail.com',153513824,'prd9781338732870','Audiobook');
INSERT INTO Rating_T
VALUES(4,"Action Packed",'bcole@yahoo.com',153513822,'prd9780316420259','Print');
INSERT INTO Rating_T
VALUES(2,"Spooky",'jgarcia@gmail.com',153513823,'prd9780316420259','Print');
INSERT INTO Rating_T
VALUES(5,"Made Me Smarter",'kmitchell@gmail.com',153513825,'prd9781338732870','Digital');

SELECT * FROM Product_Profile;