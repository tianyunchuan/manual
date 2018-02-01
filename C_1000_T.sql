DROP TABLE `C_1000`.b_宝贝明细;
DROP TABLE `C_1000`.bbmx;
DELETE FROM `C_1000`.ddmx;
CREATE DATABASE `C_1000`;
USE `C_1000`;

DROP TABLE a0001,a0101,a0102,a0103,a0104,b0001,b0101,b0102,b0103,b0104,b0105,c0001,c0101,d0001,d0101;
RENAME TABLE a_宝贝明细 TO b_宝贝明细;
UPDATE d0001 SET 商家编号 = 商家编码;
ALTER TABLE d0001 CHANGE COLUMN 商家编号 商家编码;
ALTER TABLE d0001 CHANGE 商家编号 商家编码 VARCHAR(20); 

#  A表 数据导入  =========================================================================
CREATE TABLE `a0001`(
	订单编号 VARCHAR(50),
    买家会员名 VARCHAR(50),
    买家支付宝账号 VARCHAR(50),
    买家应付货款 DECIMAL(9,2),
    买家应付邮费 DECIMAL(9,2),
    买家支付积分 INT,
    总金额 DECIMAL(9,2),
    返点积分 INT,
    买家实际支付金额 DECIMAL(9,2),
    买家实际支付积分 INT,
    订单状态 VARCHAR(50),
    买家留言 VARCHAR(50),
    收货人姓名 VARCHAR(50),
    收货地址 VARCHAR(150) ,
    运送方式 VARCHAR(50),
    联系电话 VARCHAR(50) ,
    联系手机 VARCHAR(50),
    订单创建时间 DATE,
    订单付款时间 DATE,
    宝贝标题 VARCHAR(300) ,
    宝贝种类 INT,
    物流单号 VARCHAR(50) ,
    物流公司 VARCHAR(50),
    订单备注 VARCHAR(50),
    宝贝总数量 INT,
    店铺Id VARCHAR(50),
    店铺名称 VARCHAR(50)
    #订单关闭原因 varchar(50),卖家服务费 varchar(10),买家服务费 varchar(10),发票抬头 varchar(50),是否手机订单 varchar(50),
    #分阶段订单信息 varchar(50),特权订金订单id varchar(50),是否上传合同照片 varchar(50),是否上传小票 varchar(50),
    #是否代付 varchar(50),定金排名 varchar(50),修改后的sku varchar(50),修改后的收货地址 varchar(50),异常信息 varchar(50),
    #天猫卡券抵扣 varchar(50),集分宝抵扣 varchar(50),是否是O2O交易 varchar(50),退款金额 decimal(9,2)
    #辅助_ALL int,辅助_订单唯一 int,辅助_买家唯一 int,辅助_文件 varchar(50),交易年份 varchar(10),交易月份 varchar(10),交易年月 varchar(20),省市单位_1 varchar(20),市单位 varchar(20),省市单位_2 varchar(20),订单编号_有效 int,买家_有效 int,价格_1 decimal(9,2),订单明细×_宝贝明细○ int
)ENGINE=MYISAM CHARSET=utf8;
LOAD DATA LOCAL INFILE 'C:\\candy\\mysql\\T1000\\a0001.csv' INTO TABLE a0001 
CHARACTER SET 'utf8' 
COLUMNS TERMINATED BY ',' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;
#========================================================================================================================
CREATE TEMPORARY TABLE a0101 
	SELECT *,CONCAT(订单编号,'～～',宝贝标题) AS 编号标题 FROM a0001
		WHERE 订单状态='卖家已发货｜｜｜等待买家确认' OR 订单状态='交易成功' OR 订单状态='买家已付款，等待卖家发货';
    
ALTER TABLE a0101 ADD COLUMN a_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST ;    

SET SQL_SAFE_UPDATES = 0;
UPDATE a0101 SET 订单付款时间 = 订单创建时间 WHERE 订单付款时间='0000-00-00';
SET SQL_SAFE_UPDATES = 1;
#========================================================================================================================
CREATE TEMPORARY TABLE a0103 AS 
SELECT a_id,订单编号,买家会员名,宝贝标题,订单付款时间,SUBSTRING_INDEX(收货地址,' ',1) AS 省市_1,SUBSTRING_INDEX(收货地址,' ',2) AS 市单位,买家实际支付金额,宝贝种类,宝贝总数量,编号标题,
		YEAR(订单付款时间) AS 年份,MONTH(订单付款时间) AS 月份 ,WEEK(订单付款时间) AS 周 ,DATE_FORMAT(订单付款时间, '%Y-%m') AS 年月 FROM a0101;

