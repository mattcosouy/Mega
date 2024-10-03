-- 12/09/23 PG y MG
-- TABLA DE CONFIGURACION DE EMPRESAS en SERVIDOR AXFACADECORP, Utilizada por los Orchestadores y Otros procesos locales

SET ANSI_NULLS ON
GO

drop table [dbo].[EmpresasAx]

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[EmpresasAx](
	[Empresa] [nvarchar](20) NULL,
	[DataAreaId] [nvarchar](5) NULL,
	[Bandeja] [nvarchar](20) NULL,
	[AxTipo] [nvarchar](5) NULL,
	[AxAcceso] [nvarchar](100) NULL,
	[InstanciaLocal] [nvarchar](50) NULL,
	[BaseDatos] [nvarchar](50) NULL,
	[LinkedServer] [nvarchar](20) NULL,
	[PaisEmpresa] [nvarchar](10) NULL,
	IdBase [nvarchar](10) NULL,
) ON [PRIMARY]
GO

INSERT INTO EmpresasAx (Empresa, DataAreaId, Bandeja, AxTipo, AxAcceso, InstanciaLocal, BaseDatos, LinkedServer, PaisEmpresa, IdBase) VALUES ('Megalabs UY', '120', 'AX5URUMPH_CAIC', 'AX2k9', 'AOS', 'MLAP105CAN2\AX2K9URUMPHPRO', 'Ax2k9MPHPro', 'NULL', 'NULL', 'NULL')
INSERT INTO EmpresasAx (Empresa, DataAreaId, Bandeja, AxTipo, AxAcceso, InstanciaLocal, BaseDatos, LinkedServer, PaisEmpresa, IdBase) VALUES ('Selenin', '125', 'AX5URUMPH_CAIC', 'AX2k9', 'AOS', 'MLAP105CAN2\AX2K9URUMPHPRO', 'Ax2k9MPHPro', 'NULL', 'NULL', 'NULL')
INSERT INTO EmpresasAx (Empresa, DataAreaId, Bandeja, AxTipo, AxAcceso, InstanciaLocal, BaseDatos, LinkedServer, PaisEmpresa, IdBase) VALUES ('Klinos', '048', 'AX4VENKLI_CAIC', 'AX2k4', 'AOS', 'MLAP020CCS\AX4VENKLIPRO', 'Ax4VenKliPRO', 'NULL', 'NULL', 'NULL')
INSERT INTO EmpresasAx (Empresa, DataAreaId, Bandeja, AxTipo, AxAcceso, InstanciaLocal, BaseDatos, LinkedServer, PaisEmpresa, IdBase) VALUES ('Acromax', '090', 'AX4ECUACR_CAIC', 'AX2k4', 'AOS', 'ACAP014GYE\AX4ECUACRPRO', 'Ax4EcuAcrPro', 'NULL', 'NULL', 'NULL')
INSERT INTO EmpresasAx (Empresa, DataAreaId, Bandeja, AxTipo, AxAcceso, InstanciaLocal, BaseDatos, LinkedServer, PaisEmpresa, IdBase) VALUES ('Megalabs', '010', 'URU-ROE_CAIC', 'AX2k9', 'AOS', 'MLAP021MVD1\AX2K9URUROEPRO', 'Ax2k9UruRoePro', 'NULL', 'NULL', 'NULL')
INSERT INTO EmpresasAx (Empresa, DataAreaId, Bandeja, AxTipo, AxAcceso, InstanciaLocal, BaseDatos, LinkedServer, PaisEmpresa, IdBase) VALUES ('Megalabs PE', '310', 'AX5PERROE_CAIC', 'AX2k9', 'AOS', 'REAP010LIM\AX2K9PERROEPRO', 'Ax2k9PerRoePro', 'NULL', 'NULL', 'NULL')
INSERT INTO EmpresasAx (Empresa, DataAreaId, Bandeja, AxTipo, AxAcceso, InstanciaLocal, BaseDatos, LinkedServer, PaisEmpresa, IdBase) VALUES ('Megalabs AR', '070', 'AX5ARGRAY_CAIC', 'AX2k9', 'AOS', 'RYAP021BUE\AX2K9ARGRAYPRO', 'Ax2k9ArgRayPro', 'NULL', 'NULL', 'NULL')
INSERT INTO EmpresasAx (Empresa, DataAreaId, Bandeja, AxTipo, AxAcceso, InstanciaLocal, BaseDatos, LinkedServer, PaisEmpresa, IdBase) VALUES ('Megalabs MX', '100', 'AX5MEXITA_CAIC', 'AX2k9', 'AOS', 'ITAP020MEX\AX2K9MEXITAPRO', 'Ax2k9MexItaPro', 'NULL', 'NULL', 'NULL')
INSERT INTO EmpresasAx (Empresa, DataAreaId, Bandeja, AxTipo, AxAcceso, InstanciaLocal, BaseDatos, LinkedServer, PaisEmpresa, IdBase) VALUES ('Scandinavia', '050', 'AX5COLSCA_CAIC', 'AX2k9', 'AOS', 'SCAP023BOG\AX2K9COLSCAPRO', 'Ax2k9ColScaPro', 'NULL', 'NULL', 'NULL')
INSERT INTO EmpresasAx (Empresa, DataAreaId, Bandeja, AxTipo, AxAcceso, InstanciaLocal, BaseDatos, LinkedServer, PaisEmpresa, IdBase) VALUES ('Leterago PA', 'PA1L', 'AX7PANLET_CAIC', 'AX365', 'https://panletpro.operations.dynamics.com/?cmp=PA1L', 'LEAP018PMA\AX2K9PANLETPRO', 'AxPanLetOLAP', 'AzOLAPPanLet', 'PANLET', 'AX7PANLET')
INSERT INTO EmpresasAx (Empresa, DataAreaId, Bandeja, AxTipo, AxAcceso, InstanciaLocal, BaseDatos, LinkedServer, PaisEmpresa, IdBase) VALUES ('Leterago DO', 'LD1L', 'AX7DOMLET_CAIC', 'AX365', 'https://domletpro.operations.dynamics.com/?cmp=LD1L', 'LEAP026GAZ', 'AxDomLetOLAP', 'AzOLAPDomLet', 'DOMLET', 'AX7DOMLET')
INSERT INTO EmpresasAx (Empresa, DataAreaId, Bandeja, AxTipo, AxAcceso, InstanciaLocal, BaseDatos, LinkedServer, PaisEmpresa, IdBase) VALUES ('Rowe DO', 'DO1L', 'AX7DOMROW_CAIC', 'AX365', 'https://domrowpro.operations.dynamics.com/?cmp=DO1L', 'ROAP048STD\AX4DOMROWPRO', 'AxDomRowOLAP', 'AzOLAPDomRow', 'DOMROW', 'AX7DOMROW')
INSERT INTO EmpresasAx (Empresa, DataAreaId, Bandeja, AxTipo, AxAcceso, InstanciaLocal, BaseDatos, LinkedServer, PaisEmpresa, IdBase) VALUES ('Leterago CR', 'CR1L', 'AX7CRILET_CAIC', 'AX365', 'https://criletpro.operations.dynamics.com/?cmp=CR1L', 'LEAP010USA2\AxGuaLetOlap', 'AxCriLetOLAP', 'AzOLAPCriLet', 'CRILET', 'AX7CRILET')
INSERT INTO EmpresasAx (Empresa, DataAreaId, Bandeja, AxTipo, AxAcceso, InstanciaLocal, BaseDatos, LinkedServer, PaisEmpresa, IdBase) VALUES ('Pharma Investi', 'CL1L', 'AX7CHIPHI_CAIC', 'AX365', 'https://chiphipro.operations.dynamics.com/?cmp=CL1L', 'PIAP020USA', 'AxChiPhiOLAP', 'AzOLAPChiPhi', 'CHIPHI', 'AX7CHIPHI')
INSERT INTO EmpresasAx (Empresa, DataAreaId, Bandeja, AxTipo, AxAcceso, InstanciaLocal, BaseDatos, LinkedServer, PaisEmpresa, IdBase) VALUES ('Leterago GT', 'GT1L', 'AX7GUALET_CAIC', 'AX365', 'https://gualetpro.operations.dynamics.com/?cmp=GT1L', 'LEAP010USA2\AxGuaLetOlap', 'AxGuaLetOLAP', 'AzOLAPGuaLet', 'GUALET', 'AX7GUALET')
INSERT INTO EmpresasAx (Empresa, DataAreaId, Bandeja, AxTipo, AxAcceso, InstanciaLocal, BaseDatos, LinkedServer, PaisEmpresa, IdBase) VALUES ('Leterago HN', 'HN1L', 'AX7HNDLET_CAIC', 'AX365', 'https://hndletpro.operations.dynamics.com/?cmp=HN1L', 'LEAP010USA2\AxGuaLetOlap', 'AxHndLetOLAP', 'AzOLAPHndLet', 'HNDLET', 'AX7HNDLET')



