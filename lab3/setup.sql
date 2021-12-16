
-------------------------------------------------------------------------------
--                                   TABLES
-------------------------------------------------------------------------------

-- INSERT INTO Branches VALUES ('B1','Prog1');
CREATE TABLE Branches(
    name CHAR(2) NOT NULL,
    program CHAR(5) NOT NULL,
    PRIMARY KEY(name,program),
    CONSTRAINT check_valid_branch_format CHECK(name~'^B[0-9]$'),
    CONSTRAINT check_valid_program_format CHECK(program~'^Prog[0-9]$')
);

-- INSERT INTO Students VALUES ('1111111111','N1','ls1','Prog1');
CREATE TABLE Students(
    idnr CHAR(10) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    login VARCHAR(255) NOT NULL,
    program CHAR(5) NOT NULL,
    UNIQUE(login),
    CONSTRAINT check_ten_digits_allowed CHECK(idnr~'^[0-9]{10}$'),
    CONSTRAINT check_digits_characters_underscore_allowed
               CHECK(name~*'^([0-9]|[a-z_ ])*$'),
    CONSTRAINT check_valid_program_format CHECK(program~'^Prog[0-9]$')
);

-- INSERT INTO Courses VALUES ('CCC111','C1',22.5,'Dep1');
CREATE TABLE Courses(
    code CHAR(6) NOT NULL,
    name VARCHAR(255) NOT NULL,
    credits DECIMAL NOT NULL,
    department VARCHAR(255) NOT NULL,
    PRIMARY KEY(code),
    CONSTRAINT check_valid_course_format CHECK(code~'^[A-Z]{3}[0-9]{3}$'),
    CONSTRAINT check_digits_characters_underscore_allowed
               CHECK(name~*'^([0-9]|[a-z_ ])*$'),
    CONSTRAINT check_more_than_zero CHECK(credits > 0),
    CONSTRAINT check_valid_department_format CHECK(department~'^Dep[0-9]$')
);

-- INSERT INTO LimitedCourses VALUES ('CCC222',1);
CREATE TABLE LimitedCourses(
    code CHAR(6) NOT NULL,
    capacity SMALLINT NOT NULL,
    CONSTRAINT check_more_than_zero CHECK(capacity > 0),
    PRIMARY KEY(code),
    FOREIGN KEY(code) REFERENCES Courses(code)
);

-- INSERT INTO Classifications VALUES ('math');
CREATE TABLE Classifications(
    name VARCHAR(255) PRIMARY KEY,
    CONSTRAINT check_characters_underscore_allowed CHECK(name~*'^[a-z_ ]*$')
);

-- INSERT INTO Classifications VALUES ('math');
CREATE TABLE Classified(
    course CHAR(6) NOT NULL,
    classification VARCHAR(255) NOT NULL,
    PRIMARY KEY(course,classification),
    FOREIGN KEY(course) REFERENCES Courses(code),
    FOREIGN KEY(classification) REFERENCES Classifications(name)
);

-- INSERT INTO StudentBranches VALUES ('2222222222','B1','Prog1');
CREATE TABLE StudentBranches(
    student CHAR(10) NOT NULL,
    branch CHAR(2) NOT NULL,
    program CHAR(5) NOT NULL,
    PRIMARY KEY(student),
    FOREIGN KEY(student) REFERENCES Students(idnr),
    FOREIGN KEY(branch,program) REFERENCES Branches(name,program)
);

-- INSERT INTO MandatoryProgram VALUES ('CCC111','Prog1');
CREATE TABLE MandatoryProgram(
    course CHAR(6) NOT NULL,
    program CHAR(5) NOT NULL,
    PRIMARY KEY(course,program),
    FOREIGN KEY(course) REFERENCES Courses(code),
    CONSTRAINT check_valid_program_format CHECK(program~'^Prog[0-9]$')
);

-- INSERT INTO MandatoryBranch VALUES ('CCC333', 'B1', 'Prog1');
CREATE TABLE MandatoryBranch(
    course CHAR(6) NOT NULL,
    branch CHAR(2) NOT NULL,
    program CHAR(5) NOT NULL,
    PRIMARY KEY(course,branch,program),
    FOREIGN KEY(course) REFERENCES Courses(code),
    FOREIGN KEY(branch,program) REFERENCES Branches(name,program)
);