CREATE TABLE a0104 AS
	SELECT a0103.*,CASE 省市_1
		WHEN '北京' THEN '北京市'
		WHEN '上海' THEN '上海市'
		WHEN '天津' THEN '天津市'
		WHEN '重庆' THEN '重庆市'
        ELSE 省市_1
        END  AS 省直辖市 FROM a0103;
ALTER TABLE a0104 ADD PRIMARY KEY (a_id);
ALTER TABLE a0104 ADD INDEX (订单编号,编号标题,宝贝标题);


SELECT 省直辖市,
	COUNT(订单编号) AS count_订单编号_唯一, 
    COUNT(DISTINCT 买家会员名) AS count_买家数量_唯一,
    SUM(买家实际支付金额) AS sum_买家实际支付金额,
	CAST(AVG(买家实际支付金额) AS DECIMAL(10,2) ) AS avg_平均实付金额,
    MAX(买家实际支付金额) AS max_平均实付金额,
    MIN(买家实际支付金额) AS min_平均实付金额,
    CAST(STD(买家实际支付金额) AS DECIMAL(10,2)) AS std_平均实付金额,
    AVG(宝贝种类) AS avg_平均购买宝贝种类,
    AVG(宝贝总数量) AS avg_平均购买宝贝数量
FROM a0104 /*where 省直辖市='上海市'*/ GROUP BY 省直辖市 WITH ROLLUP;

SELECT 市单位,
	COUNT(订单编号) AS count_订单编号_唯一, 
    COUNT(DISTINCT 买家会员名) AS count_买家数量_唯一,
    SUM(买家实际支付金额) AS sum_买家实际支付金额,
	CAST(AVG(买家实际支付金额) AS DECIMAL(10,2) ) AS avg_平均实付金额,
    MAX(买家实际支付金额) AS max_平均实付金额,
    MIN(买家实际支付金额) AS min_平均实付金额,
    CAST(STD(买家实际支付金额) AS DECIMAL(10,2)) AS std_平均实付金额,
    AVG(宝贝种类) AS avg_平均购买宝贝种类,
    AVG(宝贝总数量) AS avg_平均购买宝贝数量
FROM a0104 /*where 省直辖市='上海市'*/ GROUP BY 市单位 WITH ROLLUP;

#========================================================================================================================
CREATE TABLE `b0001`(
	订单编号 VARCHAR(50),
    标题 VARCHAR(100),
    价格 DECIMAL(9,2),
    购买数量 INT,
    外部系统编号 VARCHAR(50),
    商品属性 VARCHAR(100),
    套餐信息 VARCHAR(50),
    备注 VARCHAR(50),
    订单状态 VARCHAR(50),
    商家编码 VARCHAR(50)
    #金额 decimal(9,2),辅助_ALL int,辅助_订单唯一 int,辅助_标题唯一 int,辅助_商家编号唯一 int,文件 varchar(50),订单付款时间 datetime,买家会员名 varchar(50),买家实际支付金额 decimal(9,2),交易年份 varchar(10),交易月份 varchar(10),交易年月 varchar(20) 
)ENGINE=MYISAM DEFAULT CHARSET=utf8;
LOAD DATA LOCAL INFILE 'C:\\candy\\mysql\\T1000\\b0001.csv' INTO TABLE b0001 
CHARACTER SET 'UTF8' 
COLUMNS TERMINATED BY ',' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

ALTER TABLE a0001 ADD INDEX (订单编号);
ALTER TABLE b0001 ADD INDEX (订单编号);
CREATE TEMPORARY TABLE b0002
SELECT b0001.*,a0001.买家会员名 FROM b0001 LEFT JOIN a0001 ON b0001.订单编号=a0001.订单编号; 
#========================================================================================================================
CREATE TEMPORARY TABLE b0101
	SELECT *,CONCAT(订单编号,'～～',标题)  AS 编号标题  FROM b0002
		WHERE 订单状态='卖家已发货｜｜｜等待买家确认' OR 订单状态='交易成功' OR 订单状态='买家已付款，等待卖家发货';
        
#CREATE TABLE b0102 as
	#select (@bb_id:=@bb_id+1) as bb_id,b0101.* from b0101,(select @bb_id:=0) as it;
ALTER TABLE b0101 ADD COLUMN b_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST ;   

