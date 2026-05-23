--==================

--id
--: 
--7315
--lastEditedDt
--: 
--"2026-05-21 14:39:59"
--lastEditor
--: 
--"V1802185"
--lastEditorId
--: 
--null
--materialId
--: 
--null
--materialName
--: 
--null
--materialNo
--: 
--null
--materialfamilyCode
--: 
--"CLIMAX"
--materialfamilyDesc
--: 
--"THIẾT BỊ IOT CLIMAX "
--materialfamilyName
--: 
--"THIẾT BỊ IOT CLIMAX "
--materialfamilySnrule
--: 
--null

-- ==========
-- org_code = 'EPDVI_VN'

-- 车间管理
-- workshop_name: CLIMAX_VN-T01-1F
-- ID: 263
SELECT *
FROM basic_sys.basic_workshop bw
WHERE bw.workshop_name = 'CLIMAX_VN-T01-1F';

-- LINE
-- 线别管理
-- A01-1F-A01A
-- 822
-- line_code: 'T01-1F-LINEA'
-- line_name: 'T01-1F-LINEA'
SELECT *
FROM basic_sys.basic_line bl
WHERE bl.line_name = 'T01-1F-LINEA';
-- 1420	T01-1F-LINEA	T01-1F-LINEA	SMT	263		CLIMAX PRODUCTION LINE	V1802185	4583	1779505567277	V1802185	4583	1779505567277	EPDVI_VN	false			CLIMAX_LINEA		false

-- STATION
-- 工位管理
-- tram A01A-SMT-FEED
-- SMT-FEED
-- A01A
-- line_station_code = 'T01-1F-LINEA-SMT-FEED'
-- line_station_name = 'T01-1F-LINEA-SMT-FEED'
-- process_seg_id = 500
SELECT *
FROM basic_sys.basic_line_station bls
WHERE bls.line_station_code = 'T01-1F-LINEA-SMT-FEED';
-- 3758	T01-1F-LINEA-SMT-FEED	T01-1F-LINEA-SMT-FEED	1420	500				V1802185	4583	1779506116523	V1802185	4583	1779506116523		EPDVI_VN	false		

-- BASIC EQP TYPE
-- 设备类别
-- GKG G5 : solder paster printer
SELECT*
FROM basic_sys.basic_eqp_type bet
WHERE bet.type_code LIKE 'GKG G5';

-- DEVICE CONFIG
-- 设备管理
-- need:關聯工位 关联工位 （ 要绑定 工位）
-- GKG-PMAX6 may in kem thiec
-- line_id = 1420
SELECT *
FROM basic_sys.basic_eqp be
WHERE be.eqp_code = 'GKG-PMAX6';

-- ADD METHOD
-- 管控方法
-- SMT-FEED
SELECT *
FROM mes.mes_process_control mpc
WHERE mpc.control_name = 'SMT-FEED' AND mpc.org_code = 'EPDVI_VN'

-- CONFIG STEP SCAN
-- 采集步
-- step code, step_name(human)
SELECT *
FROM mes.mes_process_step mps 

-- ADD DETAIL SCAN FOR OPERTATION
-- 操作类型
-- Data foreig key id -> operate_id
SELECT
	id,
	mpot.operation_code,
	mpot.operation_name,
	mpot."desc",
	mpot.org_code,
	mpot.is_deleted
FROM
	MES.mes_process_operation_type mpot
WHERE
	mpot.operation_code = 'SMT-FEED' AND mpot.org_code = 'EPDVI_VN';


-- quan he gia  mes_process_operation_type vs mes_process_step
SELECT *
FROM mes.mes_process_operation_step_rel mposr
WHERE mposr.operation_id = 61;

-- cac buoc scan
-- SMT-FEED
SELECT
	mps.*,
	mposr.sort_no
FROM
	mes.mes_process_step mps
JOIN mes.mes_process_operation_step_rel mposr ON
	mps.id = mposr.step_id
