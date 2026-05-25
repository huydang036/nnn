--==================

--id
--: 
--7315
--lastEditedDt
--: 
--"2026-05-21 14:39:59"
--lastEditor
-- info : emp_no  = V1802185	emp_id = 4583

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
-- wo_no = '000129052026001'
select * from mes.mes_wo_material mwm 
where mwm.org_code  = 'EPDVI_VN'
 and mwm.wo_id ='21071996';

select * from mes.mes_wo mw
where mw.id  ='21071996';



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


where mlrm.material_no = 'PRODUCT-CLIMAX-001';
-- status -> AUDITING, 提交中, AUDIT_PASS
-- Thêm quy định nhãn sản phẩm
-- co 2 config la pcb label va box sn

select * from mes.mes_label_rule_config mlrc 
where mlrc.material_no = 'PRODUCT-CLIMAX-001';


select * from mes.mes_label_rule_config mlrc 
where mlrc.material_no = 'M1259480-001-G1';

------------------- DAI SN CHO CONG LENH -------------------------------
-- MY WO_NO = 000129052026001 , wo_id = 21071996, material_id = 21071996, material_no='PRODUCT-CLIMAX-001'
-- org_code= 'EPDVI_VN'
-- SAMPLE WO = 000100000798-04, 205946
-- HE THONG SE LIEN KET CAC BANG THEO KIEU
-- ID( AUTO ), TARGET_ID(Bang relation)
-- VD: mes.mes_wo （id = 1,wo_no=0001)
--     mes.mes_label_print_task（id=1, wo_id=1)
--     mes.mes_label_print_detail(id=1, label_print_task=1, wo_id=1)

-- 工单管理
-- sinh label SN theo wo_no , wo_id
-- mes_label_print_task
-- mlpd.label_print_task_id -> mlpt.id
select *from mes.mes_label_print_task mlpt 
where wo_no = '000129052026001' and org_code= 'EPDVI_VN';
--id;wo_id;wo_no;material_id;material_no;version;product_series_id;barcode_type;print_template_id;start_sn;end_sn;status;audit_status;source_type;source_id;created_dt;creator;creator_id;last_edited_dt;last_editor;last_editor_id;org_code;is_deleted;lable_pn;audit_staff_code;audit_time;audit_reason;print_copies;has_print;print_total;receive_code;receive_time;tco_id
--6,729;21,071,996;000129052026001;21,071,996;PRODUCT-CLIMAX-001;A01;7,315;SN;1,063;SNCLIMAX0001;SNCLIMAX0020;0;WAIT_AUDIT;[NULL];[NULL];1,743,146,917,385;V;3,853;1,743,146,917,637;V1800995;3,853;EPDVI_VN;false;LABEL-CLIMAX-001;[NULL];2026-05-23 17:26:59.175;[NULL];1;0;20;[NULL];[NULL];[NULL]