CREATE TABLE b0103 AS 
SELECT b_id,订单编号,买家会员名,标题,购买数量,商家编码,编号标题 FROM b0101;

#========================================================================================================================
CREATE TABLE `d0001`(
    标题 VARCHAR(200),
    价格 DECIMAL(9,2),
    子品牌 VARCHAR(20),
    副品牌 VARCHAR(20),
    口味 VARCHAR(20),
    包装 VARCHAR(20),
    产地 VARCHAR(10),
    类别 VARCHAR(20),
    标准价格 DECIMAL(9,2)
);
LOAD DATA LOCAL INFILE 'C:\\candy\\mysql\\T1000\\d0001.csv' INTO TABLE d0001 
CHARACTER SET 'UTF8' 
COLUMNS TERMINATED BY ',' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

ALTER TABLE d0001 ADD COLUMN d_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST ;  

#========================================================================================================================
-- ALTER TABLE a0101 ADD INDEX (宝贝标题);
-- ALTER TABLE a0103 ADD INDEX (订单编号);
ALTER TABLE a0104 ADD INDEX (订单编号);
ALTER TABLE a0104 ADD INDEX (编号标题);
ALTER TABLE b0103 ADD INDEX (订单编号);
ALTER TABLE b0103 ADD INDEX (编号标题);
-- ALTER TABLE c0001 ADD INDEX (商家编码);
ALTER TABLE d0001 ADD INDEX (商家编码);
ALTER TABLE d0001 ADD INDEX (标题);
ALTER TABLE b0103 ADD INDEX (标题);
ALTER TABLE b0104 ADD PRIMARY KEY (b_id);
ALTER TABLE a0104 DROP INDEX 订单编号; 

SELECT * FROM b0103 LEFT JOIN a0104 ON a0104.编号标题 =b0103.编号标题;		#test
SELECT * FROM a0104 LEFT JOIN b0103 ON a0104.编号标题 =b0103.编号标题;		#test

CREATE TABLE b0104 AS 
    SELECT b0103.b_id,b0103.订单编号,b0103.标题,b0103.购买数量,b0103.商家编码,b0103.编号标题,a0104.买家实际支付金额,
买家实际支付金额/购买数量 AS 单价 FROM b0103 LEFT JOIN a0104 ON a0104.编号标题 =b0103.编号标题;

#CREATE TABLE b0204 AS
#	SELECT b0103.*,d0101.价格,d0101.子品牌,d0101.副品牌,d0101.口味,d0101.产地 FROM b0103 LEFT JOIN d0101 ON b0103.标题 =d0101.标题;

SELECT * FROM b0104 LIMIT 3;		#test

-- SELECT * FROM b0104 WHERE 单价 IS NOT NULL ORDER BY 标题;
-- SELECT COUNT(DISTINCT(标题)) FROM b0104;
CREATE TEMPORARY TABLE z0001 AS
	SELECT DISTINCT(标题) FROM b0104;
CREATE TEMPORARY TABLE z0002 AS    
	SELECT DISTINCT(标题) FROM b0104 WHERE 单价 IS NOT NULL;

CREATE TABLE z0101 AS    
	SELECT z0001.标题 AS 标题_all,z0002.标题 AS 标题_有价 FROM z0001 LEFT JOIN z0002 ON z0001.标题 =z0002.标题;
    
ALTER TABLE z0101 ADD COLUMN 标题_有价与否 VARCHAR(10);

SET SQL_SAFE_UPDATES = 0;
UPDATE z0101 SET 标题_有价与否 = '有单价' WHERE 标题_有价 IS NOT NULL;
UPDATE z0101 SET 标题_有价与否 = '无单价' WHERE 标题_有价 IS NULL;
SET SQL_SAFE_UPDATES = 1; 


ALTER TABLE z0101 ADD COLUMN z_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST ;    
ALTER TABLE z0101 ADD INDEX (标题_all);

SELECT z0101.*,b0104.商家编码 FROM z0101 LEFT JOIN b0104 ON z0101.标题_all=b0104.标题;
SELECT z0101.*,b0104.商家编码,b0104.订单编号 FROM z0101,b0104 WHERE z0101.标题_all=b0104.标题;



SELECT * FROM z0101 LEFT JOIN b0104 ON z0101.标题_all =b0104.标题;		#test


SELECT * FROM z0101;		#test
SELECT * FROM b0104;		#test