WHERE
	mposr.operation_id = 61
ORDER BY
	mposr.sort_no ASC;

-- link stations to line;
-- 工位管理
-- T01-1F-LINEA-SMT-FEED
-- * process_seg_id = 500 --> 工站名称
SELECT *
FROM basic_sys.basic_line_station bls
WHERE bls.line_station_code = 'T01-1F-LINEA-SMT-FEED';

-- deduct SMT config
-- 上料 扣账 配置
-- line_code = 'T01-1F-LINEA'
SELECT *
FROM mes.mes_deduction_config mdc
WHERE line_code = 'T01-1F-LINEA';

-- PRODUCTION==========================================================
-- mfg master
-- mfg_material_code: 0101K6B00-000-G
-- id: 7983
-- nha cung ung
SELECT *
FROM basic_sys.basic_mfg_info bmi
WHERE mfg_name = 'TTM'
AND bmi.mfg_material_code = '0101K6B00-000-G';

-- 物料管理
-- VAT LIEU SAMPLE LA 1 PCB LINK 2 
-- material_no = 'PCB0001-CLIMAX-VN'
-- material_id = 826278
SELECT *
FROM basic_sys.basic_material bm
WHERE bm.material_no IN ('PCB0001-CLIMAX-VN', 'PRODUCT-CLIMAX-001');

-- MATERIAL SYNC
-- bang luu mapping giua vat lieu va ma vat lieu cua
-- nha cung ung 
-- material_id = 826278 ==> basic_material（'PCB0001-CLIMAX-VN'）
-- vat lieu pcb nay la tu nha cung ung TTMP voi ma so la 0101K6B00-000-G
SELECT*
FROM basic_sys.basic_material_mfg bmm
WHERE bmm.material_id in ('826278','21071996');
-- CREATE INDEX idx_basic_material_mfg ON basic_sys.basic_material_mfg (material_id, id);                                                                    

--- DU LIEU DONG BO TU SAP VE 2 BANG SAU 
--- mes_product_master  va basic_material
--- material_no = 'PRODUCT-CLIMAX-VN-001'
-- id = '447897'
SELECT *
FROM basic_sys.basic_material bm
WHERE bm.material_no IN ('PRODUCT-CLIMAX-001','0101MV500-000-G','YTR1G-LF')

-- NEW PRODUCT
-- 產品信息
-- material_id= '826279'
-- product_no = 'PRODUCT-CLIMAX-VN-001'
-- san pham ROUTER voi model 
select * from mes.mes_product_master mpm
where  mpm.material_id  = '21071996'
order by mpm.created_dt desc;

-- BOM 
select * from basic_sys.basic_product_bom bpb 
where bpb.product_no  = 'PRODUCT-CLIMAX-001';
-- PRODUCT-CLIMAX-001 danh sach vat lieu
--PCB0001-CLIMAX-VN 21071996
--0101MV500-000-G 1342846
--YTR1G-LF 1371399

-- workorder auto sync
-- ma lieu cho con leh
select * from mes.mes_wo_material mwm 
where mwm.org_code  = 'EPDVI_VN'
 and mwm.wo_id ='21071996'

select * from mes.mes_wo mw 
where mw.wo_no  ='000129052026001';