-- INSERT INTO RecommendedBranch VALUES ('CCC222', 'B1', 'Prog1');
CREATE TABLE RecommendedBranch(
    course CHAR(6) NOT NULL,
    branch CHAR(2) NOT NULL,
    program CHAR(5) NOT NULL,
    PRIMARY KEY(course,branch,program),
    FOREIGN KEY(course) REFERENCES Courses(code),
    FOREIGN KEY(branch,program) REFERENCES Branches(name,program)
);

-- INSERT INTO Registered VALUES ('1111111111','CCC111');
CREATE TABLE Registered(
    student CHAR(10) NOT NULL,
    course CHAR(6) NOT NULL,
    PRIMARY KEY(student,course),
    FOREIGN KEY(student) REFERENCES Students(idnr),
    FOREIGN KEY(course) REFERENCES Courses(code)
);

-- INSERT INTO Taken VALUES('4444444444','CCC111','5');
CREATE TABLE Taken(
    student CHAR(10) NOT NULL,
    course CHAR(6) NOT NULL,
    grade CHAR(1) NOT NULL,
    PRIMARY KEY(student,course),
    FOREIGN KEY(student) REFERENCES Students(idnr),
    FOREIGN KEY(course) REFERENCES Courses(code),
    CONSTRAINT check_valid_grade CHECK(grade IN ('U','3','4','5'))
);

-- INSERT INTO WaitingList VALUES('3333333333','CCC222',1);
CREATE TABLE WaitingList(
    student CHAR(10) NOT NULL,
    course CHAR(6) NOT NULL,
    position INTEGER NOT NULL,
    PRIMARY KEY(student,course),
    FOREIGN KEY(student) REFERENCES Students(idnr),
    FOREIGN KEY(course) REFERENCES LimitedCourses(code),
    CONSTRAINT check_status_more_than_0 CHECK(position > 0)
);

CREATE TABLE Prerequisites(
    course CHAR(6) NOT NULL,
    dependsOn CHAR(6) NOT NULL,
    PRIMARY KEY(course,dependsOn),
    FOREIGN KEY(course) REFERENCES courses(code),
    FOREIGN KEY(dependsOn) REFERENCES courses(code)
);

-------------------------------------------------------------------------------
--                                  INSERTS
-------------------------------------------------------------------------------

INSERT INTO Branches VALUES ('B1','Prog1');
INSERT INTO Branches VALUES ('B2','Prog1');
INSERT INTO Branches VALUES ('B1','Prog2');

INSERT INTO Students VALUES ('1111111111','N1','ls1','Prog1');
INSERT INTO Students VALUES ('2222222222','N2','ls2','Prog1');
INSERT INTO Students VALUES ('3333333333','N3','ls3','Prog2');
INSERT INTO Students VALUES ('4444444444','N4','ls4','Prog1');
INSERT INTO Students VALUES ('5555555555','Nx','ls5','Prog2');
INSERT INTO Students VALUES ('6666666666','Nx','ls6','Prog2');

INSERT INTO Courses VALUES ('CCC111','C1',22.5,'Dep1');
INSERT INTO Courses VALUES ('CCC222','C2',20,'Dep1');
INSERT INTO Courses VALUES ('CCC333','C3',30,'Dep1');
INSERT INTO Courses VALUES ('CCC444','C4',60,'Dep1');
INSERT INTO Courses VALUES ('CCC555','C5',50,'Dep1');

INSERT INTO LimitedCourses VALUES ('CCC222',1);
INSERT INTO LimitedCourses VALUES ('CCC333',4);

INSERT INTO Classifications VALUES ('math');
INSERT INTO Classifications VALUES ('research');
INSERT INTO Classifications VALUES ('seminar');

INSERT INTO Classified VALUES ('CCC333','math');
INSERT INTO Classified VALUES ('CCC444','math');
INSERT INTO Classified VALUES ('CCC444','research');
INSERT INTO Classified VALUES ('CCC444','seminar');