SELECT * FROM a0104 WHERE 宝贝标题='【年货预售】森永 日本DARS白巧克力4盒牛奶巧克力4盒 共8盒';
SELECT * FROM a0101 WHERE 宝贝标题 LIKE '%【年货预售】森永 日本DARS白巧克力4盒牛奶巧克力4盒 共8盒%';
SELECT * FROM b0101 WHERE 标题='【年货预售】森永 日本DARS白巧克力4盒牛奶巧克力4盒 共8盒';

SELECT * FROM a0101 WHERE 宝贝标题='森永 日本进口Bake 烘焙巧克力38g*5包（代可可脂）';
SELECT * FROM a0101 WHERE 宝贝标题 LIKE '%森永 日本进口Bake 烘焙巧克力38g*5包（代可可脂）%';
SELECT * FROM b0101 WHERE 标题='森永 日本进口Bake 烘焙巧克力38g*5包（代可可脂）';

CREATE TABLE z9000 AS
SELECT 标题,
    AVG(单价) AS avg_单价
FROM b0104 WHERE 单价 IS NOT NULL GROUP BY 标题;

ALTER TABLE b0104 ADD INDEX (标题);
ALTER TABLE z0101 ADD INDEX (标题_all);
ALTER TABLE z9000 ADD INDEX (标题);

CREATE TABLE z0102 AS    
	SELECT * FROM z0101 LEFT JOIN z9000 ON z0101.标题_all =z9000.标题;

ALTER TABLE z0102 ADD COLUMN k_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST;    


###===============================================================================
CREATE TABLE a7001 AS
SELECT a0001.*,CASE 订单付款时间
	WHEN '0000-00-00' THEN 订单创建时间
    ELSE 订单付款时间
    END  AS 订单付款时间_2 FROM a0001;

SELECT 买家会员名,
	COUNT(订单编号) AS count_订单编号_唯一, 
    COUNT(DISTINCT 买家会员名) AS count_买家数量_唯一,
    SUM(买家实际支付金额) AS sum_买家实际支付金额,
	CAST(AVG(买家实际支付金额) AS DECIMAL(10,2) ) AS avg_平均实付金额,
    MAX(买家实际支付金额) AS max_平均实付金额,
    MIN(买家实际支付金额) AS min_平均实付金额,
    CAST(STD(买家实际支付金额) AS DECIMAL(10,2)) AS std_平均实付金额,
    AVG(宝贝种类) AS avg_平均购买宝贝种类,
    AVG(宝贝总数量) AS avg_平均购买宝贝数量
FROM a0104 GROUP BY 买家会员名 ORDER BY sum_买家实际支付金额 DESC;

SELECT SHA1(标题) INTO OUTFILE 'C:/ProgramData/MySQL/MySQL\ Server\ 5.7/Uploads/temp_0.csv' LINES TERMINATED BY '\n'FROM  d0001 LIMIT 2; 
SELECT SHA1(标题) INTO OUTFILE 'C:/ProgramData/MySQL/MySQL\ Server\ 5.7/Uploads/temp_0.xlsx' FROM  d0001 LIMIT 2; 			#select文件导出

mysqldump c_1000 -uroot -ptt65212879 > c_1000.sql;


SELECT bb_id,订单编号 INTO OUTFILE 'C:\\ProgramData\\MySQL\\MySQL Server 5.7\\Uploads\\2.csv' FROM a0104;
SELECT bb_id,订单编号 INTO OUTFILE 'C:\\ProgramData\\MySQL\\MySQL Server 5.7\\Uploads\\3.csv' FROM b0105;

SELECT COUNT(DISTINCT 订单编号) FROM a0104;
SELECT COUNT(DISTINCT 订单编号) FROM b0104;

(SELECT 订单编号 FROM a0104 ) UNION (SELECT 订单编号 FROM b0104);



ALTER TABLE d0001 ADD INDEX (标题);
ALTER TABLE b0104 ADD INDEX (标题);

CREATE TABLE b0105 AS
SELECT b0104.*,d0001.`价格`,d0001.`子品牌`,d0001.`副品牌`,d0001.`口味`,d0001.`产地`,d0001.`类别` FROM b0104 LEFT JOIN d0001 ON b0104.标题=d0001.标题;

SET SQL_SAFE_UPDATES = 0;
UPDATE b0105 SET 买家实际支付金额 = 价格*购买数量 WHERE 买家实际支付金额 IS NULL;
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE b0105 ADD PRIMARY KEY (b_id);
#ALTER TABLE z0102 ADD INDEX (标题_all,avg_单价);

CREATE TABLE b0106 AS
SELECT b0105.*,z9000.avg_单价 FROM b0105 LEFT JOIN z9000 ON b0105.标题=z9000.标题;