--INSERT INTO mes.mes_wo 
--(wo_pid,wo_no,sap_wo_no,wo_status,wo_type,plant_code,material_id,product_no,product_name,product_version,plan_qty,uom_id,route_id,route_version,line_id,line_code,shift_id,plan_start_time,plan_end_time,est_delivery_time,pause_status,source_id,source_type,product_level,customer_code,customer_pn,customer_pn_name,customer_po,sales_no,ecn_no,rma_no,transport_type,sell_place,created_dt,creator,creator_id,last_edited_dt,last_editor,last_editor_id,org_code,is_deleted,old_order_status,online_time,start_time,end_time,input_qty,output_qty,scraped_qty,error_qty,repair_qty,instore_qty,shipped_qty,customer_id,start_process_id,end_process_id,start_node_id,end_node_id,evaluation_result,rework_qty,upgrade_qty,cust_pn2,sap_plan_qty,is_open_sn,is_generate_sn,check_aoa,unloading_point,zmd_no,project_code) VALUES
--(21071996,'000129052026001','000129052026001','OPEN','NORMAL','F6V1',21071996,'PRODUCT-CLIMAX-001','PCBA CLIMAX ROUTER V1 NPI','A',20.0,NULL,165,'1',1241,'T01-1F-LINEA',NULL,'2026-05-23 00:00:00',NULL,NULL,false,379847,'0','L6','MICROSOFT','M1035799-003','MICROSOFT','','','','','','',1779086027625,'F5009857',3251,1779089220844,'F5009857',3251,'EPDVI_VN',false,NULL,NULL,NULL,NULL,0.000,0.000,NULL,NULL,NULL,NULL,NULL,384,401,497,'214da53b-266a-4e40-9eb9-d26200a4d43d','c422c90a-8809-4b82-bfe6-e5c096a77c0b',0,NULL,NULL,'',20.0,true,true,false,NULL,NULL,NULL);
--

-- =====================================================================
-- LABELING -- 標籤
--打印模版
-- CLIMAX_PCB_LABEL_TEMPLATE
select * from basic_sys.basic_print_template bpt 
where file_name ='CLIMAX_PCB_LABEL_TEMPLATE';
-- 产品标签规则 -- 產品標籤規則
-- quy cach label san pham
select * from mes.mes_label_rule_master mlrm 
where mlrm.material_no = 'PRODUCT-CLIMAX-001';
-- status -> AUDITING, 提交中, AUDIT_PASS
-- Thêm quy định nhãn sản phẩm
-- co 2 config la pcb label va box sn
select * from mes.mes_label_rule_config mlrc 
where mlrc.material_no = 'PRODUCT-CLIMAX-001';

------------------- DAI SN CHO CONG LENH -------------------------------

select * from mes.mes_label_print_task mlpt
where wo_no in('000129052026001');

---- label sau khi in xong xem 
select * from mes.mes_sn_master msm 
where msm.wo_no  = '000129052026001'；


--select
--from
--	mes.mes_label_print_task task
--left join mes.mes_wo wo on
--	task.wo_id = wo.id
--	and wo.is_deleted = false
--	and wo.org_code = 'EPDVI_VN'
--where
--	task.is_deleted = false
--	and wo.wo_no like concat('%', '000129052026001', '%')
--	and wo.org_code = 'EPDVI_VN'
--	and task.org_code = 'EPDVI_VN'
--	
--INSERT INTO mes.mes_label_print_task 
--(wo_id,wo_no,material_id,material_no,"version",product_series_id,barcode_type,print_template_id,start_sn,end_sn,status,audit_status,source_type,source_id,created_dt,creator,creator_id,last_edited_dt,last_editor,last_editor_id,org_code,is_deleted,lable_pn,audit_staff_code,audit_time,audit_reason,print_copies,has_print,print_total,receive_code,receive_time,tco_id) VALUES
--(21071996,'000129052026001',21071996,'PRODUCT-CLIMAX-001','A00',0101,'SN',421,'SNCLIMAX0001','SNCLIMAX00020',1,'WAIT_AUDIT',NULL,NULL,1680123835758,'V1802185',563,1686376217878,'V1802185',563,'EPDVI_VN',false,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
--
--5730	132106	WO2024010400001	175950	03G5R-A06	A06	6033	SN	837	CNO03G5RFCP004180001A06	CNO03G5RFCP00418001DA06	1	WAIT_AUDIT			1720748565615	H7300013	563	1779529065885	V1802185	4583	EPDVI_VN	false	7J-004-1069				1	0	50			
------------------- DAI SN CHO CONG LENH -------------------------------

 