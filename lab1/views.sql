
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
    col6 AS (SELECT Students.idnr AS student, sum(PassedCourses.credits) AS credits
            FROM Students, StudentBranches, RecommendedBranch, PassedCourses
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