SELECT * FROM b0106 WHERE 买家实际支付金额=0;
SELECT * FROM b0106 WHERE 商家编码='\'4902888206672\r';
SELECT * FROM b0106 WHERE 产地='国产';

SET SQL_SAFE_UPDATES = 0;
UPDATE b0106 SET 买家实际支付金额 = avg_单价*购买数量 WHERE 买家实际支付金额=0;
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE b0106 ADD INDEX (标题);
ALTER TABLE b0106 ADD INDEX (订单编号);
ALTER TABLE a0104 ADD INDEX (订单编号);
ALTER TABLE a0001 ADD INDEX (订单编号);

CREATE TEMPORARY TABLE t_b0106_1
SELECT b0106.*,a0104.`买家会员名`,a0104.`年份`,a0104.`年月`,a0104.`市单位`,a0104.`省直辖市`,a0104.`宝贝总数量`,a0104.`宝贝种类` FROM b0106 LEFT JOIN a0104 ON b0106.订单编号=a0104.`订单编号`;
ALTER TABLE t_b0106_1 ADD INDEX (订单编号);

CREATE TEMPORARY TABLE t_b0106_2
SELECT t_b0106_1.*,a0001.`订单付款时间` FROM t_b0106_1 LEFT JOIN a0001 ON t_b0106_1.订单编号=a0001.`订单编号`;
ALTER TABLE t_b0106_2 ADD INDEX (订单编号,标题);

CREATE TABLE b0107
SELECT t_b0106_1.*,a0001.`订单付款时间` FROM t_b0106_1 LEFT JOIN a0001 ON t_b0106_1.订单编号=a0001.`订单编号`;
ALTER TABLE b0107 ADD INDEX(订单编号,买家会员名)

#  B表  统计===================================================================================
SELECT 年月,
	COUNT(DISTINCT 订单编号) AS count_订单编号_唯一,
	COUNT(订单编号) AS count_订单,
	SUM(购买数量) AS sum_购买数量,
	CAST(AVG(购买数量) AS DECIMAL(10,2) ) AS avg_购买数量,
	SUM(买家实际支付金额) AS sum_买家实际支付金额,
	CAST(AVG(买家实际支付金额) AS DECIMAL(10,2) ) AS avg_平均实付金额,
	COUNT(DISTINCT 买家会员名) AS count_买家_唯一,
	COUNT(买家会员名) AS count_买家_人次
FROM b0107 /*where 省直辖市='上海市'*/ GROUP BY 年月 WITH ROLLUP;

SELECT 子品牌,
	COUNT(DISTINCT 订单编号) AS count_订单编号_唯一,
	COUNT(订单编号) AS count_订单,
	SUM(购买数量) AS sum_购买数量,
	CAST(AVG(购买数量) AS DECIMAL(10,2) ) AS avg_购买数量,
	SUM(买家实际支付金额) AS sum_买家实际支付金额,
	CAST(AVG(买家实际支付金额) AS DECIMAL(10,2) ) AS avg_平均实付金额,
	COUNT(DISTINCT 买家会员名) AS count_买家_唯一,
	COUNT(买家会员名) AS count_买家_人次
FROM b0107 /*where 省直辖市='上海市'*/ GROUP BY 子品牌 WITH ROLLUP;

SELECT 产地,
	COUNT(DISTINCT 订单编号) AS count_订单编号_唯一,
	COUNT(订单编号) AS count_订单,
	SUM(购买数量) AS sum_购买数量,
	CAST(AVG(购买数量) AS DECIMAL(10,2) ) AS avg_购买数量,
	SUM(买家实际支付金额) AS sum_买家实际支付金额,
	CAST(AVG(买家实际支付金额) AS DECIMAL(10,2) ) AS avg_平均实付金额,
	COUNT(DISTINCT 买家会员名) AS count_买家_唯一,
	COUNT(买家会员名) AS count_买家_人次
FROM b0107 /*where 省直辖市='上海市'*/ GROUP BY 产地 WITH ROLLUP;


