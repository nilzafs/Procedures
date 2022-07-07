

 ALTER PROCEDURE [dbo].[JB_SI_SP_CONTROLE_VECTO_CNH] 
/* CRIADO POR NILZA EM 08/06/2022 - SOLICITADO PELA DIRETORIA OPERACIONAL */
 AS



Declare @Body varchar(max),  
		@TableHead varchar(max),  
	    @TableTail varchar(max),  
		@subj  nvarchar(300),  
		@emailCCo nvarchar(256),  
		@tableHTML  NVARCHAR(MAX) ,
		@EMAIL varchar(max)
 Set NoCount On;   
 Set @EMAIL = 'email@email.com.br'
 Set @TableHead =   
 
 --- CONTRUÇÃO DA TABELA EM HTML QUE SERÁ ENVIADA POR E-MAIL

  '<html>  
  
		<head>' +  
		'<style>' +  
		'td {padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:12pt;} ' +  
		'</style>' +  
		'</head>' +  
		'<body>' +  
		'<table cellpadding=0 cellspacing=0 border=0 width=100%>  
		<tr bgcolor="white">  
		<td width="10%" align=left>  
		<b><img src="" width="256" height="70"/></b>  
		</td>  
		<td width="25"></td>  
		<td width="70%">  

		<font coloR = "#00008B"><h2>Controle Vencimento CNH - Motoristas Próprio''
		</td>  
		</tr>  
		</table>' +  
		'<center>  
		<table cellpadding=0 cellspacing=0 border=1 width=100%>' +  
		'<tr bgcolor=#1E90FF><font coloR = "#000000">' +  
 
		 '<td align=center><b>COD.MOT</b></td>' + 
		 '<td align=center><b>MOTORISTA</b></td>' + 
		 '<td align=center><b>CATEGORIA</b></td>' + 
		 '<td align=center><b>VENCIMENTO</b></td>' +
		 '<td align=center><b>CARENCIA</b></td>' +
		 '<td align=center><b>DIAS VENCIDO</b></td>'+
		 '<td align=center><b>DIAS A VENCER</b></td>'  

 ---- DADOS DE ENVIO -------------------------------------------------------------------------------------------------        
  
   SELECT  
		
		 @Body = isnull((Select Row_Number() Over(ORDER BY SUB.DIAS_VCTO  ASC) % 2 As [TRRow],  
		
		
		'<font size = "2">' + isnull(convert(varchar(10), SUB.CODMOT), '')  + '</font>' As [TD align=center],  
		'<font size = "2">' + isnull(convert(varchar(10), SUB.NOMEAB),'') + '</font>' As [TD align=center],  
		'<font size = "2">' + isnull(convert(varchar(10), SUB.CATEGORIA),'') + '</font>' As [TD align=center],  
		'<font size = "2">' + isnull(convert(varchar(10), SUB.VENCIMENTO ),'') + '</font>' As [TD align=center],
		'<font size = "2">' + isnull(convert(varchar(10), SUB.CARENCIA),'') + '</font>' As [TD align=center],
		'<font size = "2">' + isnull(convert(varchar(10), SUB.DIAS_VCTO),'') + '</font>' As [TD align=center],
		'<font size = "2">' + isnull(convert(varchar(10), SUB.DIAS_VENCER),'') + '</font>' As [TD align=center]



	
FROM	
(
	SELECT RODMOT.CODMOT, 
			RODMOT.NOMEAB,  
			CATECH AS CATEGORIA,
			CONVERT(VARCHAR, RODMOT.VENCHA, 103) AS VENCIMENTO,  
			CONVERT(VARCHAR,  DATEADD(DAY, 30, RODMOT.VENCHA), 103)  AS CARENCIA, 
			CASE WHEN DATEDIFF(DAY, GETDATE(), RODMOT.VENCHA)  >=0 THEN '-' ELSE CONVERT(VARCHAR(10),DATEDIFF(DAY, GETDATE(), RODMOT.VENCHA)) END AS DIAS_VCTO ,
			CASE WHEN DATEDIFF(DAY, GETDATE(), RODMOT.VENCHA)  <0 THEN '-' ELSE CONVERT(VARCHAR(10),DATEDIFF(DAY, GETDATE(), RODMOT.VENCHA)) END AS DIAS_VENCER
		FROM RODMOT
		WHERE SITUAC = 'A'
			AND EMPREG = 'S'
			AND DATEDIFF(DAY, GETDATE(), RODMOT.VENCHA) <=30
			AND RODMOT.TIPMOT = 'M'
		
) AS SUB


For XML raw('tr'), Elements),'')   


  
 set @Body = replace(REPLACE(@Body,'&lt;','<'),'&gt;','>')  
 Set @Body = Replace(@Body, '_x0020_', space(1))      
 Set @Body = Replace(@Body, '_x003D_', '=')      
 Set @Body = Replace(@Body, '<tr><TRRow>1</TRRow>', '<tr bgcolor=#dedede>')      
 Set @Body = Replace(@Body, '<TRRow>0</TRRow>', '')      
 Set @TableTail = '</table><h4>Mensagem enviada automaticamente pelo sistema, <b>não responder.</body></html>';  

  
 Select @Body = @TableHead + @Body + @TableTail  
  
----- TITULO DO EMAIL  ---------------------------------------------------
 set @subj = 'Controle Vencimento CNH - Motoristas Próprio' 

 
  IF isnull(@Body,'') <> ''  
  
  BEGIN     
  
-----  SE NÃO TIVER DADOS O SISTEMA NÃO VAI DISPARAR O E-MAIL -------------
  IF (SELECT COUNT(*)
  				FROM RODMOT
						WHERE SITUAC = 'A'
							AND EMPREG = 'S'
							AND DATEDIFF(DAY, GETDATE(), RODMOT.VENCHA) <=30
							AND RODMOT.TIPMOT = 'M'
		
				)  >=1
----- HAVENDO DADOS SERÁ FEITO UM INSERT DA TABELA RODFEM --------------------
  insert into RODFEM_CUSTOM(EMAIL,CONTEUDO,ASSUNTO,ORIGEM,STATUS,DATINC)  
  SELECT   @email,   @Body,  @subj,   left('JB_SI_SP_CONTROLE_VECTO_CNH',30), 'P', CONVERT(SMALLDATETIME,GETDATE())  



 END
GO