-- chi tiet label da in
select *from mes.mes_label_print_detail 
where org_code= 'EPDVI_VN' and mes.mes_label_print_detail.label_print_task_id  = 6729;
--id;label_print_task_id;sn_id;sn;print_template_id;label_type;qty;print_copies;print_times;print_item;printer_id;printeruri;created_dt;creator;creator_id;last_edited_dt;last_editor;last_editor_id;org_code;is_deleted;print_flag
--510,284;7,982;[NULL];VN065I000B;1,063;SN;1;[NULL];0;[NULL];[NULL];[NULL];1,779,086,404,349;V1067271;2,948;1,779,086,404,349;V1067271;2,948;EPDVI_VN;false;false
--510,285;7,982;[NULL];VN065I000C;1,063;SN;1;[NULL];0;[NULL];[NULL];[NULL];1,779,086,404,350;V1067271;2,948;1,779,086,404,350;V1067271;2,948;EPDVI_VN;false;false
--510,286;7,982;[NULL];VN065I000D;1,063;SN;1;[NULL];0;[NULL];[NULL];[NULL];1,779,086,404,350;V1067271;2,948;1,779,086,404,350;V1067271;2,948;EPDVI_VN;false;false
--510,287;7,982;[NULL];VN065I000E;1,063;SN;1;[NULL];0;[NULL];[NULL];[NULL];1,779,086,404,352;V1067271;2,948;1,779,086,404,352;V1067271;2,948;EPDVI_VN;false;false
--510,288;7,982;[NULL];VN065I000F;1,063;SN;1;[NULL];0;[NULL];[NULL];[NULL];1,779,086,404,354;V1067271;2,948;1,779,086,404,354;V1067271;2,948;EPDVI_VN;false;false
--510,289;7,982;[NULL];VN065I000G;1,063;SN;1;[NULL];0;[NULL];[NULL];[NULL];1,779,086,404,354;V1067271;2,948;1,779,086,404,354;V1067271;2,948;EPDVI_VN;false;false
--510,290;7,982;[NULL];VN065I000H;1,063;SN;1;[NULL];0;[NULL];[NULL];[NULL];1,779,086,404,354;V1067271;2,948;1,779,086,404,354;V1067271;2,948;EPDVI_VN;false;false
--510,291;7,982;[NULL];VN065I000I;1,063;SN;1;[NULL];0;[NULL];[NULL];[NULL];1,779,086,404,354;V1067271;2,948;1,779,086,404,354;V1067271;2,948;EPDVI_VN;false;false
--510,292;7,982;[NULL];VN065I000J;1,063;SN;1;[NULL];0;[NULL];[NULL];[NULL];1,779,086,404,354;V1067271;2,948;1,779,086,404,354;V1067271;2,948;EPDVI_VN;false;false
--510,293;7,982;[NULL];VN065I000K;1,063;SN;1;[NULL];0;[NULL];[NULL];[NULL];1,779,086,404,354;V1067271;2,948;1,779,086,404,354;V1067271;2,948;EPDVI_VN;false;false
--510,294;7,982;[NULL];VN065I000L;1,063;SN;1;[NULL];0;[NULL];[NULL];[NULL];1,779,086,404,354;V1067271;2,948;1,779,086,404,354;V1067271;2,948;EPDVI_VN;false;false
--510,295;7,982;[NULL];VN065I000M;1,063;SN;1;[NULL];0;[NULL];[NULL];[NULL];1,779,086,404,355;V1067271;2,948;1,779,086,404,355;V1067271;2,948;EPDVI_VN;false;false
--510,296;7,982;[NULL];VN065I000N;1,063;SN;1;[NULL];0;[NULL];[NULL];[NULL];1,779,086,404,355;V1067271;2,948;1,779,086,404,355;V1067271;2,948;EPDVI_VN;false;false
--510,297;7,982;[NULL];VN065I000O;1,063;SN;1;[NULL];0;[NULL];[NULL];[NULL];1,779,086,404,355;V1067271;2,948;1,779,086,404,355;V1067271;2,948;EPDVI_VN;false;false
--510,298;7,982;[NULL];VN065I000P;1,063;SN;1;[NULL];0;[NULL];[NULL];[NULL];1,779,086,404,355;V1067271;2,948;1,779,086,404,355;V1067271;2,948;EPDVI_VN;false;false
--510,299;7,982;[NULL];VN065I000Q;1,063;SN;1;[NULL];0;[NULL];[NULL];[NULL];1,779,086,404,355;V1067271;2,948;1,779,086,404,355;V1067271;2,948;EPDVI_VN;false;false
--510,300;7,982;[NULL];VN065I000R;1,063;SN;1;[NULL];0;[NULL];[NULL];[NULL];1,779,086,404,355;V1067271;2,948;1,779,086,404,355;V1067271;2,948;EPDVI_VN;false;false
--510,301;7,982;[NULL];VN065I000S;1,063;SN;1;[NULL];0;[NULL];[NULL];[NULL];1,779,086,404,355;V1067271;2,948;1,779,086,404,355;V1067271;2,948;EPDVI_VN;false;false
--510,302;7,982;[NULL];VN065I000T;1,063;SN;1;[NULL];0;[NULL];[NULL];[NULL];1,779,086,404,355;V1067271;2,948;1,779,086,404,355;V1067271;2,948;EPDVI_VN;false;false
--510,303;7,982;[NULL];VN065I000U;1,063;SN;1;[NULL];0;[NULL];[NULL];[NULL];1,779,086,404,355;V1067271;2,948;1,779,086,404,355;V1067271;2,948;EPDVI_VN;false;false
-- sau khi tao xong 

