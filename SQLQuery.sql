--1.Hər Publisherin ən az səhifəli kitabını ekrana çıxarın
SELECT Books.Name, Press.Name 
FROM Books
JOIN Press ON Books.Id_Press = Press.Id
WHERE Books.Pages = ANY(SELECT MIN(Pages) FROM Books
JOIN Press ON Books.Id_Press = Press.Id GROUP BY Press.Id)
GROUP BY Books.Id_Press, Books.Name, Books.Pages, Press.Name 

--2.Publisherin ümumi çap etdiyi kitabların orta səhifəsi 100dən yuxarıdırsa, o Publisherləri ekrana çıxarın
SELECT Books.Name,Books.Pages, Press.Name
FROM Books
JOIN Press ON Books.Id_Press = Press.Id
GROUP BY Books.Id_Press, Books.Name, Books.Pages, Press.Name
HAVING AVG(Pages) > 100

--3.BHV və BİNOM Publisherlərinin kitabların bütün cəmi səhifəsini ekrana çıxarın
SELECT Press.Name, SUM(Pages) AS 'Sum of Pages'
FROM Books
JOIN Press ON Books.Id_Press = Press.Id
WHERE Press.Name = 'BHV' OR Press.Name = 'Binom'
GROUP BY Press.Name

--4.Yanvarın 1-i 2001ci il və bu gün arasında kitabxanadan kitab götürən bütün tələbələrin adlarını ekrana çıxarın
SELECT  Students.FirstName AS 'FirstName', Books.Name
FROM Students
JOIN S_Cards ON Students.Id = S_Cards.Id_Student 
JOIN Books ON S_Cards.Id_Book = Books.Id 
WHERE S_Cards.DateOut > '2001-01-01' AND S_Cards.DateOut < SYSDATETIME()

--5.Olga Kokorevanın  "Windows 2000 Registry" kitabı üzərində işləyən tələbələri tapın
SELECT Students.FirstName ,Books.Name
From Students
JOIN S_Cards ON Students.Id=Id_Student
JOIN Books ON Id_Book=Books.Id
WHERE Books.Name='Windows 2000 Registry'


--6.Yazdığı bütün kitabları nəzərə aldıqda, orta səhifə sayı 600dən çox olan Yazıçılar haqqında məlumat çıxarın.

SELECT Authors.FirstName ,SUM(Pages) AS 'Pages Count'
FROM Books
JOIN  Authors ON Authors.Id=Books.Id_Author
GROUP BY Books.Pages,  Authors.FirstName
HAVING AVG(Pages) > 600


--7.Çap etdiyi bütün kitabların cəmi səhifə sayı 700dən çox olan Publisherlər haqqında ekrana məlumat çıxarın

SELECT Authors.FirstName,SUM(Pages) AS 'SUM OF PAGES'
FROM Books
JOIN Authors ON Authors.Id=Books.Id_Author
GROUP BY Authors.FirstName
HAVING SUM(Pages)>700


--8.Kitabxananın bütün ziyarətçilərini və onların götürdüyü kitabları çıxarın.

SELECT Teachers.Id, Teachers.FirstName, Books.Name, T_Cards.DateOut 
FROM Books
JOIN T_Cards ON T_Cards.Id_Book = Books.Id
JOIN Teachers ON T_Cards.Id_Teacher = Teachers.Id
UNION
SELECT Students.Id, Students.FirstName, Books.Name, S_Cards.DateOut 
FROM Books
JOIN S_Cards ON S_Cards.Id_Book = Books.Id
JOIN Students ON S_Cards.Id_Student = Students.Id

--9. Studentlər arasında ən məşhur author(lar) və onun(ların) götürülmüş kitablarının sayını çıxarın.

SELECT TOP 1 WITH TIES Authors.FirstName , Books.Name AS 'BOOK  NAME', COUNT(S_Cards.Id_Book) AS 'Books Count'
FROM S_Cards
JOIN Students ON S_Cards.Id_Student = Students.Id
JOIN Books ON S_Cards.Id_Book = Books.Id
JOIN Authors ON Books.Id_Author = Authors.Id
GROUP BY S_Cards.Id_Book, Authors.FirstName, Books.Name
ORDER BY COUNT(S_Cards.Id_Book)  DESC




--10.Tələbələr arasında ən məşhur author(lar) və onun(ların) götürülmüş kitablarının sayını çıxarın.

SELECT TOP 1 WITH TIES Authors.FirstName,Books.Name AS 'BOOKS NAME', COUNT(T_Cards.Id_Book) AS 'Books Count'
FROM T_Cards
JOIN Teachers ON T_Cards.Id_Teacher = Teachers.Id
JOIN Books ON T_Cards.Id_Book = Books.Id
JOIN Authors ON Books.Id_Author = Authors.Id
GROUP BY T_Cards.Id_Book, Authors.FirstName, Authors.LastName, Books.Name
ORDER BY COUNT(T_Cards.Id_Book) DESC

--11.Student və Teacherlər arasında ən məşhur mövzunu(ları) çıxarın.

SELECT TOP 1 WITH TIES Themes.Name, COUNT(Themes.Name) AS 'Themes name' 
FROM Books
JOIN Themes ON Themes.Id = Books.Id_Themes
GROUP BY Themes.Name
ORDER BY COUNT(Themes.Name) DESC

