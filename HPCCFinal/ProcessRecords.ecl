IMPORT HPCCFinal;
IMPORT STD;
RevRecords := HPCCFinal.File_Wiki(Revision = 'REVISION');
RevSortedRecords := SORT(RevRecords, -RevRecords.Date);

ExtractDate(STRING TimeSt) := STD.Str.FilterOut(TimeSt[1..10], '-');

HPCCFinal.Layout_Processed_Wiki processRevRecords(HPCCFinal.Layout_Wiki inputRec) 

	:= TRANSFORM

	SELF.Dt := ExtractDate(inputRec.Date);
	SELF.ArticleId := inputRec.ArticleId;
	SELF.RevId := inputRec.RevId;
	SELF.User := inputRec.User;
	SELF.Extra1 := inputRec.Extra1;
	SELF.Extra2 := inputRec.Extra2;
	
END ;

ProcessedDataset := PROJECT(RevSortedRecords,processRevRecords(LEFT));
SORT(ProcessedDataset, ProcessedDataset.Dt, ProcessedDataset.ArticleId);
//OUTPUT(ProcessedDataset,, 'processed_rev_recs.txt', overwrite);

