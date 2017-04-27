﻿IMPORT HPCCFinal;
IMPORT STD;

RevRecords := HPCCFinal.File_WikiProcessed2;

/* Join on Dates to fetch records for specific dates */
//JoinDateRec := JOIN(AllDates, RevRecords, LEFT.dt = RIGHT.dt);
JoinDateRec := RevRecords;
GrForm := RECORD
	STRING8 Dt := JoinDateRec.Dt;
	STRING8 ArticleId := JoinDateRec.ArticleId;
	DECIMAL10 NoOfUpdate := COUNT(GROUP);
END;
GrTable := TABLE(JoinDateRec, GrForm, Dt, ArticleId);

GrFormSum := RECORD
	STRING8 Dt := GrTable.Dt;
	DECIMAL10 TotalUpdates := SUM(GROUP, GrTable.NoOfUpdate);
END;
GrTable2 := TABLE(GrTable, GrFormSum, Dt);
JoinDateRec2 := JOIN(GrTable2, GrTable, LEFT.dt = RIGHT.dt);
//Output(JoinDateRec2);
OUTPUT(JoinDateRec2,, '~thor::joinedrecs.txt', overwrite);


OutEntropyRec := RECORD
	STRING8 Dt;
	DECIMAL10 TotUpdates;
	DECIMAL10_5 Entropy;
	DECIMAL10_5 NormedEntropy;
END;

OutEntropyRec calculateEntropy(JoinDateRec2 l, OutEntropyRec r) := TRANSFORM 
  SELF.Dt := l.Dt; 
	SELF.TotUpdates:=l.TotalUpdates;
  SELF.Entropy:= r.Entropy + -(l.NoOfUpdate/l.TotalUpdates)*LOG(l.NoOfUpdate/l.TotalUpdates); 
	SELF.NormedEntropy:=0;
END; 

EntropyDS := AGGREGATE(JoinDateRec2, OutEntropyRec, calculateEntropy(LEFT, RIGHT), LEFT.Dt);
EntropyDS;
OutEntropyRec NormalizeEntropy(OutEntropyRec l) := TRANSFORM 
  SELF.Dt := l.Dt; 
	SELF.TotUpdates:=l.TotUpdates;
	SELF.Entropy:= l.Entropy; 
  SELF.NormedEntropy:= l.Entropy/LOG(l.TotUpdates); 
END; 
NormedEntropyDS:=PROJECT(EntropyDS, NormalizeEntropy(LEFT));

OUTPUT(NormedEntropyDS,, '~thor::article_based_entropies.txt', overwrite);