####  RFM===================================================================================
CREATE TABLE c_1001.rfm_0001 AS
SELECT 订单编号 AS OrderID,买家会员名 AS CustomerID,订单付款时间 AS DealDateTime,买家应付货款 AS Sales FROM c_1001.a0101;
####  重复购买 fz_cishu_a0001表 ===================================================================================
CREATE TABLE fz_cishu_a0001 AS
SELECT 买家会员名,
	COUNT(DISTINCT 订单编号) AS count_订单编号_唯一,
	COUNT(订单编号) AS count_订单,
	SUM(购买数量) AS sum_购买数量,
	CAST(AVG(购买数量) AS DECIMAL(10,2) ) AS avg_购买数量,
	SUM(买家实际支付金额) AS sum_买家实际支付金额,
	CAST(AVG(买家实际支付金额) AS DECIMAL(10,2) ) AS avg_平均实付金额,
	COUNT(DISTINCT 买家会员名) AS count_买家_唯一,
	COUNT(买家会员名) AS count_买家_人次
FROM b0107 /*where 省直辖市='上海市'*/ GROUP BY 买家会员名 ORDER BY COUNT(DISTINCT 订单编号) DESC;
ALTER TABLE fz_cishu_a0001 ADD INDEX(买家会员名)


SELECT count_订单编号_唯一,
	COUNT(买家会员名) AS 次数_a
FROM x0000 /*where 省直辖市='上海市'*/ GROUP BY count_订单编号_唯一  WITH ROLLUP;

####  时间间隔 daydiff 表 ===================================================================================
SELECT * FROM a0104 ORDER BY 买家会员名,订单付款时间;

CREATE TEMPORARY TABLE x0001 AS
SELECT a_id,买家会员名 AS id,订单付款时间 AS DATE FROM a0104 ORDER BY 买家会员名,订单付款时间;

SET @id_rank:=0;
SELECT id, DATE, id_rank FROM (
SELECT id, DATE, 
	   @id_rank := IF(@id = id, @id_rank + 1, 1) AS id_rank,
	   @id := id 
  FROM x0001
  ORDER BY id, DATE
) a;


SET @id_rank:=0;
CREATE TABLE temp ENGINE=MYISAM DEFAULT CHARSET=utf8 AS
SELECT id, DATE, id_rank FROM (
SELECT id, DATE, 
	   @id_rank := IF(@id = id, @id_rank + 1, 1) AS id_rank,
	   @id := id 
  FROM x0001
  ORDER BY id, DATE
) a;
ALTER TABLE temp ADD INDEX (id,DATE,id_rank);

SELECT * FROM temp;



CREATE TABLE fz_daydiff_a0001 ENGINE=MYISAM DEFAULT CHARSET=utf8 AS
SELECT a.id, a.date, b.date AS date2 FROM (
	SELECT id, DATE, id_rank FROM temp
) a LEFT JOIN (
	SELECT id, DATE, (id_rank-1) AS id_rank_1 FROM temp
) b ON a.id=b.id AND a.id_rank=b.id_rank_1;

DROP TABLE x0003;
CREATE TEMPORARY TABLE x0003 AS
SELECT *,DATEDIFF(date2,DATE) AS daydiff FROM fz_daydiff_a0001 WHERE DATEDIFF(date2,DATE) IS NOT NULL;

SELECT 
	COUNT(id) AS 买家数, 
	AVG(daydiff)
    FROM x0003;