select *from mes.mes_sn_master msm 
where msm.wo_id = '21071996';
--id;wo_id;material_id;product_no;product_version;sn;internal_sn;panel_sn;customer_sn;product_status;status;qty;uom_id;line_id;shift_id;line_station_id;route_id;last_dt;start_dt;finished_dt;instore_dt;shipped_dt;pack_id;weight;fail_times;rework_times;input_flag;output_flag;ship_flag;inspect_flag;inspect_lot_no;created_dt;creator;creator_id;last_edited_dt;last_editor;last_editor_id;org_code;is_deleted;type;barcode_type;wo_no;check_print;print_time;print_name;product_name;date_code;lot_no;current_process_id;next_process_id;node_source_id;node_target_id;end_process_id;end_node_id;lock_status;lock_date;lock_message;plant_code;plan_no;lock_process_code;remark;container_no;place_of_origin;quality_code;tightness_test_flag
--14,800,189;205,946;419,446;M1035799-003;B;VN065I000B;[NULL];[NULL];[NULL];good;create;1;[NULL];1,241;[NULL];[NULL];2,880;[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];1,779,086,401,576;V1067271;2,948;1,779,086,401,576;V1067271;2,948;EPDVI_VN;false;PRODUCT;SN;000100000798-04;false;[NULL];[NULL];PCBA,POWER BOARD,M2010;[NULL];[NULL];-1;[NULL];c0ec4d10-185b-4a63-b684-52953050cd7e;[NULL];497;c422c90a-8809-4b82-bfe6-e5c096a77c0b;0;[NULL];[NULL];F6V1;000100000798;[NULL];[NULL];[NULL];[NULL];[NULL];1
--14,800,190;205,946;419,446;M1035799-003;B;VN065I000C;[NULL];[NULL];[NULL];good;create;1;[NULL];1,241;[NULL];[NULL];2,880;[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];1,779,086,401,576;V1067271;2,948;1,779,086,401,576;V1067271;2,948;EPDVI_VN;false;PRODUCT;SN;000100000798-04;false;[NULL];[NULL];PCBA,POWER BOARD,M2010;[NULL];[NULL];-1;[NULL];c0ec4d10-185b-4a63-b684-52953050cd7e;[NULL];497;c422c90a-8809-4b82-bfe6-e5c096a77c0b;0;[NULL];[NULL];F6V1;000100000798;[NULL];[NULL];[NULL];[NULL];[NULL];1
--14,800,191;205,946;419,446;M1035799-003;B;VN065I000D;[NULL];[NULL];[NULL];good;create;1;[NULL];1,241;[NULL];[NULL];2,880;[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];1,779,086,401,576;V1067271;2,948;1,779,086,401,576;V1067271;2,948;EPDVI_VN;false;PRODUCT;SN;000100000798-04;false;[NULL];[NULL];PCBA,POWER BOARD,M2010;[NULL];[NULL];-1;[NULL];c0ec4d10-185b-4a63-b684-52953050cd7e;[NULL];497;c422c90a-8809-4b82-bfe6-e5c096a77c0b;0;[NULL];[NULL];F6V1;000100000798;[NULL];[NULL];[NULL];[NULL];[NULL];1
--14,800,192;205,946;419,446;M1035799-003;B;VN065I000E;[NULL];[NULL];[NULL];good;create;1;[NULL];1,241;[NULL];[NULL];2,880;[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];1,779,086,401,576;V1067271;2,948;1,779,086,401,576;V1067271;2,948;EPDVI_VN;false;PRODUCT;SN;000100000798-04;false;[NULL];[NULL];PCBA,POWER BOARD,M2010;[NULL];[NULL];-1;[NULL];c0ec4d10-185b-4a63-b684-52953050cd7e;[NULL];497;c422c90a-8809-4b82-bfe6-e5c096a77c0b;0;[NULL];[NULL];F6V1;000100000798;[NULL];[NULL];[NULL];[NULL];[NULL];1
--14,800,193;205,946;419,446;M1035799-003;B;VN065I000F;[NULL];[NULL];[NULL];good;create;1;[NULL];1,241;[NULL];[NULL];2,880;[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];1,779,086,401,576;V1067271;2,948;1,779,086,401,576;V1067271;2,948;EPDVI_VN;false;PRODUCT;SN;000100000798-04;false;[NULL];[NULL];PCBA,POWER BOARD,M2010;[NULL];[NULL];-1;[NULL];c0ec4d10-185b-4a63-b684-52953050cd7e;[NULL];497;c422c90a-8809-4b82-bfe6-e5c096a77c0b;0;[NULL];[NULL];F6V1;000100000798;[NULL];[NULL];[NULL];[NULL];[NULL];1
--14,800,194;205,946;419,446;M1035799-003;B;VN065I000G;[NULL];[NULL];[NULL];good;create;1;[NULL];1,241;[NULL];[NULL];2,880;[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];1,779,086,401,576;V1067271;2,948;1,779,086,401,576;V1067271;2,948;EPDVI_VN;false;PRODUCT;SN;000100000798-04;false;[NULL];[NULL];PCBA,POWER BOARD,M2010;[NULL];[NULL];-1;[NULL];c0ec4d10-185b-4a63-b684-52953050cd7e;[NULL];497;c422c90a-8809-4b82-bfe6-e5c096a77c0b;0;[NULL];[NULL];F6V1;000100000798;[NULL];[NULL];[NULL];[NULL];[NULL];1
--14,800,195;205,946;419,446;M1035799-003;B;VN065I000H;[NULL];[NULL];[NULL];good;create;1;[NULL];1,241;[NULL];[NULL];2,880;[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];1,779,086,401,576;V1067271;2,948;1,779,086,401,576;V1067271;2,948;EPDVI_VN;false;PRODUCT;SN;000100000798-04;false;[NULL];[NULL];PCBA,POWER BOARD,M2010;[NULL];[NULL];-1;[NULL];c0ec4d10-185b-4a63-b684-52953050cd7e;[NULL];497;c422c90a-8809-4b82-bfe6-e5c096a77c0b;0;[NULL];[NULL];F6V1;000100000798;[NULL];[NULL];[NULL];[NULL];[NULL];1
--14,800,196;205,946;419,446;M1035799-003;B;VN065I000I;[NULL];[NULL];[NULL];good;create;1;[NULL];1,241;[NULL];[NULL];2,880;[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];1,779,086,401,576;V1067271;2,948;1,779,086,401,576;V1067271;2,948;EPDVI_VN;false;PRODUCT;SN;000100000798-04;false;[NULL];[NULL];PCBA,POWER BOARD,M2010;[NULL];[NULL];-1;[NULL];c0ec4d10-185b-4a63-b684-52953050cd7e;[NULL];497;c422c90a-8809-4b82-bfe6-e5c096a77c0b;0;[NULL];[NULL];F6V1;000100000798;[NULL];[NULL];[NULL];[NULL];[NULL];1
--14,800,197;205,946;419,446;M1035799-003;B;VN065I000J;[NULL];[NULL];[NULL];good;create;1;[NULL];1,241;[NULL];[NULL];2,880;[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];1,779,086,401,576;V1067271;2,948;1,779,086,401,576;V1067271;2,948;EPDVI_VN;false;PRODUCT;SN;000100000798-04;false;[NULL];[NULL];PCBA,POWER BOARD,M2010;[NULL];[NULL];-1;[NULL];c0ec4d10-185b-4a63-b684-52953050cd7e;[NULL];497;c422c90a-8809-4b82-bfe6-e5c096a77c0b;0;[NULL];[NULL];F6V1;000100000798;[NULL];[NULL];[NULL];[NULL];[NULL];1
--14,800,198;205,946;419,446;M1035799-003;B;VN065I000K;[NULL];[NULL];[NULL];good;create;1;[NULL];1,241;[NULL];[NULL];2,880;[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];1,779,086,401,576;V1067271;2,948;1,779,086,401,576;V1067271;2,948;EPDVI_VN;false;PRODUCT;SN;000100000798-04;false;[NULL];[NULL];PCBA,POWER BOARD,M2010;[NULL];[NULL];-1;[NULL];c0ec4d10-185b-4a63-b684-52953050cd7e;[NULL];497;c422c90a-8809-4b82-bfe6-e5c096a77c0b;0;[NULL];[NULL];F6V1;000100000798;[NULL];[NULL];[NULL];[NULL];[NULL];1
--14,800,199;205,946;419,446;M1035799-003;B;VN065I000L;[NULL];[NULL];[NULL];good;create;1;[NULL];1,241;[NULL];[NULL];2,880;[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];1,779,086,401,577;V1067271;2,948;1,779,086,401,577;V1067271;2,948;EPDVI_VN;false;PRODUCT;SN;000100000798-04;false;[NULL];[NULL];PCBA,POWER BOARD,M2010;[NULL];[NULL];-1;[NULL];c0ec4d10-185b-4a63-b684-52953050cd7e;[NULL];497;c422c90a-8809-4b82-bfe6-e5c096a77c0b;0;[NULL];[NULL];F6V1;000100000798;[NULL];[NULL];[NULL];[NULL];[NULL];1
--14,800,200;205,946;419,446;M1035799-003;B;VN065I000M;[NULL];[NULL];[NULL];good;create;1;[NULL];1,241;[NULL];[NULL];2,880;[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];1,779,086,401,577;V1067271;2,948;1,779,086,401,577;V1067271;2,948;EPDVI_VN;false;PRODUCT;SN;000100000798-04;false;[NULL];[NULL];PCBA,POWER BOARD,M2010;[NULL];[NULL];-1;[NULL];c0ec4d10-185b-4a63-b684-52953050cd7e;[NULL];497;c422c90a-8809-4b82-bfe6-e5c096a77c0b;0;[NULL];[NULL];F6V1;000100000798;[NULL];[NULL];[NULL];[NULL];[NULL];1
--14,800,201;205,946;419,446;M1035799-003;B;VN065I000N;[NULL];[NULL];[NULL];good;create;1;[NULL];1,241;[NULL];[NULL];2,880;[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];1,779,086,401,577;V1067271;2,948;1,779,086,401,577;V1067271;2,948;EPDVI_VN;false;PRODUCT;SN;000100000798-04;false;[NULL];[NULL];PCBA,POWER BOARD,M2010;[NULL];[NULL];-1;[NULL];c0ec4d10-185b-4a63-b684-52953050cd7e;[NULL];497;c422c90a-8809-4b82-bfe6-e5c096a77c0b;0;[NULL];[NULL];F6V1;000100000798;[NULL];[NULL];[NULL];[NULL];[NULL];1
--14,800,202;205,946;419,446;M1035799-003;B;VN065I000O;[NULL];[NULL];[NULL];good;create;1;[NULL];1,241;[NULL];[NULL];2,880;[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];1,779,086,401,577;V1067271;2,948;1,779,086,401,577;V1067271;2,948;EPDVI_VN;false;PRODUCT;SN;000100000798-04;false;[NULL];[NULL];PCBA,POWER BOARD,M2010;[NULL];[NULL];-1;[NULL];c0ec4d10-185b-4a63-b684-52953050cd7e;[NULL];497;c422c90a-8809-4b82-bfe6-e5c096a77c0b;0;[NULL];[NULL];F6V1;000100000798;[NULL];[NULL];[NULL];[NULL];[NULL];1
--14,800,203;205,946;419,446;M1035799-003;B;VN065I000P;[NULL];[NULL];[NULL];good;create;1;[NULL];1,241;[NULL];[NULL];2,880;[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];1,779,086,401,577;V1067271;2,948;1,779,086,401,577;V1067271;2,948;EPDVI_VN;false;PRODUCT;SN;000100000798-04;false;[NULL];[NULL];PCBA,POWER BOARD,M2010;[NULL];[NULL];-1;[NULL];c0ec4d10-185b-4a63-b684-52953050cd7e;[NULL];497;c422c90a-8809-4b82-bfe6-e5c096a77c0b;0;[NULL];[NULL];F6V1;000100000798;[NULL];[NULL];[NULL];[NULL];[NULL];1
--14,800,204;205,946;419,446;M1035799-003;B;VN065I000Q;[NULL];[NULL];[NULL];good;create;1;[NULL];1,241;[NULL];[NULL];2,880;[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];1,779,086,401,582;V1067271;2,948;1,779,086,401,582;V1067271;2,948;EPDVI_VN;false;PRODUCT;SN;000100000798-04;false;[NULL];[NULL];PCBA,POWER BOARD,M2010;[NULL];[NULL];-1;[NULL];c0ec4d10-185b-4a63-b684-52953050cd7e;[NULL];497;c422c90a-8809-4b82-bfe6-e5c096a77c0b;0;[NULL];[NULL];F6V1;000100000798;[NULL];[NULL];[NULL];[NULL];[NULL];1
--14,800,205;205,946;419,446;M1035799-003;B;VN065I000R;[NULL];[NULL];[NULL];good;create;1;[NULL];1,241;[NULL];[NULL];2,880;[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];1,779,086,401,582;V1067271;2,948;1,779,086,401,582;V1067271;2,948;EPDVI_VN;false;PRODUCT;SN;000100000798-04;false;[NULL];[NULL];PCBA,POWER BOARD,M2010;[NULL];[NULL];-1;[NULL];c0ec4d10-185b-4a63-b684-52953050cd7e;[NULL];497;c422c90a-8809-4b82-bfe6-e5c096a77c0b;0;[NULL];[NULL];F6V1;000100000798;[NULL];[NULL];[NULL];[NULL];[NULL];1
--14,800,206;205,946;419,446;M1035799-003;B;VN065I000S;[NULL];[NULL];[NULL];good;create;1;[NULL];1,241;[NULL];[NULL];2,880;[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];1,779,086,401,583;V1067271;2,948;1,779,086,401,583;V1067271;2,948;EPDVI_VN;false;PRODUCT;SN;000100000798-04;false;[NULL];[NULL];PCBA,POWER BOARD,M2010;[NULL];[NULL];-1;[NULL];c0ec4d10-185b-4a63-b684-52953050cd7e;[NULL];497;c422c90a-8809-4b82-bfe6-e5c096a77c0b;0;[NULL];[NULL];F6V1;000100000798;[NULL];[NULL];[NULL];[NULL];[NULL];1
--14,800,207;205,946;419,446;M1035799-003;B;VN065I000T;[NULL];[NULL];[NULL];good;create;1;[NULL];1,241;[NULL];[NULL];2,880;[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];1,779,086,401,583;V1067271;2,948;1,779,086,401,583;V1067271;2,948;EPDVI_VN;false;PRODUCT;SN;000100000798-04;false;[NULL];[NULL];PCBA,POWER BOARD,M2010;[NULL];[NULL];-1;[NULL];c0ec4d10-185b-4a63-b684-52953050cd7e;[NULL];497;c422c90a-8809-4b82-bfe6-e5c096a77c0b;0;[NULL];[NULL];F6V1;000100000798;[NULL];[NULL];[NULL];[NULL];[NULL];1
--14,800,208;205,946;419,446;M1035799-003;B;VN065I000U;[NULL];[NULL];[NULL];good;create;1;[NULL];1,241;[NULL];[NULL];2,880;[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];[NULL];1,779,086,401,583;V1067271;2,948;1,779,086,401,583;V1067271;2,948;EPDVI_VN;false;PRODUCT;SN;000100000798-04;false;[NULL];[NULL];PCBA,POWER BOARD,M2010;[NULL];[NULL];-1;[NULL];c0ec4d10-185b-4a63-b684-52953050cd7e;[NULL];497;c422c90a-8809-4b82-bfe6-e5c096a77c0b;0;[NULL];[NULL];F6V1;000100000798;[NULL];[NULL];[NULL];[NULL];[NULL];1