INSERT INTO StudentBranches VALUES ('2222222222','B1','Prog1');
INSERT INTO StudentBranches VALUES ('3333333333','B1','Prog2');
INSERT INTO StudentBranches VALUES ('4444444444','B1','Prog1');
INSERT INTO StudentBranches VALUES ('5555555555','B1','Prog2');

INSERT INTO MandatoryProgram VALUES ('CCC111','Prog1');

INSERT INTO MandatoryBranch VALUES ('CCC333', 'B1', 'Prog1');
INSERT INTO MandatoryBranch VALUES ('CCC444', 'B1', 'Prog2');

INSERT INTO RecommendedBranch VALUES ('CCC222', 'B1', 'Prog1');
INSERT INTO RecommendedBranch VALUES ('CCC333', 'B1', 'Prog2');

-- These are inserted in tests.sql
--INSERT INTO Registered VALUES ('1111111111','CCC111');
--INSERT INTO Registered VALUES ('1111111111','CCC222');
--INSERT INTO Registered VALUES ('1111111111','CCC333');
--INSERT INTO Registered VALUES ('2222222222','CCC222');
--INSERT INTO Registered VALUES ('5555555555','CCC222');
--INSERT INTO Registered VALUES ('5555555555','CCC333');

INSERT INTO Taken VALUES('4444444444','CCC111','5');
INSERT INTO Taken VALUES('4444444444','CCC222','5');
INSERT INTO Taken VALUES('4444444444','CCC333','5');
INSERT INTO Taken VALUES('4444444444','CCC444','5');

INSERT INTO Taken VALUES('5555555555','CCC111','5');
INSERT INTO Taken VALUES('5555555555','CCC222','4');
INSERT INTO Taken VALUES('5555555555','CCC444','3');

INSERT INTO Taken VALUES('2222222222','CCC111','U');
INSERT INTO Taken VALUES('2222222222','CCC222','U');
INSERT INTO Taken VALUES('2222222222','CCC444','U');

-- These are inserted in tests.sql
--INSERT INTO WaitingList VALUES('3333333333','CCC222',8);
--INSERT INTO WaitingList VALUES('4444444444','CCC222',2);
--INSERT INTO WaitingList VALUES('6666666666','CCC222',1);
--INSERT INTO WaitingList VALUES('3333333333','CCC333',1);
--INSERT INTO WaitingList VALUES('2222222222','CCC333',2);

 -- course = dependsOn, in case there is no prerequisites
INSERT INTO Prerequisites  VALUES('CCC111','CCC111');
INSERT INTO Prerequisites  VALUES('CCC222','CCC222');
INSERT INTO Prerequisites  VALUES('CCC333','CCC333');
INSERT INTO Prerequisites  VALUES('CCC444','CCC111');
INSERT INTO Prerequisites  VALUES('CCC444','CCC222');
INSERT INTO Prerequisites  VALUES('CCC444','CCC444');
INSERT INTO Prerequisites  VALUES('CCC555','CCC555');

-------------------------------------------------------------------------------
--                                   VIEWS
-------------------------------------------------------------------------------

CREATE VIEW BasicInformation AS
    SELECT students.idnr,name,login,students.program,branch
        FROM students LEFT OUTER JOIN studentbranches
        ON students.idnr = studentbranches.student;

CREATE VIEW FinishedCourses AS
    SELECT student,Taken.course,grade,credits
        FROM Taken JOIN Courses ON Taken.course = Courses.code;


CREATE VIEW PassedCourses AS
    SELECT student,Taken.course,credits
        FROM Taken JOIN Courses on Taken.course = Courses.code
        WHERE Taken.grade<>'U';


CREATE VIEW Registrations AS
    SELECT student,course,(SELECT 'registered' AS status)
        FROM Registered
    UNION
    SELECT student,course,(SELECT 'waiting' AS status)
        FROM WaitingList;


