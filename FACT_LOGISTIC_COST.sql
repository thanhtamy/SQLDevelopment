﻿
CREATE VIEW [gld].[VW_TRANSPORT_COST_ACTUAL] AS
WITH DELIVERY_ROUTE AS
(
--1220014689 có 2 SHIPMENT_NO check trong tcode VL03N
SELECT 
SI.SHIPMENT_NO
,SI.SHIPMENT_ROUTE
,DI.DELIVERY_NO
,DI.S_LOC
,DI.AC_GI_DATE
,DI.SO_HIEU_TAU
,DI.KHO_GNHH
,DI.NGUOI_NHAN
,DI.CHO_VE
,DI.DAI_DIEN_BEN_GIAO
,DI.CHUC_VU
,DI.MO_TA_LENH
,DI.SALE_OFF
,DI.SALE_GRP
,DI.DISTR_CHAN
,DI.BUOM
,DI.AC_DELIVERY_QUANTITY
,DI.DELIVERY_QUANTITY
FROM   [sil].[VW_FACT_SHIPMENT_ITEM] SI
LEFT JOIN  (SELECT DELIVERY_NO,S_LOC, AC_GI_DATE, SO_HIEU_TAU, KHO_GNHH, NGUOI_NHAN, CHO_VE, DAI_DIEN_BEN_GIAO, CHUC_VU, MO_TA_LENH, SALE_OFF, SALE_GRP, DISTR_CHAN, BUOM, SUM(AC_DELIVERY_QUANTITY) AS AC_DELIVERY_QUANTITY, SUM(DELIVERY_QUANTITY) AS DELIVERY_QUANTITY 
FROM [sil].[VW_FACT_DELIVERY_ITEM] 
			GROUP BY DELIVERY_NO
					,S_LOC
					,AC_GI_DATE
					,SO_HIEU_TAU
					,KHO_GNHH
					,NGUOI_NHAN
					,CHO_VE
					,DAI_DIEN_BEN_GIAO
					,CHUC_VU
					,MO_TA_LENH
					,SALE_OFF
					,SALE_GRP
					,DISTR_CHAN
					,BUOM ) AS DI
	ON SI.DELIVERY_NO = DI.DELIVERY_NO 
	AND SI.SHIPMENT_TYPE NOT IN ('Z007', 'Z008', 'Z009') --Loai chi phi bao hiem vi khong co CONDITIONAL PRICE cho bao hiem trong bang KONP

)
SELECT 
DR.*
,LCP.ROUTE_NAME
,LCP.CONDITION_PRICE
,LCP.CURRENCY
,LCP.UOM 
,(DR.AC_DELIVERY_QUANTITY * LCP.CONDITION_PRICE) AS TRANSPORT_COST_ACTUAL
FROM DELIVERY_ROUTE DR
LEFT JOIN [sil].[VW_FACT_LOGISTICS_COND_PRICE] LCP 
	ON DR.SHIPMENT_ROUTE = LCP.ROUTE 
	AND (DR.AC_GI_DATE >= LCP.VALID_FROM AND DR.AC_GI_DATE <= LCP.VALID_TO)
	