---- label sau khi in xong xem ------------------- DAI SN CHO CONG LENH -------------------------------

------------------- SMT BOM --------------------------------------------
select *from mes.mes_smt_bom msb 
where msb.product_no  ='PRODUCT-CLIMAX-001';

---- smt_bom_id -> mes_smt_bom.id;

select* from mes.mes_smt_bom_detail msbd 
where msbd.smt_bom_id  in (1342, 1343)

------------------- SMT BOM --------------------------------------------

------------------- ASSEMBLY BOM --------------------------------------------
-- material_id = '826280', material_no = 'ASSEMBLY-CLIMAX-001'
-- product_no = 'PRODUCT-CLIMAX-001'

--INSERT INTO mes.mes_assy_bom (
--    bom_code, 
--    bom_name, 
--    material_id, 
--    product_no, 
--    product_name, 
--    product_version, 
--    created_dt, 
--    creator, 
--    creator_id, 
--    last_edited_dt, 
--    last_editor, 
--    last_editor_id, 
--    org_code, 
--    is_deleted, 
--    customer_code, 
--    customer_pn, 
--    bom_date, 
--    plant_code
--) VALUES (
--    'BOM-ASSY-CLIMAX-001',           
--    'BOM FOR CLIMAX 001',       
--    826280,                     
--    'PRODUCT-CLIMAX-001',       
--    'PRODUCT-CLIMAX-001',       
--    'A0',                        
--    -- Tự động lấy epoch timestamp dạng mili-giây (bigint) của Postgres
--    (EXTRACT(EPOCH FROM NOW()) * 1000)::bigint,  
--    'V1802185',                 
--    4583,                       
--    -- Tự động lấy epoch timestamp dạng mili-giây (bigint) cho last_edited
--    (EXTRACT(EPOCH FROM NOW()) * 1000)::bigint,  
--    'V1802185',                 
--    4583,                       
--    'EPDVI_VN',                 
--    false, -- Postgres hỗ trợ trực tiếp kiểu dữ liệu BOOLEAN (true/false)
--    '',                  
--    '',            
--    CURRENT_DATE, -- Tự động lấy ngày hệ thống (date) của Postgres
--    'E6V1'                      
--);

