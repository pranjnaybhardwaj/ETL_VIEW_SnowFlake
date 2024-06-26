create or replace view DB.FIN.VW_FACT(
	
WITH CTE_USD_A AS (
    SELECT
        ER.EXCHANGE_RATE_TYPE,
        ER.START_DATE_DT,
        ER.END_DATE_DT,
        ER.SOURCE_CURRENCY,
        ER.EXCHANGE_RATE
    FROM
        C_REF.EXCHANGE_RATE ER
    WHERE
        ER.EXCHANGE_RATE_TYPE = '##3'
        AND ER.TARGET_CURRENCY = 'USD'
		
),
CTE_USD_P AS (
    SELECT
        ER.EXCHANGE_RATE_TYPE,
        ER.START_DATE_DT,
        ER.END_DATE_DT,
        ER.SOURCE_CURRENCY,
        ER.EXCHANGE_RATE
    FROM
        C_REF.EXCHANGE_RATE ER
    WHERE
        ER.EXCHANGE_RATE_TYPE = '#'
        AND ER.TARGET_CURRENCY = 'USD'
),
--CTE_USD_ME AS (
--    SELECT
--        ER.EXCHANGE_RATE_TYPE,
--        ER.START_DATE,
--        ER.END_DATE,
--        ER.START_DATE_DT,
--        ER.END_DATE_DT,
--        ER.SOURCE_CURRENCY,
--        ER.EXCHANGE_RATE
--    FROM
--        C_REF.EXCHANGE_RATE ER
--    WHERE
--        ER.EXCHANGE_RATE_TYPE = 'AS01' 
--        AND ER.TARGET_CURRENCY = 'USD'
--),
CTE_ENG_SR_NR AS (
    SELECT
        V44_T_SER01.MANDT,
		V44_T_SER01.LIEF_NR,
		V44_T_SER01.POSNR,
		V45_T_OBJK.SERNR
    FROM
        DB.S_SAPECC_A.T_OBJK V45_T_OBJK
		JOIN DB.S_SAPECC_A.T_SER01 V44_T_SER01
		ON V45_T_OBJK.MANDT = V44_T_SER01.MANDT
		AND V45_T_OBJK.OBKNR = V44_T_SER01.OBKNR
    WHERE
        V45_T_OBJK.OBZAE='1'
		AND V45_T_OBJK.TASER='##' 
		AND V45_T_OBJK.OBJVW='#'        
)



SELECT 
    MD5(
        V01_T_CE1.BELNR || V01_T_CE1.POSNR || V01_T_CE1.KAUFN || V01_T_CE1.KDPOS || V01_T_CE1.BUDAT 
    ) AS ROW_KEY,
    V11_T_VBAK.YYACCESS AS ACCESS_CLASS,
    'LOL' || V01_T_CE1.MANDT AS SOURCE_SYSTEM,
    V01_T_CE1.BELNR AS COPA_DOC,
    V01_T_CE1.POSNR AS COPA_DOC_ITEM_NUM,
    V01_T_CE1.KAUFN AS SO_SK,
    V01_T_CE1.KDPOS AS SO_ITEM_SK,
    V12_T_YFIT_HEL_PRCTR.YYENTTYCODE AS SOURCE_ENTITY_CODE_SK,
    V01_T_CE1.PRCTR AS PROFIT_CENTER, 	
	(CASE WHEN V01_T_CE1.WWRS1 in ('ENG','NRE') THEN NVL(V29_T_YPST_ENHIP00001.YYPRODTYCD,' ') ELSE
     NVL(MARA.YY_PTY,' ') END) AS SOURCE_ORG_SK,
	ORG.ORG_CODE ,
    ENTITY.ENTITY_CODE,
    V01_T_CE1.WERKS AS PLANT_CODE_SK,
    V01_T_CE1.ARTNR AS MATERIAL_NUM_SK,
    V01_T_CE1.PSPNR AS WBS_ELEMENT_SK,
    V01_T_CE1.KNDNR AS SOLD_TO_SK,
    V01_T_CE1.KUNWE AS SHIP_TO_SK,
    V14_T_VBPA.KUNNR AS ULTIMATE_CONSIGNEE_SK,
    V17_T_VBPA.KUNNR AS BILL_TO_SK,
    TRY_TO_DATE(V01_T_CE1.BUDAT::VARCHAR,'YYYYMMDD') AS POSTING_DATE,
    TRY_TO_NUMBER(V01_T_CE1.BUDAT) AS POSTING_DATE_INT,
    V01_T_CE1.RBELN AS REFERENCE_DOC,
    V01_T_CE1.RPOSN AS REFERENCE_DOC_ITEM,
    V01_T_CE1.BUKRS AS COMPANY_CODE,
    V01_T_CE1.WWRS1 AS REVENUE_SEGMENT,
    V01_T_CE1.WWBPN AS BASE_MATERIAL,
    V01_T_CE1.KSTAR AS COST_ELEMENT,
    TRY_TO_NUMBER(NULLIF(V01_T_CE1.FADAT,0)) AS INVOICE_DATE_INT,
    TRY_TO_DATE(V01_T_CE1.FADAT::VARCHAR,'YYYYMMDD') AS INVOICE_DATE,
    TRY_TO_NUMBER(V01_T_CE1.HZDAT) AS COPA_DOC_CREATED_ON_DATE_INT,
    TRY_TO_DATE(V01_T_CE1.HZDAT::VARCHAR,'YYYYMMDD') AS COPA_DOC_CREATED_ON_DATE,
   
	TRY_TO_DATE(V11_T_VBAK.AEDAT::VARCHAR,'YYYYMMDD') AS BILL_DOC_CHANGED_DATE,
    TRY_TO_NUMBER(V11_T_VBAK.AEDAT) AS BILL_DOC_CHANGED_DATE_INT,
    TRY_TO_DATE(V11_T_VBAK.BSTDK::VARCHAR, 'YYYYMMDD') AS CUSTOMER_PO_DATE,
    TRY_TO_NUMBER(V11_T_VBAK.BSTDK) AS CUSTOMER_PO_DATE_INT,
	CASE WHEN (V45_T_VBKD.BSTKD IS NULL OR TRIM(V45_T_VBKD.BSTKD) = '') THEN V11_T_VBAK.BSTNK ELSE V45_T_VBKD.BSTKD END AS CUSTOMER_PO_NUMBER, 
    TRY_TO_DATE(V11_T_VBAK.VDATU::VARCHAR, 'YYYYMMDD') AS CUSTOMER_REQUEST_DATE,
    TRY_TO_NUMBER(V11_T_VBAK.VDATU) AS CUSTOMER_REQUEST_DATE_INT,
	V01_T_CE1.PERIO AS FISCAL_PERIOD,
    TFP.FISCAL_PERIOD_START_DATE AS FISCAL_PERIOD_START_DATE,
    TFP.FISCAL_PERIOD_START_STR::NUMBER(38,0) AS FISCAL_PERIOD_START_DATE_INT,
    TFP.FISCAL_PERIOD_END_DATE AS FISCAL_PERIOD_END_DATE,
    TFP.FISCAL_PERIOD_END_STR::NUMBER(38,0) AS FISCAL_PERIOD_END_DATE_INT,
    V01_T_CE1.GJAHR AS FISCAL_YEAR
	
	
   
    ZEROIFNULL(
        SUM(
            IFF(
                V01_T_CE1.PALEDGER = '02',
                (V15_T_VBAP.KZWI1),
                0
            )
        )
    ) AS LIST_PRICE_AMT_LCL,
    zeroifnull(SUM(IFF(V01_T_CE1.PALEDGER = '02',(V15_T_VBAP.KZWI1 * DOC.EXCHANGE_RATE),0))) AS LIST_PRICE_AMT_DOC,--DOC
    zeroifnull(
        SUM(
            IFF(
                V01_T_CE1.PALEDGER = '01',
                (V15_T_VBAP.KZWI1),
                0
            )
        )
    ) AS LIST_PRICE_AMT_GRP,
    ZEROIFNULL(
        SUM(
            IFF(
                V24_T_DIM_CUST.CUSTOMER_TYPE = 'I',
                IFF(
                    V01_T_CE1.PALEDGER = '02',
                    (
                        V01_T_CE1.ERLOS + V01_T_CE1.VVREV + V01_T_CE1.VVRST + V01_T_CE1.VVFRT -(V01_T_CE1.VVDSC + V01_T_CE1.VVEDC)
                    ),
                    0
                ),
                0
            )
        )
    ) AS INTERNAL_REVENUE_AMT_LCL,
    ZEROIFNULL(
        SUM(
            IFF(
                V24_T_DIM_CUST.CUSTOMER_TYPE = 'I',
                IFF(
                    V01_T_CE1.PALEDGER = '02',
                    (
                        V01_T_CE1.ERLOS + V01_T_CE1.VVREV + V01_T_CE1.VVRST + V01_T_CE1.VVFRT -(V01_T_CE1.VVDSC + V01_T_CE1.VVEDC)
                    ),
                    0
                ),
                0
            ) * DOC.EXCHANGE_RATE--DOC
        )
    ) AS INTERNAL_REVENUE_AMT_DOC,
    ZEROIFNULL(
        SUM(
            IFF(
                V24_T_DIM_CUST.CUSTOMER_TYPE = 'I',
                IFF(
                    V01_T_CE1.PALEDGER = '01',
                    (
                        V01_T_CE1.ERLOS + V01_T_CE1.VVREV + V01_T_CE1.VVRST + V01_T_CE1.VVFRT -(V01_T_CE1.VVDSC + V01_T_CE1.VVEDC)
                    ),
                    0
                ),
                0
            )
        )
    ) AS INTERNAL_REVENUE_AMT_GRP,
	
	
   
    ZEROIFNULL(
        SUM(
            IFF(
                V01_T_CE1.PALEDGER = '02',(V01_T_CE1.VVDSC),
                0
            )
        )
    ) AS DISCOUNT_AMT_LCL,
    ZEROIFNULL(
        SUM(
            IFF(
                V01_T_CE1.PALEDGER = '02',(V01_T_CE1.VVDSC),
                0
            ) * DOC.EXCHANGE_RATE--DOC
        )
    ) AS DISCOUNT_AMT_DOC,
    ZEROIFNULL(
        SUM(
            IFF(
                V01_T_CE1.PALEDGER = '01',
                (V01_T_CE1.VVDSC),
                0
            )
        )
    ) AS DISCOUNT_AMT_GRP,
    ZEROIFNULL(
        SUM(
            IFF(
                V24_T_DIM_CUST.CUSTOMER_TYPE = 'E' OR V24_T_DIM_CUST.CUSTOMER_TYPE IS NULL,
                IFF(
                    V01_T_CE1.PALEDGER = '02',
                    (
                        V01_T_CE1.ERLOS + V01_T_CE1.VVREV + V01_T_CE1.VVRST + V01_T_CE1.VVFRT -(V01_T_CE1.VVDSC + V01_T_CE1.VVEDC)
                    ),
                    0
                ),
                0
            )
        )
    ) AS EXTERNAL_REVENUE_AMT_LCL,
    ZEROIFNULL(
        SUM(
            IFF(
                V24_T_DIM_CUST.CUSTOMER_TYPE = 'E' OR V24_T_DIM_CUST.CUSTOMER_TYPE IS NULL,
                IFF(
                    V01_T_CE1.PALEDGER = '02',
                    (
                        V01_T_CE1.ERLOS + V01_T_CE1.VVREV + V01_T_CE1.VVRST + V01_T_CE1.VVFRT -(V01_T_CE1.VVDSC + V01_T_CE1.VVEDC)
                    ),
                    0
                ),
                0
            ) * DOC.EXCHANGE_RATE--DOC
        )
    ) AS EXTERNAL_REVENUE_AMT_DOC,
    ZEROIFNULL(
        SUM(
            IFF(
                V24_T_DIM_CUST.CUSTOMER_TYPE = 'E' OR V24_T_DIM_CUST.CUSTOMER_TYPE IS NULL,
                IFF(
                    V01_T_CE1.PALEDGER = '01',
                    (
                        V01_T_CE1.ERLOS + V01_T_CE1.VVREV + V01_T_CE1.VVRST + V01_T_CE1.VVFRT -(V01_T_CE1.VVDSC + V01_T_CE1.VVEDC)
                    ),
                    0
                ),
                0
            )
        )
    ) AS EXTERNAL_REVENUE_AMT_GRP,
    ZEROIFNULL(
        SUM(
            IFF(
                V01_T_CE1.PALEDGER = '02',
                (
                    V01_T_CE1.VVCC4 + V01_T_CE1.VVLOI + V01_T_CE1.VVCC3 + V01_T_CE1.VVMOI + V01_T_CE1.VVSP2 + V01_T_CE1.VVSH4 + V01_T_CE1.VVSH3 + V01_T_CE1.VVCAK
                ),
                0
            )
        )
    ) AS FIXED_COST_AMT_LCL,
						
				
				
    ZEROIFNULL(
        SUM(
            IFF(
                V01_T_CE1.PALEDGER = '02',
                (
                    V01_T_CE1.VVCC4 + V01_T_CE1.VVLOI + V01_T_CE1.VVCC3 + V01_T_CE1.VVMOI + V01_T_CE1.VVSP2 + V01_T_CE1.VVSH4 + V01_T_CE1.VVSH3 + V01_T_CE1.VVCAK
                ),
                0
            ) * DOC.EXCHANGE_RATE--DOC
        )
    ) AS FIXED_COST_AMT_DOC,
    ZEROIFNULL(
        SUM(
            IFF(
                V01_T_CE1.PALEDGER = '01',
                (
                    V01_T_CE1.VVCC4 + V01_T_CE1.VVLOI + V01_T_CE1.VVCC3 + V01_T_CE1.VVMOI + V01_T_CE1.VVSP2 + V01_T_CE1.VVSH4 + V01_T_CE1.VVSH3 + V01_T_CE1.VVCAK
                ),
                0
            )
        )
    ) AS FIXED_COST_AMT_GRP,
    
    ZEROIFNULL(
        SUM(
            IFF(
                V01_T_CE1.PALEDGER = '02',(V01_T_CE1.VVFRT),
                0
            )
        )
    ) AS FREIGHT_VALUE_AMT_LCL,
    ZEROIFNULL(
        SUM(
            IFF(
                V01_T_CE1.PALEDGER = '02',(V01_T_CE1.VVFRT),
                0
            ) * DOC.EXCHANGE_RATE--DOC
        )
    ) AS FREIGHT_VALUE_AMT_DOC,
    ZEROIFNULL(
        SUM(
            IFF(
                V01_T_CE1.PALEDGER = '01',(V01_T_CE1.VVFRT),
                0
            )
        )
    ) AS FREIGHT_VALUE_AMT_GRP,
 
    ZEROIFNULL(
        SUM(
            IFF(
                V01_T_CE1.PALEDGER = '02',
                (
                    V18_T_VBRP.NETWR / IFF(V18_T_VBRP.FKIMG = 0, 1, V18_T_VBRP.FKIMG)
                ),
                0
            )
        )
    ) AS PRICE_PER_UNIT_LCL,
    ZEROIFNULL(
        SUM(
            IFF(
                V01_T_CE1.PALEDGER = '02',
                (
                    V18_T_VBRP.NETWR / IFF(V18_T_VBRP.FKIMG = 0, 1, V18_T_VBRP.FKIMG)
                ),
                0
            ) * DOC.EXCHANGE_RATE--DOC
        )
    ) AS PRICE_PER_UNIT_DOC,
    ZEROIFNULL(
        SUM(
            IFF(
                V01_T_CE1.PALEDGER = '01',
                (
                    V18_T_VBRP.NETWR / IFF(V18_T_VBRP.FKIMG = 0, 1, V18_T_VBRP.FKIMG)
                ),
                0
            )
        )
    ) AS PRICE_PER_UNIT_GRP,
    ZEROIFNULL(
        SUM(
            IFF(
                V01_T_CE1.PALEDGER = '02',
                (
                    (
                        V01_T_CE1.ERLOS + V01_T_CE1.VVREV + V01_T_CE1.VVRST + V01_T_CE1.VVFRT
                    ) - (V01_T_CE1.VVDSC + V01_T_CE1.VVEDC)
                ),
                0
            )
        )
    ) AS SALES_VALUE_AMT_LCL,
    ZEROIFNULL(
        SUM(
            IFF(
                V01_T_CE1.PALEDGER = '02',
                (
                    (
                        V01_T_CE1.ERLOS + V01_T_CE1.VVREV + V01_T_CE1.VVRST + V01_T_CE1.VVFRT
                    ) - (V01_T_CE1.VVDSC + V01_T_CE1.VVEDC)
                ),
                0
            ) * DOC.EXCHANGE_RATE--DOC
        )
    ) AS SALES_VALUE_AMT_DOC,
    ZEROIFNULL(
        SUM(
            IFF(
                V01_T_CE1.PALEDGER = '01',
                (
                    V01_T_CE1.ERLOS + V01_T_CE1.VVREV + V01_T_CE1.VVRST + V01_T_CE1.VVFRT - (V01_T_CE1.VVDSC + V01_T_CE1.VVEDC)
                ),
                0
            )
        )
    ) AS SALES_VALUE_AMT_GRP,
    

   ZEROIFNULL(
        SUM(
            IFF(
                V01_T_CE1.PALEDGER = '02',(V01_T_CE1.ERLOS),
                0
            ) * DOC.EXCHANGE_RATE
        )
    ) AS REVENUE_AMT_DOC
,

   ZEROIFNULL(
        SUM(
            IFF(
                V01_T_CE1.PALEDGER = '01',(V01_T_CE1.VVWR1),
                0
            )
        )
    ) AS WARRANTY_COSTS_AMT_GRP
,

   ZEROIFNULL(
        SUM(
            IFF(
                V01_T_CE1.PALEDGER = '02',(V01_T_CE1.VVWR1),
                0
            ) * DOC.EXCHANGE_RATE
        )
    ) AS WARRANTY_COSTS_AMT_DOC
,

   ZEROIFNULL(
        SUM(
            IFF(
                V01_T_CE1.PALEDGER = '02',
              (V01_T_CE1.VVWR1 * CTE_USD_A.EXCHANGE_RATE),
                0
            )
        )
    ) AS WARRANTY_COSTS_AMT_USD_MA
,



---MA---02--



ZEROIFNULL(
        SUM(
            IFF(
                V01_T_CE1.PALEDGER = '02',
                (V01_T_CE1.VVCC4 * CTE_USD_A.EXCHANGE_RATE),
                0
            )
        )
    ) AS LABOR_COST_FIXED_AMT_USD_MA,



ZEROIFNULL(
        SUM(
            IFF(
                V01_T_CE1.PALEDGER = '02',
                (V01_T_CE1.VVRST * CTE_USD_P.EXCHANGE_RATE),
                0
            )
        )
    ) AS FEES_AMT_USD_PLAN,


----------------------------------------------------------------


------------TOTAL FOR + -------------------



 ZEROIFNULL(
       SUM(
            IFF(
                V01_T_CE1.PALEDGER = '01',
            (V01_T_CE1.VVMAT +V01_T_CE1.VVCC3 +V01_T_CE1.VVCC1 +  V01_T_CE1.VVCC4 + V01_T_CE1.VVCC2
+ V01_T_CE1.VVMOH + V01_T_CE1.VVSH3 + V01_T_CE1.VVMOI +  V01_T_CE1.VVSH1 + V01_T_CE1.VVLOI 
+ V01_T_CE1.VVLOH +  V01_T_CE1.VVSP2 + V01_T_CE1.VVSP1 + V01_T_CE1.VVSH4 + V01_T_CE1.VVSH2 
+ V01_T_CE1.VVCAJ + V01_T_CE1.VVCAK  + V01_T_CE1.VVPV7
             ),
                0
            )
        )
    )  AS TOTAL_COST_AMT_GRP,

			 
			 
ZEROIFNULL(
       SUM(
            IFF(
                V01_T_CE1.PALEDGER = '02',
             (V01_T_CE1.VVMAT +V01_T_CE1.VVCC3 +V01_T_CE1.VVCC1 +  V01_T_CE1.VVCC4 + V01_T_CE1.VVCC2
+ V01_T_CE1.VVMOH + V01_T_CE1.VVSH3 + V01_T_CE1.VVMOI +  V01_T_CE1.VVSH1 + V01_T_CE1.VVLOI 
+ V01_T_CE1.VVLOH +  V01_T_CE1.VVSP2 + V01_T_CE1.VVSP1 + V01_T_CE1.VVSH4 + V01_T_CE1.VVSH2 
+ V01_T_CE1.VVCAJ + V01_T_CE1.VVCAK  + V01_T_CE1.VVPV7
             ),
                0
            )
        )
    )  AS TOTAL_COST_AMT_LCL,
    
    
    ZEROIFNULL(
       SUM(
            IFF(
                V01_T_CE1.PALEDGER = '02',
             (V01_T_CE1.VVMAT +V01_T_CE1.VVCC3 +V01_T_CE1.VVCC1 +  V01_T_CE1.VVCC4 + V01_T_CE1.VVCC2
+ V01_T_CE1.VVMOH + V01_T_CE1.VVSH3 + V01_T_CE1.VVMOI +  V01_T_CE1.VVSH1 + V01_T_CE1.VVLOI 
+ V01_T_CE1.VVLOH +  V01_T_CE1.VVSP2 + V01_T_CE1.VVSP1 + V01_T_CE1.VVSH4 + V01_T_CE1.VVSH2 
+ V01_T_CE1.VVCAJ + V01_T_CE1.VVCAK  + V01_T_CE1.VVPV7
             ),
                0
           ) * DOC.EXCHANGE_RATE
        )
    )  AS TOTAL_COST_AMT_DOC,
    
    
    -------------------------------
	
-------------------------USD_STD---------------------------------------



	
----------------Security columns---------------------------------------


 CASE
        WHEN V11_T_VBAK.YYACCESS IS NULL
        OR TRIM(V11_T_VBAK.YYACCESS) = '' THEN '#N/A'
        ELSE V11_T_VBAK.YYACCESS
    END AS SEC_ACCESS_CLASS,
    CASE
        WHEN V20_T_PROJ.YYAUTHVALUE IS NULL
        OR TRIM(V20_T_PROJ.YYAUTHVALUE) = '' THEN '#N/A'
        ELSE V20_T_PROJ.YYAUTHVALUE
    END AS SEC_PROJECT_AUTH_VALUE,
    CASE
        WHEN V29_T_YPST_ENHIP00001.YYUSONLY IS NULL
        OR TRIM(V29_T_YPST_ENHIP00001.YYUSONLY) = '' THEN '#N/A'
        ELSE V29_T_YPST_ENHIP00001.YYUSONLY
    END AS SEC_USONLY_KEYCODE_FLAG,
    IFF(V24_T_DIM_CUST.CUSTOMER_VERTICAL IS NULL OR TRIM(V24_T_DIM_CUST.CUSTOMER_VERTICAL) = '','#N/A',V24_T_DIM_CUST.CUSTOMER_VERTICAL) AS SEC_CUSTOMER_VERTICAL,
    IFF(SEC.SEC_CFDB_POP IS NULL OR TRIM(SEC_CFDB_POP) = '','UNRESTRICTED',SEC.SEC_CFDB_POP ) AS SEC_CFDB_POP,
    IFF(SEC.SEC_CFDB_CITIZEN IS NULL OR TRIM(SEC.SEC_CFDB_CITIZEN) = '','UNRESTRICTED',SEC.SEC_CFDB_CITIZEN) AS SEC_CFDB_CITIZEN,
	IFF(V20_T_PROJ.PARGR IN( 'Z001' , 'Z002'),V20_T_PROJ.PARGR, 'UNRESTRICTED') AS SEC_PARTNER_DETERMINATION

FROM
    S_SAPECC_A.T_CE1 V01_T_CE1
	
    LEFT JOIN DB.S_SAPECC_A.T_VBAK V11_T_VBAK ON (
        V01_T_CE1.MANDT = V11_T_VBAK.MANDT
        AND V01_T_CE1.KAUFN = V11_T_VBAK.VBELN
    )
    LEFT JOIN DB.S_SAPECC_A.T_YFIT_HEL_PRCTR V12_T_YFIT_HEL_PRCTR ON (
        V01_T_CE1.MANDT = V12_T_YFIT_HEL_PRCTR.MANDT
        AND V01_T_CE1.BUKRS = V12_T_YFIT_HEL_PRCTR.BUKRS
        AND V01_T_CE1.PRCTR = V12_T_YFIT_HEL_PRCTR.PRCTR
		
    )
    LEFT JOIN DB.S_SAPECC_A.T_T001 V13_T_T001 ON (
        V01_T_CE1.MANDT = V13_T_T001.MANDT
        AND V01_T_CE1.BUKRS = V13_T_T001.BUKRS
    )
    LEFT JOIN DB.S_SAPECC_A.T_VBPA V14_T_VBPA ON (
        V01_T_CE1.MANDT = V14_T_VBPA.MANDT
        AND V01_T_CE1.KAUFN = V14_T_VBPA.VBELN
        AND V14_T_VBPA.POSNR = '000000'
        AND V14_T_VBPA.PARVW = 'EN'
    )
    LEFT JOIN DB.S_SAPECC_A.T_VBAP V15_T_VBAP ON (
        V01_T_CE1.MANDT = V15_T_VBAP.MANDT
        AND V01_T_CE1.KAUFN = V15_T_VBAP.VBELN
        AND V01_T_CE1.KDPOS = V15_T_VBAP.POSNR
    )
    LEFT JOIN DB.S_SAPECC_A.T_TAKT V16_T_TAKT ON (
        V01_T_CE1.MANDT = V16_T_TAKT.MANDT
        AND V01_T_CE1.AUART = V16_T_TAKT.AUART
        AND V16_T_TAKT.SPRAS = 'E'
    )
    LEFT JOIN DB.S_SAPECC_A.T_VBPA V17_T_VBPA ON (
        V01_T_CE1.MANDT = V17_T_VBPA.MANDT
        AND V01_T_CE1.KAUFN = V17_T_VBPA.VBELN
        AND V17_T_VBPA.POSNR = '000000'
        AND V17_T_VBPA.PARVW = 'RE'
    )
    LEFT JOIN DB.S_SAPECC_A.T_VBRP V18_T_VBRP ON (
        V01_T_CE1.MANDT = V18_T_VBRP.MANDT
        AND V01_T_CE1.KAUFN = V18_T_VBRP.AUBEL
        AND V01_T_CE1.KDPOS = V18_T_VBRP.AUPOS
        AND V01_T_CE1.RPOSN = V18_T_VBRP.POSNR
        AND V01_T_CE1.RBELN = V18_T_VBRP.VBELN
    )
    LEFT JOIN DB.S_SAPECC_A.T_PRPS V19_T_PRPS ON (
        V01_T_CE1.MANDT = V19_T_PRPS.MANDT
        AND V01_T_CE1.PSPNR = V19_T_PRPS.PSPNR
    )
    LEFT JOIN DB.S_SAPECC_A.T_PROJ V20_T_PROJ ON (
        V19_T_PRPS.MANDT = V20_T_PROJ.MANDT
        AND V19_T_PRPS.PSPHI = V20_T_PROJ.PSPNR
    )
    LEFT JOIN DB.S_SAPECC_A.T_TGAT V21_T_TGAT ON (
        V01_T_CE1.MANDT = V21_T_TGAT.MANDT
        AND V01_T_CE1.VRGAR = V21_T_TGAT.VRGAR
        AND V21_T_TGAT.SPRAS = 'E'
    )
    LEFT JOIN DB.S_SAPECC_A.T_TKKAD V22_T_TKKAD ON (
        V01_T_CE1.MANDT = V22_T_TKKAD.MANDT
        AND V15_T_VBAP.ABGRS = V22_T_TKKAD.ABGSL
        AND V22_T_TKKAD.SPRAS = 'E'
    )
    LEFT JOIN DB.S_SAPECC_A.T_VBRK V23_T_VBRK ON (
        V01_T_CE1.MANDT = V23_T_VBRK.MANDT
        AND V01_T_CE1.RBELN = V23_T_VBRK.VBELN
        AND V01_T_CE1.KAUFN = V23_T_VBRK.ZUONR
    )
    LEFT JOIN C_MASTER.T_DIM_CUSTOMER V24_T_DIM_CUST ON (
        'A' || V01_T_CE1.MANDT = V24_T_DIM_CUST.SOURCE_SYSTEM
        AND V01_T_CE1.KNDNR = V24_T_DIM_CUST.CUSTOMER_NUM
    )
   LEFT JOIN DB.C_REF.TIME_FISCAL_PERIOD TFP ON (
        V01_T_CE1.PERIO = TFP.FISCAL_COPA_YEAR_PERIOD_STR--PERIOD_END_DATE
    )
   LEFT JOIN "C_REF"."EXCHANGE_RATE" DOC ON (
        DOC.SOURCE_CURRENCY = V01_T_CE1.REC_WAERS 
        AND DOC.TARGET_CURRENCY = V01_T_CE1.FRWAE
        AND TFP.FISCAL_PERIOD_END_DATE  BETWEEN DOC.START_DATE_DT AND DOC.END_DATE_DT
        --AND DOC.END_DATE_DT >= TFP.FISCAL_PERIOD_END_DATE
        --AND  DOC.START_DATE <= V01_T_CE1.BUDAT
       -- and DOC.END_DATE >= V01_T_CE1.BUDAT
        AND DOC.EXCHANGE_RATE_TYPE  = 'AS02'
    )
   
    LEFT JOIN DB.S_SAPECC_A.T_TFKT V25_T_TKFT ON (
        V01_T_CE1.MANDT = V25_T_TKFT.MANDT
        AND V01_T_CE1.FKART = V25_T_TKFT.FKART
        AND V25_T_TKFT.SPRAS = 'E'
    )
    LEFT JOIN DB.S_SAPECC_A.T_T151T V26_T_T151T ON (
        V01_T_CE1.MANDT = V26_T_T151T.MANDT
        AND V01_T_CE1.KDGRP = V26_T_T151T.KDGRP
        AND V26_T_T151T.SPRAS = 'E'
    )
    LEFT JOIN DB.S_SAPECC_A.T_T001W V27_T_T001W ON (
        V01_T_CE1.MANDT = V27_T_T001W.MANDT
        AND V01_T_CE1.WERKS = V27_T_T001W.WERKS
    )
    LEFT JOIN DB.S_SAPECC_A.T_VBKD V28_T_VBKD ON (
        V01_T_CE1.MANDT = V28_T_VBKD.MANDT
        AND V01_T_CE1.KAUFN = V28_T_VBKD.VBELN
        AND V01_T_CE1.KDPOS = V28_T_VBKD.POSNR
    )
    LEFT JOIN CTE_USD_A ON (
        TFP.FISCAL_PERIOD_END_DATE BETWEEN CTE_USD_A.START_DATE_DT
        AND CTE_USD_A.END_DATE_DT
        AND V13_T_T001.WAERS = CTE_USD_A.SOURCE_CURRENCY
    )
    LEFT JOIN CTE_USD_P ON (
        TFP.FISCAL_PERIOD_END_DATE BETWEEN CTE_USD_P.START_DATE_DT
        AND CTE_USD_P.END_DATE_DT
        AND V13_T_T001.WAERS = CTE_USD_P.SOURCE_CURRENCY
    )
--   LEFT JOIN CTE_USD_ME ON (
--       TFP.FISCAL_PERIOD_END_DATE BETWEEN CTE_USD_ME.START_DATE_DT
--       AND CTE_USD_ME.END_DATE_DT
--       AND V13_T_T001.WAERS = CTE_USD_ME.SOURCE_CURRENCY
--   )
  
    LEFT JOIN DB.S_SAPECC_A.T_YPST_ENHIP00001 V29_T_YPST_ENHIP00001 ON (
        V20_T_PROJ.YYKEYCODE = V29_T_YPST_ENHIP00001.YYKEYCODE
        AND V20_T_PROJ.MANDT = V29_T_YPST_ENHIP00001.MANDT
    )
    LEFT JOIN DB.C_REF.T_REF_SALES_ORDER_CONTRACT_SECURITY SEC ON (
        'A'||V01_T_CE1.MANDT = SEC.SOURCE_SYSTEM
        AND V01_T_CE1.KAUFN = SEC.SALES_ORDER
        AND V01_T_CE1.KDPOS = SEC.SALE_ORDER_ITEM
    )
	LEFT JOIN "S_SAPECC_A"."T_MARA"  MARA ON(
	V01_T_CE1.MANDT=MARA.MANDT AND 
	V01_T_CE1.ARTNR=MARA.MATNR
	)
	LEFT JOIN "C_REPORT"."VW_DIM_ORG" ORG ON(
	'A'||V01_T_CE1.MANDT = ORG.SOURCE_SYSTEM
     AND SOURCE_ORG_SK = ORG.SOURCE_ORG
	)
    LEFT JOIN C_MASTER.T_DIM_ENTITY ENTITY ON (
            'A'||V12_T_YFIT_HEL_PRCTR.MANDT = ENTITY.SOURCE_SYSTEM
            AND V12_T_YFIT_HEL_PRCTR.YYENTTYCODE = ENTITY.SOURCE_ENTITY_CODE_SK
           
    )
    ----CUTOMER JOIN FOR DESTINATION---
    LEFT JOIN C_MASTER.T_DIM_CUSTOMER SHIP_TO ON (
            'A'||V01_T_CE1.MANDT  = SHIP_TO.SOURCE_SYSTEM
            AND SHIP_TO_SK = SHIP_TO.CUSTOMER_NUM_SK
    )
    LEFT JOIN C_MASTER.T_DIM_CUSTOMER BILL_TO ON (
            'A'||V01_T_CE1.MANDT  = BILL_TO.SOURCE_SYSTEM
            AND BILL_TO_SK = BILL_TO.CUSTOMER_NUM_SK
    )
    LEFT JOIN C_MASTER.T_DIM_CUSTOMER ULT_CON ON (
            'A'||V01_T_CE1.MANDT = ULT_CON.SOURCE_SYSTEM
            AND ULTIMATE_CONSIGNEE_SK = ULT_CON.CUSTOMER_NUM_SK
     )
     
     LEFT JOIN C_REF.XREF_COMMON_PARAMETER XREF_COUNTRY ON (
      'A'||V01_T_CE1.MANDT = XREF_COUNTRY.PARAMETER_VALUE1
	 AND XREF_COUNTRY.MODULE_NAME ='REVENUE_MARGIN_SUMMARY' AND 
       XREF_COUNTRY.PARAMETER_NAME = 'COUNTRY_CODE'//US
      )  	
      
       LEFT JOIN C_REF.XREF_COMMON_PARAMETER XREF_STATE ON (
         'A'||V01_T_CE1.MANDT = XREF_STATE.PARAMETER_VALUE1
	 AND XREF_STATE.MODULE_NAME ='REVENUE_MARGIN_SUMMARY' AND 
       XREF_STATE.PARAMETER_NAME = 'STATE_CODE'//PR
      ) 
    
	
	LEFT JOIN DB.S_SAPECC_A.T_T25A9 V30_T_T25A9 ON (
        V01_T_CE1.MANDT = V30_T_T25A9.MANDT
        AND V01_T_CE1.WWRS1 = V30_T_T25A9.WWRS1
        AND V30_T_T25A9.SPRAS = 'E'
    )
	LEFT JOIN DB.S_SAPECC_A.T_T25A4 V31_T_T25A4 ON (
        V01_T_CE1.MANDT = V31_T_T25A4.MANDT
        AND V01_T_CE1.WWPGM = V31_T_T25A4.WWPGM
        AND V31_T_T25A4.SPRAS = 'E'
    )
	LEFT JOIN DB.S_SAPECC_A.T_TM2T V32_T_TM2T ON (
        V01_T_CE1.MANDT = V32_T_TM2T.MANDT
        AND V01_T_CE1.WWMF1 = V32_T_TM2T.MVGR2
        AND V32_T_TM2T.SPRAS = 'E'
    )
	LEFT JOIN DB.S_SAPECC_A.T_T151T V33_T_T151T ON (
        V01_T_CE1.MANDT = V33_T_T151T.MANDT
        AND V01_T_CE1.KDGRP = V33_T_T151T.KDGRP
		AND V33_T_T151T.SPRAS = 'E'
    )
	LEFT JOIN DB.S_SAPECC_A.T_TAPT V34_T_TAPT ON (
        V01_T_CE1.MANDT = V34_T_TAPT.MANDT
        AND V15_T_VBAP.PSTYV = V34_T_TAPT.PSTYV
		AND V34_T_TAPT.SPRAS = 'E'
    )
	LEFT JOIN DB.S_SAPECC_A.T_TKMT V35_T_TKMT ON (
        V01_T_CE1.MANDT = V35_T_TKMT.MANDT
        AND V01_T_CE1.KTGRD = V35_T_TKMT.KTGRM
		AND V35_T_TKMT.SPRAS = 'E'
    )
	LEFT JOIN DB.S_SAPECC_A.T_CEPCT V36_T_CEPCT ON (
        V01_T_CE1.MANDT = V36_T_CEPCT.MANDT
        AND V01_T_CE1.PRCTR = V36_T_CEPCT.PRCTR
        AND V36_T_CEPCT.SPRAS = 'E'
		AND UPPER(V36_T_CEPCT.KOKRS) LIKE '%A%'
		)
	LEFT JOIN DB.S_SAPECC_A.T_TAUT V37_T_TAUT ON (
        V01_T_CE1.MANDT = V37_T_TAUT.MANDT
        AND V11_T_VBAK.AUGRU = V37_T_TAUT.AUGRU
        AND V37_T_TAUT.SPRAS = 'E'
		)
	LEFT JOIN DB.S_SAPECC_A.T_USR21 V38_T_USR21 ON (
        V01_T_CE1.MANDT = V38_T_USR21.MANDT
        AND V01_T_CE1.USNAM = V38_T_USR21.BNAME
    )
	LEFT JOIN DB.S_SAPECC_A.T_TM1T V39_T_TM1T ON (
        V01_T_CE1.MANDT = V39_T_TM1T.MANDT
        AND V01_T_CE1.WWPF1 = V39_T_TM1T.MVGR1
        AND V39_T_TM1T.SPRAS = 'E'
		)
     
	LEFT JOIN DB.S_SAPECC_A.T_T001L V41_T_T001L ON (
        V01_T_CE1.MANDT = V41_T_T001L.MANDT
        AND V01_T_CE1.LGORT = V41_T_T001L.LGORT
		AND V01_T_CE1.WERKS = V41_T_T001L.WERKS
    )
	LEFT JOIN DB.S_SAPECC_A.T_CSKU V42_T_CSKU ON (
        V01_T_CE1.MANDT = V42_T_CSKU.MANDT
        AND V01_T_CE1.KSTAR = V42_T_CSKU.KSTAR
		AND V42_T_CSKU.SPRAS = 'E'
    )
	LEFT JOIN DB.S_SAPECC_A.T_ADRP V43_T_ADRP ON (
        V01_T_CE1.MANDT = V38_T_USR21.MANDT
        AND V01_T_CE1.USNAM = V38_T_USR21.BNAME
		AND V38_T_USR21.MANDT = V43_T_ADRP.CLIENT
		AND V38_T_USR21.PERSNUMBER= V43_T_ADRP.PERSNUMBER
    )
    LEFT JOIN CTE_ENG_SR_NR ON (
        V15_T_VBAP.MANDT = CTE_ENG_SR_NR.MANDT
        AND V15_T_VBAP.VGBEL = CTE_ENG_SR_NR.LIEF_NR
        AND V15_T_VBAP.VGPOS = CTE_ENG_SR_NR.POSNR
	)
                                                         
     LEFT JOIN DB.S_SAPECC_A.T_YAFT_ACTYPE V44_T_YAFT_ACTYPE ON (
        V15_T_VBAP.MANDT = V44_T_YAFT_ACTYPE.MANDT
        AND V15_T_VBAP.YYACTYPE = V44_T_YAFT_ACTYPE.YACTYPE
        
	)                                                   
                                                         
    LEFT JOIN DB.S_SAPECC_A.T_VBKD V45_T_VBKD ON (
        V01_T_CE1.MANDT = V45_T_VBKD.MANDT
        AND V01_T_CE1.KAUFN = V45_T_VBKD.VBELN
        AND V45_T_VBKD.POSNR = '000000'
    )
	
	LEFT JOIN DB.S_SAPECC_A.T_KNA1 V46_T_KNA1_SHIP ON (
        V01_T_CE1.MANDT = V46_T_KNA1_SHIP.MANDT
        AND V01_T_CE1.KUNWE = V46_T_KNA1_SHIP.KUNNR
    )
	
	LEFT JOIN DB.S_SAPECC_A.T_TLVT V47_T_TLVT ON (
        V01_T_CE1.MANDT = V47_T_TLVT.MANDT
		AND V15_T_VBAP.VKAUS = V47_T_TLVT.ABRVW		
        AND V47_T_TLVT.SPRAS = 'E'
	)
	
	LEFT JOIN C_MASTER.T_DIM_ADDR SHIP_TO_ADDR ON (
            'A'||V01_T_CE1.MANDT  = SHIP_TO_ADDR.SOURCE_SYSTEM
            AND SHIP_TO_ADDR_SK = SHIP_TO_ADDR.ADDR_NUM_SK
    )
    LEFT JOIN C_MASTER.T_DIM_ADDR BILL_TO_ADDR ON (
            'A'||V01_T_CE1.MANDT  = BILL_TO_ADDR.SOURCE_SYSTEM
            AND BILL_TO_ADDR_SK = BILL_TO_ADDR.ADDR_NUM_SK
    )
    LEFT JOIN C_MASTER.T_DIM_ADDR ULT_CON_ADDR ON (
            'A'||V01_T_CE1.MANDT = ULT_CON_ADDR.SOURCE_SYSTEM
            AND ULTIMATE_CONSIGNEE_ADDR_SK = ULT_CON_ADDR.ADDR_NUM_SK
     )
	
WHERE
	FISCAL_YEAR in(YEAR(CURRENT_DATE),YEAR(CURRENT_DATE)-1,YEAR(CURRENT_DATE)-2)
	AND PROFIT_CENTER NOT IN('DUMMY')
    AND COMPANY_CODE BETWEEN 1000 AND 7999
    

GROUP BY ALL;