--12.Kitabxanaya neçə tələbə və neçə müəllim gəldiyini ekrana çıxarın

--alnmadi

--13.. Əgər bütün kitabların sayını 100% qəbul etsək, siz hər fakultənin neçə faiz kitab götürdüyünü hesablamalısınız.

--

--14.Ən çox oxuyan fakultə cə dekanatlığı ekrana çıxarın

SELECT COUNT(Groups.Id_Faculty) AS 'Taken books', Groups.Id_Faculty AS 'Id', 'Faculty' AS 'Departments'
FROM Students
JOIN S_Cards ON Students.Id = S_Cards.Id_Student
JOIN Groups ON Groups.Id = Students.Id_Group
GROUP BY Groups.Id_Faculty
HAVING COUNT(Groups.Id_Faculty) >= ALL(SELECT COUNT(Groups.Id_Faculty)  FROM Students
									   JOIN S_Cards ON Students.Id = S_Cards.Id_Student
									   JOIN Groups ON Groups.Id = Students.Id_Group
									   GROUP BY Groups.Id_Faculty)
UNION 
SELECT COUNT(Departments.Id) AS 'Taken books', Departments.Id, 'Dec' 
FROM Teachers
JOIN T_Cards ON Teachers.Id = T_Cards.Id_Teacher
JOIN Departments ON Departments.Id = Teachers.Id_Dep
GROUP BY Departments.Id
HAVING COUNT(Departments.Id) >= ALL(SELECT COUNT(Departments.Id) FROM Teachers
									JOIN T_Cards ON Teachers.Id = T_Cards.Id_Teacher
									JOIN Departments ON Departments.Id = Teachers.Id_Dep
									GROUP BY Departments.Id)
ORDER BY COUNT(Groups.Id_Faculty) DESC 

--15.Tələbələr və müəllimlər arasında ən məşhur authoru çıxarın

SELECT TOP 1 WITH TIES  Authors.FirstName
FROM Books
JOIN Authors ON Books.Id_Author = Authors.Id
JOIN S_Cards ON S_Cards.Id_Book = Books.Id
JOIN Students ON Students.Id = S_Cards.Id_Student
JOIN T_Cards ON T_Cards.Id_Book = Books.Id
JOIN Teachers ON Teachers.Id = T_Cards.Id_Teacher
GROUP BY Authors.Id, Authors.FirstName
ORDER BY COUNT(Id_Author) DESC

--16. Müəllim və Tələbələr arasında ən məşhur kitabların adlarını çıxarın.

SELECT TOP 1 WITH TIES  Books.[Name] 
FROM Books
JOIN S_Cards ON S_Cards.Id_Book = Books.Id
JOIN Students ON Students.Id = S_Cards.Id_Student
JOIN T_Cards ON T_Cards.Id_Book = Books.Id
JOIN Teachers ON Teachers.Id = T_Cards.Id_Teacher
GROUP BY  Books.[Name]
ORDER BY COUNT(Books.Id) DESC

--17.Dizayn sahəsində olan bütün tələbə və müəllimləri ekrana çıxarın

SELECT Students.FirstName , 'Student' AS [position]
FROM Students
JOIN Groups ON Groups.Id = Students.Id_Group
WHERE Groups.Id_Faculty = 2
UNION
SELECT Teachers.FirstName , 'Teacher' 
FROM Teachers
JOIN Departments ON Departments.Id = Teachers.Id_Dep
WHERE Departments.Id = 2
ORDER BY [position]


--18.. Kitab götürən tələbə və müəllimlər haqqında informasiya çıxarın

SELECT Students.FirstName , 'Student' AS [position]
FROM Students
JOIN S_Cards ON S_Cards.Id_Student = Students.Id
UNION
SELECT Teachers.FirstName , 'Teacher' 
FROM Teachers
JOIN T_Cards ON T_Cards.Id_Teacher = Teachers.Id
ORDER BY [position]


--19.Müəllim və şagirdlərin cəmi neçə kitab götürdüyünü ekrana çıxarın.

SELECT COUNT(Books.Id) AS 'Book Id', 'Student' AS [position] 
FROM Books
JOIN S_Cards ON S_Cards.Id_Book = Books.Id
UNION
SELECT COUNT(Books.Id), 'Teacher' 
FROM Books
JOIN T_Cards ON T_Cards.Id_Book = Books.Id
ORDER BY [position]

--20.Hər kitbxanaçının (libs) neçə kitab verdiyini ekrana çıxarın

SELECT Libs.Id, COUNT(Books.Id) AS 'Books id', 'Student' AS [position] 
FROM Books
JOIN S_Cards ON S_Cards.Id_Book = Books.Id
JOIN Libs ON Libs.Id = S_Cards.Id_Lib
GROUP BY Libs.Id
UNION ALL
SELECT Libs.Id, COUNT(Books.Id) , 'Teacher' 
FROM Books
JOIN T_Cards ON T_Cards.Id_Book = Books.Id
JOIN Libs ON Libs.Id = T_Cards.Id_Lib
GROUP BY Libs.Id