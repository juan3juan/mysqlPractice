CREATE DATABASE practice
USE practice

CREATE TABLE Student(
	Sid VARCHAR(20),
	Sname NVARCHAR(20),
	Sage DATETIME,
	Ssex NVARCHAR(20)
)
INSERT INTO Student VALUES('01' , '����' , '1990-01-01' , '��');
INSERT INTO Student VALUES('02' , 'Ǯ��' , '1990-12-21' , '��');
INSERT INTO Student VALUES('03' , '���' , '1990-05-20' , '��');
INSERT INTO Student VALUES('04' , '����' , '1990-08-06' , '��');
INSERT INTO Student VALUES('05' , '��÷' , '1991-12-01' , 'Ů');
INSERT INTO Student VALUES('06' , '����' , '1992-03-01' , 'Ů');
INSERT INTO Student VALUES('07' , '֣��' , '1989-07-01' , 'Ů');
INSERT INTO Student VALUES('08' , '����' , '1990-01-20' , 'Ů');

CREATE TABLE IF NOT EXISTS Course(Cid VARCHAR(10),Cname NVARCHAR(10),Tid VARCHAR(10))
INSERT INTO Course VALUES('01' , '����' , '02');
INSERT INTO Course VALUES('02' , '��ѧ' , '01');
INSERT INTO Course VALUES('03' , 'Ӣ��' , '03');

CREATE TABLE Teacher(Tid VARCHAR(10),Tname NVARCHAR(10))
INSERT INTO Teacher VALUES('01' , N'����');
INSERT INTO Teacher VALUES('02' , N'����');  
INSERT INTO Teacher VALUES('03' , N'����');

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


1. ��ѯ" 01 "�γ̱�" 02 "�γ̳ɼ��ߵ�ѧ������Ϣ���γ̷���
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


2. ��ѯƽ���ɼ����ڵ��� 60 �ֵ�ͬѧ��ѧ����ź�ѧ��������ƽ���ɼ�
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

3. ��ѯ�� SC ����ڳɼ���ѧ����Ϣ
SELECT s.* FROM student s WHERE s.sid IN (SELECT sid FROM sc WHERE score IS NOT NULL)