select * from mes.mes_assy_bom mab
where mab.product_no = 'PRODUCT-CLIMAX-001';
--id	bom_code	bom_name	material_id	product_no	product_name	product_version	created_dt	creator	creator_id	last_edited_dt	last_editor	last_editor_id	org_code	is_deleted	customer_code	customer_pn	bom_date	plant_code
--1,034	M1259480-001-G1	[NULL]	403,164	M1259480-001-G1	MOTHERBOARD-C2195	E	1,730,262,686,647	H7109506	4,298	1,730,262,686,647	H7109506	4,298	EPDVI_VN	false	FOXCONN	M1259480-001	2024-10-30	F6V1


--INSERT INTO mes.mes_assy_bom_detail  (
--    assy_bom_id,            -- ID liên kết sang bảng bom chính
--    pid, 
--    parent_material_no, 
--    process_id, 
--    process_code, 
--    line_id, 
--    line_code, 
--    eqp_id, 
--    eqp_code, 
--    material_id, 
--    material_no, 
--    material_name, 
--    material_version, 
--    material_type, 
--    basic_qty, 
--    uom_id, 
--    assy_sort, 
--    location, 
--    "desc",                 -- Bọc trong dấu ngoặc kép vì desc là từ khóa trùng với ORDER BY DESC
--    alternative, 
--    assy_flag, 
--    assy_type, 
--    mfg, 
--    mfg_material_no, 
--    mfg_material_version, 
--    created_dt, 
--    creator, 
--    creator_id, 
--    last_edited_dt, 
--    last_editor, 
--    last_editor_id, 
--    org_code, 
--    is_deleted, 
--    scan_type, 
--    material_parse_rule_id, 
--    item, 
--    customer_sn_flag, 
--    material_group, 
--    primary_material_no, 
--    "level"                 -- Bọc trong dấu ngoặc kép vì level là từ khóa hệ thống
--) VALUES (
--    -- Tự động tìm id của BOM chính dựa theo bom_code vừa tạo ở bước trước
--    (SELECT id FROM mes.mes_assy_bom mab  WHERE mab.bom_code = 'BOM-ASSY-CLIMAX-001' LIMIT 1), 
--    0, 
--    'PRODUCT-CLIMAX-001',   -- parent_material_no (Mã sản phẩm cha)
--    484,                    -- process_id (Mẫu)
--    'ASSY-1',               -- process_code
--    NULL, NULL, NULL, NULL, -- line và eqp để trống theo mẫu
--    826280,                 -- material_id (ID linh kiện con bạn vừa đưa)
--    'ASSEMBLY-CLIMAX-001',  -- material_no (Mã linh kiện con bạn vừa đưa)
--    'Component for Climax', -- material_name (Tên linh kiện con)
--    NULL, 
--    'Assembly',             -- material_type
--    NULL, NULL, 
--    6,                      -- assy_sort
--    NULL, NULL, 
--    'ALT', 
--    true, 
--    'ASSY', 
--    NULL, NULL, NULL, 
--    (EXTRACT(EPOCH FROM NOW()) * 1000)::bigint, -- created_dt (Systime Postgres)
--    'V1802185',             -- creator
--    4583,                   -- creator_id
--    (EXTRACT(EPOCH FROM NOW()) * 1000)::bigint, -- last_edited_dt (Systime Postgres)
--    'V1802185',             -- last_editor
--    4583,                   -- last_editor_id
--    'EPDVI_VN',             -- org_code
--    false,                  -- is_deleted (để false để dữ liệu hiển thị, mẫu của bạn đang để true tức là bị xóa)
--    'PKGID', 
--    NULL, 
--    '@', 
--    false, 
--    'M1010885-005-14', 
--    'M1010885-005', 
--    1                       -- level
--);
select * from mes.mes_assy_bom_detail mabd
where mabd.assy_bom_id = 1034
and mabd.material_no  = 'M1008629-001';