####  进口/国产标签 B表 → A表 ===================================================================================
#drop table x0001;
CREATE TEMPORARY TABLE x0001 AS SELECT * FROM b0107 WHERE 产地='国产';
CREATE TABLE fz_LB_gc AS
SELECT DISTINCT(订单编号),@国产 :='国产' AS 国产 FROM x0001;
ALTER TABLE fz_LB_gc ADD INDEX (订单编号);
##
CREATE TEMPORARY TABLE x0002 AS SELECT * FROM b0107 WHERE 产地='进口';
CREATE TABLE fz_lb_jk AS
SELECT DISTINCT(订单编号),@进口 :='进口' AS 进口 FROM x0002;
ALTER TABLE fz_lb_jk ADD INDEX (订单编号);
##
CREATE TEMPORARY TABLE x0003 AS SELECT * FROM b0107 WHERE 子品牌='DARS';
CREATE TABLE fz_lb_dars AS
SELECT DISTINCT(订单编号),@DARS :='DARS' AS DARS FROM x0003;
ALTER TABLE fz_lb_dars ADD INDEX (订单编号);
##
CREATE TEMPORARY TABLE x0004 AS SELECT * FROM b0107 WHERE 子品牌='BAKE';
CREATE TABLE fz_lb_bake AS
SELECT DISTINCT(订单编号),@BAKE :='BAKE' AS BAKE FROM x0004;
ALTER TABLE fz_lb_bake ADD INDEX (订单编号);
##
CREATE TEMPORARY TABLE x0005 AS SELECT * FROM b0107 WHERE 子品牌='嗨啾';
CREATE TABLE fz_lb_hc AS
SELECT DISTINCT(订单编号),@嗨啾 :='嗨啾' AS 嗨啾 FROM x0005;
ALTER TABLE fz_lb_hc ADD INDEX (订单编号);
##
CREATE TEMPORARY TABLE x0006 AS SELECT * FROM b0107 WHERE 子品牌='松饼粉';
CREATE TABLE fz_lb_sbf AS
SELECT DISTINCT(订单编号),@松饼粉 :='松饼粉' AS 松饼粉 FROM x0006;
ALTER TABLE fz_lb_sbf ADD INDEX (订单编号);
##
CREATE TEMPORARY TABLE x0007 AS SELECT * FROM b0107 WHERE 子品牌='蒙奈';
CREATE TABLE fz_lb_mn AS
SELECT DISTINCT(订单编号),@蒙奈 :='蒙奈' AS 蒙奈 FROM x0007;
ALTER TABLE fz_lb_mn ADD INDEX (订单编号);
##
CREATE TEMPORARY TABLE x0008 AS SELECT * FROM b0107 WHERE 子品牌='可可粉';
CREATE TABLE fz_lb_kkf AS
SELECT DISTINCT(订单编号),@可可粉 :='可可粉' AS 可可粉 FROM x0008;
ALTER TABLE fz_lb_kkf ADD INDEX (订单编号);
##
CREATE TEMPORARY TABLE x0009 AS SELECT * FROM b0107 WHERE 副品牌='嗨啾';
CREATE TABLE fz_lb_hc_1 AS
SELECT DISTINCT(订单编号),@hc_1 :='hc_1' AS hc_1 FROM x0009;
ALTER TABLE fz_lb_hc_1 ADD INDEX (订单编号);
##
CREATE TEMPORARY TABLE x0010 AS SELECT * FROM b0107 WHERE 副品牌='嗨啾酸酸哒';
CREATE TABLE fz_lb_hc_2 AS
SELECT DISTINCT(订单编号),@hc_2 :='hc_2' AS hc_2 FROM x0010;
ALTER TABLE fz_lb_hc_2 ADD INDEX (订单编号);
##
CREATE TEMPORARY TABLE x0011 AS SELECT * FROM b0107 WHERE 副品牌='嗨啾淘汽小子';
CREATE TABLE fz_lb_hc_3 AS
SELECT DISTINCT(订单编号),@hc_3 :='hc_3' AS hc_3 FROM x0011;
ALTER TABLE fz_lb_hc_3 ADD INDEX (订单编号);
##
CREATE TEMPORARY TABLE x0012 AS SELECT * FROM b0107 WHERE 产地='国产' AND 子品牌='嗨啾';
CREATE TABLE fz_lb_hc_gc AS
SELECT DISTINCT(订单编号),@hc_gc :='hc_gc' AS hc_gc FROM x0012;
ALTER TABLE fz_lb_hc_gc ADD INDEX (订单编号);


##
##drop table xxxx0009,xxxx0010;
CREATE TEMPORARY TABLE xxxx0009 AS SELECT * FROM b0107 WHERE 副品牌='嗨啾';
CREATE TABLE fz_lb2_hc_1 AS
SELECT DISTINCT(买家会员名),@hc_1 :='hc_1' AS hc_1 FROM xxxx0009;
ALTER TABLE fz_lb2_hc_1 ADD INDEX (买家会员名);
##
CREATE TEMPORARY TABLE xxxx0010 AS SELECT * FROM b0107 WHERE 副品牌='嗨啾酸酸哒';
CREATE TABLE fz_lb2_hc_2 AS
SELECT DISTINCT(买家会员名),@hc_2 :='hc_2' AS hc_2 FROM xxxx0010;
ALTER TABLE fz_lb2_hc_2 ADD INDEX (买家会员名);

SELECT fz_lb2_hc_1.*,fz_lb2_hc_2.`hc_2` FROM fz_lb2_hc_1 LEFT JOIN fz_lb2_hc_2 ON fz_lb2_hc_1.`买家会员名`=fz_lb2_hc_2.`买家会员名`;





