

CREATE VIEW BasicInformation AS
    SELECT students.idnr,name,login,students.program,branch
        FROM students LEFT OUTER JOIN studentbranches
        ON students.idnr = studentbranches.idnr;


CREATE VIEW FinishedCourses AS
    SELECT idnr AS student,Taken.course,grade,credits
        FROM Taken JOIN Courses ON Taken.course=Courses.course;


CREATE VIEW PassedCourses AS
    SELECT idnr AS student,Taken.course,credits
        FROM Taken JOIN Courses on Taken.course=Courses.course
        WHERE Taken.grade<>'U';


CREATE VIEW Registrations AS
    SELECT idnr AS student,course,(SELECT 'registered' AS status)
        FROM Registered
    UNION
    SELECT idnr AS student,course,(SELECT 'waiting' AS status)
        FROM WaitingList;


CREATE VIEW DidMandatoryProgram AS
    SELECT PassedCourses.student,
           PassedCourses.course,
           MandatoryProgram.program
    FROM Students 
    LEFT OUTER JOIN PassedCourses
        ON Students.idnr = PassedCourses.student
    LEFT OUTER JOIN MandatoryProgram
        ON MandatoryProgram.course = PassedCourses.course
    WHERE Students.program = MandatoryProgram.program;


CREATE VIEW DidMandatoryBranch AS
    SELECT PassedCourses.student,
           PassedCourses.course,
           MandatoryBranch.branch,
           MandatoryBranch.program
    FROM StudentBranches
    LEFT OUTER JOIN PassedCourses
        ON StudentBranches.idnr = PassedCourses.student
    LEFT OUTER JOIN MandatoryBranch
        ON MandatoryBranch.course = PassedCourses.course
    WHERE StudentBranches.program = MandatoryBranch.program
          AND StudentBranches.branch = MandatoryBranch.branch;


CREATE VIEW AllMandatoryProgram AS
    SELECT Students.idnr AS student,
           MandatoryProgram.program,
           MandatoryProgram.course
    FROM Students 
    LEFT OUTER JOIN MandatoryProgram
        ON Students.program = MandatoryProgram.program
    WHERE Students.program = MandatoryProgram.program;


CREATE VIEW AllMandatoryBranch AS
    SELECT StudentBranches.idnr AS student,
           MandatoryBranch.branch,
           MandatoryBranch.program,
           MandatoryBranch.course
    FROM StudentBranches
    LEFT OUTER JOIN MandatoryBranch
        ON StudentBranches.program = MandatoryBranch.program
    WHERE StudentBranches.program = MandatoryBranch.program
        AND StudentBranches.branch = MandatoryBranch.branch;


CREATE VIEW UnreadMandatoryBranch AS
    SELECT student,course FROM AllMandatoryBranch
    EXCEPT
    SELECT student,course FROM DidMandatoryBranch;


CREATE VIEW UnreadMandatoryProgram AS
    SELECT student,course FROM AllMandatoryProgram
    EXCEPT
    SELECT student,course FROM DidMandatoryProgram;


CREATE VIEW UnreadMandatory AS
    SELECT * FROM UnreadMandatoryBranch
    UNION
    SELECT * FROM UnreadMandatoryProgram;

CREATE VIEW PathToGraduation_column0_to_column5 AS
WITH col0 AS
    (
    SELECT idnr AS student FROM students
    ),
    col1 AS
    (
    SELECT student,sum(credits) AS totalcredits
        FROM PassedCourses
        GROUP BY student
    ),
    col2 AS
    (
    SELECT student,count(course) AS mandatoryleft
        FROM UnreadMandatory
        GROUP BY student
    ),
    col3 AS
    -- math credits
    (
    SELECT student,sum(credits) as credits FROM PassedCourses
        LEFT OUTER JOIN Classified
        ON PassedCourses.course = Classified.course
        WHERE class = 'math'
        GROUP BY student
    ),
    col4 AS
    -- research credits
    (
    SELECT student,sum(credits) as credits FROM PassedCourses
        LEFT OUTER JOIN Classified
        ON PassedCourses.course = Classified.course
        WHERE class = 'research'
        GROUP BY student
    ),
    col5 AS
    -- seminar courses
    (
    SELECT student,count(PassedCourses.course) as course FROM PassedCourses
        LEFT OUTER JOIN Classified
        ON PassedCourses.course = Classified.course
        WHERE class = 'seminar'
        GROUP BY student
    )
SELECT col0.student,
       coalesce(col1.totalcredits,0) AS totalcredits,
       coalesce(col2.mandatoryleft,0) AS mandatoryleft,
       coalesce(col3.credits,0) AS mathcredits,
       coalesce(col4.credits,0) AS researchcredits,
       coalesce(col5.course,0) AS seminarcourses,
       'TODO' as qualified
    FROM col0
    LEFT OUTER JOIN col1 ON col0.student=col1.student
    LEFT OUTER JOIN col2 ON col0.student=col2.student
    LEFT OUTER JOIN col3 ON col0.student=col3.student
    LEFT OUTER JOIN col4 ON col0.student=col4.student
    LEFT OUTER JOIN col5 ON col0.student=col5.student
    ORDER BY student
;

CREATE VIEW PathToGraduation AS

    WITH passedRecommended AS(
    SELECT
        Students.idnr AS student
        FROM Students
        LEFT OUTER JOIN StudentBranches
            ON Students.idnr = StudentBranches.idnr
        LEFT OUTER JOIN RecommendedBranch
            ON StudentBranches.program = RecommendedBranch.program
        LEFT OUTER JOIN PassedCourses
            ON Students.idnr = PassedCourses.Student
        WHERE
            StudentBranches.branch = RecommendedBranch.branch AND
            StudentBranches.program = RecommendedBranch.program AND
            PassedCourses.course = RecommendedBranch.course AND
            PassedCourses.credits > 10
        ORDER BY student
    )
               
    SELECT student,
           totalcredits,
           mandatoryleft,
           mathcredits,
           researchcredits,
           seminarcourses,
           (
             mandatoryleft = 0         -- mandatory courses left
             AND mathcredits > 20      -- math credits
             AND researchcredits > 10  -- research credits
             AND seminarcourses  >= 1  -- seminar curses
             AND (SELECT passedRecommended.student FROM passedRecommended)
                 = student -- student have >10 recommended credits
           ) = TRUE AS qualified

        FROM PathToGraduation_column0_to_column5
;
