CREATE DATABASE practice
USE practice

CREATE TABLE Student(
	Sid VARCHAR(20),
	Sname NVARCHAR(20),
	Sage DATETIME,
	Ssex NVARCHAR(20)
)
INSERT INTO Student VALUES('01' , '赵雷' , '1990-01-01' , '男');
INSERT INTO Student VALUES('02' , '钱电' , '1990-12-21' , '男');
INSERT INTO Student VALUES('03' , '孙风' , '1990-05-20' , '男');
INSERT INTO Student VALUES('04' , '李云' , '1990-08-06' , '男');
INSERT INTO Student VALUES('05' , '周梅' , '1991-12-01' , '女');
INSERT INTO Student VALUES('06' , '吴兰' , '1992-03-01' , '女');
INSERT INTO Student VALUES('07' , '郑竹' , '1989-07-01' , '女');
INSERT INTO Student VALUES('08' , '王菊' , '1990-01-20' , '女');

CREATE TABLE IF NOT EXISTS Course(Cid VARCHAR(10),Cname NVARCHAR(10),Tid VARCHAR(10))
INSERT INTO Course VALUES('01' , '语文' , '02');
INSERT INTO Course VALUES('02' , '数学' , '01');
INSERT INTO Course VALUES('03' , '英语' , '03');

CREATE TABLE Teacher(Tid VARCHAR(10),Tname NVARCHAR(10))
INSERT INTO Teacher VALUES('01' , N'张三');
INSERT INTO Teacher VALUES('02' , N'李四');  
INSERT INTO Teacher VALUES('03' , N'王五');

CREATE TABLE SC(Sid VARCHAR(10),Cid VARCHAR(10),score DECIMAL(18,1))
INSERT INTO SC VALUES('01' , '01' , 80);
INSERT INTO SC VALUES('01' , '02' , 90);
INSERT INTO SC VALUES('01' , '03' , 99);
INSERT INTO SC VALUES('02' , '01' , 70);
INSERT INTO SC VALUES('02' , '02' , 60);
INSERT INTO SC VALUES('02' , '03' , 80);
INSERT INTO SC VALUES('03' , '01' , 80);
INSERT INTO SC VALUES('03' , '02' , 80);
INSERT INTO SC VALUES('03' , '03' , 80);
INSERT INTO SC VALUES('04' , '01' , 50);
INSERT INTO SC VALUES('04' , '02' , 30);
INSERT INTO SC VALUES('04' , '03' , 20);
INSERT INTO SC VALUES('05' , '01' , 76);
INSERT INTO SC VALUES('05' , '02' , 87);
INSERT INTO SC VALUES('06' , '01' , 31);
INSERT INTO SC VALUES('06' , '03' , 34);
INSERT INTO SC VALUES('07' , '02' , 89);
INSERT INTO SC VALUES('07' , '03' , 98);


1. 查询" 01 "课程比" 02 "课程成绩高的学生的信息及课程分数
SELECT s.*, a.score AS s1, b.score AS s2 
FROM Student s,
(SELECT sid,score FROM SC WHERE cid='01') AS a,
(SELECT sid,score FROM SC WHERE cid=02) AS b
WHERE a.sid=b.sid AND a.score > b.score AND a.sid=s.sid

SELECT s.*, a.score AS s1, b.score AS s2 
FROM Student s,
(SELECT sid,score FROM SC WHERE cid='01') AS a LEFT JOIN 
(SELECT sid,score FROM SC WHERE cid=02) AS b
ON a.sid=b.sid 
WHERE a.score > b.score AND a.sid=s.sid


2. 查询平均成绩大于等于 60 分的同学的学生编号和学生姓名和平均成绩
SELECT s.sid, s.sname, AVG(score) AS avg_score
FROM Student s, sc 
WHERE s.sid=sc.`Sid`
GROUP BY s.sid
HAVING avg_score>=60 

SELECT s.sid, s.sname, a.score AS avg_score
FROM
student s LEFT JOIN 
(SELECT sid, AVG(score) AS score FROM sc GROUP BY sid) a 
ON a.sid=s.sid
WHERE a.score>=60

3. 查询在 SC 表存在成绩的学生信息
SELECT s.* FROM student s WHERE s.sid IN (SELECT sid FROM sc WHERE score IS NOT NULL)