###
CREATE TEMPORARY TABLE xx0001 AS
SELECT a0104.*,fz_lb_gc.`国产` FROM a0104 LEFT JOIN fz_lb_gc ON a0104.订单编号=fz_lb_gc.`订单编号`; 
ALTER TABLE xx0001 ADD INDEX (订单编号);
###
CREATE TEMPORARY TABLE xx0002 AS
SELECT xx0001.*,fz_lb_jk.`进口` FROM xx0001 LEFT JOIN fz_lb_jk ON xx0001.订单编号=fz_lb_jk.`订单编号`; 
ALTER TABLE xx0002 ADD INDEX (订单编号);
#SELECT * FROM xx0002 WHERE 进口='进口';
###
CREATE TEMPORARY TABLE xx0003 AS
SELECT xx0002.*,fz_lb_bake.`BAKE` FROM xx0002 LEFT JOIN fz_lb_bake ON xx0002.订单编号=fz_lb_bake.`订单编号`; 
ALTER TABLE xx0003 ADD INDEX (订单编号);
#SELECT * FROM xx0003 WHERE BAKE='BAKE';
###
CREATE TEMPORARY TABLE xx0004 AS
SELECT xx0003.*,fz_lb_dars.`DARS` FROM xx0003 LEFT JOIN fz_lb_dars ON xx0003.订单编号=fz_lb_dars.`订单编号`; 
ALTER TABLE xx0004 ADD INDEX (订单编号);
#SELECT * FROM xx0004 WHERE DARS='DARS';
###
CREATE TEMPORARY TABLE xx0005 AS
SELECT xx0004.*,fz_lb_sbf.`松饼粉` FROM xx0004 LEFT JOIN fz_lb_sbf ON xx0004.订单编号=fz_lb_sbf.`订单编号`; 
ALTER TABLE xx0005 ADD INDEX (订单编号);
#SELECT * FROM xx0005 WHERE 松饼粉='松饼粉';
###
CREATE TEMPORARY TABLE xx0006 AS
SELECT xx0005.*,fz_lb_hc.`嗨啾` FROM xx0005 LEFT JOIN fz_lb_hc ON xx0005.订单编号=fz_lb_hc.`订单编号`; 
ALTER TABLE xx0006 ADD INDEX (订单编号);
###
CREATE TEMPORARY TABLE xx0007 AS
SELECT xx0006.*,fz_lb_mn.`蒙奈` FROM xx0006 LEFT JOIN fz_lb_mn ON xx0006.订单编号=fz_lb_mn.`订单编号`; 
ALTER TABLE xx0007 ADD INDEX (订单编号);
###
CREATE TEMPORARY TABLE xx0008 AS
SELECT xx0007.*,fz_lb_kkf.`可可粉` FROM xx0007 LEFT JOIN fz_lb_kkf ON xx0007.订单编号=fz_lb_kkf.`订单编号`; 
ALTER TABLE xx0008 ADD INDEX (订单编号);
###
CREATE TEMPORARY TABLE xx0009 AS
SELECT xx0008.*,fz_lb_hc_1.`hc_1` FROM xx0008 LEFT JOIN fz_lb_hc_1 ON xx0008.订单编号=fz_lb_hc_1.`订单编号`; 
ALTER TABLE xx0009 ADD INDEX (订单编号);
###
CREATE TEMPORARY TABLE xx0010 AS
SELECT xx0009.*,fz_lb_hc_2.`hc_2` FROM xx0009 LEFT JOIN fz_lb_hc_2 ON xx0009.订单编号=fz_lb_hc_2.`订单编号`; 
ALTER TABLE xx0010 ADD INDEX (订单编号);
###
CREATE TEMPORARY TABLE xx0011 AS
SELECT xx0010.*,fz_lb_hc_3.`hc_3` FROM xx0010 LEFT JOIN fz_lb_hc_3 ON xx0010.订单编号=fz_lb_hc_3.`订单编号`; 
ALTER TABLE xx0011 ADD INDEX (订单编号);
###
CREATE TEMPORARY TABLE xx0012 AS
SELECT xx0011.*,fz_lb_hc_gc.`hc_gc` FROM xx0011 LEFT JOIN fz_lb_hc_gc ON xx0011.订单编号=fz_lb_hc_gc.`订单编号`; 
ALTER TABLE xx0012 ADD INDEX (订单编号);


ALTER TABLE xx0012 ADD INDEX (买家会员名);
#SELECT * FROM xx0006 WHERE 嗨啾='嗨啾';

###
CREATE TABLE a0105 AS
SELECT xx0012.*,fz_cishu_a0001.`count_买家_人次` FROM xx0012 LEFT JOIN fz_cishu_a0001 ON xx0012.买家会员名=fz_cishu_a0001.`买家会员名`; 