CREATE VIEW UnreadMandatoryHelper AS
    SELECT student,MandatoryBranch.course
        FROM StudentBranches, MandatoryBranch
        WHERE StudentBranches.branch = MandatoryBranch.branch AND
              StudentBranches.program = MandatoryBranch.program
    UNION
    SELECT Students.idnr,MandatoryProgram.course 
        FROM Students, MandatoryProgram
        WHERE Students.program = MandatoryProgram.program;


CREATE VIEW UnreadMandatory AS
    SELECT UnreadMandatoryHelper.student,UnreadMandatoryHelper.course 
        FROM UnreadMandatoryHelper
    EXCEPT 
    SELECT PassedCourses.student,PassedCourses.course 
        FROM PassedCourses;


CREATE VIEW PathToGraduationHelper AS
WITH
    -- student
    col0 AS (SELECT idnr AS student FROM students),

    -- total credits
    col1 AS (SELECT student,sum(credits) AS totalcredits
             FROM PassedCourses GROUP BY student),

    -- mandatory left
    col2 AS (SELECT student,count(course) AS mandatoryleft
             FROM UnreadMandatory GROUP BY student),

    -- math credits
    col3 AS (SELECT student,sum(credits) AS credits
             FROM PassedCourses, Classified
             WHERE PassedCourses.course = Classified.course AND
                   classification= 'math'
             GROUP BY student),

    -- research credits
    col4 AS (SELECT student,sum(credits) AS credits
             FROM PassedCourses, Classified
             WHERE classification = 'research' AND
                   PassedCourses.course = Classified.course
             GROUP BY student),

    -- seminar courses
    col5 AS (SELECT student,count(PassedCourses.course) AS course
             FROM PassedCourses, Classified
             WHERE PassedCourses.course = Classified.course AND
                   classification = 'seminar'
             GROUP BY student),

    -- recommended courses
    col6 AS (SELECT Students.idnr AS student, sum(PassedCourses.credits)
            AS credits
            FROM Students, StudentBranches, RecommendedBranch,PassedCourses
            WHERE
                Students.idnr = StudentBranches.student
                AND Students.idnr = PassedCourses.student
                AND StudentBranches.branch = RecommendedBranch.branch
                AND StudentBranches.program = RecommendedBranch.program
                AND PassedCourses.course = RecommendedBranch.course
            GROUP BY students.idnr)

SELECT col0.student,
       coalesce(col1.totalcredits,0)   AS totalcredits,
       coalesce(col2.mandatoryleft,0)  AS mandatoryleft,
       coalesce(col3.credits,0)        AS mathcredits,
       coalesce(col4.credits,0)        AS researchcredits,
       coalesce(col5.course,0)         AS seminarcourses,
       coalesce(col6.credits,0)        AS recommendedcredits
    FROM col0
    LEFT OUTER JOIN col1 ON col0.student=col1.student
    LEFT OUTER JOIN col2 ON col0.student=col2.student
    LEFT OUTER JOIN col3 ON col0.student=col3.student
    LEFT OUTER JOIN col4 ON col0.student=col4.student
    LEFT OUTER JOIN col5 ON col0.student=col5.student
    LEFT OUTER JOIN col6 ON col0.student=col6.student;


CREATE VIEW PathToGraduation AS
    SELECT student,
           totalcredits,
           mandatoryleft,
           mathcredits,
           researchcredits,
           seminarcourses,
                 mandatoryleft = 0             -- mandatory courses left
                 AND mathcredits >= 20         -- math credits
                 AND researchcredits >= 10     -- research credits
                 AND seminarcourses  >= 1      -- seminar curses
                 AND recommendedcredits >= 10  -- recommended credits
           AS qualified
        FROM PathToGraduationHelper;

-------------------------------------------------------------------------------
--                                A VIEW FOR
--                                   LAB 3
-------------------------------------------------------------------------------
-- For all students who are in the queue for a course, 
--     the course code,
--     the student's identification number,
--     the student's current place in the queue
-------------------------------------------------------------------------------

CREATE VIEW CourseQueuePositions AS
    SELECT course,student,position AS place FROM waitinglist
    UNION
    SELECT course,student,(SELECT 0 AS place) FROM registered;