4. ��ѯ����ͬѧ��ѧ����š�ѧ��������ѡ�����������пγ̵��ܳɼ�(û�ɼ�����ʾΪ NULL ) (WHERE ��inner JOIN, ����ʾnull��
SELECT s.sid, s.sname, COUNT(cid) AS totalCourse, SUM(score) AS totalScore
FROM student s LEFT JOIN sc
ON s.sid=sc.`Sid`
GROUP BY s.sid

4.1 ���гɼ���ѧ����Ϣ
SELECT s.sid, s.sname, COUNT(cid) AS totalCourse, SUM(score) AS totalScore,
	SUM(CASE WHEN cid=01 THEN score ELSE NULL END) AS score_01,
	SUM(CASE WHEN cid=02 THEN score ELSE NULL END) AS score_02,
	SUM(CASE WHEN cid=03 THEN score ELSE NULL END) AS score_03
FROM student AS s, sc
WHERE s.sid=sc.`Sid`
GROUP BY s.sid

5. ��ѯ�������ʦ������
SELECT COUNT(tname) 
FROM teacher
WHERE tname LIKE '��%'

6. ��ѯѧ������������ʦ�ڿε�ͬѧ����Ϣ
SELECT s.* 
FROM student s 
LEFT JOIN sc ON s.sid=sc.`Sid`
LEFT JOIN course c ON sc.cid=c.cid
LEFT JOIN  teacher t ON t.tid=c.tid
WHERE t.tname = '����'

SELECT * FROM student WHERE sid IN (
	SELECT sid FROM sc, course c, teacher t
	WHERE sc.cid=c.cid AND c.tid=t.tid AND tname='����'
)

7. ��ѯû��ѧȫ���пγ̵�ͬѧ����Ϣ
SELECT * FROM student WHERE sid IN (
	SELECT sid FROM sc 
	GROUP BY sid 
	HAVING COUNT(cid)<3)

8. ��ѯ������һ�ſ���ѧ��Ϊ" 01 "��ͬѧ��ѧ��ͬ��ͬѧ����Ϣ
SELECT * FROM student WHERE sid IN(
	SELECT DISTINCT sid FROM sc 
	WHERE cid IN (SELECT cid FROM sc WHERE sid='01')
 

9. ��ѯ��" 01 "�ŵ�ͬѧѧϰ�Ŀγ���ȫ��ͬ������ͬѧ����Ϣ
SELECT * FROM student WHERE sid IN(
	SELECT sid FROM sc
	WHERE cid IN ( SELECT cid FROM sc WHERE sid='01') AND sid != '01' 
	GROUP BY sid
	HAVING COUNT(cid)>=3
)

	
10. ��ѯûѧ��"����"��ʦ���ڵ���һ�ſγ̵�ѧ������
SELECT sname FROM student WHERE sid NOT IN (
	SELECT sid FROM sc 
	LEFT JOIN course c ON sc.cid=c.cid
	LEFT JOIN teacher t ON t.tid=c.tid
	WHERE t.tname='����'
)

SELECT sname FROM student WHERE sname NOT IN (
    SELECT s.sname
    FROM student AS s, course AS c, teacher AS t, sc
    WHERE s.sid = sc.sid
        AND sc.cid = c.cid
        AND c.tid = t.tid
        AND t.tname = '����'
)
	
11. ��ѯ���ż������ϲ�����γ̵�ͬѧ��ѧ�ţ���������ƽ���ɼ� 
SELECT s.sid, s.sname, AVG(sc.score)
FROM student s , sc
WHERE s.sid=sc.sid AND score<60
GROUP BY s.sid
HAVING COUNT(sc.score)>=2

12. ����" 01 "�γ̷���С�� 60���������������е�ѧ����Ϣ
SELECT * FROM student WHERE sid IN (
	SELECT sid FROM sc WHERE score<60 AND cid='01'
	ORDER BY score DESC)

SELECT s.*, score FROM student s, sc WHERE
s.sid=sc.sid AND sc.`score`<60 AND sc.`Cid`='01'
ORDER BY score DESC

13. ��ƽ���ɼ��Ӹߵ�����ʾ����ѧ�������пγ̵ĳɼ��Լ�ƽ���ɼ�
SELECT s.sid, s.sname,
	SUM(CASE WHEN cid=01 THEN score ELSE NULL END) AS score_01,
	SUM(CASE WHEN cid=02 THEN score ELSE NULL END) AS score_02,
	SUM(CASE WHEN cid=03 THEN score ELSE NULL END) AS score_03,
	AVG(score)
FROM sc, student s
WHERE s.sid=sc.sid
GROUP BY s.sid
ORDER BY AVG(score) DESC

14. ��ѯ���Ƴɼ���߷֡���ͷֺ�ƽ���֣���������ʽ��ʾ���γ� ID���γ� name����߷֣���ͷ֣�ƽ���֣������ʣ��е��ʣ������ʣ�������(����Ϊ>=60���е�Ϊ��70-80������Ϊ��80-90������Ϊ��>=90���� 
SELECT c.cid AS �γ̺�, c.cname AS �γ�����, COUNT(*) AS ѡ������,
    MAX(score) AS ��߷�, MIN(score) AS ��ͷ�, AVG(score) AS ƽ����,
    SUM(CASE WHEN score >= 60 THEN 1 ELSE 0 END)/COUNT(*) AS ������,
    SUM(CASE WHEN score >= 70 AND score < 80 THEN 1 ELSE 0 END)/COUNT(*) AS �е���,
    SUM(CASE WHEN score >= 80 AND score < 90 THEN 1 ELSE 0 END)/COUNT(*) AS ������,
    SUM(CASE WHEN score >= 90 THEN 1 ELSE 0 END)/COUNT(*) AS ������
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

17. ͳ�Ƹ��Ƴɼ����������������γ̱�ţ��γ����ƣ�[100-85]��[85-70]��[70-60]��[60-0] ����ռ�ٷֱ�
SELECT c.cname, a.*
FROM course c,(
SELECT cid, 
	SUM(CASE WHEN score>=85 THEN 1 ELSE 0 END)/COUNT(*) AS 100_85,
	SUM(CASE WHEN score>=70 AND score<85 THEN 1 ELSE 0 END)/COUNT(*) AS 85_70,
	SUM(CASE WHEN score>=60 AND score<70 THEN 1 ELSE 0 END)/COUNT(*) AS 70_60,
	SUM(CASE WHEN score<60 THEN 1 ELSE 0 END)/COUNT(*) AS 60_0
FROM sc GROUP BY cid) AS a
WHERE c.cid=a.cid	

18. ��ѯ���Ƴɼ�ǰ�����ļ�¼
SELECT * FROM (
SELECT *, rank() over(PARTITION BY cid ORDER BY score DESC) AS rank FROM sc) AS a
WHERE a.rank<=3

SELECT * FROM (SELECT *, rank()over (PARTITION BY cid ORDER BY score DESC) AS graderank FROM sc) A 
WHERE A.graderank <= 3

20. ��ѯ��ֻѡ�����ſγ̵�ѧ��ѧ�ź�����
SELECT s.sname, s.sid FROM student s, sc
WHERE s.sid=sc.`Sid` 
GROUP BY s.sid
HAVING COUNT(cid)=2

24. ��ѯ 1990 �������ѧ������
SELECT * FROM student WHERE YEAR(sage) = 1990

33. �ɼ����ظ�����ѯѡ�ޡ���������ʦ���ڿγ̵�ѧ���У��ɼ���ߵ�ѧ����Ϣ����ɼ�
SELECT s.*, MAX(score) 
FROM student s, sc, course c, teacher t
WHERE s.sid=sc.`Sid` AND sc.`Cid`=c.cid AND c.tid=t.tid AND t.tname='����'

40. ��ѯ��ѧ�������䣬ֻ���������
SELECT sname, YEAR(NOW())-YEAR(sage) AS age FROM student

41. ���ճ����������㣬��ǰ���� < �������µ������������һ
SELECT sname, TIMESTAMPDIFF(YEAR, sage, NOW()) AS age FROM student

42. ��ѯ��(��)�ܹ����յ�ѧ��
SELECT * FROM student WHERE WEEK(NOW()+1) = WEEK(sage)

43. SQL stored PROCEDURE
CALL practice.`SelectStudent`(6);