4. 查询所有同学的学生编号、学生姓名、选课总数、所有课程的总成绩(没成绩的显示为 NULL ) (WHERE 是inner JOIN, 不显示null）
SELECT s.sid, s.sname, COUNT(cid) AS totalCourse, SUM(score) AS totalScore
FROM student s LEFT JOIN sc
ON s.sid=sc.`Sid`
GROUP BY s.sid

4.1 查有成绩的学生信息
SELECT s.sid, s.sname, COUNT(cid) AS totalCourse, SUM(score) AS totalScore,
	SUM(CASE WHEN cid=01 THEN score ELSE NULL END) AS score_01,
	SUM(CASE WHEN cid=02 THEN score ELSE NULL END) AS score_02,
	SUM(CASE WHEN cid=03 THEN score ELSE NULL END) AS score_03
FROM student AS s, sc
WHERE s.sid=sc.`Sid`
GROUP BY s.sid

5. 查询「李」姓老师的数量
SELECT COUNT(tname) 
FROM teacher
WHERE tname LIKE '李%'

6. 查询学过「张三」老师授课的同学的信息
SELECT s.* 
FROM student s 
LEFT JOIN sc ON s.sid=sc.`Sid`
LEFT JOIN course c ON sc.cid=c.cid
LEFT JOIN  teacher t ON t.tid=c.tid
WHERE t.tname = '张三'

SELECT * FROM student WHERE sid IN (
	SELECT sid FROM sc, course c, teacher t
	WHERE sc.cid=c.cid AND c.tid=t.tid AND tname='张三'
)

7. 查询没有学全所有课程的同学的信息
SELECT * FROM student WHERE sid IN (
	SELECT sid FROM sc 
	GROUP BY sid 
	HAVING COUNT(cid)<3)

8. 查询至少有一门课与学号为" 01 "的同学所学相同的同学的信息
SELECT * FROM student WHERE sid IN(
	SELECT DISTINCT sid FROM sc 
	WHERE cid IN (SELECT cid FROM sc WHERE sid='01')
 

9. 查询和" 01 "号的同学学习的课程完全相同的其他同学的信息
SELECT * FROM student WHERE sid IN(
	SELECT sid FROM sc
	WHERE cid IN ( SELECT cid FROM sc WHERE sid='01') AND sid != '01' 
	GROUP BY sid
	HAVING COUNT(cid)>=3
)

	
10. 查询没学过"张三"老师讲授的任一门课程的学生姓名
SELECT sname FROM student WHERE sid NOT IN (
	SELECT sid FROM sc 
	LEFT JOIN course c ON sc.cid=c.cid
	LEFT JOIN teacher t ON t.tid=c.tid
	WHERE t.tname='张三'
)

SELECT sname FROM student WHERE sname NOT IN (
    SELECT s.sname
    FROM student AS s, course AS c, teacher AS t, sc
    WHERE s.sid = sc.sid
        AND sc.cid = c.cid
        AND c.tid = t.tid
        AND t.tname = '张三'
)
	
11. 查询两门及其以上不及格课程的同学的学号，姓名及其平均成绩 
SELECT s.sid, s.sname, AVG(sc.score)
FROM student s , sc
WHERE s.sid=sc.sid AND score<60
GROUP BY s.sid
HAVING COUNT(sc.score)>=2

12. 检索" 01 "课程分数小于 60，按分数降序排列的学生信息
SELECT * FROM student WHERE sid IN (
	SELECT sid FROM sc WHERE score<60 AND cid='01'
	ORDER BY score DESC)

SELECT s.*, score FROM student s, sc WHERE
s.sid=sc.sid AND sc.`score`<60 AND sc.`Cid`='01'
ORDER BY score DESC

13. 按平均成绩从高到低显示所有学生的所有课程的成绩以及平均成绩
SELECT s.sid, s.sname,
	SUM(CASE WHEN cid=01 THEN score ELSE NULL END) AS score_01,
	SUM(CASE WHEN cid=02 THEN score ELSE NULL END) AS score_02,
	SUM(CASE WHEN cid=03 THEN score ELSE NULL END) AS score_03,
	AVG(score)
FROM sc, student s
WHERE s.sid=sc.sid
GROUP BY s.sid
ORDER BY AVG(score) DESC

14. 查询各科成绩最高分、最低分和平均分，以如下形式显示：课程 ID，课程 name，最高分，最低分，平均分，及格率，中等率，优良率，优秀率(及格为>=60，中等为：70-80，优良为：80-90，优秀为：>=90）。 
SELECT c.cid AS 课程号, c.cname AS 课程名称, COUNT(*) AS 选修人数,
    MAX(score) AS 最高分, MIN(score) AS 最低分, AVG(score) AS 平均分,
    SUM(CASE WHEN score >= 60 THEN 1 ELSE 0 END)/COUNT(*) AS 及格率,
    SUM(CASE WHEN score >= 70 AND score < 80 THEN 1 ELSE 0 END)/COUNT(*) AS 中等率,
    SUM(CASE WHEN score >= 80 AND score < 90 THEN 1 ELSE 0 END)/COUNT(*) AS 优良率,
    SUM(CASE WHEN score >= 90 THEN 1 ELSE 0 END)/COUNT(*) AS 优秀率
FROM sc, course c
WHERE c.cid = sc.cid
GROUP BY c.cid
ORDER BY COUNT(*) DESC, c.cid ASC

15. 
SELECT s.*, rank_01, rank_02, rank_03, rank_total
FROM student s
LEFT JOIN (SELECT sid, dense_rank() over(PARTITION BY cid ORDER BY score DESC) AS rank_01 FROM sc WHERE cid=01) A ON s.sid=A.sid
LEFT JOIN (SELECT sid, dense_rank() over(PARTITION BY cid ORDER BY score DESC) AS rank_02 FROM sc WHERE cid=02) B ON s.sid=B.sid
LEFT JOIN (SELECT sid, dense_rank() over(PARTITION BY cid ORDER BY score DESC) AS rank_03 FROM sc WHERE cid=03) C ON s.sid=C.sid
LEFT JOIN (SELECT sid, dense_rank() over(ORDER BY AVG(score) DESC) AS rank_total FROM sc GROUP BY sid) D ON s.sid=D.sid
ORDER BY rank_total ASC

17. 统计各科成绩各分数段人数：课程编号，课程名称，[100-85]，[85-70]，[70-60]，[60-0] 及所占百分比
SELECT c.cname, a.*
FROM course c,(
SELECT cid, 
	SUM(CASE WHEN score>=85 THEN 1 ELSE 0 END)/COUNT(*) AS 100_85,
	SUM(CASE WHEN score>=70 AND score<85 THEN 1 ELSE 0 END)/COUNT(*) AS 85_70,
	SUM(CASE WHEN score>=60 AND score<70 THEN 1 ELSE 0 END)/COUNT(*) AS 70_60,
	SUM(CASE WHEN score<60 THEN 1 ELSE 0 END)/COUNT(*) AS 60_0
FROM sc GROUP BY cid) AS a
WHERE c.cid=a.cid	

18. 查询各科成绩前三名的记录
SELECT * FROM (
SELECT *, rank() over(PARTITION BY cid ORDER BY score DESC) AS rank FROM sc) AS a
WHERE a.rank<=3

SELECT * FROM (SELECT *, rank()over (PARTITION BY cid ORDER BY score DESC) AS graderank FROM sc) A 
WHERE A.graderank <= 3

20. 查询出只选修两门课程的学生学号和姓名
SELECT s.sname, s.sid FROM student s, sc
WHERE s.sid=sc.`Sid` 
GROUP BY s.sid
HAVING COUNT(cid)=2

24. 查询 1990 年出生的学生名单
SELECT * FROM student WHERE YEAR(sage) = 1990

33. 成绩不重复，查询选修「张三」老师所授课程的学生中，成绩最高的学生信息及其成绩
SELECT s.*, MAX(score) 
FROM student s, sc, course c, teacher t
WHERE s.sid=sc.`Sid` AND sc.`Cid`=c.cid AND c.tid=t.tid AND t.tname='张三'

40. 查询各学生的年龄，只按年份来算
SELECT sname, YEAR(NOW())-YEAR(sage) AS age FROM student

41. 按照出生日期来算，当前月日 < 出生年月的月日则，年龄减一
SELECT sname, TIMESTAMPDIFF(YEAR, sage, NOW()) AS age FROM student

42. 查询本(下)周过生日的学生
SELECT * FROM student WHERE WEEK(NOW()+1) = WEEK(sage)

43. SQL stored PROCEDURE
CALL practice.`SelectStudent`(6);