select * from mes.mes_assy_bom_detail mabd
where mabd.assy_bom_id = '1189'


select *from basic_sys.basic_material bm 
where bm.material_no  = 'PRODUCT-CLIMAX-001';

------------------- ASSEMBLY BOM --------------------------------------------

------------------- ROUTE --------------------------------------------
-- route_id = 483
select * from mes.mes_route mr
where mr.route_code  = 'CLIMAX-ROUTER-ROUTE'

-- 路由节点属性表
select * from mes.mes_route_node mrn
where mrn.route_id  = 483

-- 路由节点关系表
-- condition : điều kiện để sang node mới (PASS/FAIL)

--Process_from_id/ process_to_id: lấy từ bảng basic_sys.basic_process_seg theo tên node đã chọn trên giao diện
select * from basic_sys.basic_process_seg 

select * from mes.mes_route_conn mrc 
where mrc.route_id  = 483

-- LIST PRODUCT BY ROUTE
select  * from mes.mes_route_product mrp 
where mrp.material_id  = 21071996

select * from mes.mes_wo_route mwr 
where route_id ='483'


214da53b-266a-4e40-9eb9-d26200a4d43d	c422c90a-8809-4b82-bfe6-e5c096a77c0b
------------------- ROUTE --------------------------------------------

------------------- WO ONLINE ----------------------------------------
select *from mes.mes_wo mw 
where mw.id = 21071996;

