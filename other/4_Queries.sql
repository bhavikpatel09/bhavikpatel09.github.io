select * from INFORMATION_SCHEMA.COLUMNS where COLUMN_NAME like '%ehr%'

--Stat
Select EhrUid, * from Stat.dbo.PatientDebtor
Select * from Stat.dbo.PathologyResult
Select * from Stat.dbo.PatientDebtor
Select * from Stat.dbo.ClinicalCache

--StatClinical
Select  C.EhrUid, PD.Id AS PatientId, PD.Contact1Name, 		
		C.ManuscriptUid, C.DocumentType,DC.Id,DC.DocumentType,C.DocumentType,
		C.stat_UserId,  
		MA.Blob,
		C.* from Correspondence C
LEFT JOIN  Manuscript M ON C.ManuscriptUId = M.ManuscriptUid
LEFT JOIN ManuscriptAttachment MA ON MA.ManuscriptAttachmentUid = M.ManuscriptAttachmentUid
LEFT JOIN Stat.dbo.DocumentCategory DC ON DC.Id = C.DocumentCategoryId
LEFT JOIN Stat.dbo.PatientDebtor PD ON PD.EhrUid = C.EhrUid