--- ORDER_ONLINE_RULE_CODE SN
select*from mes.mes_product_barcode_rule
where product_no = 'PRODUCT-CLIMAX-001';
--- ONLINE_RULE_PACK PACKING 
select * from mes.mes_product_package_rule mppr 
where mppr.product_no  = 'M1259480-001-G1';

select * from mes.mes_product_package_rule mppr 
where mppr.product_no  = 'PRODUCT-CLIMAX-001';
-- ONLINE_RULE_PACK
select*from mes.mes_wo_pack_rule
where product_no  = 'PRODUCT-CLIMAX-001'
--     MaterialFeignVO materialFeignVO = new MaterialFeignVO();
--      materialFeignVO.setMaterialNo(workOrder.getProductNo());
--      materialFeignVO.setPlantCode(workOrder.getPlantCode());
--      materialFeignVO.setOrgCode(workOrder.getOrgCode());
--      List<MaterialFeignDTO> materials = (List)this.materialClient.getMaterials(materialFeignVO).getData();
--      if (CollectionUtils.isEmpty(materials)) {
--         throw new BizException(ErrorCodeEnum.MATERIAL_NO_IS_NOT_EXIST);
--      } 
-- because call external service ==> go online WorOrder fail MATERIAL_NO_IS_NOT_EXIST
-- im dont have table information

-----------------------------------------------------------------------

-------------------------smt material online----------------------

-- 工位操作配置

select * from MES.mes_smt_bom bmb
where product_no = 'PRODUCT-CLIMAX-001'

select * from basic_sys.basic_eqp be 
where id = '2488'





 

-----------------------------------------------------------------------


